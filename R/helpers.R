# Request-body helper constructors for common API structures.

#' Build a sort specification
#'
#' @param order_by Field to sort by. See [grant_search_options()] or
#'   [grant_extract_options()] for endpoint-specific values.
#' @param sort_direction Sort direction, either `"ascending"` or `"descending"`.
#'
#' @return A list suitable for the API `sort_order` array.
#'
#' @examples
#' grant_sort("created_at")
#' grant_sort("close_date", "ascending")
#' @export
grant_sort <- function(order_by, sort_direction = "descending") {
  sort_direction <- match.arg(sort_direction, c("ascending", "descending"))

  list(
    order_by = order_by,
    sort_direction = sort_direction
  )
}

#' Build a pagination specification
#'
#' @param page_offset One-based page index. The public API examples start at 1.
#' @param page_size Number of records per page. The live API accepts values up
#'   to 5000 for paginated endpoints.
#' @param sort_order Optional sort specification. Use [grant_sort()] or a
#'   list of sort specifications.
#'
#' @return A list suitable for request-body `pagination`.
#'
#' @examples
#' grant_pagination()
#' grant_pagination(
#'   page_offset = 2,
#'   page_size = 5000,
#'   sort_order = grant_sort("created_at")
#' )
#' @export
grant_pagination <- function(page_offset = 1, page_size = 25, sort_order = NULL) {
  if (!is.numeric(page_offset) || length(page_offset) != 1 || page_offset < 1) {
    stop("`page_offset` must be a single number greater than or equal to 1.", call. = FALSE)
  }
  if (!is.numeric(page_size) || length(page_size) != 1 || page_size < 1 || page_size > 5000) {
    stop("`page_size` must be a single number between 1 and 5000.", call. = FALSE)
  }

  pagination <- list(
    page_offset = as.integer(page_offset),
    page_size = as.integer(page_size)
  )

  if (!is.null(sort_order)) {
    pagination$sort_order <- grant_normalize_sort_order(sort_order)
  }

  pagination
}

