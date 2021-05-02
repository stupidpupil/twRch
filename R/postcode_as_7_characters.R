postcode_as_7_characters <- function(some_codes){
  some_codes <- some_codes %>% str_to_upper %>% str_replace_all("[^A-Z0-9]","")

  inward <- some_codes %>% str_sub(start = -3L, end = -1L) 
  outward <- some_codes %>% str_sub(start = 1L, end = -4L) %>% str_pad(width=4, side='right')

  paste0(outward, inward)
}