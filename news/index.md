# Changelog

## grantsgov 0.0.0.9000

- Added core Simpler Grants.gov API wrappers for health checks,
  opportunity search, opportunity details, extracts, agency search,
  legacy opportunity ID lookup, CommonGrants opportunity endpoints, and
  organization endpoints.

- Added authentication through the `GRANTS_GOV_API_KEY` environment
  variable and improved HTTP error handling, including API validation
  messages and rate-limit headers.

- Added pagination helpers, including
  [`grant_paginate()`](../reference/grant_paginate.md),
  [`grant_search_all_opportunities()`](../reference/grant_search_all_opportunities.md),
  and
  [`grant_list_all_extracts()`](../reference/grant_list_all_extracts.md),
  with support for `page_size = 5000`.

- Added
  [`grant_recent_opportunities()`](../reference/grant_recent_opportunities.md)
  for retrieving opportunities posted in the last day, last week, or a
  custom number of days.

- Added extract download and read helpers.
  [`grant_download_extract()`](../reference/grant_download_extract.md)
  now defaults to a temporary CSV path and can validate file size, while
  [`grant_read_extract()`](../reference/grant_read_extract.md) reads CSV
  extracts with readr and warns on parse problems.

- Added README, vignette, roxygen examples for exported functions,
  GitHub Actions workflows, Codecov coverage workflow, and unit tests
  with 100% coverage.
