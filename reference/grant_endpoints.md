# List endpoints and documented option values

List endpoints and documented option values

## Usage

``` r
grant_endpoints()
```

## Value

A named list with endpoint paths, authentication details, supported
filters, sort fields, formats, and rate-limit header names.

## Examples

``` r
endpoints <- grant_endpoints()
names(endpoints$endpoints)
#> [1] "search_opportunities"   "search_agencies"        "get_opportunity"       
#> [4] "get_opportunity_legacy" "list_extracts"          "common_grants"         
#> [7] "organizations"          "health"                
endpoints$endpoints$health
#> $method
#> [1] "GET"
#> 
#> $path
#> [1] "/health"
#> 
#> $function_name
#> [1] "grant_health"
#> 
```
