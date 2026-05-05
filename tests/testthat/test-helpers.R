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

test_that("recent opportunities builds a post_date window for day and week", {
  calls <- list()
  testthat::local_mocked_bindings(
    grant_search_all_opportunities = function(query, query_operator, filters, page_size,
                                              page_offset, sort_order, max_pages,
                                              api_key, base_url) {
      calls[[length(calls) + 1L]] <<- list(
        query = query,
        query_operator = query_operator,
        filters = filters,
        page_size = page_size,
        page_offset = page_offset,
        sort_order = sort_order,
        max_pages = max_pages,
        api_key = api_key,
        base_url = base_url
      )
      list(list(id = "one"))
    },
    .package = "grantsgov"
  )

  day <- grant_recent_opportunities(
    "day",
    end_date = as.Date("2026-05-05"),
    query = "education",
    filters = list(opportunity_status = grant_filter_one_of("posted")),
    api_key = "key",
    base_url = "https://example.test",
    max_pages = 1
  )
  week <- grant_recent_opportunities(
    "week",
    end_date = as.Date("2026-05-05"),
    api_key = "key",
    base_url = "https://example.test",
    max_pages = 1
  )

  expect_equal(length(day), 1)
  expect_equal(calls[[1]]$query, "education")
  expect_equal(calls[[1]]$filters$post_date, list(start_date = "2026-05-04", end_date = "2026-05-05"))
  expect_equal(calls[[1]]$filters$opportunity_status$one_of, "posted")
  expect_equal(calls[[1]]$sort_order$order_by, "post_date")
  expect_equal(calls[[1]]$max_pages, 1)
  expect_equal(calls[[2]]$filters$post_date, list(start_date = "2026-04-28", end_date = "2026-05-05"))
  expect_equal(length(week), 1)
})

test_that("recent opportunities supports custom days and validates inputs", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_search_all_opportunities = function(query, query_operator, filters, page_size,
                                              page_offset, sort_order, max_pages,
                                              api_key, base_url) {
      captured <<- filters
      list()
    },
    .package = "grantsgov"
  )

  grant_recent_opportunities(
    days = 3,
    end_date = as.Date("2026-05-05"),
    api_key = "key",
    base_url = "https://example.test"
  )

  expect_equal(captured$post_date, list(start_date = "2026-05-02", end_date = "2026-05-05"))
  expect_error(
    grant_recent_opportunities(filters = list(post_date = list()), api_key = "key"),
    "post_date"
  )
  expect_error(grant_recent_opportunities(days = 0, api_key = "key"), "days")
})
