json_resp <- function(status = 200, body = '{"message":"Success"}', headers = list()) {
  httr2::response(
    status_code = status,
    headers = c(list("content-type" = "application/json"), headers),
    body = charToRaw(body)
  )
}
