# Retrieve CommonGrants opportunity details

Maps to `GET /common-grants/opportunities/{oppId}`.

## Usage

``` r
grant_common_grants_get_opportunity(
  opportunity_id,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- opportunity_id:

  CommonGrants opportunity ID.

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
  opportunities <- grant_common_grants_list_opportunities(page = 1, page_size = 1)
  grant_common_grants_get_opportunity(opportunities$items[[1]]$id)
}
```
