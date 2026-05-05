# Download and read a CSV extract

Downloads an extract with
[`grant_download_extract()`](grant_download_extract.md) and reads it
with
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).
If readr reports parsing problems, this function emits a warning. The
downloaded file path is stored in the returned data frame's `file`
attribute.

## Usage

``` r
grant_read_extract(
  extract,
  path = tempfile(fileext = ".csv"),
  overwrite = FALSE,
  expected_file_size = NULL,
  ...
)
```

## Arguments

- extract:

  Metadata list containing a `download_path` or `download_url`, or a
  scalar URL.

- path:

  Local output path. Defaults to a temporary `.csv` file.

- overwrite:

  If `FALSE`, error when `path` already exists.

- expected_file_size:

  Optional expected downloaded file size in bytes.

- ...:

  Additional arguments passed to
  [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).

## Value

A tibble with the downloaded file path in `attr(x, "file")`.

## Examples

``` r
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  extracts <- grant_list_extracts(
    filters = list(extract_type = "opportunities_csv"),
    pagination = grant_pagination(page_size = 1, sort_order = grant_sort("created_at"))
  )
  data <- grant_read_extract(
    extracts$data[[1]],
    expected_file_size = extracts$data[[1]]$file_size_bytes
  )
  attr(data, "file")
}
```
