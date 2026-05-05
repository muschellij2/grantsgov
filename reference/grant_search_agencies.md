# Search agencies

Maps to `POST /v1/agencies/search`.

## Usage

``` r
grant_search_agencies(
  query = NULL,
  query_operator = c("AND", "OR"),
  filters = list(),
  pagination = grant_pagination(sort_order = grant_sort("agency_name", "ascending")),
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

  Named list of agency filters. Documented filters include
  `has_active_opportunity`, `is_test_agency`, and
  `opportunity_statuses`.

- pagination:

  Pagination list. Sort fields are `agency_code` and `agency_name`.

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
  agencies <- grant_search_agencies(
    query = "health",
    pagination = grant_pagination(
      page_size = 25,
      sort_order = grant_sort("agency_name", "ascending")
    )
  )
  length(agencies$data)
}
```
