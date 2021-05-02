test_that("'AB11AA' is rendered as 'AB1 1AA'", {
  expect_equal('AB11AA' %>% postcode_as_7_characters(), 'AB1 1AA')
})

test_that("'AB121AA' is rendered as 'AB112AA'", {
  expect_equal('AB121AA' %>% postcode_as_7_characters(), 'AB121AA')
})

test_that("'A11AA' is rendered as 'A1  1AA'", {
  expect_equal('A11AA' %>% postcode_as_7_characters(), 'A1  1AA')
})
