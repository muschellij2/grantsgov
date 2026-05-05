# Build a `one_of` filter

Build a `one_of` filter

## Usage

``` r
grant_filter_one_of(values)
```

## Arguments

- values:

  Values accepted by the API for the selected filter.

## Value

A list with a `one_of` member.

## Examples

``` r
grant_filter_one_of(c("posted", "forecasted"))
#> $one_of
#> $one_of[[1]]
#> [1] "posted"
#> 
#> $one_of[[2]]
#> [1] "forecasted"
#> 
#> 
```
