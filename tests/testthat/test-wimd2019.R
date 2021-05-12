test_that("LL18 1BA (Rhyl West 2) has an LSOA11 WIMD19 Rank of 1", {
  example <- tibble(ResidentPostcode = c('LL18 1BA'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields='LSOA11WIMD19Rank')

  expect_equal(example$ResidentLSOA11WIMD19Rank, c(1L))
})
