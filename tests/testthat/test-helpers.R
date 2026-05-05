test_that("sort, pagination, and filters build request-body fragments", {
  expect_equal(
    grantsgov_sort("post_date", "ascending"),
    list(order_by = "post_date", sort_direction = "ascending")
  )
  expect_error(grantsgov_sort("post_date", "sideways"), "should be one of")

  expect_equal(
    grantsgov_pagination(2, 10, grantsgov_sort("close_date")),
    list(
      page_offset = 2L,
      page_size = 10L,
      sort_order = list(list(order_by = "close_date", sort_direction = "descending"))
    )
  )
  expect_equal(
    grantsgov_pagination(sort_order = list(list(order_by = "created_at")))$sort_order,
    list(list(order_by = "created_at"))
  )
  expect_error(grantsgov_pagination(0), "page_offset")
  expect_error(grantsgov_pagination(page_size = 101), "page_size")

  expect_equal(grantsgov_filter_one_of(c("posted", "closed")), list(one_of = c("posted", "closed")))
  expect_error(grantsgov_filter_one_of(character()), "at least one")

  expect_equal(
    grantsgov_filter_date_range(as.Date("2026-01-01"), "2026-12-31"),
    list(start_date = "2026-01-01", end_date = "2026-12-31")
  )
  expect_equal(grantsgov_filter_date_range(end_date = "2026-12-31"), list(end_date = "2026-12-31"))

  expect_equal(grantsgov_filter_number_range(min = 1, max = 5), list(min = 1, max = 5))
  expect_equal(grantsgov_filter_number_range(max = 5), list(max = 5))
  expect_error(grantsgov_filter_number_range(min = "1"), "min")
  expect_error(grantsgov_filter_number_range(max = c(1, 2)), "max")
})
