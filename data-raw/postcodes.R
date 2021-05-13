library(fst)
library(readr)
library(dplyr)
library(magrittr)

print("Reading…")
postcodes <- read_csv(
  "data-raw/75edec484c5d49bcadd4893c0ebca0ff_0.csv.gz",
  col_types = cols_only(
    pcd = col_character(),
    # 2011 Statistical Building Blocks
    oa11 = col_character(),
    ru11ind = col_character(),
    lsoa11 = col_character(),
    msoa11 = col_character(),
    # 2011 Census
    buasd11 = col_character(),
    bua11 = col_character(),
    # Adminstrative
    oslaua = col_character(),
    ctry = col_character(),
    # Constituency
    pcon = col_character(),
    # Health
    oshlthau = col_character(),
    # Latitude/Longitude
    lat = col_double(),
    long = col_double()
  )
  ) %>% rename(
    Postcode = pcd,
    OA11Code = oa11,
    OA11RuralUrbanClassification = ru11ind,
    LSOA11Code = lsoa11,
    MSOA11Code = msoa11,
    BUASD11Code = buasd11,
    BUA11Code = bua11,
    LocalAuthorityCode = oslaua,
    CountryCode = ctry,
    WestminsterParliamentConstituencyCode = pcon,
    HealthBoardONSCode = oshlthau, # Good enough name for now…
    PostcodeLatitude = lat,
    PostcodeLongitude = long
  )

equivalents <- read_csv(unz("data-raw/Code_History_Database_(December_2020)_UK.zip", "Equivalents_V2.csv"),
  col_types = cols_only(
    GEOGCD = col_character(),
    GEOGCDO = col_character(),
    GEOGCDD = col_character(),
    GEOGCDH = col_character(),
    GEOGCDS = col_character(),
    GEOGCDI = col_character(),
    GEOGCDWG = col_character()
  )
  )

print("Writing…")


postcodes %>% 
  select(Postcode, CountryCode, HealthBoardONSCode, LocalAuthorityCode, OA11Code, BUASD11Code, BUA11Code, PostcodeLatitude, PostcodeLongitude) %>%
  filter(CountryCode != 'N92000002') %>% # Northern Ireland's postcodes have painful licensing
  arrange(desc(CountryCode), HealthBoardONSCode, LocalAuthorityCode, Postcode) %>%
  write_fst("inst/extdata/Postcode.fst", compress=100)


postcodes %>% select(HealthBoardONSCode) %>% distinct() %>%
  left_join(equivalents %>% mutate(HealthBoardONSCode = GEOGCD, HealthBoardOrgCode = GEOGCDO) %>% select(starts_with('HealthBoard'))) %>%
  write_fst("inst/extdata/HealthBoardONSCode.fst")


#
# Output Areas
#

postcodes %>%
  filter(!is.na(OA11Code)) %>%
  select(OA11Code, OA11RuralUrbanClassification, LSOA11Code) %>% distinct() %>%
  arrange(desc(OA11Code), LSOA11Code) %>%
  write_fst("inst/extdata/OA11Code.fst", compress=100)

best_fit_lsoa_to_la <- read_csv("https://opendata.arcgis.com/datasets/e1931df9376447308dc2b8016431fbee_0.csv") %>%
  mutate(
    LSOA11Code = LSOA11CD,
    LocalAuthorityCode = UTLA21CD
  ) %>% select(LSOA11Code, LocalAuthorityCode)

mysoc_uk_imd_w <- read_csv("https://raw.githubusercontent.com/mysociety/composite_uk_imd/master/uk_index/UK_IMD_W.csv") %>%
  mutate(
    LSOA11Code = lsoa,
    LSOA11MySocIMD20WScore = UK_IMD_W_score,
    LSOA11MySocIMD20LocalScore = overall_local_score,
    LSOA11WIMD19Rank = rank(if_else(str_sub(LSOA11Code, end=1L) == 'W', -overall_local_score, NA_real_), na.last='keep') %>% as.integer() # Invert Overall local score to match WG ranking
  ) %>%
  select(starts_with("LSOA11"))

postcodes %>%
  filter(!is.na(LSOA11Code)) %>%
  select(LSOA11Code, MSOA11Code, CountryCode) %>% distinct() %>%
  left_join(mysoc_uk_imd_w, by='LSOA11Code') %>%
  left_join(best_fit_lsoa_to_la, by='LSOA11Code') %>%
  arrange(desc(LSOA11Code), MSOA11Code) %>%
  write_fst("inst/extdata/LSOA11Code.fst", compress=100)

stupidpupil_wimd_msoa <- read_csv("https://raw.githubusercontent.com/stupidpupil/wimd_msoa/main/output/wimd_msoa.csv") %>%
  mutate(
    MSOA11Code = `MSOA Code`,
    MSOA11StpPplWIMD19Rank = `Pseudo-WIMD 2019 rank`
    ) %>%
  select(starts_with('MSOA11'))

msoa11_names <- read_csv("https://visual.parliament.uk/msoanames/static/MSOA-Names-Latest.csv",
  col_types = cols_only(
    msoa11cd = col_character(),
    msoa11hclnm = col_character(),
    msoa11hclnmw = col_character()
  )) %>% rename(
    MSOA11Code = msoa11cd,
    MSOA11Name = msoa11hclnm,
    MSOA11NameWelsh = msoa11hclnmw
  ) %>%
  left_join(stupidpupil_wimd_msoa, by='MSOA11Code') %>%
  arrange(MSOA11Code) %>%
  write_fst("inst/extdata/MSOA11Code.fst", compress=100)

#
# Local Authorities
#

read_csv("https://geoportal.statistics.gov.uk/datasets/c02975a3618b46db958369ff7204d1bf_0.csv",
  col_types = cols_only(
    LAD21CD = col_character(),
    LAD21NM = col_character(),
    LAD21NMW = col_character()
  )
) %>%
rename(
  LocalAuthorityCode = LAD21CD,
  LocalAuthorityName = LAD21NM,
  LocalAuthorityNameWelsh = LAD21NMW
) %>%
left_join(postcodes %>% select(LocalAuthorityCode, CountryCode) %>% distinct(), by='LocalAuthorityCode') %>%
write_fst("inst/extdata/LocalAuthorityCode.fst", compress=100)

read_csv("https://geoportal.statistics.gov.uk/datasets/e8e97fbc0444484a942f37d4190d520a_0.csv",
  col_types = cols_only(
    BUA11CD = col_character(),
    BUA11NM = col_character()
  )
) %>%
rename(
  BUA11Code = BUA11CD,
  BUA11Name = BUA11NM
) %>%
write_fst("inst/extdata/BUA11Code.fst", compress=100)

#postcodes <- NULL
