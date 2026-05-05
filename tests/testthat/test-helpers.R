test_that("sort, pagination, and filters build request-body fragments", {
  expect_equal(
    grant_sort("post_date", "ascending"),
    list(order_by = "post_date", sort_direction = "ascending")
  )
  expect_error(grant_sort("post_date", "sideways"), "should be one of")

  expect_equal(
    grant_pagination(2, 10, grant_sort("close_date")),
    list(
      page_offset = 2L,
      page_size = 10L,
      sort_order = list(list(order_by = "close_date", sort_direction = "descending"))
    )
  )
  expect_equal(
    grant_pagination(sort_order = list(list(order_by = "created_at")))$sort_order,
    list(list(order_by = "created_at"))
  )
  expect_equal(grant_pagination(page_size = 5000)$page_size, 5000L)
  expect_error(grant_pagination(0), "page_offset")
  expect_error(grant_pagination(page_size = 5001), "page_size")

  expect_equal(grant_filter_one_of(c("posted", "closed")), list(one_of = c("posted", "closed")))
  expect_error(grant_filter_one_of(character()), "at least one")

  expect_equal(
    grant_filter_date_range(as.Date("2026-01-01"), "2026-12-31"),
    list(start_date = "2026-01-01", end_date = "2026-12-31")
  )
  expect_equal(grant_filter_date_range(end_date = "2026-12-31"), list(end_date = "2026-12-31"))

  expect_equal(grant_filter_number_range(min = 1, max = 5), list(min = 1, max = 5))
  expect_equal(grant_filter_number_range(max = 5), list(max = 5))
  expect_error(grant_filter_number_range(min = "1"), "min")
  expect_error(grant_filter_number_range(max = c(1, 2)), "max")
})

test_that("generic paginator combines pages using API pagination metadata", {
  calls <- list()
  endpoint <- function(pagination) {
    calls[[length(calls) + 1L]] <<- pagination
    list(
      data = list(list(id = pagination$page_offset)),
      pagination_info = list(
        page_offset = pagination$page_offset,
        page_size = pagination$page_size,
        total_pages = 3,
        total_records = 3
      )
    )
  }

  out <- grant_paginate(endpoint, page_size = 2, page_offset = 1)

  expect_equal(vapply(out, `[[`, integer(1), "id"), 1:3)
  expect_equal(length(attr(out, "pages")), 3)
  expect_equal(attr(out, "pagination_info")[[3]]$total_pages, 3)
  expect_equal(vapply(calls, function(x) x$page_offset, integer(1)), 1:3)
})

test_that("generic paginator supports function names and max_pages", {
  page_count <- 0L
  local_endpoint <- function(pagination) {
    page_count <<- page_count + 1L
    list(
      data = as.list(seq_len(pagination$page_size)),
      pagination_info = list(
        page_offset = pagination$page_offset,
        page_size = pagination$page_size,
        total_pages = 10
      )
    )
  }

  out <- grant_paginate("local_endpoint", page_size = 2, max_pages = 2)

  expect_equal(length(out), 4)
  expect_equal(page_count, 2L)
})

test_that("generic paginator stops on short pages and validates inputs", {
  endpoint <- function(pagination) {
    list(data = list(list(id = 1)))
  }

  expect_equal(length(grant_paginate(endpoint, page_size = 2)), 1)
  expect_error(grant_paginate(1), "function")
  expect_error(grant_paginate(endpoint, max_pages = 0), "max_pages")
  expect_error(grant_paginate(endpoint, data_field = ""), "data_field")
})
