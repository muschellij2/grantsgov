# Public endpoint wrappers for the Simpler Grants.gov API.

#' Search grant opportunities
#'
#' Maps to `POST /v1/opportunities/search`.
#'
#' @param query Optional free-text query, up to 100 characters.
#' @param query_operator How multiple query terms are combined: `"AND"` or
#'   `"OR"`.
#' @param filters Named list of filters. Build values with
#'   [grantsgov_filter_one_of()], [grantsgov_filter_date_range()], and
#'   [grantsgov_filter_number_range()]. Documented filter names include
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
#' @export
grantsgov_search_opportunities <- function(query = NULL,
                                           query_operator = c("AND", "OR"),
                                           filters = list(),
                                           pagination = grantsgov_pagination(),
                                           format = c("json", "csv"),
                                           api_key = grantsgov_api_key(),
                                           base_url = grantsgov_base_url()) {
  query_operator <- match.arg(query_operator)
  format <- match.arg(format)

  if (!is.null(query) && (length(query) != 1 || nchar(query) > 100)) {
    stop("`query` must be NULL or a single string of 100 characters or fewer.", call. = FALSE)
  }

  body <- grantsgov_compact_list(list(
    query = query,
    query_operator = query_operator,
    filters = filters,
    pagination = pagination,
    format = format
  ))

  grantsgov_post_json("/v1/opportunities/search", body, api_key, base_url)
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
#' @export
grantsgov_get_opportunity <- function(opportunity_id,
                                      api_key = grantsgov_api_key(),
                                      base_url = grantsgov_base_url()) {
  if (!is.character(opportunity_id) || length(opportunity_id) != 1 || !nzchar(opportunity_id)) {
    stop("`opportunity_id` must be a non-empty string.", call. = FALSE)
  }

  path <- paste0("/v1/opportunities/", opportunity_id)
  req <- grantsgov_request(path, "GET", api_key, base_url)

  grantsgov_handle_response(grantsgov_perform(req))
}

#' List extract metadata
#'
#' Maps to `POST /v1/extracts`.
#'
#' @param filters Named list of filters. Documented filters are `extract_type`
#'   and `created_at`.
#' @param pagination Pagination list. Defaults to page 1 with 25 rows.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return Parsed JSON as a list.
#' @export
grantsgov_list_extracts <- function(filters = list(),
                                    pagination = grantsgov_pagination(
                                      sort_order = grantsgov_sort("created_at")
                                    ),
                                    api_key = grantsgov_api_key(),
                                    base_url = grantsgov_base_url()) {
  body <- grantsgov_compact_list(list(
    filters = filters,
    pagination = pagination
  ))

  grantsgov_post_json("/v1/extracts", body, api_key, base_url)
}

#' Download an extract file
#'
#' Download URLs returned by the extracts endpoint may be pre-signed file URLs
#' and may not require API-key authentication.
#'
#' @param extract Metadata list containing a `download_url`, or a scalar URL.
#' @param path Local output path.
#' @param overwrite If `FALSE`, error when `path` already exists.
#'
#' @return The output path, invisibly.
#' @export
grantsgov_download_extract <- function(extract, path, overwrite = FALSE) {
  download_url <- grantsgov_extract_download_url(extract)

  if (!is.character(path) || length(path) != 1 || !nzchar(path)) {
    stop("`path` must be a non-empty string.", call. = FALSE)
  }
  if (file.exists(path) && !isTRUE(overwrite)) {
    stop("`path` already exists. Use `overwrite = TRUE` to replace it.", call. = FALSE)
  }

  req <- httr2::request(download_url)
  resp <- grantsgov_perform(req)

  if (httr2::resp_is_error(resp)) {
    stop(grantsgov_response_error_message(resp), call. = FALSE)
  }

  writeBin(httr2::resp_body_raw(resp), path)
  invisible(path)
}

# POST a JSON body and parse the response.
grantsgov_post_json <- function(path, body, api_key, base_url) {
  req <- grantsgov_request(path, "POST", api_key, base_url)
  req <- httr2::req_body_json(req, body, auto_unbox = TRUE)

  grantsgov_handle_response(grantsgov_perform(req))
}

# Extract a download URL from metadata or accept a URL directly.
grantsgov_extract_download_url <- function(extract) {
  if (is.character(extract) && length(extract) == 1 && nzchar(extract)) {
    return(extract)
  }

  if (is.list(extract) && is.character(extract$download_url) &&
      length(extract$download_url) == 1 && nzchar(extract$download_url)) {
    return(extract$download_url)
  }

  stop("`extract` must be a URL or a metadata list with `download_url`.", call. = FALSE)
}
