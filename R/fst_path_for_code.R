fst_path_for_code <- function(code_name){
  if(file.exists(paste0("inst/extdata/", code_name, ".fst"))){
    return(paste0("inst/extdata/", code_name, ".fst"))
  }

  system.file("extdata", paste0(code_name, ".fst"), package="BasicPostcodes")
}
