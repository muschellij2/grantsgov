# Shared httr2 request and response handling.

# Build an authenticated API request for endpoint wrappers.
grant_request <- function(path, method, api_key, base_url = grant_base_url()) {
  req <- httr2::request(base_url)
  req <- httr2::req_url_path_append(req, path)
  req <- httr2::req_method(req, method)
  req <- httr2::req_headers(req, "X-API-Key" = api_key)
  req <- httr2::req_user_agent(req, "grantsgov R package")
  req
}

# Small wrapper kept separate so tests can stub network behavior cleanly.
grant_perform <- function(req) {
  req <- httr2::req_error(req, is_error = function(resp) FALSE)
  httr2::req_perform(req)
}

# Decode a successful response according to its content type.
grant_parse_response <- function(resp) {
  content_type <- httr2::resp_content_type(resp)

  if (identical(content_type, "application/json")) {
    return(httr2::resp_body_json(resp, simplifyVector = FALSE))
  }

  if (grepl("text/csv", content_type %||% "", fixed = TRUE)) {
    return(httr2::resp_body_string(resp))
  }

  httr2::resp_body_string(resp)
}

# Stop on HTTP errors and include API message plus rate-limit metadata.
grant_handle_response <- function(resp) {
  if (!httr2::resp_is_error(resp)) {
    return(grant_parse_response(resp))
  }

  stop(grant_response_error_message(resp), call. = FALSE)
}

# Compose a readable error message from status, body, and selected headers.
grant_response_error_message <- function(resp) {
  status <- httr2::resp_status(resp)
  status_desc <- httr2::resp_status_desc(resp)
  body_message <- grant_error_body_message(resp)
  rate_limit_message <- grant_rate_limit_message(resp)

  paste(
    grant_compact_character(c(
      sprintf("Grants.gov API request failed [%s %s].", status, status_desc),
      grant_status_guidance(status),
      body_message,
      rate_limit_message
    )),
    collapse = " "
  )
}

# Extract a compact message from JSON or text error bodies.
grant_error_body_message <- function(resp) {
  if (!httr2::resp_has_body(resp)) {
    return(NULL)
  }

  body <- httr2::resp_body_string(resp)
  if (!nzchar(body)) {
    return(NULL)
  }

  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) NULL
  )

  if (is.list(parsed)) {
    if (is.list(parsed$errors) && length(parsed$errors) > 0) {
      errors <- vapply(parsed$errors, grant_format_api_error, character(1))
      return(paste0("API errors: ", paste(errors, collapse = "; "), "."))
    }

    for (field in c("message", "detail", "error")) {
      if (!is.null(parsed[[field]]) && length(parsed[[field]]) == 1) {
        return(paste0("API message: ", parsed[[field]], "."))
      }
    }
  }

  paste0("Response body: ", body)
}

# Format one validation error from the API's errors array.
grant_format_api_error <- function(error) {
  if (!is.list(error)) {
    return(as.character(error))
  }

  field <- error$field %||% "unknown field"
  message <- error$message %||% "Invalid value."
  paste0(field, ": ", message)
}

# Add status-specific context for common API failures.
grant_status_guidance <- function(status) {
  switch(
    as.character(status),
    "400" = "Check request parameters and required pagination fields.",
    "401" = "Check that GRANTS_GOV_API_KEY is set and valid.",
    "403" = "The API key does not have permission for this request.",
    "404" = "The requested resource was not found.",
    "429" = "Rate limit exceeded; retry after the indicated delay or use backoff.",
    "500" = "The API reported an internal server error.",
    NULL
  )
}

# Include rate-limit headers when the gateway returns them.
grant_rate_limit_message <- function(resp) {
  values <- vapply(
    grant_rate_limit_headers(),
    function(header) httr2::resp_header(resp, header, default = NA_character_),
    character(1)
  )
  values <- values[!is.na(values)]

  if (length(values) == 0) {
    return(NULL)
  }

  paste0(
    "Rate limit headers: ",
    paste(sprintf("%s=%s", names(values), values), collapse = ", "),
    "."
  )
}

# Compact character vectors without dropping meaningful empty response bodies.
grant_compact_character <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}

# Minimal infix helper to avoid depending on rlang.
`%||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}