#' Paginate through an endpoint
#'
#' Generic paginator for endpoint wrappers that accept a `pagination` argument
#' and return a `data` element plus optional `pagination_info` metadata. This
#' applies to [grant_search_opportunities()] and [grant_list_extracts()].
#'
#' @param .f Endpoint function, or a string naming one.
#' @param ... Arguments passed to `.f`.
#' @param page_size Number of records per page.
#' @param page_offset First page offset.
#' @param sort_order Optional sort specification passed to [grant_pagination()].
#' @param max_pages Maximum number of pages to request. Use `Inf` to continue
#'   until API pagination metadata or a short page indicates completion.
#' @param data_field Response field containing page records.
#'
#' @return A list of records with `pages` and `pagination_info` attributes.
#'
#' @examples
#' mock_endpoint <- function(pagination) {
#'   list(
#'     data = list(list(page = pagination$page_offset)),
#'     pagination_info = list(
#'       page_offset = pagination$page_offset,
#'       page_size = pagination$page_size,
#'       total_pages = 2
#'     )
#'   )
#' }
#' grant_paginate(mock_endpoint, page_size = 2)
#'
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   grant_paginate(
#'     grant_list_extracts,
#'     page_size = 5000,
#'     sort_order = grant_sort("created_at"),
#'     max_pages = 1
#'   )
#' }
#' @export
grant_paginate <- function(.f,
                           ...,
                           page_size = 5000,
                           page_offset = 1,
                           sort_order = NULL,
                           max_pages = Inf,
                           data_field = "data") {
  .f <- grant_match_endpoint_function(.f)
  if (!is.numeric(max_pages) || length(max_pages) != 1 || max_pages < 1) {
    stop("`max_pages` must be a single positive number or Inf.", call. = FALSE)
  }
  if (!is.character(data_field) || length(data_field) != 1 || !nzchar(data_field)) {
    stop("`data_field` must be a non-empty string.", call. = FALSE)
  }

  current_page <- as.integer(page_offset)
  records <- list()
  pages <- list()
  page_infos <- list()
  pages_requested <- 0L

  repeat {
    pages_requested <- pages_requested + 1L
    response <- .f(
      ...,
      pagination = grant_pagination(
        page_offset = current_page,
        page_size = page_size,
        sort_order = sort_order
      )
    )

    page_records <- response[[data_field]] %||% list()
    records <- c(records, page_records)
    pages[[length(pages) + 1L]] <- response

    page_info <- response$pagination_info %||% list()
    page_infos[[length(page_infos) + 1L]] <- page_info

    total_pages <- page_info$total_pages
    if (!is.null(total_pages)) {
      if (current_page >= total_pages) {
        break
      }
    } else {
      if (length(page_records) < page_size) {
        break
      }
    }
    if (pages_requested >= max_pages) {
      break
    }

    current_page <- current_page + 1L
  }

  attr(records, "pages") <- pages
  attr(records, "pagination_info") <- page_infos
  records
}

#' Paginate through all extract metadata
#'
#' Convenience wrapper around `grant_paginate()` for [grant_list_extracts()].
#'
#' @param filters Named list of extract filters.
#' @param page_size Number of records per page.
#' @param page_offset First page offset.
#' @param sort_order Sort specification. The extracts endpoint requires a sort
#'   order, so this defaults to `created_at` descending.
#' @param max_pages Maximum number of pages to request.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return A list of extract metadata records.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   extracts <- grant_list_all_extracts(
#'     filters = list(extract_type = "opportunities_csv"),
#'     page_size = 5000
#'   )
#'   length(extracts)
#' }
#' @export
grant_list_all_extracts <- function(filters = list(),
                                    page_size = 5000,
                                    page_offset = 1,
                                    sort_order = grant_sort("created_at"),
                                    max_pages = Inf,
                                    api_key = grant_api_key(),
                                    base_url = grant_base_url()) {
  grant_paginate(
    grant_list_extracts,
    filters = filters,
    page_size = page_size,
    page_offset = page_offset,
    sort_order = sort_order,
    max_pages = max_pages,
    api_key = api_key,
    base_url = base_url
  )
}

#' Paginate through opportunity search results
#'
#' Convenience wrapper around `grant_paginate()` for
#' [grant_search_opportunities()].
#'
#' @param query Optional free-text query.
#' @param query_operator Query operator, `"AND"` or `"OR"`.
#' @param filters Named list of search filters.
#' @param page_size Number of records per page.
#' @param page_offset First page offset.
#' @param sort_order Optional sort specification.
#' @param max_pages Maximum number of pages to request.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return A list of opportunity search records.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   opportunities <- grant_search_all_opportunities(
#'     query = "education",
#'     filters = list(opportunity_status = grant_filter_one_of("posted")),
#'     page_size = 5000,
#'     max_pages = 1
#'   )
#'   length(opportunities)
#' }
#' @export
grant_search_all_opportunities <- function(query = NULL,
                                           query_operator = c("AND", "OR"),
                                           filters = list(),
                                           page_size = 5000,
                                           page_offset = 1,
                                           sort_order = NULL,
                                           max_pages = Inf,
                                           api_key = grant_api_key(),
                                           base_url = grant_base_url()) {
  grant_paginate(
    grant_search_opportunities,
    query = query,
    query_operator = match.arg(query_operator),
    filters = filters,
    page_size = page_size,
    page_offset = page_offset,
    sort_order = sort_order,
    max_pages = max_pages,
    api_key = api_key,
    base_url = base_url
  )
}

#' Get recently posted opportunities
#'
#' Convenience wrapper for getting all opportunities posted in the last day or
#' last week. The Simpler Grants.gov opportunity search endpoint exposes this
#' as the `post_date` filter, so "created" opportunities are interpreted as
#' opportunities posted within the requested date window.
#'
#' @param period Recent window, either `"day"` or `"week"`.
#' @param days Optional custom number of days to look back. If supplied, this
#'   overrides `period`.
#' @param end_date Last date in the date window. Defaults to today.
#' @param query Optional free-text query.
#' @param query_operator Query operator, `"AND"` or `"OR"`.
#' @param filters Additional search filters. Do not include `post_date`; this
#'   function sets it from `period`, `days`, and `end_date`.
#' @param page_size Number of records per page.
#' @param page_offset First page offset.
#' @param sort_order Sort specification. Defaults to `post_date` descending.
#' @param max_pages Maximum number of pages to request.
#' @param api_key API key. Defaults to `GRANTS_GOV_API_KEY`.
#' @param base_url API base URL.
#'
#' @return A list of opportunity search records.
#'
#' @examples
#' if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
#'     identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
#'   last_day <- grant_recent_opportunities("day", max_pages = 1)
#'   last_week <- grant_recent_opportunities("week", max_pages = 1)
#'   length(last_day)
#'   length(last_week)
#' }
#' @export
grant_recent_opportunities <- function(period = c("day", "week"),
                                       days = NULL,
                                       end_date = Sys.Date(),
                                       query = NULL,
                                       query_operator = c("AND", "OR"),
                                       filters = list(),
                                       page_size = 5000,
                                       page_offset = 1,
                                       sort_order = grant_sort("post_date"),
                                       max_pages = Inf,
                                       api_key = grant_api_key(),
                                       base_url = grant_base_url()) {
  period <- match.arg(period)
  query_operator <- match.arg(query_operator)

  if (!is.null(filters$post_date)) {
    stop("`filters` must not include `post_date`; use `period`, `days`, and `end_date`.", call. = FALSE)
  }

  lookback_days <- grant_recent_days(period, days)
  end_date <- as.Date(end_date)
  start_date <- end_date - lookback_days

  filters$post_date <- grant_filter_date_range(start_date, end_date)

  grant_search_all_opportunities(
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
}

#' Build a `one_of` filter
#'
#' @param values Values accepted by the API for the selected filter.
#'
#' @return A list with a `one_of` member.
#'
#' @examples
#' grant_filter_one_of(c("posted", "forecasted"))
#' @export
grant_filter_one_of <- function(values) {
  if (is.null(values) || length(values) == 0) {
    stop("`values` must contain at least one value.", call. = FALSE)
  }

  list(one_of = values)
}

#' Build a date range filter
#'
#' @param start_date,end_date Optional date bounds in `YYYY-MM-DD` format, or
#'   objects coercible with [as.Date()].
#'
#' @return A list containing non-missing date bounds.
#'
#' @examples
#' grant_filter_date_range("2026-01-01", "2026-12-31")
#' grant_filter_date_range(end_date = Sys.Date() + 30)
#' @export
grant_filter_date_range <- function(start_date = NULL, end_date = NULL) {
  grant_compact_list(list(
    start_date = grant_format_date(start_date),
    end_date = grant_format_date(end_date)
  ))
}

#' Build a numeric range filter
#'
#' @param min,max Optional numeric lower and upper bounds.
#'
#' @return A list containing non-missing numeric bounds.
#'
#' @examples
#' grant_filter_number_range(min = 10000, max = 1000000)
#' grant_filter_number_range(max = 500000)
#' @export
grant_filter_number_range <- function(min = NULL, max = NULL) {
  if (!is.null(min) && (!is.numeric(min) || length(min) != 1)) {
    stop("`min` must be a single number or NULL.", call. = FALSE)
  }
  if (!is.null(max) && (!is.numeric(max) || length(max) != 1)) {
    stop("`max` must be a single number or NULL.", call. = FALSE)
  }

  grant_compact_list(list(min = min, max = max))
}

# Normalize one sort object or a list of sort objects into an API array.
grant_normalize_sort_order <- function(sort_order) {
  if (is.null(sort_order$order_by)) {
    return(sort_order)
  }

  list(sort_order)
}

# Drop NULL values while preserving false, zero, and empty strings.
grant_compact_list <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}

# Convert dates to the API's YYYY-MM-DD representation.
grant_format_date <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  format(as.Date(x), "%Y-%m-%d")
}

# Resolve a function object or exported function name.
grant_match_endpoint_function <- function(.f) {
  if (is.function(.f)) {
    return(.f)
  }
  if (is.character(.f) && length(.f) == 1 && nzchar(.f)) {
    return(get(.f, envir = parent.frame(2), mode = "function", inherits = TRUE))
  }

  stop("`.f` must be a function or a function name.", call. = FALSE)
}

# Convert a named recent period or custom day count into a lookback window.
grant_recent_days <- function(period, days = NULL) {
  if (!is.null(days)) {
    if (!is.numeric(days) || length(days) != 1 || is.na(days) || days < 1) {
      stop("`days` must be NULL or a single positive number.", call. = FALSE)
    }
    return(as.integer(days))
  }

  switch(
    period,
    day = 1L,
    week = 7L
  )
}
