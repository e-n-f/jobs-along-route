jobs-along-route
================

Download LODES for california:

```
curl -L -O https://lehd.ces.census.gov/data/lodes/LODES7/ca/rac/ca_rac_S000_JT00_2015.csv.gz
curl -L -O https://lehd.ces.census.gov/data/lodes/LODES7/ca/wac/ca_wac_S000_JT00_2015.csv.gz
```

Download Census 2000 preliminary data, as the easiest source
for block centroids:

```
curl -L -O https://www2.census.gov/census_2010/01-Redistricting_File--PL_94-171/California/ca2010.pl.zip
```

Join block centroids to home and work locations:

```
./join-blocks > joined
```

Calculate and plot

```
cat ironhorse.json | ./plot > out.ps
ps2pdf out.ps
gs -sDEVICE=png16m -sOutputFile=out.png -dBATCH -dNOPAUSE -r150x150 -dGraphicsAlphaBits=4 out.pdf
```
