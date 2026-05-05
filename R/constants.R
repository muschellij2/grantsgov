# Constants and option lists shared by the endpoint wrappers.

#' Simpler Grants.gov API base URL
#'
#' @return A scalar character URL.
#'
#' @examples
#' grant_base_url()
#' @export
grant_base_url <- function() {
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
#'
#' @examples
#' grant_api_key(required = FALSE)
#' @export
grant_api_key <- function(required = TRUE) {
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
#'
#' @examples
#' endpoints <- grant_endpoints()
#' names(endpoints$endpoints)
#' endpoints$endpoints$health
#' @export
grant_endpoints <- function() {
  list(
    base_url = grant_base_url(),
    authentication = list(
      header = "X-API-Key",
      environment_variable = "GRANTS_GOV_API_KEY"
    ),
    endpoints = list(
      search_opportunities = list(
        method = "POST",
        path = "/v1/opportunities/search",
        function_name = "grant_search_opportunities"
      ),
      search_agencies = list(
        method = "POST",
        path = "/v1/agencies/search",
        function_name = "grant_search_agencies"
      ),
      get_opportunity = list(
        method = "GET",
        path = "/v1/opportunities/{opportunity_id}",
        function_name = "grant_get_opportunity"
      ),
      get_opportunity_legacy = list(
        method = "GET",
        path = "/v1/opportunities/{legacy_opportunity_id}",
        function_name = "grant_get_opportunity_legacy"
      ),
      list_extracts = list(
        method = "POST",
        path = "/v1/extracts",
        function_name = "grant_list_extracts"
      ),
      common_grants = list(
        list_opportunities = list(
          method = "GET",
          path = "/common-grants/opportunities",
          function_name = "grant_common_grants_list_opportunities"
        ),
        search_opportunities = list(
          method = "POST",
          path = "/common-grants/opportunities/search",
          function_name = "grant_common_grants_search_opportunities"
        ),
        get_opportunity = list(
          method = "GET",
          path = "/common-grants/opportunities/{oppId}",
          function_name = "grant_common_grants_get_opportunity"
        )
      ),
      organizations = list(
        get = list(method = "GET", path = "/v1/organizations/{organization_id}", function_name = "grant_get_organization"),
        create_invitation = list(method = "POST", path = "/v1/organizations/{organization_id}/invitations", function_name = "grant_create_organization_invitation"),
        list_invitations = list(method = "POST", path = "/v1/organizations/{organization_id}/invitations/list", function_name = "grant_list_organization_invitations"),
        list_legacy_users = list(method = "POST", path = "/v1/organizations/{organization_id}/legacy-users", function_name = "grant_list_organization_legacy_users"),
        ignore_legacy_user = list(method = "POST", path = "/v1/organizations/{organization_id}/legacy-users/ignore", function_name = "grant_ignore_organization_legacy_user"),
        list_roles = list(method = "POST", path = "/v1/organizations/{organization_id}/roles/list", function_name = "grant_list_organization_roles"),
        save_opportunity = list(method = "POST", path = "/v1/organizations/{organization_id}/saved-opportunities", function_name = "grant_save_organization_opportunity"),
        delete_saved_opportunity = list(method = "DELETE", path = "/v1/organizations/{organization_id}/saved-opportunities/{opportunity_id}", function_name = "grant_delete_organization_saved_opportunity"),
        list_users = list(method = "POST", path = "/v1/organizations/{organization_id}/users", function_name = "grant_list_organization_users"),
        remove_user = list(method = "DELETE", path = "/v1/organizations/{organization_id}/users/{user_id}", function_name = "grant_remove_organization_user"),
        update_user_roles = list(method = "PUT", path = "/v1/organizations/{organization_id}/users/{user_id}", function_name = "grant_update_organization_user_roles")
      ),
      health = list(
        method = "GET",
        path = "/health",
        function_name = "grant_health"
      )
    ),
    search = grant_search_options(),
    extracts = grant_extract_options(),
    rate_limit_headers = grant_rate_limit_headers()
  )
}

#' List opportunity search options
#'
#' @return A named list of documented search parameters and values.
#'
#' @examples
#' opts <- grant_search_options()
#' opts$filters
#' opts$sort_by
#' @export
grant_search_options <- function() {
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
#'
#' @examples
#' grant_extract_options()
#' @export
grant_extract_options <- function() {
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
#'
#' @examples
#' grant_rate_limit_headers()
#' @export
grant_rate_limit_headers <- function() {
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
