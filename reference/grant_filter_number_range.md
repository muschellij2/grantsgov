# Build a numeric range filter

Build a numeric range filter

## Usage

``` r
grant_filter_number_range(min = NULL, max = NULL)
```

## Arguments

- min, max:

  Optional numeric lower and upper bounds.

## Value

A list containing non-missing numeric bounds.

## Examples

``` r
grant_filter_number_range(min = 10000, max = 1000000)
#> $min
#> [1] 10000
#> 
#> $max
#> [1] 1e+06
#> 
grant_filter_number_range(max = 500000)
#> $max
#> [1] 5e+05
#> 
```
