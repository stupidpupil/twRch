all_codes_with_fields <- function(code_name, fields=c()){
  fst_path_for_code(code_name) %>% 
    read.fst(columns=code_name) %>%
    add_fields_based_on_some_code(code_name, fields=fields)
}
