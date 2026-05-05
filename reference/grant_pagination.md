# Build a pagination specification

Build a pagination specification

## Usage

``` r
grant_pagination(page_offset = 1, page_size = 25, sort_order = NULL)
```

## Arguments

- page_offset:

  One-based page index. The public API examples start at 1.

- page_size:

  Number of records per page. The live API accepts values up to 5000 for
  paginated endpoints.

- sort_order:

  Optional sort specification. Use [`grant_sort()`](grant_sort.md) or a
  list of sort specifications.

## Value

A list suitable for request-body `pagination`.

## Examples

``` r
grant_pagination()
#> $page_offset
#> [1] 1
#> 
#> $page_size
#> [1] 25
#> 
grant_pagination(
  page_offset = 2,
  page_size = 5000,
  sort_order = grant_sort("created_at")
)
#> $page_offset
#> [1] 2
#> 
#> $page_size
#> [1] 5000
#> 
#> $sort_order
#> $sort_order[[1]]
#> $sort_order[[1]]$order_by
#> [1] "created_at"
#> 
#> $sort_order[[1]]$sort_direction
#> [1] "descending"
#> 
#> 
#> 
```
