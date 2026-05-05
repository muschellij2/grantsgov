# Request-body helper constructors for common API structures.

#' Build a sort specification
#'
#' @param order_by Field to sort by. See [grantsgov_search_options()] or
#'   [grantsgov_extract_options()] for endpoint-specific values.
#' @param sort_direction Sort direction, either `"ascending"` or `"descending"`.
#'
#' @return A list suitable for the API `sort_order` array.
#' @export
grantsgov_sort <- function(order_by, sort_direction = "descending") {
  sort_direction <- match.arg(sort_direction, c("ascending", "descending"))

  list(
    order_by = order_by,
    sort_direction = sort_direction
  )
}

#' Build a pagination specification
#'
#' @param page_offset One-based page index. The public API examples start at 1.
#' @param page_size Number of records per page. The API documentation currently
#'   describes valid values from 1 through 100.
#' @param sort_order Optional sort specification. Use [grantsgov_sort()] or a
#'   list of sort specifications.
#'
#' @return A list suitable for request-body `pagination`.
#' @export
grantsgov_pagination <- function(page_offset = 1, page_size = 25, sort_order = NULL) {
  if (!is.numeric(page_offset) || length(page_offset) != 1 || page_offset < 1) {
    stop("`page_offset` must be a single number greater than or equal to 1.", call. = FALSE)
  }
  if (!is.numeric(page_size) || length(page_size) != 1 || page_size < 1 || page_size > 100) {
    stop("`page_size` must be a single number between 1 and 100.", call. = FALSE)
  }

  pagination <- list(
    page_offset = as.integer(page_offset),
    page_size = as.integer(page_size)
  )

  if (!is.null(sort_order)) {
    pagination$sort_order <- grantsgov_normalize_sort_order(sort_order)
  }

  pagination
}

#' Build a `one_of` filter
#'
#' @param values Values accepted by the API for the selected filter.
#'
#' @return A list with a `one_of` member.
#' @export
grantsgov_filter_one_of <- function(values) {
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
#' @export
grantsgov_filter_date_range <- function(start_date = NULL, end_date = NULL) {
  grantsgov_compact_list(list(
    start_date = grantsgov_format_date(start_date),
    end_date = grantsgov_format_date(end_date)
  ))
}

#' Build a numeric range filter
#'
#' @param min,max Optional numeric lower and upper bounds.
#'
#' @return A list containing non-missing numeric bounds.
#' @export
grantsgov_filter_number_range <- function(min = NULL, max = NULL) {
  if (!is.null(min) && (!is.numeric(min) || length(min) != 1)) {
    stop("`min` must be a single number or NULL.", call. = FALSE)
  }
  if (!is.null(max) && (!is.numeric(max) || length(max) != 1)) {
    stop("`max` must be a single number or NULL.", call. = FALSE)
  }

  grantsgov_compact_list(list(min = min, max = max))
}

# Normalize one sort object or a list of sort objects into an API array.
grantsgov_normalize_sort_order <- function(sort_order) {
  if (is.null(sort_order$order_by)) {
    return(sort_order)
  }

  list(sort_order)
}

# Drop NULL values while preserving false, zero, and empty strings.
grantsgov_compact_list <- function(x) {
  x[!vapply(x, is.null, logical(1))]
}

# Convert dates to the API's YYYY-MM-DD representation.
grantsgov_format_date <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  format(as.Date(x), "%Y-%m-%d")
}
