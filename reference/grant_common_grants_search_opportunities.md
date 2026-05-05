# Search CommonGrants opportunities

Maps to `POST /common-grants/opportunities/search`.

## Usage

``` r
grant_common_grants_search_opportunities(
  search = NULL,
  filters = list(),
  pagination = list(page = 1, pageSize = 25),
  sorting = NULL,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- search:

  Optional search query string.

- filters:

  CommonGrants opportunity filters.

- pagination:

  CommonGrants pagination parameters.

- sorting:

  CommonGrants sorting parameters.

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
  grant_common_grants_search_opportunities(
    search = "education",
    pagination = list(page = 1, pageSize = 10)
  )
}
```
