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
    HealthOrgCode = oshlthau, # Good enough name for now…
    Latitude = lat,
    Longitude = long
  )


print("Writing…")


postcodes %>% 
  select(Postcode, CountryCode, HealthOrgCode, LocalAuthorityCode, OA11Code, BUASD11Code, Latitude, Longitude) %>%
  arrange(desc(CountryCode), HealthOrgCode, LocalAuthorityCode, Postcode) %>%
  write_fst("inst/extdata/Postcode.fst", compress=100)


postcodes %>%
  select(OA11Code, OA11RuralUrbanClassification, LSOA11Code) %>% distinct() %>%
  arrange(desc(OA11Code), LSOA11Code) %>%
  write_fst("inst/extdata/OA11Code.fst", compress=100)

postcodes %>%
  select(LSOA11Code, MSOA11Code) %>% distinct() %>%
  arrange(desc(LSOA11Code), MSOA11Code) %>%
  write_fst("inst/extdata/LSOA11Code.fst", compress=100)


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
  write_fst("inst/extdata/MSOA11Code.fst", compress=100)


postcodes %>%
  select(BUASD11Code, BUA11Code) %>% distinct() %>%
  arrange(desc(BUA11Code), BUASD11Code) %>%
  write_fst("inst/extdata/BUASD11Code.fst", compress=100)

postcodes <- NULL


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
write_fst("inst/extdata/LocalAuthorityCode.fst", compress=100)