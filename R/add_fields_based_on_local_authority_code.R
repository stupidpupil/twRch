local_authorities_fst_path <- function(){
  if(file.exists("inst/extdata/local_authorities.fst")){
    return("inst/extdata/local_authorities.fst")
  }

  system.file("extdata", "local_authorities.fst", package="BasicPostcodes")
}

add_fields_based_on_local_authority_code <- function(
  in_data, prefix = "", fields = c("LocalAuthorityName")){

  simple_fields <- c('LocalAuthorityName','LocalAuthorityNameWelsh')

  fields_to_keep_for_join <- intersect(fields, simple_fields)

  local_authorities <- read_fst(local_authorities_fst_path(), c('LocalAuthorityCode', fields_to_keep_for_join))

  names(local_authorities) <- paste0(prefix, names(local_authorities))

  in_data %>% left_join(local_authorities, by=c(paste0(prefix, 'LocalAuthorityCode')))
}
