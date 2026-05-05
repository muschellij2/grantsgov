test_that("search opportunities posts the expected body and parses JSON", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grantsgov_perform = function(req) {
      captured <<- req
      json_resp(body = '{"message":"Success","data":[{"opportunity_id":"one"}]}')
    },
    .package = "grantsgov"
  )

  out <- grantsgov_search_opportunities(
    query = "research",
    filters = list(opportunity_status = grantsgov_filter_one_of("posted")),
    pagination = grantsgov_pagination(page_size = 5),
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

test_that("search validates query and can return CSV", {
  testthat::local_mocked_bindings(
    grantsgov_perform = function(req) {
      httr2::response(
        headers = list("content-type" = "text/csv"),
        body = charToRaw("opportunity_id\none\n")
      )
    },
    .package = "grantsgov"
  )

  expect_error(
    grantsgov_search_opportunities(query = paste(rep("a", 101), collapse = ""), api_key = "key"),
    "100 characters"
  )
  expect_equal(
    grantsgov_search_opportunities(format = "csv", api_key = "key"),
    "opportunity_id\none\n"
  )
})

test_that("get opportunity encodes the ID and parses JSON", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grantsgov_perform = function(req) {
      captured <<- req
      json_resp(body = '{"data":{"opportunity_id":"abc def"}}')
    },
    .package = "grantsgov"
  )

  out <- grantsgov_get_opportunity("abc def", api_key = "key", base_url = "https://example.test")

  expect_equal(out$data$opportunity_id, "abc def")
  expect_equal(captured$method, "GET")
  expect_match(captured$url, "abc%20def", fixed = TRUE)
  expect_error(grantsgov_get_opportunity("", api_key = "key"), "opportunity_id")
})

test_that("list extracts posts filters and parses JSON", {
  captured <- NULL
  testthat::local_mocked_bindings(
    grantsgov_perform = function(req) {
      captured <<- req
      json_resp(body = '{"data":[{"extract_type":"opportunities_json"}]}')
    },
    .package = "grantsgov"
  )

  out <- grantsgov_list_extracts(
    filters = list(extract_type = "opportunities_json"),
    api_key = "key",
    base_url = "https://example.test"
  )

  expect_equal(out$data[[1]]$extract_type, "opportunities_json")
  expect_equal(captured$method, "POST")
  expect_match(captured$url, "/v1/extracts", fixed = TRUE)
  expect_equal(captured$body$data$filters$extract_type, "opportunities_json")
})

test_that("download extract writes bytes and validates inputs", {
  testthat::local_mocked_bindings(
    grantsgov_perform = function(req) {
      httr2::response(body = charToRaw("downloaded"))
    },
    .package = "grantsgov"
  )

  path <- tempfile()
  expect_identical(
    grantsgov_download_extract(list(download_url = "https://example.test/file.csv"), path),
    path
  )
  expect_equal(readChar(path, file.info(path)$size), "downloaded")
  expect_error(grantsgov_download_extract("https://example.test/file.csv", path), "already exists")

  path2 <- tempfile()
  expect_identical(grantsgov_download_extract("https://example.test/file.csv", path2), path2)
  expect_error(grantsgov_download_extract(list(), tempfile()), "download_url")
  expect_error(grantsgov_download_extract("https://example.test/file.csv", ""), "path")
})

test_that("download extract reports HTTP errors", {
  testthat::local_mocked_bindings(
    grantsgov_perform = function(req) {
      json_resp(status = 404, body = '{"detail":"missing"}')
    },
    .package = "grantsgov"
  )

  expect_error(
    grantsgov_download_extract("https://example.test/missing.csv", tempfile()),
    "404|missing"
  )
})
