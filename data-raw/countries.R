tibble(
  CountryCode = c('W92000004', 'E92000001', 'N92000002', 'S92000003', 'L93000001', 'M83000003'),
  CountryName = c('Wales', 'England', 'Northern Ireland', 'Scotland', 'Channel Islands', 'Isle of Man'),
  CountryNameWelsh = c('Cymru', 'Lloegr', 'Gogledd Iwerddon', 'Yr Alban', 'Ynysoedd y Sianel', 'Ynys_Manaw'),
  CountryISO_3166_2Code= c('GB-WLS', 'GB-ENG', 'GB-NIR', 'GB-SCT', 'GB-CHA', 'IM'),
  CountryAbbr = c('Cym', 'Eng', 'NI', 'Sct', 'Cha', 'Man') 
) %>%
  write_fst("inst/extdata/CountryCode.fst", compress=100)
