# Using grantsgov

``` r

if (file.exists("../DESCRIPTION") && dir.exists("../R")) {
  pkgload::load_all(path = "..", quiet = TRUE)
} else {
  library(grantsgov)
}
```

The `grantsgov` package wraps the Simpler Grants.gov API. It helps you
search grant opportunities, retrieve details for a specific opportunity,
and list bulk extract metadata.

Most API requests require an API key. The package reads it from
`GRANTS_GOV_API_KEY`.

``` r

Sys.setenv(GRANTS_GOV_API_KEY = "your-api-key")
```

Live API examples in this vignette run only when both environment
variables are set:

``` r

Sys.setenv(
  GRANTS_GOV_API_KEY = "your-api-key",
  GRANTSGOV_VIGNETTE_LIVE = "true"
)
```

## Discover available endpoints and options

The package documents the API paths, auth header, supported search
filters, sort fields, extract filters, and rate-limit headers checked by
the error handler.

``` r

grant_endpoints()$endpoints
#> $search_opportunities
#> $search_opportunities$method
#> [1] "POST"
#> 
#> $search_opportunities$path
#> [1] "/v1/opportunities/search"
#> 
#> $search_opportunities$function_name
#> [1] "grant_search_opportunities"
#> 
#> 
#> $search_agencies
#> $search_agencies$method
#> [1] "POST"
#> 
#> $search_agencies$path
#> [1] "/v1/agencies/search"
#> 
#> $search_agencies$function_name
#> [1] "grant_search_agencies"
#> 
#> 
#> $get_opportunity
#> $get_opportunity$method
#> [1] "GET"
#> 
#> $get_opportunity$path
#> [1] "/v1/opportunities/{opportunity_id}"
#> 
#> $get_opportunity$function_name
#> [1] "grant_get_opportunity"
#> 
#> 
#> $get_opportunity_legacy
#> $get_opportunity_legacy$method
#> [1] "GET"
#> 
#> $get_opportunity_legacy$path
#> [1] "/v1/opportunities/{legacy_opportunity_id}"
#> 
#> $get_opportunity_legacy$function_name
#> [1] "grant_get_opportunity_legacy"
#> 
#> 
#> $list_extracts
#> $list_extracts$method
#> [1] "POST"
#> 
#> $list_extracts$path
#> [1] "/v1/extracts"
#> 
#> $list_extracts$function_name
#> [1] "grant_list_extracts"
#> 
#> 
#> $common_grants
#> $common_grants$list_opportunities
#> $common_grants$list_opportunities$method
#> [1] "GET"
#> 
#> $common_grants$list_opportunities$path
#> [1] "/common-grants/opportunities"
#> 
#> $common_grants$list_opportunities$function_name
#> [1] "grant_common_grants_list_opportunities"
#> 
#> 
#> $common_grants$search_opportunities
#> $common_grants$search_opportunities$method
#> [1] "POST"
#> 
#> $common_grants$search_opportunities$path
#> [1] "/common-grants/opportunities/search"
#> 
#> $common_grants$search_opportunities$function_name
#> [1] "grant_common_grants_search_opportunities"
#> 
#> 
#> $common_grants$get_opportunity
#> $common_grants$get_opportunity$method
#> [1] "GET"
#> 
#> $common_grants$get_opportunity$path
#> [1] "/common-grants/opportunities/{oppId}"
#> 
#> $common_grants$get_opportunity$function_name
#> [1] "grant_common_grants_get_opportunity"
#> 
#> 
#> 
#> $organizations
#> $organizations$get
#> $organizations$get$method
#> [1] "GET"
#> 
#> $organizations$get$path
#> [1] "/v1/organizations/{organization_id}"
#> 
#> $organizations$get$function_name
#> [1] "grant_get_organization"
#> 
#> 
#> $organizations$create_invitation
#> $organizations$create_invitation$method
#> [1] "POST"
#> 
#> $organizations$create_invitation$path
#> [1] "/v1/organizations/{organization_id}/invitations"
#> 
#> $organizations$create_invitation$function_name
#> [1] "grant_create_organization_invitation"
#> 
#> 
#> $organizations$list_invitations
#> $organizations$list_invitations$method
#> [1] "POST"
#> 
#> $organizations$list_invitations$path
#> [1] "/v1/organizations/{organization_id}/invitations/list"
#> 
#> $organizations$list_invitations$function_name
#> [1] "grant_list_organization_invitations"
#> 
#> 
#> $organizations$list_legacy_users
#> $organizations$list_legacy_users$method
#> [1] "POST"
#> 
#> $organizations$list_legacy_users$path
#> [1] "/v1/organizations/{organization_id}/legacy-users"
#> 
#> $organizations$list_legacy_users$function_name
#> [1] "grant_list_organization_legacy_users"
#> 
#> 
#> $organizations$ignore_legacy_user
#> $organizations$ignore_legacy_user$method
#> [1] "POST"
#> 
#> $organizations$ignore_legacy_user$path
#> [1] "/v1/organizations/{organization_id}/legacy-users/ignore"
#> 
#> $organizations$ignore_legacy_user$function_name
#> [1] "grant_ignore_organization_legacy_user"
#> 
#> 
#> $organizations$list_roles
#> $organizations$list_roles$method
#> [1] "POST"
#> 
#> $organizations$list_roles$path
#> [1] "/v1/organizations/{organization_id}/roles/list"
#> 
#> $organizations$list_roles$function_name
#> [1] "grant_list_organization_roles"
#> 
#> 
#> $organizations$save_opportunity
#> $organizations$save_opportunity$method
#> [1] "POST"
#> 
#> $organizations$save_opportunity$path
#> [1] "/v1/organizations/{organization_id}/saved-opportunities"
#> 
#> $organizations$save_opportunity$function_name
#> [1] "grant_save_organization_opportunity"
#> 
#> 
#> $organizations$delete_saved_opportunity
#> $organizations$delete_saved_opportunity$method
#> [1] "DELETE"
#> 
#> $organizations$delete_saved_opportunity$path
#> [1] "/v1/organizations/{organization_id}/saved-opportunities/{opportunity_id}"
#> 
#> $organizations$delete_saved_opportunity$function_name
#> [1] "grant_delete_organization_saved_opportunity"
#> 
#> 
#> $organizations$list_users
#> $organizations$list_users$method
#> [1] "POST"
#> 
#> $organizations$list_users$path
#> [1] "/v1/organizations/{organization_id}/users"
#> 
#> $organizations$list_users$function_name
#> [1] "grant_list_organization_users"
#> 
#> 
#> $organizations$remove_user
#> $organizations$remove_user$method
#> [1] "DELETE"
#> 
#> $organizations$remove_user$path
#> [1] "/v1/organizations/{organization_id}/users/{user_id}"
#> 
#> $organizations$remove_user$function_name
#> [1] "grant_remove_organization_user"
#> 
#> 
#> $organizations$update_user_roles
#> $organizations$update_user_roles$method
#> [1] "PUT"
#> 
#> $organizations$update_user_roles$path
#> [1] "/v1/organizations/{organization_id}/users/{user_id}"
#> 
#> $organizations$update_user_roles$function_name
#> [1] "grant_update_organization_user_roles"
#> 
#> 
#> 
#> $health
#> $health$method
#> [1] "GET"
#> 
#> $health$path
#> [1] "/health"
#> 
#> $health$function_name
#> [1] "grant_health"
grant_endpoints()$endpoints$health
#> $method
#> [1] "GET"
#> 
#> $path
#> [1] "/health"
#> 
#> $function_name
#> [1] "grant_health"
grant_search_options()$filters
#>  [1] "top_level_agency"                "funding_instrument"             
#>  [3] "funding_category"                "applicant_type"                 
#>  [5] "opportunity_status"              "post_date"                      
#>  [7] "close_date"                      "award_floor"                    
#>  [9] "award_ceiling"                   "expected_number_of_awards"      
#> [11] "estimated_total_program_funding" "assistance_listing_number"      
#> [13] "is_cost_sharing"
grant_search_options()$sort_by
#>  [1] "relevancy"             "opportunity_id"        "opportunity_number"   
#>  [4] "opportunity_title"     "post_date"             "close_date"           
#>  [7] "agency_code"           "agency_name"           "top_level_agency_name"
#> [10] "award_floor"           "award_ceiling"
grant_extract_options()
#> $filters
#> [1] "extract_type" "created_at"  
#> 
#> $extract_type
#> [1] "opportunities_json" "opportunities_csv" 
#> 
#> $sort_by
#> [1] "created_at"
#> 
#> $sort_direction
#> [1] "ascending"  "descending"
grant_rate_limit_headers()
#> [1] "retry-after"           "x-ratelimit-limit"     "x-ratelimit-remaining"
#> [4] "x-ratelimit-reset"     "ratelimit-limit"       "ratelimit-remaining"  
#> [7] "ratelimit-reset"
```

