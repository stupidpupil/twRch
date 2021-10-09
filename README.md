

## Examples

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
