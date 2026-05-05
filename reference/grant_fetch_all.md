# Fetch all records from a first-page response

Takes the output from a paginated endpoint call, such as
[`grant_search_opportunities()`](grant_search_opportunities.md), and
requests the remaining pages using the same query, filters, and sort
options. This is a convenience wrapper for the common workflow where you
inspect the first page and then decide to collect all matching records.

## Usage

``` r
grant_fetch_all(
  x,
  page_size = NULL,
  max_pages = Inf,
  api_key = grant_api_key(),
  base_url = NULL,
  data_field = NULL
)
```

## Arguments

- x:

  A response object returned by a paginated grantsgov endpoint.

- page_size:

  Optional page size for the full collection. If `NULL`, the function
  continues from `x` using the original page size. If different from the
  original page size, the first page is requested again to avoid
  skipping records.

- max_pages:

  Maximum total number of pages to include.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  Optional API base URL override. Defaults to the URL used by the
  original response.

- data_field:

  Response field containing page records. Defaults to the field recorded
  by the original endpoint, usually `"data"`.

## Value

A list of records with `pages` and `pagination_info` attributes.

## Examples

``` r
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  first_page <- grant_search_opportunities(
    query = "cancer",
    filters = list(
      top_level_agency = grant_filter_one_of("HHS"),
      opportunity_status = grant_filter_one_of(c("posted", "forecasted"))
    ),
    pagination = grant_pagination(
      page_size = 25,
      sort_order = grant_sort("close_date", "ascending")
    )
  )
  all_records <- grant_fetch_all(first_page)
  length(all_records)
}
```
