# Establish the geographic mapping

## File used
### continents.csv
### countries.csv
### adjacent_countries_headers_ISO.csv
### cities.csv
### subdivisions.csv

## Create Constraints as an alternative since it implicitly creates an Index

CREATE CONSTRAINT ON (ctn:continents) ASSERT ctn.continent_id IS UNIQUE
CREATE CONSTRAINT ON (ctr:countries) ASSERT ctr.countries_id IS UNIQUE

## Import continents

LOAD CSV WITH HEADERS FROM "file:/continents.csv" AS row
CREATE (ctn:continents{continent_name:row.continent_name})
SET ctn = row,
ctn.continent_id = toInteger(row.continent_id)

## Import countries

LOAD CSV WITH HEADERS FROM "file:/countries.csv" AS row
CREATE (ctr:countries {alpha_2:row.alpha_2, alpha_3:row.alpha_3, country_name:row.country_name,part_of_continent:row.part_of_continent_name})
SET ctr = row,
ctr.country_id = toInteger(row.country_id), ctr.continent_id = toInteger(row.continent_id)

## Create relationship between continents and countries

MATCH (cnt:continents),(ctr:countries)
WHERE ctr.continent_id = cnt.continent_id
CREATE (ctr)-[:IS_PART_OF]->(cnt)

## Import country adjacency records and estblish relationships

LOAD CSV WITH HEADERS FROM 'file:/adjacent_countries_headers_ISO.csv' AS row
MATCH (ctr1:countries{alpha_3: row.bdr_ctr_1_a3}),(ctr2:countries{alpha_3:row.bdr_ctr_2_a3})
MERGE (ctr1)-[adj:BORDERS]-(ctr2)
RETURN ctr1.alpha_3,ctr2.alpha_3

## Import cities and establish relationships to countries

LOAD CSV WITH HEADERS FROM 'file:/cities.csv' AS row
CREATE(cts:cities {alpha_2:row.alpha_2, subdivision_code:row.subdivision_code, city_code:row.city_code, city_latin_name:row.city_latin_name, lat_ns:row.lat_ns, long_ew:row.long_ew})
SET cts = row,
cts.city_id=toInteger(row.city_id), cts.airport=toInteger(row.airport), cts.rail=toInteger(row.rail), cts.port=toInteger(row.port), cts.lat=toInteger(row.lat), cts.long=toInteger(row.long)


MATCH (ctr:countries), (cts:cities)
WHERE ctr.alpha_2 = cts.alpha_2
CREATE (cts)-[cn:IS_CITY_IN]->(ctr)

## Import subdivisions and establish relationships with countries and cities

LOAD CSV WITH HEADERS FROM 'file:/subdivisions.csv' AS row
CREATE (sdv:subdivision {subdivision_compound_code:row.subdivision_compound.code, alpha_2:row.alpha_2, subdivision_code:row.subdivision_code, subdivsion_name:row.subdivision_name, subdivision_type:row.subdivision_type})
SET sdv = row,
sdv.subdivision_id = toINTEGER(row.subdivision_id)

MATCH (sdv:subdivision), (ctr:countries)
WHERE sdv.alpha_2 = ctr.alpha_2
CREATE (sdv)-[sd:IS_DIVISION_OF]->(ctr)

MATCH (sdv:subdivision), (cts:cities)
WHERE sdv.subdivision_code = cts.subdivision_code
CREATE (cts)-[cdv:IS_CITY_IN_SDV]->(sdv)
