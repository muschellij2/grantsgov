# Paginate through opportunity search results

Convenience wrapper around [`grant_paginate()`](grant_paginate.md) for
[`grant_search_opportunities()`](grant_search_opportunities.md).

## Usage

``` r
grant_search_all_opportunities(
  query = NULL,
  query_operator = c("AND", "OR"),
  filters = list(),
  page_size = 5000,
  page_offset = 1,
  sort_order = NULL,
  max_pages = Inf,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- query:

  Optional free-text query.

- query_operator:

  Query operator, `"AND"` or `"OR"`.

- filters:

  Named list of search filters.

- page_size:

  Number of records per page.

- page_offset:

  First page offset.

- sort_order:

  Optional sort specification.

- max_pages:

  Maximum number of pages to request.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

A list of opportunity search records.

## Examples

``` r
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  opportunities <- grant_search_all_opportunities(
    query = "education",
    filters = list(opportunity_status = grant_filter_one_of("posted")),
    page_size = 5000,
    max_pages = 1
  )
  length(opportunities)
}
```
