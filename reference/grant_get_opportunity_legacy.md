# Retrieve opportunity details by legacy opportunity ID

Maps to `GET /v1/opportunities/{legacy_opportunity_id}`.

## Usage

``` r
grant_get_opportunity_legacy(
  legacy_opportunity_id,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- legacy_opportunity_id:

  Numeric legacy opportunity ID.

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
  legacy_id <- search$data[[1]]$legacy_opportunity_id
  grant_get_opportunity_legacy(legacy_id)
}
```
