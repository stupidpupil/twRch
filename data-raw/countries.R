tibble(
  CountryCode = c('W92000004', 'E92000001', 'N92000002', 'S92000003'),
  CountryName = c('Wales', 'England', 'Northern Ireland', 'Scotland'),
  CountryNameWelsh = c('Cymru', 'Lloegr', 'Gogledd Iwerddon', 'Yr Alban'),
  CountryISO_3166_2Code= c('GB-WLS', 'GB-ENG', 'GB-NIR', 'GB-SCT'),
  CountryAbbr = c('Cym', 'Eng', 'NI', 'Sct') 
) %>%
  write_fst("inst/extdata/CountryCode.fst", compress=100)
