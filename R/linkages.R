all_linkages <- function(){


  if(file.exists("inst/extdata")){
    dir_path <- "inst/extdata"
  }else{
    dir_path <- system.file("extdata", package="BasicPostcodes")
  }

  fsts <- dir(dir_path)


  ret <- list()

  for(f in fsts){
    md <- metadata_fst(paste0(dir_path, "/", f))

    in_code <- md$columnNames[[1]]
    out_codes <- setdiff(md$columnNames, in_code)

    ret[[in_code]] <- out_codes
  }

  return(ret)
}

linkages_from <- function(initial_out_codes){

  all_links <- all_linkages()

  ret <- all_links[initial_out_codes]

  for(l in names(ret)){
    ret[[l]] <- c(ret[[l]], unlist(linkages_from(ret[[l]]), use.names = FALSE))
  }

  return(ret)
}

add_fields_function_for_code <- function(code_name){
  hardcoded <- list(
    'Postcode' = add_fields_based_on_postcode
  )

  if(code_name %in% names(hardcoded)){
    return(hardcoded[[code_name]])
  }

  return(function(in_data, prefix="", fields=c()){
    add_fields_based_on_some_code(in_data, code_name, prefix, fields)
    })
}