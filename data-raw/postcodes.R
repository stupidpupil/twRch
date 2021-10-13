library(fst)
library(readr)
library(dplyr)
library(magrittr)
library(stringr)
library(sf)
library(readODS)

if(!file.exists("data-raw/postcodes.csv")){
  download.file(
    url = "https://geoportal.statistics.gov.uk/datasets/75edec484c5d49bcadd4893c0ebca0ff_0.csv",
    destfile = "data-raw/postcodes.csv"
    )
}

if(!file.exists("data-raw/code_history_database.zip")){
  download.file(
    url = "https://www.arcgis.com/sharing/rest/content/items/8e8f12e8fa5d476e829b105103ada83c/data",
    destfile = "data-raw/code_history_database.zip"
    )
}

print("Reading…")
postcodes <- read_csv(
  "data-raw/postcodes.csv",
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
    osward = col_character(),
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
    ElectoralWardCode = osward,
    WestminsterParliamentConstituencyCode = pcon,
    HealthBoardONSCode = oshlthau, # Good enough name for now…
    PostcodeLatitude = lat,
    PostcodeLongitude = long
  )

equivalents <- read_csv(unz("data-raw/code_history_database.zip", "Equivalents_V2.csv"),
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
  filter(CountryCode != 'N92000002') %>% # Northern Ireland's postcodes have painful licensing
  mutate(PostcodeCentroidWKT = paste0("SRID=4326;POINT(", PostcodeLongitude, " ", PostcodeLatitude,")")) %>%
  select(Postcode, CountryCode, HealthBoardONSCode, LocalAuthorityCode, ElectoralWardCode, OA11Code, BUASD11Code, BUA11Code, PostcodeCentroidWKT) %>%
  arrange(desc(CountryCode), HealthBoardONSCode, LocalAuthorityCode, Postcode) %>%
  write_fst("inst/extdata/Postcode.fst", compress=100)


postcodes %>% select(HealthBoardONSCode) %>% distinct() %>%
  left_join(equivalents %>% mutate(
    HealthBoardONSCode = GEOGCD, 
    HealthBoardOrgCode = if_else(is.na(GEOGCDO), GEOGCDWG, GEOGCDO) # HACK for Cwm Taf Morgannwg & Swansea Bay
    ) %>% select(starts_with('HealthBoard'))) %>%
  write_fst("inst/extdata/HealthBoardONSCode.fst")


#
# Output Areas
#

oa_to_senedd_constituency_code <- read_csv("https://opendata.arcgis.com/datasets/c1e0c4c13c6a4484aa3d7216ead56785_0.csv") %>%
  mutate(
    OA11Code = OA11CD,
    SeneddConstituencyCode = NAWC17CD,
    SeneddConstituencyName = NAWC17NM,
    SeneddRegionCode = NAWER17CD,
    SeneddRegionName = NAWER17NM
  )


postcodes %>%
  filter(!is.na(OA11Code)) %>%
  select(OA11Code, OA11RuralUrbanClassification, LSOA11Code) %>% distinct() %>%
  left_join(oa_to_senedd_constituency_code %>% select(OA11Code, SeneddConstituencyCode), by='OA11Code') %>%
  arrange(desc(OA11Code), LSOA11Code) %>%
  write_fst("inst/extdata/OA11Code.fst", compress=100)

senedd_constituency_boundaries <- st_read("https://opendata.arcgis.com/datasets/961ca1d4611e4c9ebefee0144c1497f0_0.geojson") %>%
  mutate(
    SeneddConstituencyCode = nawc18cd,
    SeneddConstituencyBoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(SeneddConstituencyCode, SeneddConstituencyBoundariesGeneralisedClippedWKT)

senedd_region_boundaries <- st_read("https://opendata.arcgis.com/datasets/976c4b73cf034a9d9355ebc04b856ff2_0.geojson") %>%
  mutate(
    SeneddRegionCode = nawer18cd,
    SeneddRegionBoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(SeneddRegionCode, SeneddRegionBoundariesGeneralisedClippedWKT)

oa_to_senedd_constituency_code %>%
  select(SeneddConstituencyCode, SeneddConstituencyName, SeneddRegionCode) %>%
  distinct() %>%
  left_join(senedd_constituency_boundaries, by='SeneddConstituencyCode') %>%
  write_fst("inst/extdata/SeneddConstituencyCode.fst", compress=100)

oa_to_senedd_constituency_code %>%
  select(SeneddRegionCode, SeneddRegionName) %>%
  distinct() %>%
  left_join(senedd_region_boundaries, by='SeneddRegionCode') %>%
  write_fst("inst/extdata/SeneddRegionCode.fst", compress=100)

best_fit_lsoa_admin <- read_csv("https://opendata.arcgis.com/datasets/6408273b5aff4e01ab540a1b1b95b7a7_0.csv") %>%
  mutate(
    LSOA11Code = LSOA11CD,
    ElectoralWardCode = WD20CD,
    LocalAuthorityCode = LAD20CD
  ) %>% select(LSOA11Code, ElectoralWardCode, LocalAuthorityCode)

if(!file.exists("data-raw/lsoa_stats_wales_lookup.ods")){
  download.file(
    url = "https://statswales.gov.wales/Download/File?fileId=570",
    destfile = "data-raw/lsoa_stats_wales_lookup.ods"
    )
}

lsoa_to_senedd_constituency_code <- read_ods("data-raw/lsoa_stats_wales_lookup.ods", sheet="Geography_Lookup") %>% 
  rename(
    LSOA11Code = `Lower Layer Super Output Area (LSOA) Code`, 
    SeneddConstituencyCode = `Constituency Area (CA) Code`) %>% 
  select(LSOA11Code, SeneddConstituencyCode)

lsoa_boundaries <- st_read("https://opendata.arcgis.com/datasets/8bbadffa6ddc493a94078c195a1e293b_0.geojson") %>%
  mutate(
    LSOA11Code = LSOA11CD,
    LSOA11BoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(LSOA11Code, LSOA11BoundariesGeneralisedClippedWKT)

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
  select(LSOA11Code, CountryCode, MSOA11Code) %>% distinct() %>%
  left_join(mysoc_uk_imd_w, by='LSOA11Code') %>%
  left_join(best_fit_lsoa_admin, by='LSOA11Code') %>%
  left_join(lsoa_boundaries, by='LSOA11Code') %>%
  left_join(lsoa_to_senedd_constituency_code, by='LSOA11Code') %>%
  arrange(desc(LSOA11Code), MSOA11Code) %>%
  write_fst("inst/extdata/LSOA11Code.fst", compress=100)

stupidpupil_wimd_msoa <- read_csv("https://raw.githubusercontent.com/stupidpupil/wimd_msoa/main/output/wimd_msoa.csv") %>%
  mutate(
    MSOA11Code = `MSOA Code`,
    MSOA11StpPplWIMD19Rank = `Pseudo-WIMD 2019 rank`
    ) %>%
  select(starts_with('MSOA11'))

msoa11_boundaries <- st_read("https://opendata.arcgis.com/datasets/abfccdf1071c43dd981a49eb7da13d2b_0.geojson") %>%
  mutate(
    MSOA11Code = MSOA11CD,
    MSOA11BoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(MSOA11Code, MSOA11BoundariesGeneralisedClippedWKT)

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
  left_join(msoa11_boundaries, by="MSOA11Code") %>%
  left_join(postcodes %>% filter(!is.na(MSOA11Code)) %>% select(MSOA11Code, CountryCode) %>% distinct(), by='MSOA11Code') %>%
  arrange(MSOA11Code) %>%
  write_fst("inst/extdata/MSOA11Code.fst", compress=100)

#
# Local Authorities
#

la_boundaries <- st_read("https://opendata.arcgis.com/datasets/4f47ca74ff0a470cb4128905a38e1b35_0.geojson") %>%
  mutate(
    LocalAuthorityCode = LAD21CD,
    LocalAuthorityBoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(LocalAuthorityCode, LocalAuthorityBoundariesGeneralisedClippedWKT)

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
left_join(postcodes %>% select(LocalAuthorityCode, HealthBoardONSCode, CountryCode) %>% distinct(), by='LocalAuthorityCode') %>%
left_join(la_boundaries, by='LocalAuthorityCode') %>%
write_fst("inst/extdata/LocalAuthorityCode.fst", compress=100)

#
# Constituencies
#

westminster_parliament_constituency_boundaries <- st_read("https://opendata.arcgis.com/datasets/8533474c4a474990a80e7c932f54fa46_0.geojson") %>%
  mutate(
    WestminsterParliamentConstituencyCode = PCON20CD,
    WestminsterParliamentConstituencyName = PCON20NM,
    WestminsterParliamentConstituencyBoundariesGeneralisedClippedWKT = st_as_text(geometry, EWKT=TRUE)) %>% 
  st_drop_geometry() %>%
  select(
    WestminsterParliamentConstituencyCode,
    WestminsterParliamentConstituencyName,
    WestminsterParliamentConstituencyBoundariesGeneralisedClippedWKT,
    ) %>%
  left_join(postcodes %>% select(WestminsterParliamentConstituencyCode, CountryCode) %>% distinct(), 
    by='WestminsterParliamentConstituencyCode') %>%
  write_fst("inst/extdata/WestminsterParliamentConstituencyCode.fst", compress=100)

#
# Wards
#

wards <- read_csv("https://opendata.arcgis.com/datasets/063ccaa43b9a4f4281b3ad803c1ed2e8_0.csv",
  col_types = cols_only(
    WD20CD = col_character(),
    WD20NM = col_character(),
    LAD20CD = col_character()
  )) %>% distinct()

wards %>%
  rename(
    ElectoralWardCode = WD20CD,
    ElectoralWardName = WD20NM,
    LocalAuthorityCode = LAD20CD
  ) %>%
  write_fst("inst/extdata/ElectoralWardCode.fst", compress=100)

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
