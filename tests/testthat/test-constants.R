test_that("base URL, key lookup, and options are documented", {
  expect_equal(grantsgov_base_url(), "https://api.simpler.grants.gov")

  withr::local_envvar(GRANTS_GOV_API_KEY = "test-key")
  expect_equal(grantsgov_api_key(), "test-key")
  expect_equal(grantsgov_api_key(required = FALSE), "test-key")

  withr::local_envvar(GRANTS_GOV_API_KEY = NA)
  expect_null(grantsgov_api_key(required = FALSE))
  expect_error(grantsgov_api_key(), "GRANTS_GOV_API_KEY")

  endpoints <- grantsgov_endpoints()
  expect_equal(endpoints$authentication$header, "X-API-Key")
  expect_equal(endpoints$endpoints$search_opportunities$path, "/v1/opportunities/search")
  expect_equal(endpoints$endpoints$get_opportunity$method, "GET")
  expect_equal(endpoints$endpoints$list_extracts$function_name, "grantsgov_list_extracts")
  expect_true("opportunity_status" %in% endpoints$search$filters)
  expect_true("opportunities_json" %in% endpoints$extracts$extract_type)
  expect_true("retry-after" %in% endpoints$rate_limit_headers)

  expect_true("OR" %in% grantsgov_search_options()$query_operator)
  expect_true("created_at" %in% grantsgov_extract_options()$filters)
  expect_true("x-ratelimit-remaining" %in% grantsgov_rate_limit_headers())
})
