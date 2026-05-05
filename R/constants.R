# Constants and option lists shared by the endpoint wrappers.

#' Simpler Grants.gov API base URL
#'
#' @return A scalar character URL.
#' @export
grantsgov_base_url <- function() {
  "https://api.simpler.grants.gov"
}

#' Read the Grants.gov API key from the environment
#'
#' The package looks for the API key in the `GRANTS_GOV_API_KEY` environment
#' variable. Most endpoint functions call this helper automatically.
#'
#' @param required If `TRUE`, error when `GRANTS_GOV_API_KEY` is unset.
#'
#' @return A scalar character API key, or `NULL` when `required = FALSE` and no
#'   key is configured.
#' @export
grantsgov_api_key <- function(required = TRUE) {
  key <- Sys.getenv("GRANTS_GOV_API_KEY", unset = "")

  if (!nzchar(key)) {
    if (isTRUE(required)) {
      stop(
        "Set the GRANTS_GOV_API_KEY environment variable before calling the API.",
        call. = FALSE
      )
    }
    return(NULL)
  }

  key
}

#' List endpoints and documented option values
#'
#' @return A named list with endpoint paths, authentication details, supported
#'   filters, sort fields, formats, and rate-limit header names.
#' @export
grantsgov_endpoints <- function() {
  list(
    base_url = grantsgov_base_url(),
    authentication = list(
      header = "X-API-Key",
      environment_variable = "GRANTS_GOV_API_KEY"
    ),
    endpoints = list(
      search_opportunities = list(
        method = "POST",
        path = "/v1/opportunities/search",
        function_name = "grantsgov_search_opportunities"
      ),
      get_opportunity = list(
        method = "GET",
        path = "/v1/opportunities/{opportunity_id}",
        function_name = "grantsgov_get_opportunity"
      ),
      list_extracts = list(
        method = "POST",
        path = "/v1/extracts",
        function_name = "grantsgov_list_extracts"
      )
    ),
    search = grantsgov_search_options(),
    extracts = grantsgov_extract_options(),
    rate_limit_headers = grantsgov_rate_limit_headers()
  )
}

#' List opportunity search options
#'
#' @return A named list of documented search parameters and values.
#' @export
grantsgov_search_options <- function() {
  list(
    query_operator = c("AND", "OR"),
    format = c("json", "csv"),
    filters = c(
      "top_level_agency",
      "funding_instrument",
      "funding_category",
      "applicant_type",
      "opportunity_status",
      "post_date",
      "close_date",
      "award_floor",
      "award_ceiling",
      "expected_number_of_awards",
      "estimated_total_program_funding",
      "assistance_listing_number",
      "is_cost_sharing"
    ),
    opportunity_status = c("forecasted", "posted", "closed", "archived"),
    sort_by = c(
      "relevancy",
      "opportunity_id",
      "opportunity_number",
      "opportunity_title",
      "post_date",
      "close_date",
      "agency_code",
      "agency_name",
      "top_level_agency_name",
      "award_floor",
      "award_ceiling"
    ),
    sort_direction = c("ascending", "descending")
  )
}

#' List extract endpoint options
#'
#' @return A named list of documented extract parameters and values.
#' @export
grantsgov_extract_options <- function() {
  list(
    filters = c("extract_type", "created_at"),
    extract_type = c("opportunities_json", "opportunities_csv"),
    sort_by = "created_at",
    sort_direction = c("ascending", "descending")
  )
}

#' List rate-limit response headers checked by the package
#'
#' Different API gateways use slightly different names for rate-limit metadata.
#' This helper documents the headers the error handler checks and includes in
#' error messages when present.
#'
#' @return A character vector of rate-limit header names.
#' @export
grantsgov_rate_limit_headers <- function() {
  c(
    "retry-after",
    "x-ratelimit-limit",
    "x-ratelimit-remaining",
    "x-ratelimit-reset",
    "ratelimit-limit",
    "ratelimit-remaining",
    "ratelimit-reset"
  )
}
