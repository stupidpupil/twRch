test_that("adding OA11Code for B75NJ works", {

  example <- tibble(ResidentPostcode = c('B75NJ'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields='OA11Code')

  expect_equal(example$ResidentPostcode, 'B7  5NJ')
  expect_equal(example$ResidentOA11Code, 'E00046669')
  expect_equal(length(colnames(example)), 2)
})


test_that("adding CountryName for EH99 1SP and SA99 1BN works", {

  example <- tibble(ResidentPostcode = c('EH99 1SP', 'SA99 1BN'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields='CountryName')

  expect_equal(example$ResidentCountryName, c('Scotland', 'Wales'))
  expect_equal(length(colnames(example)), 2)
})


test_that("adding MSOA11Code and MSOA11Name for SM5 2AT works", {

  example <- tibble(ResidentPostcode = c('SM5 2AT'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields=c('MSOA11Code', 'MSOA11Name'))

  expect_equal(example$ResidentMSOA11Code, 'E02000843')
  expect_equal(example$ResidentMSOA11Name, 'Hackbridge')
  expect_equal(length(colnames(example)), 3)
})


test_that("adding Local Authority for ME10 2HG works", {

  example <- tibble(ResidentPostcode = c('ME10 2HG'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields=c('LocalAuthorityName'))

  expect_equal(example$ResidentLocalAuthorityName, 'Swale')
  expect_equal(length(colnames(example)), 2)
})


test_that("adding Local Authority for 'Nothing' produces NA", {

  example <- tibble(ResidentPostcode = c('Nothing'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields=c('LocalAuthorityName'))

  expect_equal(example$ResidentLocalAuthorityName, NA_character_)
  expect_equal(length(colnames(example)), 2)
})

test_that("adding HealthBoardOrgCode for CF47 8AX works", {

  # This test checks that we can determine the post-April 2019 health board code
  # for a postcode in Merthyr correctly
  example <- tibble(ResidentPostcode = c('CF47 8AX'))

  example <- example %>% 
    add_fields_based_on_postcode(prefix='Resident', fields=c('HealthBoardOrgCode'))

  expect_equal(example$ResidentHealthBoardOrgCode, '7A5')
  expect_equal(length(colnames(example)), 2)
})
