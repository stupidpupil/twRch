

## Examples

### All Welsh LSOAs with boundaries 


```R

welsh_lsoas <- all_codes_with_fields("LSOA11Code", "CountryName") %>%
  filter(CountryName == "Wales") %>%
  add_fields_based_on_some_code(fields="LSOA11BoundariesGeneralisedClippedWKT")

library(sf)

welsh_lsoas <- welsh_lsoas %>% 
  st_set_geometry(st_as_sfc(welsh_lsoas$LSOA11BoundariesGeneralisedClippedWKT)) %>% 
  select(-LSOA11BoundariesGeneralisedClippedWKT)

library(ggplot2)

ggplot(welsh_lsoas) + geom_sf()

```


## See also

- https://github.com/francisbarton/jogger/
