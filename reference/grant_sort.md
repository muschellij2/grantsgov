# Build a sort specification

Build a sort specification

## Usage

``` r
grant_sort(order_by, sort_direction = "descending")
```

## Arguments

- order_by:

  Field to sort by. See
  [`grant_search_options()`](grant_search_options.md) or
  [`grant_extract_options()`](grant_extract_options.md) for
  endpoint-specific values.

- sort_direction:

  Sort direction, either `"ascending"` or `"descending"`.

## Value

A list suitable for the API `sort_order` array.

## Examples

``` r
grant_sort("created_at")
#> $order_by
#> [1] "created_at"
#> 
#> $sort_direction
#> [1] "descending"
#> 
grant_sort("close_date", "ascending")
#> $order_by
#> [1] "close_date"
#> 
#> $sort_direction
#> [1] "ascending"
#> 
```