## Common use case: find open education opportunities

A common workflow is to search for open or forecasted opportunities,
filter by deadline and award size, then sort the results by close date.

``` r

education_filters <- list(
  opportunity_status = grant_filter_one_of(c("posted", "forecasted")),
  close_date = grant_filter_date_range(
    start_date = Sys.Date(),
    end_date = Sys.Date() + 90
  ),
  award_ceiling = grant_filter_number_range(min = 50000, max = 2000000)
)

education_pagination <- grant_pagination(
  page_offset = 1,
  page_size = 5000,
  sort_order = grant_sort("close_date", "ascending")
)

str(education_filters)
#> List of 3
#>  $ opportunity_status:List of 1
#>   ..$ one_of:List of 2
#>   .. ..$ : chr "posted"
#>   .. ..$ : chr "forecasted"
#>  $ close_date        :List of 2
#>   ..$ start_date: chr "2026-07-06"
#>   ..$ end_date  : chr "2026-10-04"
#>  $ award_ceiling     :List of 2
#>   ..$ min: num 50000
#>   ..$ max: num 2e+06
education_pagination
#> $page_offset
#> [1] 1
#> 
#> $page_size
#> [1] 5000
#> 
#> $sort_order
#> $sort_order[[1]]
#> $sort_order[[1]]$order_by
#> [1] "close_date"
#> 
#> $sort_order[[1]]$sort_direction
#> [1] "ascending"
```

