output_areas11_fst_path <- function(){
  if(file.exists("inst/extdata/output_areas11.fst")){
    return("inst/extdata/output_areas11.fst")
  }

  system.file("extdata", "output_areas11.fst", package="BasicPostcodes")
}

add_fields_based_on_oa11_code <- function(
  in_data, prefix = "", fields = c("LSOA11Code")){

  simple_fields <- c('OA11RuralUrbanClassification','LSOA11Code', 'MSOA11Code', 'MSOA11Name', 'MSOA11NameWelsh')

  fields_to_keep_for_join <- intersect(fields, simple_fields)

  output_areas11 <- read_fst(output_areas11_fst_path(), c('OA11Code', fields_to_keep_for_join))

  names(output_areas11) <- paste0(prefix, names(output_areas11))

  in_data %>% left_join(output_areas11, by=c(paste0(prefix, 'OA11Code')))
}