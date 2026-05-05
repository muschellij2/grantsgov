test_that("health checks the health endpoint without an API key", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      captured <<- req
      json_resp(body = '{"status":"ok"}')
    },
    .package = "grantsgov"
  )

  out <- grant_health(base_url = "https://example.test")

  expect_equal(out$status, "ok")
  expect_equal(captured$method, "GET")
  expect_match(captured$url, "/health", fixed = TRUE)
  expect_null(captured$headers[["X-API-Key"]])
})

test_that("search opportunities posts the expected body and parses JSON", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      captured <<- req
      json_resp(body = '{"message":"Success","data":[{"opportunity_id":"one"}]}')
    },
    .package = "grantsgov"
  )

  out <- grant_search_opportunities(
    query = "research",
    filters = list(opportunity_status = grant_filter_one_of("posted")),
    pagination = grant_pagination(page_size = 5),
    api_key = "key",
    base_url = "https://example.test"
  )

  expect_equal(out$data[[1]]$opportunity_id, "one")
  expect_equal(captured$method, "POST")
  expect_match(captured$url, "/v1/opportunities/search", fixed = TRUE)
  expect_equal(captured$headers[["X-API-Key"]], "key")
  expect_equal(captured$body$data$query, "research")
  expect_equal(captured$body$data$pagination$page_size, 5L)
})

test_that("search opportunities omits empty filters for the live API", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      captured <<- req
      json_resp(body = '{"message":"Success","data":[]}')
    },
    .package = "grantsgov"
  )

  grant_search_opportunities(api_key = "key", base_url = "https://example.test")

  expect_null(captured$body$data$filters)
})

test_that("search validates query and can return CSV", {
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      httr2::response(
        headers = list("content-type" = "text/csv"),
        body = charToRaw("opportunity_id\none\n")
      )
    },
    .package = "grantsgov"
  )

  expect_error(
    grant_search_opportunities(query = paste(rep("a", 101), collapse = ""), api_key = "key"),
    "100 characters"
  )
  expect_equal(
    grant_search_opportunities(format = "csv", api_key = "key"),
    "opportunity_id\none\n"
  )
})

test_that("get opportunity adds the ID to the request path and parses JSON", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      captured <<- req
      json_resp(body = '{"data":{"opportunity_id":"abc def"}}')
    },
    .package = "grantsgov"
  )

  out <- grant_get_opportunity("abc def", api_key = "key", base_url = "https://example.test")

  expect_equal(out$data$opportunity_id, "abc def")
  expect_equal(captured$method, "GET")
  expect_equal(httr2::url_parse(captured$url)$path, "/v1/opportunities/abc def")
  expect_error(grant_get_opportunity("", api_key = "key"), "opportunity_id")
})

test_that("list extracts posts filters and parses JSON", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      captured <<- req
      json_resp(body = '{"data":[{"extract_type":"opportunities_json"}]}')
    },
    .package = "grantsgov"
  )

  out <- grant_list_extracts(
    filters = list(extract_type = "opportunities_json"),
    api_key = "key",
    base_url = "https://example.test"
  )

  expect_equal(out$data[[1]]$extract_type, "opportunities_json")
  expect_equal(captured$method, "POST")
  expect_match(captured$url, "/v1/extracts", fixed = TRUE)
  expect_equal(captured$body$data$filters$extract_type, "opportunities_json")
})

test_that("list extracts omits empty filters for the live API", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      captured <<- req
      json_resp(body = '{"data":[]}')
    },
    .package = "grantsgov"
  )

  grant_list_extracts(api_key = "key", base_url = "https://example.test")

  expect_null(captured$body$data$filters)
  expect_equal(captured$body$data$pagination$sort_order[[1]]$order_by, "created_at")
})

test_that("list all extracts paginates with extract defaults", {
  calls <- list()
  testthat::local_mocked_bindings(
    grant_list_extracts = function(filters, pagination, api_key, base_url) {
      calls[[length(calls) + 1L]] <<- list(
        filters = filters,
        pagination = pagination,
        api_key = api_key,
        base_url = base_url
      )
      list(
        data = list(list(id = pagination$page_offset)),
        pagination_info = list(
          page_offset = pagination$page_offset,
          page_size = pagination$page_size,
          total_pages = 2
        )
      )
    },
    .package = "grantsgov"
  )

  out <- grant_list_all_extracts(
    filters = list(extract_type = "opportunities_csv"),
    page_size = 5000,
    api_key = "key",
    base_url = "https://example.test"
  )

  expect_equal(length(out), 2)
  expect_equal(calls[[1]]$filters$extract_type, "opportunities_csv")
  expect_equal(calls[[1]]$pagination$page_size, 5000L)
  expect_equal(calls[[1]]$pagination$sort_order[[1]]$order_by, "created_at")
  expect_equal(calls[[2]]$pagination$page_offset, 2L)
})

