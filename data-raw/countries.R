country_boundaries <- st_read("https://opendata.arcgis.com/datasets/7be6a3c1be3b4385951224d2f522470a_0.geojson") %>%
  mutate(
    CountryCode = ctry18cd,
    CountryBoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(CountryCode, CountryBoundariesGeneralisedClippedWKT)

tibble(
  CountryCode = c('W92000004', 'E92000001', 'N92000002', 'S92000003', 'L93000001', 'M83000003'),
  CountryName = c('Wales', 'England', 'Northern Ireland', 'Scotland', 'Channel Islands', 'Isle of Man'),
  CountryNameWelsh = c('Cymru', 'Lloegr', 'Gogledd Iwerddon', 'Yr Alban', 'Ynysoedd y Sianel', 'Ynys_Manaw'),
  CountryISO_3166_2Code= c('GB-WLS', 'GB-ENG', 'GB-NIR', 'GB-SCT', 'GB-CHA', 'IM'),
  CountryAbbr = c('Cym', 'Eng', 'NI', 'Sct', 'Cha', 'Man') 
) %>%
  left_join(country_boundaries, by="CountryCode") %>%
  write_fst("inst/extdata/CountryCode.fst", compress=100)
