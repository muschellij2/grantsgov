# List extract endpoint options

List extract endpoint options

## Usage

``` r
grant_extract_options()
```

## Value

A named list of documented extract parameters and values.

## Examples

``` r
grant_extract_options()
#> $filters
#> [1] "extract_type" "created_at"  
#> 
#> $extract_type
#> [1] "opportunities_json" "opportunities_csv" 
#> 
#> $sort_by
#> [1] "created_at"
#> 
#> $sort_direction
#> [1] "ascending"  "descending"
#> 
```
