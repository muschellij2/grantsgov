# Update roles for an organization user

Maps to `PUT /v1/organizations/{organization_id}/users/{user_id}`.

## Usage

``` r
grant_update_organization_user_roles(
  organization_id,
  user_id,
  role_ids,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

- user_id:

  User UUID.

- role_ids:

  Character vector of role IDs.

- api_key:

  API key. Defaults to `GRANTS_GOV_API_KEY`.

- base_url:

  API base URL.

## Value

Parsed JSON as a list.

## Examples

``` r
if (FALSE) { # \dontrun{
grant_update_organization_user_roles(
  "organization-uuid",
  "user-uuid",
  role_ids = c("role-uuid")
)
} # }
```
