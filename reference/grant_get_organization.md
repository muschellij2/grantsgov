# Get organization information

Maps to `GET /v1/organizations/{organization_id}`.

## Usage

``` r
grant_get_organization(
  organization_id,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list.

## Examples

``` r
if (FALSE) { # \dontrun{
grant_get_organization("organization-uuid")
} # }
```
