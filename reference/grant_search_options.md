# List opportunity search options

List opportunity search options

## Usage

``` r
grant_search_options()
```

## Value

A named list of documented search parameters and values.

## Examples

``` r
opts <- grant_search_options()
opts$filters
#>  [1] "top_level_agency"                "funding_instrument"             
#>  [3] "funding_category"                "applicant_type"                 
#>  [5] "opportunity_status"              "post_date"                      
#>  [7] "close_date"                      "award_floor"                    
#>  [9] "award_ceiling"                   "expected_number_of_awards"      
#> [11] "estimated_total_program_funding" "assistance_listing_number"      
#> [13] "is_cost_sharing"                
opts$sort_by
#>  [1] "relevancy"             "opportunity_id"        "opportunity_number"   
#>  [4] "opportunity_title"     "post_date"             "close_date"           
#>  [7] "agency_code"           "agency_name"           "top_level_agency_name"
#> [10] "award_floor"           "award_ceiling"        
```
