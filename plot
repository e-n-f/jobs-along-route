#!/usr/bin/perl

$pi = 4 * atan2(1, 1);
$foot = .00000274;
$bucket = 2 * 5280 * $foot;
$step = 100;

while (<STDIN>) {
	$geom .= $_;
}

$geom =~ s/\s//g;
$geom =~ s/.*"coordinates":\[//;

while ($geom =~ s/^\[([0-9-.]+),([0-9-.]+)\],*//) {
	push @seglat, $2;
	push @seglon, $1;
}

$rat = cos($seglat[0] * $pi / 180);
$seglen = 0;

for ($i = 0; $i < $#seglat; $i++) {
	$latd = $seglat[$i + 1] - $seglat[$i];
	$lond = ($seglon[$i + 1] - $seglon[$i]) * $rat;
	$d = sqrt($latd * $latd + $lond * $lond) / $foot;
	$len[$i] = $d;
	$seglen += $d;
}
print "$#seglat segs\n";

open(IN, "joined");
while (<IN>) {
	chomp;
	($block, $lat, $lon, $homes, $jobs) = split(/ /, $_);

	$lat{$block} = $lat;
	$lon{$block} = $lon;
	$homes{$block} = $homes;
	$jobs{$block} = $jobs;

	$ilat = int($lat / $bucket);
	$ilon = int($lon / $bucket);

	push @{$index{"$ilat,$ilon"}}, $block;
}
close(IN);

for ($i = 0; $i < $#seglat; $i++) {
	for ($p = 0; $p < $len[$i]; $p += $step) {
		$lat = $seglat[$i] * (1 - ($p / $len[$i])) + $seglat[$i] * ($p / $len[$i]);
		$lon = $seglon[$i] * (1 - ($p / $len[$i])) + $seglon[$i] * ($p / $len[$i]);
	}
}
