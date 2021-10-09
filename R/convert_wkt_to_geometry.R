convert_wkt_to_geometry <- function(in_data){
  wkt_columns <- colnames(in_data) %>% str_detect("WKT$")
  if(sum(wkt_columns) != 1){
    stop("Couldn't find a unique WKT column!")
  }

  wkt_column = colnames(in_data)[wkt_columns]

  in_data %>%
    sf::st_set_geometry(sf::st_as_sfc(in_data %>% pull(wkt_column))) %>% 
    select(-all_of(wkt_column))
}