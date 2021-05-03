if(file.exists("inst/extdata")){
  dir_path <- "inst/extdata"
}else{
  dir_path <- system.file("extdata", package="BasicPostcodes")
}

fsts <- dir(dir_path)

for(f in fsts){
  code_name <-  f %>% str_sub(end=-5L)
  data <- read_fst(paste0(dir_path, "/", f), code_name)

  test_that(paste0("The first column of ", f, " is unique"), {
    expect_equal(data %>% pull(code_name) %>% n_distinct(), data %>% nrow())
  })
}
