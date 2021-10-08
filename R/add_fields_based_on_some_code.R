add_fields_based_on_some_code <- function(
  in_data,
  code_name,
  prefix = "",
  fields){

  if(missing(code_name)){
    code_name <- colnames(in_data)[[1]]
  }

  if(length(fields) == 0){
    return(in_data)
  }

  fst_path <- fst_path_for_code(code_name)
  fst_metadata <- metadata_fst(fst_path)

  direct_fields <- setdiff(fst_metadata$columnNames, code_name)

  remaining_fields <- setdiff(fields, direct_fields)

  linkers <- linkages_from(direct_fields)

  req_links_with_fields <- list()
  for (l in names(linkers)) {
    if(length(intersect(remaining_fields, linkers[[l]]))){
      req_links_with_fields[[l]] <- intersect(remaining_fields, linkers[[l]])
      remaining_fields <- setdiff(remaining_fields, req_links_with_fields[[l]])
    }
  }

  fields_to_select_from_some_code <- c(
    code_name, 
    intersect(direct_fields, fields), 
    names(req_links_with_fields)) %>% unique()
  
  fields_to_keep_for_join <- paste0(
    prefix, 
    c(
      code_name, 
      intersect(direct_fields, fields), 
      req_links_with_fields %>% unlist(use.names = FALSE)) %>% unique()
    )

  if(fst_metadata$nrOfRows > 5000L){
    req_join_fields <- in_data %>% pull(paste0(prefix, code_name)) %>% unique()
    code_data <- read_fst(fst_path, code_name) 
    req_code_data_indices <- which(code_data[[code_name]] %in% req_join_fields)

    if(length(req_code_data_indices) == 0){
      req_code_data_indices <- 1
    }

    code_data <- read_fst(fst_path, fields_to_select_from_some_code, 
      from=min(req_code_data_indices), to=max(req_code_data_indices)) 
  }else{
    code_data <- read_fst(fst_path, fields_to_select_from_some_code)
  }

  for (l in names(req_links_with_fields)) {
    fields_to_fetch <- setdiff(req_links_with_fields[[l]], colnames(code_data))
    code_data <- add_fields_function_for_code(l)(code_data, prefix='', fields=req_links_with_fields[[l]])
  }

  names(code_data) <- paste0(prefix, names(code_data))


  code_data <- code_data %>%
    select(all_of(fields_to_keep_for_join)) %>%
    distinct()

  return(in_data %>% left_join(code_data, by=paste0(prefix, code_name)))
}
