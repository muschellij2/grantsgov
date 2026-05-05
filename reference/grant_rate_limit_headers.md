# List rate-limit response headers checked by the package

Different API gateways use slightly different names for rate-limit
metadata. This helper documents the headers the error handler checks and
includes in error messages when present.

## Usage

``` r
grant_rate_limit_headers()
```

## Value

A character vector of rate-limit header names.

## Examples

``` r
grant_rate_limit_headers()
#> [1] "retry-after"           "x-ratelimit-limit"     "x-ratelimit-remaining"
#> [4] "x-ratelimit-reset"     "ratelimit-limit"       "ratelimit-remaining"  
#> [7] "ratelimit-reset"      
```
