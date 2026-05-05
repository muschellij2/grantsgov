# List organization users

Maps to `POST /v1/organizations/{organization_id}/users`.

## Usage

``` r
grant_list_organization_users(
  organization_id,
  pagination = grant_pagination(),
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

- pagination:

  Pagination list.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list.

## Examples

``` r
if (FALSE) { # \dontrun{
grant_list_organization_users("organization-uuid")
} # }
```
