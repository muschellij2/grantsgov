# Paginate through all extract metadata

Convenience wrapper around [`grant_paginate()`](grant_paginate.md) for
[`grant_list_extracts()`](grant_list_extracts.md).

## Usage

``` r
grant_list_all_extracts(
  filters = list(),
  page_size = 5000,
  page_offset = 1,
  sort_order = grant_sort("created_at"),
  max_pages = Inf,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- filters:

  Named list of extract filters.

- page_size:

  Number of records per page.

- page_offset:

  First page offset.

- sort_order:

  Sort specification. The extracts endpoint requires a sort order, so
  this defaults to `created_at` descending.

- max_pages:

  Maximum number of pages to request.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

A list of extract metadata records.

## Examples

``` r
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  extracts <- grant_list_all_extracts(
    filters = list(extract_type = "opportunities_csv"),
    page_size = 5000
  )
  length(extracts)
}
```
