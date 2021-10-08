test_that("getting all LSOA11Codes for Wales works", {

  example <- all_codes_with_fields("LSOA11Code", "CountryName") %>% 
    filter(CountryName == "Wales")

  expect_equal(nrow(example), 1909)
})
