
# grantsgov

<!-- badges: start -->

[![R-CMD-check](https://github.com/muschellij2/grantsgov/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/muschellij2/grantsgov/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/muschellij2/grantsgov/graph/badge.svg)](https://app.codecov.io/gh/muschellij2/grantsgov)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

`grantsgov` is an R client for the Simpler Grants.gov API at
<https://api.simpler.grants.gov/docs#/>. It uses `httr2` for requests
and maps the documented core endpoints:

- `POST /v1/opportunities/search`
- `GET /v1/opportunities/{opportunity_id}`
- `POST /v1/extracts`

Set your API key in the `GRANTS_GOV_API_KEY` environment variable:

``` r
Sys.setenv(GRANTS_GOV_API_KEY = "your-api-key")
```

## Installation

``` r
# install.packages("pak")
pak::pak("muschellij2/grantsgov")
```

## Load the package

``` r
if (file.exists("DESCRIPTION") && dir.exists("R")) {
  pkgload::load_all(quiet = TRUE)
} else {
  library(grantsgov)
}
#> Warning: package 'testthat' was built under R version 4.4.1
```

## Inspect endpoint metadata

These examples run without an API key because they only inspect local
package metadata.

``` r
grant_base_url()
#> [1] "https://api.simpler.grants.gov"
names(grant_endpoints()$endpoints)
#> [1] "search_opportunities" "get_opportunity"      "list_extracts"       
#> [4] "health"
grant_endpoints()$endpoints$health
#> $method
#> [1] "GET"
#> 
#> $path
#> [1] "/health"
#> 
#> $function_name
#> [1] "grant_health"
grant_search_options()$sort_by
#>  [1] "relevancy"             "opportunity_id"        "opportunity_number"   
#>  [4] "opportunity_title"     "post_date"             "close_date"           
#>  [7] "agency_code"           "agency_name"           "top_level_agency_name"
#> [10] "award_floor"           "award_ceiling"
grant_extract_options()$extract_type
#> [1] "opportunities_json" "opportunities_csv"
grant_rate_limit_headers()
#> [1] "retry-after"           "x-ratelimit-limit"     "x-ratelimit-remaining"
#> [4] "x-ratelimit-reset"     "ratelimit-limit"       "ratelimit-remaining"  
#> [7] "ratelimit-reset"
```

## Build request components

The helper constructors create the nested request-body structures used
by the API.

``` r
filters <- list(
  opportunity_status = grant_filter_one_of(c("posted", "forecasted")),
  applicant_type = grant_filter_one_of("nonprofits"),
  close_date = grant_filter_date_range(
    start_date = Sys.Date(),
    end_date = Sys.Date() + 30
  ),
  award_ceiling = grant_filter_number_range(max = 1000000)
)

pagination <- grant_pagination(
  page_offset = 1,
  page_size = 5000,
  sort_order = grant_sort("close_date", "ascending")
)

str(filters)
#> List of 4
#>  $ opportunity_status:List of 1
#>   ..$ one_of: chr [1:2] "posted" "forecasted"
#>  $ applicant_type    :List of 1
#>   ..$ one_of: chr "nonprofits"
#>  $ close_date        :List of 2
#>   ..$ start_date: chr "2026-05-05"
#>   ..$ end_date  : chr "2026-06-04"
#>  $ award_ceiling     :List of 1
#>   ..$ max: num 1e+06
pagination
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

## Search opportunities

This chunk runs when `GRANTS_GOV_API_KEY` is set and
`GRANTSGOV_README_LIVE=true`.

``` r
results <- grant_search_opportunities(
  query = "education",
  filters = filters,
  pagination = pagination
)

length(results$data)
```

To request CSV content instead of JSON:

``` r
csv_text <- grant_search_opportunities(
  filters = list(opportunity_status = grant_filter_one_of("posted")),
  pagination = grant_pagination(page_size = 100),
  format = "csv"
)

substr(csv_text, 1, 200)
```

To collect more than one page, use `grant_paginate()` or the
endpoint-specific wrapper `grant_search_all_opportunities()`.

``` r
all_results <- grant_search_all_opportunities(
  query = "education",
  filters = filters,
  page_size = 5000,
  sort_order = grant_sort("close_date", "ascending")
)

length(all_results)
attr(all_results, "pagination_info")
```

## Get opportunity details

This example needs a real opportunity UUID from the API.

``` r
opportunity <- grant_get_opportunity(
  "12345678-1234-1234-1234-123456789012"
)
```

## List, download, and read extracts

The metadata request runs when `GRANTS_GOV_API_KEY` is set and
`GRANTSGOV_README_LIVE=true`. Use the CSV extract type when you want to
read the downloaded data into R.

``` r
extracts <- grant_list_extracts(
  filters = list(
    extract_type = "opportunities_csv",
    created_at = grant_filter_date_range(Sys.Date() - 30, Sys.Date())
  ),
  pagination = grant_pagination(
    page_size = 5000,
    sort_order = grant_sort("created_at")
  )
)

length(extracts$data)
```

`grant_download_extract()` defaults to a temporary `.csv` file. Pass
`expected_file_size = extract$file_size_bytes` to verify the downloaded
byte count against the API metadata.

``` r
extract_file <- grant_download_extract(
  extracts$data[[1]],
  expected_file_size = extracts$data[[1]]$file_size_bytes
)

extract_file
```

`grant_read_extract()` downloads a CSV extract, reads it with
`readr::read_csv()`, warns if readr reports parsing problems, and stores
the downloaded file path in `attr(data, "file")`.

``` r
extract_data <- grant_read_extract(
  extracts$data[[1]],
  expected_file_size = extracts$data[[1]]$file_size_bytes
)

attr(extract_data, "file")
```

Use `grant_list_all_extracts()` to automatically request each page of
extract metadata.

``` r
all_extracts <- grant_list_all_extracts(
  filters = list(extract_type = "opportunities_csv"),
  page_size = 5000
)

length(all_extracts)
```

## Errors and rate limits

HTTP errors include the status code, API-provided error message when
available, and any returned rate-limit headers such as `Retry-After`,
`X-RateLimit-Remaining`, or `RateLimit-Reset`. A `429` response is
reported with retry/backoff guidance.
