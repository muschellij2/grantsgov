# Search grant opportunities

Maps to `POST /v1/opportunities/search`.

## Usage

``` r
grant_search_opportunities(
  query = NULL,
  query_operator = c("AND", "OR"),
  filters = list(),
  pagination = grant_pagination(),
  format = c("json", "csv"),
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- query:

  Optional free-text query, up to 100 characters.

- query_operator:

  How multiple query terms are combined: `"AND"` or `"OR"`.

- filters:

  Named list of filters. Build values with
  [`grant_filter_one_of()`](grant_filter_one_of.md),
  [`grant_filter_date_range()`](grant_filter_date_range.md), and
  [`grant_filter_number_range()`](grant_filter_number_range.md).
  Documented filter names include `top_level_agency`,
  `funding_instrument`, `funding_category`, `applicant_type`,
  `opportunity_status`, `post_date`, `close_date`, `award_floor`,
  `award_ceiling`, `expected_number_of_awards`,
  `estimated_total_program_funding`, `assistance_listing_number`, and
  `is_cost_sharing`.

- pagination:

  Pagination list. Defaults to page 1 with 25 rows.

- format:

  Response format, either `"json"` or `"csv"`.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list, or CSV text when `format = "csv"`.

## Examples

``` r
filters <- list(
  opportunity_status = grant_filter_one_of(c("posted", "forecasted")),
  close_date = grant_filter_date_range(Sys.Date(), Sys.Date() + 90)
)
pagination <- grant_pagination(
  page_size = 5000,
  sort_order = grant_sort("close_date", "ascending")
)

if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  results <- grant_search_opportunities(
    query = "education",
    filters = filters,
    pagination = pagination
  )
  length(results$data)
}

# Translation of older Grants.gov-style parameters:
# params = {
#   "keyword": keyword,
#   "sortBy": "closeDate",
#   "sortOrder": "ASC",
#   "rows": limit,
#   "startRecordNum": 0
# }
if (FALSE) { # \dontrun{
keyword <- "education"
limit <- 25
old_style_search <- grant_search_opportunities(
  query = keyword,
  pagination = grant_pagination(
    page_offset = 1, # startRecordNum = 0 means the first page
    page_size = limit, # rows
    sort_order = grant_sort("close_date", "ascending") # closeDate ASC
  )
)
} # }

# NIH grants in a subject area, such as cancer.
nih_filters <- list(
  top_level_agency = grant_filter_one_of(list("HHS")),
  opportunity_status = grant_filter_one_of(c("posted", "forecasted"))
)
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  nih_cancer <- grant_search_opportunities(
    query = "cancer",
    filters = nih_filters,
    pagination = grant_pagination(
      page_size = 25,
      sort_order = grant_sort("close_date", "ascending")
    )
  )
  length(nih_cancer$data)
}
```
