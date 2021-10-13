all_codes_with_fields <- function(code_name, ...){

  code_name <- code_name %>%
    str_replace("(Code)?$","Code")

  fst_path_for_code(code_name) %>% 
    read.fst(columns=code_name) %>%
    add_fields_based_on_some_code(code_name, fields=c(...))
}
