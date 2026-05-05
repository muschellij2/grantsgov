# Retrieve opportunity details

Maps to `GET /v1/opportunities/{opportunity_id}`.

## Usage

``` r
grant_get_opportunity(
  opportunity_id,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- opportunity_id:

  Opportunity UUID.

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
  search <- grant_search_opportunities(
    query = "education",
    pagination = grant_pagination(page_size = 1)
  )
  opportunity_id <- search$data[[1]]$opportunity_id
  grant_get_opportunity(opportunity_id)
}
```
