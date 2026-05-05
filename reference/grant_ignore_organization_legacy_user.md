# Ignore a legacy user for an organization

Maps to `POST /v1/organizations/{organization_id}/legacy-users/ignore`.

## Usage

``` r
grant_ignore_organization_legacy_user(
  organization_id,
  email,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

- email:

  Legacy user email address.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list.

## Examples

``` r
if (FALSE) { # \dontrun{
grant_ignore_organization_legacy_user("organization-uuid", "legacy@example.com")
} # }
```
