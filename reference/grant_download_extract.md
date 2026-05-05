# Download an extract file

Download URLs returned by the extracts endpoint may be pre-signed file
URLs and may not require API-key authentication.

## Usage

``` r
grant_download_extract(
  extract,
  path = tempfile(fileext = ".csv"),
  overwrite = FALSE,
  expected_file_size = NULL
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

  Optional expected downloaded file size in bytes. Pass
  `extract$file_size_bytes` to verify the downloaded file against API
  metadata.

## Value

The output path, invisibly.

## Examples

``` r
if (nzchar(Sys.getenv("GRANTS_GOV_API_KEY")) &&
    identical(tolower(Sys.getenv("GRANTSGOV_EXAMPLES_LIVE")), "true")) {
  extracts <- grant_list_extracts(
    filters = list(extract_type = "opportunities_csv"),
    pagination = grant_pagination(page_size = 1, sort_order = grant_sort("created_at"))
  )
  path <- grant_download_extract(
    extracts$data[[1]],
    expected_file_size = extracts$data[[1]]$file_size_bytes
  )
  path
}
```
