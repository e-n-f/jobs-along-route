jobs-along-route
================

In the style of http://caltrain-hsr.blogspot.com/2013/10/census-driven-service-planning.html

Download LODES for California:

```
curl -L -O https://lehd.ces.census.gov/data/lodes/LODES7/ca/wac/ca_wac_S000_JT01_2015.csv.gz
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
gs -sDEVICE=png16m -sOutputFile=out.png -dBATCH -dNOPAUSE -r150x150 -dGraphicsAlphaBits=4 -dTextAlphaBits=4 out.pdf
```
