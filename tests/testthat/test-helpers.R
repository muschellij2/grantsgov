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

  expect_equal(grant_filter_one_of(c("posted", "closed")), list(one_of = list("posted", "closed")))
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

test_that("search hits can be flattened to a data frame", {
  hits <- list(
    list(
      opportunity_id = "opp-1",
      legacy_opportunity_id = 123L,
      opportunity_number = "PAR-00-001",
      opportunity_title = "Example opportunity",
      opportunity_status = "posted",
      agency = "HHS-NIH11",
      agency_code = "HHS-NIH11",
      agency_name = "National Institutes of Health",
      top_level_agency_code = "HHS",
      top_level_agency_name = "Department of Health and Human Services",
      category = "discretionary",
      category_explanation = NULL,
      opportunity_assistance_listings = list(
        list(number = "93.000", title = "Example listing")
      ),
      summary = list(
        post_date = "2026-01-01",
        close_date = "2026-02-01",
        archive_date = "2026-03-01",
        created_at = "2026-01-01T12:00:00+00:00",
        updated_at = "2026-01-02T12:00:00+00:00",
        additional_info_url = "https://example.test",
        agency_email_address = "info@example.test",
        award_floor = 1000,
        award_ceiling = 2000,
        estimated_total_program_funding = 3000,
        expected_number_of_awards = 4,
        is_cost_sharing = FALSE,
        is_forecast = FALSE,
        applicant_types = list("state_governments"),
        funding_categories = list("health"),
        funding_instruments = list("grant"),
        summary_description = "Longer summary",
        applicant_eligibility_description = "Eligibility text",
        agency_contact_description = "Contact text"
      )
    )
  )

  out <- grant_search_hits_to_df(hits)

  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 1)
  expect_equal(out$opportunity_id, "opp-1")
  expect_equal(out$post_date, as.Date("2026-01-01"))
  expect_equal(out$agency_name, "National Institutes of Health")
  expect_equal(out$funding_instruments, "grant")
  expect_equal(out$assistance_listing_numbers, "93.000")
  expect_equal(out$summary_description, "Longer summary")
})

