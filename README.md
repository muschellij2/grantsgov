# grantsgov

<!-- badges: start -->
[![R-CMD-check](https://github.com/muschellij2/grantsgov/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/muschellij2/grantsgov/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/muschellij2/grantsgov/graph/badge.svg)](https://app.codecov.io/gh/muschellij2/grantsgov)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
<!-- badges: end -->

`grantsgov` is an R client for the Simpler Grants.gov API at
<https://api.simpler.grants.gov/docs#/>. It uses `httr2` for requests and maps
the documented core endpoints:

- `POST /v1/opportunities/search`
- `GET /v1/opportunities/{opportunity_id}`
- `POST /v1/extracts`

Set your API key in the `GRANTS_GOV_API_KEY` environment variable:

```r
Sys.setenv(GRANTS_GOV_API_KEY = "your-api-key")
```

## Installation

```r
# install.packages("pak")
pak::pak("muschellij2/grantsgov")
```

## Search opportunities

```r
library(grantsgov)

results <- grantsgov_search_opportunities(
  query = "education",
  filters = list(
    opportunity_status = grantsgov_filter_one_of(c("posted", "forecasted")),
    applicant_type = grantsgov_filter_one_of("nonprofits")
  ),
  pagination = grantsgov_pagination(
    page_offset = 1,
    page_size = 10,
    sort_order = grantsgov_sort("close_date", "ascending")
  )
)
```

To request CSV content instead of JSON:

```r
csv_text <- grantsgov_search_opportunities(
  filters = list(opportunity_status = grantsgov_filter_one_of("posted")),
  pagination = grantsgov_pagination(page_size = 100),
  format = "csv"
)
```

## Get opportunity details

```r
opportunity <- grantsgov_get_opportunity(
  "12345678-1234-1234-1234-123456789012"
)
```

## List and download extracts

```r
extracts <- grantsgov_list_extracts(
  filters = list(
    extract_type = "opportunities_json",
    created_at = grantsgov_filter_date_range("2026-01-01", "2026-12-31")
  ),
  pagination = grantsgov_pagination(
    page_size = 10,
    sort_order = grantsgov_sort("created_at")
  )
)

grantsgov_download_extract(extracts$data[[1]], "opportunities.json")
```

## Endpoint metadata

Use these helpers to inspect supported endpoints, filter names, sort fields, and
rate-limit headers checked by the client:

```r
grantsgov_endpoints()
grantsgov_search_options()
grantsgov_extract_options()
grantsgov_rate_limit_headers()
```

## Errors and rate limits

HTTP errors include the status code, API-provided error message when available,
and any returned rate-limit headers such as `Retry-After`,
`X-RateLimit-Remaining`, or `RateLimit-Reset`. A `429` response is reported with
retry/backoff guidance.
