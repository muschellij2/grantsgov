test_that("requests are built with method, URL, and API key", {
  req <- grant_request("/v1/example", "POST", "abc", "https://example.test")

  expect_equal(req$method, "POST")
  expect_match(req$url, "https://example.test/v1/example", fixed = TRUE)
  expect_equal(req$headers[["X-API-Key"]], "abc")

  testthat::local_mocked_bindings(
    req_error = function(req, is_error) {
      expect_false(is_error(httr2::response(status_code = 500)))
      req
    },
    req_perform = function(req) "performed",
    .package = "httr2"
  )
  expect_equal(grant_perform(req), "performed")
})

test_that("successful responses parse JSON, CSV, and text", {
  expect_equal(
    grant_handle_response(json_resp(body = '{"data":[{"id":1}]}')),
    list(data = list(list(id = 1)))
  )

  csv <- httr2::response(
    headers = list("content-type" = "text/csv"),
    body = charToRaw("a,b\n1,2\n")
  )
  expect_equal(grant_handle_response(csv), "a,b\n1,2\n")

  text <- httr2::response(
    headers = list("content-type" = "text/plain"),
    body = charToRaw("plain")
  )
  expect_equal(grant_handle_response(text), "plain")

  no_type <- httr2::response(body = charToRaw("plain"))
  expect_equal(grant_handle_response(no_type), "plain")
})

test_that("error responses include status, body, guidance, and rate-limit details", {
  resp <- json_resp(
    status = 429,
    body = '{"message":"Too many requests"}',
    headers = list(
      "retry-after" = "60",
      "x-ratelimit-remaining" = "0"
    )
  )

  expect_error(
    grant_handle_response(resp),
    regexp = "429|Rate limit exceeded|Too many requests|retry-after=60|x-ratelimit-remaining=0"
  )

  expect_match(grant_status_guidance(400), "request parameters")
  expect_match(grant_status_guidance(401), "GRANTS_GOV_API_KEY")
  expect_match(grant_status_guidance(403), "permission")
  expect_match(grant_status_guidance(404), "not found")
  expect_match(grant_status_guidance(500), "internal server")
  expect_null(grant_status_guidance(418))

  text_resp <- httr2::response(status_code = 400, body = charToRaw("bad body"))
  expect_match(grant_response_error_message(text_resp), "bad body")

  validation_resp <- json_resp(
    status = 422,
    body = '{"errors":[{"field":"filters","message":"Invalid input type."}]}'
  )
  expect_match(grant_response_error_message(validation_resp), "filters: Invalid input type", fixed = TRUE)
  expect_equal(grant_format_api_error("plain error"), "plain error")

  empty_resp <- httr2::response(status_code = 403, body = raw())
  expect_match(grant_response_error_message(empty_resp), "403")

  testthat::local_mocked_bindings(
    resp_has_body = function(resp) TRUE,
    resp_body_string = function(resp) "",
    .package = "httr2"
  )
  blank_resp <- httr2::response(status_code = 400, body = raw())
  expect_null(grant_error_body_message(blank_resp))

  expect_equal(grantsgov:::`%||%`(NULL, "fallback"), "fallback")
})
