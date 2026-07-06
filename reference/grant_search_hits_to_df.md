# Convert opportunity search hits to a data frame

Flattens the list returned by
[`grant_search_all_opportunities()`](grant_search_all_opportunities.md)
or the `data` field returned by
[`grant_search_opportunities()`](grant_search_opportunities.md) into a
tabular form. This is useful when you want a quick data-frame
representation of search results before fetching full opportunity detail
records.

## Usage

``` r
grant_search_hits_to_df(search_hits)
```

## Arguments

- search_hits:

  A list of opportunity search-hit records.

## Value

A data frame with one row per search hit.

## Examples

``` r
hits <- list(
  list(
    opportunity_id = "opp-1",
    legacy_opportunity_id = 123,
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
grant_search_hits_to_df(hits)
#>   opportunity_id legacy_opportunity_id opportunity_number   opportunity_title
#> 1          opp-1                   123         PAR-00-001 Example opportunity
#>   opportunity_status    agency agency_code                   agency_name
#> 1             posted HHS-NIH11   HHS-NIH11 National Institutes of Health
#>   top_level_agency_code                   top_level_agency_name      category
#> 1                   HHS Department of Health and Human Services discretionary
#>   category_explanation  post_date close_date archive_date created_at updated_at
#> 1                 <NA> 2026-01-01 2026-02-01   2026-03-01 2026-01-01 2026-01-02
#>    additional_info_url agency_email_address award_floor award_ceiling
#> 1 https://example.test    info@example.test        1000          2000
#>   estimated_total_program_funding expected_number_of_awards is_cost_sharing
#> 1                            3000                         4           FALSE
#>   is_forecast   applicant_types funding_categories funding_instruments
#> 1       FALSE state_governments             health               grant
#>   assistance_listing_numbers assistance_listing_program_titles
#> 1                     93.000                   Example listing
#>   summary_description applicant_eligibility_description
#> 1      Longer summary                  Eligibility text
#>   agency_contact_description
#> 1               Contact text
```
