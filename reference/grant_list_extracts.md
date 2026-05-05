# List extract metadata

Maps to `POST /v1/extracts`.

## Usage

``` r
grant_list_extracts(
  filters = list(),
  pagination = grant_pagination(sort_order = grant_sort("created_at")),
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- filters:

  Named list of filters. Documented filters are `extract_type` as a
  scalar value, such as `"opportunities_json"`, and `created_at` as a
  date range from
  [`grant_filter_date_range()`](grant_filter_date_range.md).

- pagination:

  Pagination list. Defaults to page 1 with 25 rows.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list.

## Examples

``` r
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  extracts <- grant_list_extracts(
    filters = list(extract_type = "opportunities_csv"),
    pagination = grant_pagination(
      page_size = 5000,
      sort_order = grant_sort("created_at")
    )
  )
  length(extracts$data)
}
```