test_that("search hit flattening validates and handles empty input", {
  expect_error(grant_search_hits_to_df("not-a-list"), "search-hit records")
  expect_equal(nrow(grant_search_hits_to_df(list())), 0)
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

  expect_equal(vapply(out, `[[`, numeric(1), "id"), 1:3)
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

test_that("fetch all continues from a first paginated response", {
  calls <- list()
  first_page <- list(
    data = list(list(id = 1)),
    pagination_info = list(page_offset = 1L, page_size = 1L, total_pages = 3L)
  )
  attr(first_page, "grant_pagination_call") <- list(
    function_name = "grant_search_opportunities",
    args = list(
      query = "cancer",
      query_operator = "AND",
      filters = list(opportunity_status = grant_filter_one_of("posted")),
      format = "json"
    ),
    pagination = grant_pagination(1, 1, grant_sort("close_date", "ascending")),
    base_url = "https://example.test",
    data_field = "data"
  )

  testthat::local_mocked_bindings(
    grant_search_opportunities = function(query, query_operator, filters, pagination,
                                          format, api_key, base_url) {
      calls[[length(calls) + 1L]] <<- list(
        query = query,
        query_operator = query_operator,
        filters = filters,
        pagination = pagination,
        format = format,
        api_key = api_key,
        base_url = base_url
      )
      list(
        data = list(list(id = pagination$page_offset)),
        pagination_info = list(
          page_offset = pagination$page_offset,
          page_size = pagination$page_size,
          total_pages = 3L
        )
      )
    },
    .package = "grantsgov"
  )

  out <- grant_fetch_all(first_page, api_key = "key")

  expect_equal(vapply(out, `[[`, numeric(1), "id"), 1:3)
  expect_equal(length(calls), 2)
  expect_equal(calls[[1]]$pagination$page_offset, 2L)
  expect_equal(calls[[1]]$pagination$page_size, 1L)
  expect_equal(calls[[1]]$pagination$sort_order[[1]]$order_by, "close_date")
  expect_equal(calls[[1]]$query, "cancer")
  expect_equal(calls[[1]]$filters$opportunity_status$one_of, list("posted"))
  expect_equal(calls[[1]]$api_key, "key")
  expect_equal(calls[[1]]$base_url, "https://example.test")
  expect_equal(length(attr(out, "pages")), 3)
})

test_that("fetch all can refetch with a new page size and validates metadata", {
  calls <- list()
  first_page <- list(
    data = as.list(1:25),
    pagination_info = list(page_offset = 1L, page_size = 25L, total_pages = 2L)
  )
  attr(first_page, "grant_pagination_call") <- list(
    function_name = "grant_list_extracts",
    args = list(filters = list(extract_type = "opportunities_csv")),
    pagination = grant_pagination(1, 25, grant_sort("created_at")),
    base_url = "https://example.test",
    data_field = "data"
  )

  testthat::local_mocked_bindings(
    grant_list_extracts = function(filters, pagination, api_key, base_url) {
      calls[[length(calls) + 1L]] <<- pagination
      list(
        data = as.list(seq_len(40)),
        pagination_info = list(
          page_offset = pagination$page_offset,
          page_size = pagination$page_size,
          total_pages = 1L
        )
      )
    },
    .package = "grantsgov"
  )

  out <- grant_fetch_all(first_page, page_size = 5000, api_key = "key")

  expect_equal(length(out), 40)
  expect_equal(length(calls), 1)
  expect_equal(calls[[1]]$page_offset, 1L)
  expect_equal(calls[[1]]$page_size, 5000L)
  expect_error(grant_fetch_all(list(data = list()), api_key = "key"), "pagination metadata")
  expect_error(grant_fetch_all(first_page, page_size = 5001, api_key = "key"), "page_size")
  expect_error(grant_fetch_all(first_page, data_field = "", api_key = "key"), "data_field")
})

test_that("fetch all handles validation and early-stop cases", {
  complete_page <- list(
    data = list(list(id = 1)),
    pagination_info = list(page_offset = 1L, page_size = 1L, total_pages = 1L)
  )
  attr(complete_page, "grant_pagination_call") <- list(
    function_name = "grant_search_opportunities",
    args = list(query = "done", query_operator = "AND", filters = list(), format = "json"),
    pagination = grant_pagination(1, 1),
    base_url = "https://example.test",
    data_field = "data"
  )
  limited_page <- complete_page
  limited_page$pagination_info$total_pages <- 2L

  short_page <- list(data = list(list(id = 1)))
  attr(short_page, "grant_pagination_call") <- list(
    function_name = "grant_search_opportunities",
    args = list(query = "short", query_operator = "AND", filters = list(), format = "json"),
    pagination = grant_pagination(1, 2),
    base_url = "https://example.test",
    data_field = "data"
  )

  missing_size <- list(data = list())
  attr(missing_size, "grant_pagination_call") <- list(
    function_name = "grant_search_opportunities",
    args = list(query = "missing", query_operator = "AND", filters = list(), format = "json"),
    pagination = list(page_offset = 1L),
    base_url = "https://example.test",
    data_field = "data"
  )

  expect_error(grant_fetch_all("not-a-response", api_key = "key"), "response object")
  expect_error(grant_fetch_all(complete_page, max_pages = 0, api_key = "key"), "max_pages")
  expect_error(grant_fetch_all(missing_size, api_key = "key"), "page size")
  expect_equal(length(grant_fetch_all(complete_page, api_key = "key")), 1)
  expect_equal(length(grant_fetch_all(short_page, api_key = "key")), 1)
  expect_equal(length(grant_fetch_all(limited_page, max_pages = 1, api_key = "key")), 1)
})

test_that("fetch all stops on a short fetched page without pagination metadata", {
  calls <- 0L
  first_page <- list(data = as.list(1:2))
  attr(first_page, "grant_pagination_call") <- list(
    function_name = "grant_search_opportunities",
    args = list(query = "short", query_operator = "AND", filters = list(), format = "json"),
    pagination = grant_pagination(1, 2),
    base_url = "https://example.test",
    data_field = "data"
  )

  testthat::local_mocked_bindings(
    grant_search_opportunities = function(query, query_operator, filters, pagination,
                                          format, api_key, base_url) {
      calls <<- calls + 1L
      list(data = list(list(id = 3)))
    },
    .package = "grantsgov"
  )

  out <- grant_fetch_all(first_page, api_key = "key")

  expect_equal(length(out), 3)
  expect_equal(calls, 1L)
})

test_that("endpoint function lookup can resolve namespace functions", {
  expect_true(is.function(grantsgov:::grant_match_endpoint_function("grant_recent_days")))
  expect_error(grantsgov:::grant_match_endpoint_function("not_a_real_function"), "not_a_real_function")
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
  expect_equal(calls[[1]]$filters$opportunity_status$one_of, list("posted"))
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
