# Remove a user from an organization

Maps to `DELETE /v1/organizations/{organization_id}/users/{user_id}`.

## Usage

``` r
grant_remove_organization_user(
  organization_id,
  user_id,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

- user_id:

  User UUID.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list.

## Examples

``` r
if (FALSE) { # \dontrun{
grant_remove_organization_user("organization-uuid", "user-uuid")
} # }
```
