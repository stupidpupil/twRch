convert_wkt_to_geometry <- function(in_data){
  wkt_columns <- colnames(in_data) %>% str_detect("WKT$")
  if(sum(wkt_columns) != 1){
    stop("Couldn't find a unique WKT column!")
  }

  wkt_column = colnames(in_data)[wkt_columns]

  wkt <- in_data %>% pull(wkt_column)
  wkt <- if_else(is.na(wkt), 'SRID=4326;POINT EMPTY', wkt)

  in_data %>%
    sf::st_set_geometry(sf::st_as_sfc(wkt)) %>% 
    select(-all_of(wkt_column))
}