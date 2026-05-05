# Save an opportunity for an organization

Maps to `POST /v1/organizations/{organization_id}/saved-opportunities`.

## Usage

``` r
grant_save_organization_opportunity(
  organization_id,
  opportunity_id,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

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
if (FALSE) { # \dontrun{
grant_save_organization_opportunity("organization-uuid", "opportunity-uuid")
} # }
```
