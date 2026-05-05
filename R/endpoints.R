# Public endpoint wrappers for the Simpler Grants.gov API.

#' Check API health
#'
#' Maps to `GET /health`. Health endpoints are intended for service status
#' checks and do not require an API key.
#'
#' @param base_url API base URL.
#'
#' @return Parsed JSON as a list, or response text if the API returns a
#'   non-JSON health payload.
#'
#' @examples
#' if (interactive()) {
#'   grant_health()
#' }
#' @export
grant_health <- function(base_url = grant_base_url()) {
  req <- httr2::request(base_url)
  req <- httr2::req_url_path_append(req, "/health")
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_user_agent(req, "grantsgov R package")

  grant_handle_response(grant_perform(req))
}

#' Search grant opportunities
#'
#' Maps to `POST /v1/opportunities/search`.
#'
#' @param query Optional free-text query, up to 100 characters.
#' @param query_operator How multiple query terms are combined: `"AND"` or
#'   `"OR"`.
#' @param filters Named list of filters. Build values with
#'   [grant_filter_one_of()], [grant_filter_date_range()], and
#'   [grant_filter_number_range()]. Documented filter names include
#'   `top_level_agency`, `funding_instrument`, `funding_category`,
#'   `applicant_type`, `opportunity_status`, `post_date`, `close_date`,
#'   `award_floor`, `award_ceiling`, `expected_number_of_awards`,
#'   `estimated_total_program_funding`, `assistance_listing_number`, and
#'   `is_cost_sharing`.
#' @param pagination Pagination list. Defaults to page 1 with 25 rows.
#' @param format Response format, either `"json"` or `"csv"`.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return Parsed JSON as a list, or CSV text when `format = "csv"`.
#'
#' @examples
#' filters <- list(
#'   opportunity_status = grant_filter_one_of(c("posted", "forecasted")),
#'   close_date = grant_filter_date_range(Sys.Date(), Sys.Date() + 90)
#' )
#' pagination <- grant_pagination(
#'   page_size = 5000,
#'   sort_order = grant_sort("close_date", "ascending")
#' )
#'
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   results <- grant_search_opportunities(
#'     query = "education",
#'     filters = filters,
#'     pagination = pagination
#'   )
#'   length(results$data)
#' }
#' @export
grant_search_opportunities <- function(query = NULL,
                                           query_operator = c("AND", "OR"),
                                           filters = list(),
                                           pagination = grant_pagination(),
                                           format = c("json", "csv"),
                                           api_key = grant_api_key(),
                                           base_url = grant_base_url()) {
  query_operator <- match.arg(query_operator)
  format <- match.arg(format)

  if (!is.null(query) && (length(query) != 1 || nchar(query) > 100)) {
    stop("`query` must be NULL or a single string of 100 characters or fewer.", call. = FALSE)
  }

  body <- grant_compact_list(list(
    query = query,
    query_operator = query_operator,
    filters = grant_non_empty_filters(filters),
    pagination = pagination,
    format = format
  ))

  grant_post_json("/v1/opportunities/search", body, api_key, base_url)
}

#' Retrieve opportunity details
#'
#' Maps to `GET /v1/opportunities/{opportunity_id}`.
#'
#' @param opportunity_id Opportunity UUID.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return Parsed JSON as a list.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   search <- grant_search_opportunities(
#'     query = "education",
#'     pagination = grant_pagination(page_size = 1)
#'   )
#'   opportunity_id <- search$data[[1]]$opportunity_id
#'   grant_get_opportunity(opportunity_id)
#' }
#' @export
grant_get_opportunity <- function(opportunity_id,
                                      api_key = grant_api_key(),
                                      base_url = grant_base_url()) {
  if (!is.character(opportunity_id) || length(opportunity_id) != 1 || !nzchar(opportunity_id)) {
    stop("`opportunity_id` must be a non-empty string.", call. = FALSE)
  }

  path <- paste0("/v1/opportunities/", opportunity_id)
  req <- grant_request(path, "GET", api_key, base_url)

  grant_handle_response(grant_perform(req))
}

#' List extract metadata
#'
#' Maps to `POST /v1/extracts`.
#'
#' @param filters Named list of filters. Documented filters are `extract_type`
#'   as a scalar value, such as `"opportunities_json"`, and `created_at` as a
#'   date range from [grant_filter_date_range()].
#' @param pagination Pagination list. Defaults to page 1 with 25 rows.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return Parsed JSON as a list.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   extracts <- grant_list_extracts(
#'     filters = list(extract_type = "opportunities_csv"),
#'     pagination = grant_pagination(
#'       page_size = 5000,
#'       sort_order = grant_sort("created_at")
#'     )
#'   )
#'   length(extracts$data)
#' }
#' @export
grant_list_extracts <- function(filters = list(),
                                    pagination = grant_pagination(
                                      sort_order = grant_sort("created_at")
                                    ),
                                    api_key = grant_api_key(),
                                    base_url = grant_base_url()) {
  body <- grant_compact_list(list(
    filters = grant_non_empty_filters(filters),
    pagination = pagination
  ))

  grant_post_json("/v1/extracts", body, api_key, base_url)
}

#' Download an extract file
#'
#' Download URLs returned by the extracts endpoint may be pre-signed file URLs
#' and may not require API-key authentication.
#'
#' @param extract Metadata list containing a `download_path` or `download_url`,
#'   or a scalar URL.
#' @param path Local output path. Defaults to a temporary `.csv` file.
#' @param overwrite If `FALSE`, error when `path` already exists.
#' @param expected_file_size Optional expected downloaded file size in bytes.
#'   Pass `extract$file_size_bytes` to verify the downloaded file against API
#'   metadata.
#'
#' @return The output path, invisibly.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   extracts <- grant_list_extracts(
#'     filters = list(extract_type = "opportunities_csv"),
#'     pagination = grant_pagination(page_size = 1, sort_order = grant_sort("created_at"))
#'   )
#'   path <- grant_download_extract(
#'     extracts$data[[1]],
#'     expected_file_size = extracts$data[[1]]$file_size_bytes
#'   )
#'   path
#' }
#' @export
grant_download_extract <- function(extract,
                                   path = tempfile(fileext = ".csv"),
                                   overwrite = FALSE,
                                   expected_file_size = NULL) {
  download_url <- grant_extract_download_url(extract)

  if (!is.character(path) || length(path) != 1 || !nzchar(path)) {
    stop("`path` must be a non-empty string.", call. = FALSE)
  }
  if (file.exists(path) && !isTRUE(overwrite)) {
    stop("`path` already exists. Use `overwrite = TRUE` to replace it.", call. = FALSE)
  }

  req <- httr2::request(download_url)
  resp <- grant_perform(req)

  if (httr2::resp_is_error(resp)) {
    stop(grant_response_error_message(resp), call. = FALSE)
  }

  writeBin(httr2::resp_body_raw(resp), path)
  grant_check_file_size(path, expected_file_size)
  invisible(path)
}

#' Download and read a CSV extract
#'
#' Downloads an extract with [grant_download_extract()] and reads it with
#' [readr::read_csv()]. If readr reports parsing problems, this function emits a
#' warning. The downloaded file path is stored in the returned data frame's
#' `file` attribute.
#'
#' @param extract Metadata list containing a `download_path` or `download_url`,
#'   or a scalar URL.
#' @param path Local output path. Defaults to a temporary `.csv` file.
#' @param overwrite If `FALSE`, error when `path` already exists.
#' @param expected_file_size Optional expected downloaded file size in bytes.
#' @param ... Additional arguments passed to [readr::read_csv()].
#'
#' @return A tibble with the downloaded file path in `attr(x, "file")`.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   extracts <- grant_list_extracts(
#'     filters = list(extract_type = "opportunities_csv"),
#'     pagination = grant_pagination(page_size = 1, sort_order = grant_sort("created_at"))
#'   )
#'   data <- grant_read_extract(
#'     extracts$data[[1]],
#'     expected_file_size = extracts$data[[1]]$file_size_bytes
#'   )
#'   attr(data, "file")
#' }
#' @export
grant_read_extract <- function(extract,
                               path = tempfile(fileext = ".csv"),
                               overwrite = FALSE,
                               expected_file_size = NULL,
                               ...) {
  path <- grant_download_extract(
    extract = extract,
    path = path,
    overwrite = overwrite,
    expected_file_size = expected_file_size
  )

  data <- suppressWarnings(
    readr::read_csv(path, show_col_types = FALSE, progress = FALSE, ...)
  )
  problems <- readr::problems(data)

  if (nrow(problems) > 0) {
    warning(
      sprintf("readr reported %s parsing problem(s). See readr::problems() on the returned data.", nrow(problems)),
      call. = FALSE
    )
  }

  attr(data, "file") <- path
  data
}

# POST a JSON body and parse the response.
grant_post_json <- function(path, body, api_key, base_url) {
  req <- grant_request(path, "POST", api_key, base_url)
  req <- httr2::req_body_json(req, body, auto_unbox = TRUE)

  grant_handle_response(grant_perform(req))
}

# Extract a download URL from metadata or accept a URL directly.
grant_extract_download_url <- function(extract) {
  if (is.character(extract) && length(extract) == 1 && nzchar(extract)) {
    return(extract)
  }

  if (is.list(extract) && is.character(extract$download_path) &&
      length(extract$download_path) == 1 && nzchar(extract$download_path)) {
    return(extract$download_path)
  }

  if (is.list(extract) && is.character(extract$download_url) &&
      length(extract$download_url) == 1 && nzchar(extract$download_url)) {
    return(extract$download_url)
  }

  stop("`extract` must be a URL or a metadata list with `download_path` or `download_url`.", call. = FALSE)
}

# Validate a downloaded file size when the caller asks for that check.
grant_check_file_size <- function(path, expected_file_size = NULL) {
  if (is.null(expected_file_size)) {
    return(invisible(TRUE))
  }
  if (!is.numeric(expected_file_size) || length(expected_file_size) != 1 ||
      is.na(expected_file_size) || expected_file_size < 0) {
    stop("`expected_file_size` must be NULL or a single non-negative number of bytes.", call. = FALSE)
  }

  actual_file_size <- file.info(path)$size
  if (!identical(as.numeric(actual_file_size), as.numeric(expected_file_size))) {
    stop(
      sprintf(
        "Downloaded file size mismatch: expected %s bytes, got %s bytes.",
        expected_file_size,
        actual_file_size
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

# The live API rejects empty `filters`, so omit the field unless it has entries.
grant_non_empty_filters <- function(filters) {
  if (is.null(filters) || length(filters) == 0) {
    return(NULL)
  }

  filters
}
