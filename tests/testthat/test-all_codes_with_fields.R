test_that("getting all MSOA11s for Wales works (with varying degrees of inference)", {

  example1 <- all_codes_with_fields("MSOA11Code", "MSOA11Name", "CountryName") %>% 
    filter(CountryName == "Wales")

  example2 <- all_codes_with_fields("MSOA11Code", "Name", "CountryName") %>% 
    filter(CountryName == "Wales")

  example3 <- all_codes_with_fields("MSOA11", "Name", "CountryName") %>% 
    filter(CountryName == "Wales")

  example4 <- all_codes_with_fields("MSOA11", "MSOA11Name", "CountryName") %>% 
    filter(CountryName == "Wales")


  expect_equal(example1, example2)
  expect_equal(example1, example3)
  expect_equal(example1, example4)
  expect_equal(nrow(example1), 410)
})