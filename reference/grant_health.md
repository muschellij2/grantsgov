# Check API health

Maps to `GET /health`. Health endpoints are intended for service status
checks and do not require an API key.

## Usage

``` r
grant_health(base_url = grant_base_url())
```

## Arguments

- base_url:

  API base URL.

## Value

Parsed JSON as a list, or response text if the API returns a non-JSON
health payload.

## Examples

``` r
if (interactive()) {
  grant_health()
}
```
