# Create an organization invitation

Maps to `POST /v1/organizations/{organization_id}/invitations`.

## Usage

``` r
grant_create_organization_invitation(
  organization_id,
  invitee_email,
  role_ids,
  api_key = grant_api_key(),
  base_url = grant_base_url()
)
```

## Arguments

- organization_id:

  Organization UUID.

- invitee_email:

  Email address to invite.

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
grant_create_organization_invitation(
  "organization-uuid",
  invitee_email = "new.member@example.com",
  role_ids = c("role-uuid")
)
} # }
```