test_that("search all opportunities paginates search results", {
  calls <- list()
  testthat::local_mocked_bindings(
    grant_search_opportunities = function(query, query_operator, filters, pagination, api_key, base_url) {
      calls[[length(calls) + 1L]] <<- list(
        query = query,
        query_operator = query_operator,
        filters = filters,
        pagination = pagination,
        api_key = api_key,
        base_url = base_url
      )
      list(
        data = list(list(id = pagination$page_offset)),
        pagination_info = list(
          page_offset = pagination$page_offset,
          page_size = pagination$page_size,
          total_pages = 1
        )
      )
    },
    .package = "grantsgov"
  )

  out <- grant_search_all_opportunities(
    query = "education",
    filters = list(opportunity_status = grant_filter_one_of("posted")),
    page_size = 5000,
    api_key = "key",
    base_url = "https://example.test"
  )

  expect_equal(length(out), 1)
  expect_equal(calls[[1]]$query, "education")
  expect_equal(calls[[1]]$query_operator, "AND")
  expect_equal(calls[[1]]$pagination$page_size, 5000L)
  expect_equal(calls[[1]]$filters$opportunity_status$one_of, "posted")
})

test_that("download extract writes bytes and validates inputs", {
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      httr2::response(body = charToRaw("downloaded"))
    },
    .package = "grantsgov"
  )

  path <- tempfile()
  expect_identical(
    grant_download_extract(list(download_path = "https://example.test/file.csv"), path),
    path
  )
  expect_equal(readChar(path, file.info(path)$size), "downloaded")
  expect_error(grant_download_extract("https://example.test/file.csv", path), "already exists")

  path2 <- tempfile()
  expect_identical(grant_download_extract("https://example.test/file.csv", path2), path2)

  default_path <- grant_download_extract("https://example.test/file.csv")
  expect_true(file.exists(default_path))
  expect_match(default_path, "\\.csv$")

  path3 <- tempfile()
  expect_identical(
    grant_download_extract(list(download_url = "https://example.test/file.csv"), path3),
    path3
  )
  expect_error(grant_download_extract(list(), tempfile()), "download_url")
  expect_error(grant_download_extract("https://example.test/file.csv", ""), "path")
})

test_that("download extract can validate file size", {
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      httr2::response(body = charToRaw("downloaded"))
    },
    .package = "grantsgov"
  )

  path <- tempfile(fileext = ".csv")
  expect_identical(
    grant_download_extract("https://example.test/file.csv", path, expected_file_size = 10),
    path
  )
  expect_error(
    grant_download_extract("https://example.test/file.csv", tempfile(), expected_file_size = 9),
    "file size mismatch"
  )
  expect_error(
    grant_download_extract("https://example.test/file.csv", tempfile(), expected_file_size = -1),
    "expected_file_size"
  )
})

test_that("download extract reports HTTP errors", {
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      json_resp(status = 404, body = '{"detail":"missing"}')
    },
    .package = "grantsgov"
  )

  expect_error(
    grant_download_extract("https://example.test/missing.csv", tempfile()),
    "404|missing"
  )
})

test_that("read extract downloads CSV, reads it, and stores the file attribute", {
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      httr2::response(body = charToRaw("id,name\n1,A\n2,B\n"))
    },
    .package = "grantsgov"
  )

  data <- grant_read_extract("https://example.test/file.csv", expected_file_size = 16)

  expect_s3_class(data, "tbl_df")
  expect_equal(nrow(data), 2)
  expect_true(file.exists(attr(data, "file")))
  expect_match(attr(data, "file"), "\\.csv$")
})

test_that("read extract warns when readr reports parsing problems", {
  testthat::local_mocked_bindings(
    grant_perform = function(req) {
      httr2::response(body = charToRaw("id\nnot-a-number\n"))
    },
    .package = "grantsgov"
  )

  expect_warning(
    data <- grant_read_extract(
      "https://example.test/file.csv",
      col_types = readr::cols(id = readr::col_double())
    ),
    "parsing problem"
  )
  expect_gt(nrow(readr::problems(data)), 0)
  expect_true(file.exists(attr(data, "file")))
})
