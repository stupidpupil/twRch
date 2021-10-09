
A hacked together toy project to make some UK geography reference data, mostly from the ONS, easily queryable from R.

Uses *[fst](https://www.fstpackage.org/)* for fast reads of data.

There are probably serious issues with respecting hierarchies correctly.

## Features and Antifeatures

* Local postcode lookup (excluding Northern Ireland)
* Includes boundaries for Countries, Local Authorities, MSOAs and LSOAs (Generalised and Clipped only)
* All coordinates in EPSG:4326/WGS84 (rather than EPSG:27700/OSGB 1936)
* At least 60 megabytes installed

## Examples

### Details for a postcode

```R
tibble(MyPostcode = "CF10 3NQ") %>% 
  add_fields_based_on_postcode(prefix="My", fields=c(
    "ElectoralWardName", 
    "LocalAuthorityName", "LocalAuthorityNameWelsh", 
    "CountryName", "CountryNameWelsh", 
    "MSOA11Name", "MSOA11NameWelsh"))
```

### All Welsh LSOAs with boundaries 


```R

welsh_lsoas <- all_codes_with_fields("LSOA11Code", "CountryName", "LSOA11BoundariesGeneralisedClippedWKT") %>%
  filter(CountryName == "Wales")

library(sf)

welsh_lsoas <- welsh_lsoas %>% 
  convert_wkt_to_geometry()

library(ggplot2)

ggplot(welsh_lsoas) + geom_sf()

```


## See also

- https://github.com/francisbarton/jogger/
- https://github.com/Chrisjb/rgeoportal
