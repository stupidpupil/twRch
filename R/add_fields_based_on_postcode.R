postcodes_fst_path <- function(){
  if(file.exists("inst/extdata/postcodes.fst")){
    return("inst/extdata/postcodes.fst")
  }

  system.file("extdata", "postcodes.fst", package="BasicPostcodes")
}

add_fields_based_on_postcode <- function(
  in_data, prefix = "", fields = c("OA11Code")){

  simple_fields <- c('CountryCode', 'HealthOrgCode', 'LocalAuthorityCode', 'OA11Code', 'BUASD11Code')
  # TODO: Replace this with a proper graph
  simple_oa11_fields <- c('OA11RuralUrbanClassification','LSOA11Code', 'MSOA11Code', 'MSOA11Name', 'MSOA11NameWelsh')
  simple_la_fields <- c('LocalAuthorityName','LocalAuthorityNameWelsh')

  fields_to_keep_for_join <- c(
    'Postcode', 
    intersect(fields, simple_fields), 
    intersect(fields, simple_oa11_fields),
    intersect(fields, simple_la_fields))

  fields_to_select_from_postcodes <- intersect(fields, simple_fields)

  if(length(intersect(fields, simple_oa11_fields))){
    fields_to_select_from_postcodes <- c(fields_to_select_from_postcodes, 'OA11Code')
  }

  if(length(intersect(fields, simple_la_fields))){
    fields_to_select_from_postcodes <- c(fields_to_select_from_postcodes, 'LocalAuthorityCode')
  }

  postcode_field_sym <- paste0(prefix, 'Postcode') %>% sym()

  in_data <- in_data %>% # TODO - allow not overwriting the original field
    mutate(!!postcode_field_sym := !!postcode_field_sym %>% postcode_as_7_characters())

  # Fetch postcodes as efficiently as possible…
  # TODO - if fuzzing, we'll need to ensure we've loaded all postcodes within Districts+MSOAs or something like that
  req_postcodes <- in_data %>% pull(paste0(prefix, 'Postcode')) %>% unique()

  postcodes <- read_fst(postcodes_fst_path(), 'Postcode')
  req_postcodes_indexes <- which(postcodes$Postcode %in% req_postcodes)

  postcodes <- read_fst(postcodes_fst_path(), c('Postcode', fields_to_select_from_postcodes), 
    from=min(req_postcodes_indexes), to=max(req_postcodes_indexes))
  req_postcodes_indexes <- NULL


  names(postcodes) <- paste0(prefix, names(postcodes))

  # TODO: Replace with this with a proper graph

  if(length(intersect(fields, simple_oa11_fields))){
    postcodes <- postcodes %>% add_fields_based_on_oa11_code(prefix = prefix, fields = intersect(fields, simple_oa11_fields))
  }

  if(length(intersect(fields, simple_la_fields))){
    postcodes <- postcodes %>% add_fields_based_on_local_authority_code(prefix = prefix, fields = intersect(fields, simple_la_fields))
  }

  postcodes <- postcodes %>% select(all_of(paste0(prefix, fields_to_keep_for_join)))

  in_data %>% left_join(postcodes, by=c(paste0(prefix, 'Postcode')))
}