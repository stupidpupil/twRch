add_fields_based_on_postcode <- function(
  in_data, prefix = "", fields = c("OA11Code")){

  postcode_field_sym <- paste0(prefix, 'Postcode') %>% sym()

  in_data <- in_data %>% # TODO - allow not overwriting the original field
    mutate(!!postcode_field_sym := !!postcode_field_sym %>% postcode_as_7_characters())

  in_data %>% add_fields_based_on_some_code('Postcode', prefix, fields)
}
