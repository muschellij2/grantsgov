# Get recently posted opportunities

Convenience wrapper for getting all opportunities posted in the last day
or last week. The Simpler Grants.gov opportunity search endpoint exposes
this as the `post_date` filter, so "created" opportunities are
interpreted as opportunities posted within the requested date window.

## Usage

``` r
grant_recent_opportunities(
  period = c("day", "week"),
  days = NULL,
  end_date = Sys.Date(),
  query = NULL,
  query_operator = c("AND", "OR"),
  filters = list(),
  page_size = 5000,
  page_offset = 1,
  sort_order = grant_sort("post_date"),
  max_pages = Inf,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- period:

  Recent window, either `"day"` or `"week"`.

- days:

  Optional custom number of days to look back. If supplied, this
  overrides `period`.

- end_date:

  Last date in the date window. Defaults to today.

- query:

  Optional free-text query.

- query_operator:

  Query operator, `"AND"` or `"OR"`.

- filters:

  Additional search filters. Do not include `post_date`; this function
  sets it from `period`, `days`, and `end_date`.

- page_size:

  Number of records per page.

- page_offset:

  First page offset.

- sort_order:

  Sort specification. Defaults to `post_date` descending.

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
  last_day <- grant_recent_opportunities("day", max_pages = 1)
  last_week <- grant_recent_opportunities("week", max_pages = 1)
  length(last_day)
  length(last_week)
}
```
