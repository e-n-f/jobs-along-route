#!/usr/bin/perl

$pi = 4 * atan2(1, 1);
$foot = .00000274;
$bucket = 2 * 5280 * $foot;
$step = 200;

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

$along = 0;
@wheres = ();
%jobs_here = ();
%homes_here = ();

for ($i = 0; $i < $#seglat; $i++) {
	for ($p = 0; $p < $len[$i]; $p += $step) {
		$lat = $seglat[$i] * (1 - ($p / $len[$i])) + $seglat[$i + 1] * ($p / $len[$i]);
		$lon = $seglon[$i] * (1 - ($p / $len[$i])) + $seglon[$i + 1] * ($p / $len[$i]);

		$ilat = int($lat / $bucket);
		$ilon = int($lon / $bucket);

		push @wheres, $along + $p;

		for ($aa = $ilat - 1; $aa <= $ilat + 1; $aa++) {
			for ($oo = $ilon - 2; $oo <= $ilon + 2; $oo++) {
				@b = @{$index{"$aa,$oo"}};

				for ($j = 0; $j <= $#b; $j++) {
					$latd = $lat - $lat{$b[$j]};
					$lond = ($lon - $lon{$b[$j]}) * $rat;
					$d = sqrt($latd * $latd + $lond * $lond) / $foot;

					for $check (1320, 2640, 5280, 2 * 5280) {
						if ($d < $check) {
							$jobs_here{$along + $p}{$check} += $jobs{$b[$j]};
							$homes_here{$along + $p}{$check} += $homes{$b[$j]};
						}
					}
				}
			}
		}

		if (0) {
			printf("%d ", $along + $p);
			for $check (1320, 2640, 5280, 2 * 5280) {
				printf("%d %d ", $jobs_here{$along + $p}{$check}, $homes_here{$along + $p}{$check});
			}
			printf("\n");
		}
	}

	$along += $len[$i];
}

%jobcolors = (
	2 * 5280 => [ 251, 205, 171 ],
	5280 => [ 255, 151, 86 ],
	2640 => [ 252, 103, 1 ],
	1320 => [ 171, 68, 2 ],
);
%homecolors = (
	2 * 5280 => [ 215, 226, 244 ],
	5280 => [ 134, 169, 223 ],
	2640 => [ 54, 115, 195 ],
	1320 => [ 35, 66, 121 ],
);

for $check (2 * 5280, 5280, 2640, 1320) {
	for ($jh = 0; $jh < 2; $jh++) {
		if ($jh == 0) {
			@color = @{$jobcolors{$check}};
		} else {
			@color = @{$homecolors{$check}};
		}

		printf("%f %f %f setrgbcolor\n", $color[0] / 255, $color[1] / 255, $color[2] / 255);

		print "newpath\n";
		print "306 792 moveto\n";

		for $where (@wheres) {
			if ($jh == 0) {
				$x = 306 - $jobs_here{$where}{$check} * 306 / 250000;
			} else {
				$x = 306 + $homes_here{$where}{$check} * 306 / 250000;
			}

			printf("%f %f lineto\n", $x, 792 - 792 * $where / $along);
		}

		print "306 0 lineto closepath fill\n";
	}
}
