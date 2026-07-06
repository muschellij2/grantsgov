# Build a date range filter

Build a date range filter

## Usage

``` r
grant_filter_date_range(start_date = NULL, end_date = NULL)
```

## Arguments

- start_date, end_date:

  Optional date bounds in `YYYY-MM-DD` format, or objects coercible with
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html).

## Value

A list containing non-missing date bounds.

## Examples

``` r
grant_filter_date_range("2026-01-01", "2026-12-31")
#> $start_date
#> [1] "2026-01-01"
#> 
#> $end_date
#> [1] "2026-12-31"
#> 
grant_filter_date_range(end_date = Sys.Date() + 30)
#> $end_date
#> [1] "2026-08-05"
#> 
```
