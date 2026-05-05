# Paginate through an endpoint

Generic paginator for endpoint wrappers that accept a `pagination`
argument and return a `data` element plus optional `pagination_info`
metadata. This applies to
[`grant_search_opportunities()`](grant_search_opportunities.md) and
[`grant_list_extracts()`](grant_list_extracts.md).

## Usage

``` r
grant_paginate(
  .f,
  ...,
  page_size = 5000,
  page_offset = 1,
  sort_order = NULL,
  max_pages = Inf,
  data_field = "data"
)
```

## Arguments

- .f:

  Endpoint function, or a string naming one.

- ...:

  Arguments passed to `.f`.

- page_size:

  Number of records per page.

- page_offset:

  First page offset.

- sort_order:

  Optional sort specification passed to
  [`grant_pagination()`](grant_pagination.md).

- max_pages:

  Maximum number of pages to request. Use `Inf` to continue until API
  pagination metadata or a short page indicates completion.

- data_field:

  Response field containing page records.

## Value

A list of records with `pages` and `pagination_info` attributes.

## Examples

``` r
mock_endpoint <- function(pagination) {
  list(
    data = list(list(page = pagination$page_offset)),
    pagination_info = list(
      page_offset = pagination$page_offset,
      page_size = pagination$page_size,
      total_pages = 2
    )
  )
}
grant_paginate(mock_endpoint, page_size = 2)
#> [[1]]
#> [[1]]$page
#> [1] 1
#> 
#> 
#> [[2]]
#> [[2]]$page
#> [1] 2
#> 
#> 
#> attr(,"pages")
#> attr(,"pages")[[1]]
#> attr(,"pages")[[1]]$data
#> attr(,"pages")[[1]]$data[[1]]
#> attr(,"pages")[[1]]$data[[1]]$page
#> [1] 1
#> 
#> 
#> 
#> attr(,"pages")[[1]]$pagination_info
#> attr(,"pages")[[1]]$pagination_info$page_offset
#> [1] 1
#> 
#> attr(,"pages")[[1]]$pagination_info$page_size
#> [1] 2
#> 
#> attr(,"pages")[[1]]$pagination_info$total_pages
#> [1] 2
#> 
#> 
#> 
#> attr(,"pages")[[2]]
#> attr(,"pages")[[2]]$data
#> attr(,"pages")[[2]]$data[[1]]
#> attr(,"pages")[[2]]$data[[1]]$page
#> [1] 2
#> 
#> 
#> 
#> attr(,"pages")[[2]]$pagination_info
#> attr(,"pages")[[2]]$pagination_info$page_offset
#> [1] 2
#> 
#> attr(,"pages")[[2]]$pagination_info$page_size
#> [1] 2
#> 
#> attr(,"pages")[[2]]$pagination_info$total_pages
#> [1] 2
#> 
#> 
#> 
#> attr(,"pagination_info")
#> attr(,"pagination_info")[[1]]
#> attr(,"pagination_info")[[1]]$page_offset
#> [1] 1
#> 
#> attr(,"pagination_info")[[1]]$page_size
#> [1] 2
#> 
#> attr(,"pagination_info")[[1]]$total_pages
#> [1] 2
#> 
#> 
#> attr(,"pagination_info")[[2]]
#> attr(,"pagination_info")[[2]]$page_offset
#> [1] 2
#> 
#> attr(,"pagination_info")[[2]]$page_size
#> [1] 2
#> 
#> attr(,"pagination_info")[[2]]$total_pages
#> [1] 2
#> 
#> 

if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  grant_paginate(
    grant_list_extracts,
    page_size = 5000,
    sort_order = grant_sort("created_at"),
    max_pages = 1
  )
}
```
