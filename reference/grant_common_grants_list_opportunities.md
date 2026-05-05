# List CommonGrants opportunities

Maps to `GET /common-grants/opportunities`.

## Usage

``` r
grant_common_grants_list_opportunities(
  page = 1,
  page_size = 25,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- page:

  Page number.

- page_size:

  Number of records per page.

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
  grant_common_grants_list_opportunities(page = 1, page_size = 10)
}
```
