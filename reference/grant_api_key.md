# Read the Grants.gov API key from the environment

The package looks for the API key in the `GRANTS_GOV_API_KEY`
environment variable. Most endpoint functions call this helper
automatically.

## Usage

``` r
grant_api_key(required = TRUE)
```

## Arguments

- required:

  If `TRUE`, error when `GRANTS_GOV_API_KEY` is unset.

## Value

A scalar character API key, or `NULL` when `required = FALSE` and no key
is configured.

## Examples

``` r
grant_api_key(required = FALSE)
#> NULL
```