Run the search with
[`grant_search_opportunities()`](../reference/grant_search_opportunities.md).

``` r

education_results <- grant_search_opportunities(
  query = "education",
  filters = education_filters,
  pagination = education_pagination
)

length(education_results$data)
```

## Common use case: find NIH grants in a subject area

To search for NIH opportunities in a particular area, use a subject
keyword and filter to the Department of Health and Human Services
top-level agency. NIH opportunities are returned under agency names such
as “National Institutes of Health”.

``` r

nih_cancer <- grant_search_opportunities(
  query = "cancer",
  filters = list(
    top_level_agency = grant_filter_one_of(list("HHS")),
    opportunity_status = grant_filter_one_of(c("posted", "forecasted"))
  ),
  pagination = grant_pagination(
    page_size = 25,
    sort_order = grant_sort("close_date", "ascending")
  )
)

length(nih_cancer$data)
```

Older Grants.gov-style parameters map to the current API like this:

``` r

keyword <- "education"
limit <- 25

results <- grant_search_opportunities(
  query = keyword,
  pagination = grant_pagination(
    page_offset = 1, # startRecordNum = 0
    page_size = limit, # rows
    sort_order = grant_sort("close_date", "ascending") # closeDate ASC
  )
)
```

## Retrieve details for one opportunity

Search results include opportunity identifiers. Pass one of those
identifiers to
[`grant_get_opportunity()`](../reference/grant_get_opportunity.md) to
retrieve the full record.

``` r

first_id <- education_results$data[[1]]$opportunity_id
first_opportunity <- grant_get_opportunity(first_id)

names(first_opportunity$data)
```

If you already know an opportunity ID, call the function directly.

``` r

grant_get_opportunity("12345678-1234-1234-1234-123456789012")
```

## Paginate through all search results

After checking a first response, pass it to
[`grant_fetch_all()`](../reference/grant_fetch_all.md) to collect the
remaining pages with the same query, filters, sort order, and page size.

``` r

first_education_page <- grant_search_opportunities(
  query = "education",
  filters = education_filters,
  pagination = grant_pagination(
    page_size = 25,
    sort_order = grant_sort("close_date", "ascending")
  )
)

all_education_results <- grant_fetch_all(first_education_page)

length(all_education_results)
attr(all_education_results, "pagination_info")
```

If you request a different `page_size`,
[`grant_fetch_all()`](../reference/grant_fetch_all.md) refetches from
page 1 because API page numbers depend on page size.

``` r

all_education_results <- grant_fetch_all(first_education_page, page_size = 5000)
```

You can also use [`grant_paginate()`](../reference/grant_paginate.md)
for any endpoint function with a `pagination` argument, or use
[`grant_search_all_opportunities()`](../reference/grant_search_all_opportunities.md)
for search-specific defaults.

``` r

all_education_results <- grant_search_all_opportunities(
  query = "education",
  filters = education_filters,
  page_size = 5000,
  sort_order = grant_sort("close_date", "ascending")
)

length(all_education_results)
attr(all_education_results, "pagination_info")
```

## Common use case: find recently posted opportunities

Use
[`grant_recent_opportunities()`](../reference/grant_recent_opportunities.md)
to collect all opportunities posted in the last day or last week. The
API exposes this as a `post_date` filter.

``` r

last_day <- grant_recent_opportunities("day")
last_week <- grant_recent_opportunities("week")

length(last_day)
length(last_week)
```

## Export search results as CSV text

The search endpoint can return CSV content. This is useful when a
downstream workflow expects a delimited file.

``` r

csv_text <- grant_search_opportunities(
  query = "education",
  filters = education_filters,
  pagination = education_pagination,
  format = "csv"
)

cat(substr(csv_text, 1, 300))
```

## Common use case: find recent bulk extracts

Bulk extracts are useful when you want a complete snapshot rather than a
page of search results.

``` r

extract_filters <- list(
  extract_type = "opportunities_csv",
  created_at = grant_filter_date_range(Sys.Date() - 30, Sys.Date())
)

extract_pagination <- grant_pagination(
  page_offset = 1,
  page_size = 5000,
  sort_order = grant_sort("created_at", "descending")
)

extract_filters
#> $extract_type
#> [1] "opportunities_csv"
#> 
#> $created_at
#> $created_at$start_date
#> [1] "2026-06-06"
#> 
#> $created_at$end_date
#> [1] "2026-07-06"
extract_pagination
#> $page_offset
#> [1] 1
#> 
#> $page_size
#> [1] 5000
#> 
#> $sort_order
#> $sort_order[[1]]
#> $sort_order[[1]]$order_by
#> [1] "created_at"
#> 
#> $sort_order[[1]]$sort_direction
#> [1] "descending"
```

List available extract metadata with
[`grant_list_extracts()`](../reference/grant_list_extracts.md).

``` r

extracts <- grant_list_extracts(
  filters = extract_filters,
  pagination = extract_pagination
)

length(extracts$data)
```

Download one extract by passing the metadata record or a download URL to
[`grant_download_extract()`](../reference/grant_download_extract.md).
The default output path is a temporary `.csv` file. Pass
`expected_file_size = extract$file_size_bytes` to verify the downloaded
byte count against the API metadata.

``` r

extract_file <- grant_download_extract(
  extracts$data[[1]],
  expected_file_size = extracts$data[[1]]$file_size_bytes
)

extract_file
```

Read a CSV extract with
[`grant_read_extract()`](../reference/grant_read_extract.md). It
downloads the file, reads it with
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html),
warns if readr reports parsing problems, and stores the downloaded file
path in `attr(data, "file")`.

``` r

extract_data <- grant_read_extract(
  extracts$data[[1]],
  expected_file_size = extracts$data[[1]]$file_size_bytes
)

attr(extract_data, "file")
```

Use
[`grant_list_all_extracts()`](../reference/grant_list_all_extracts.md)
to automatically request every page of extract metadata.

``` r

all_extracts <- grant_list_all_extracts(
  filters = list(extract_type = "opportunities_csv"),
  page_size = 5000
)

length(all_extracts)
```

## Error handling and rate limits

When the API returns an error, the package reports the HTTP status, a
short status-specific hint, the API’s message body when available, and
any rate-limit headers returned by the gateway. A `429` response
includes retry/backoff guidance and rate-limit metadata such as
`Retry-After`, `X-RateLimit-Remaining`, or `RateLimit-Reset` when
present.

``` r

withr::with_envvar(
  c(GRANTS_GOV_API_KEY = NA),
  grant_api_key()
)
#> Error:
#> ! Set the GRANTS_GOV_API_KEY environment variable before calling the API.
```
