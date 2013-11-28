#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: csv.pl
#
#        USAGE: ./csv.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: wba (wolf), wbiker@gmx.at
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 27/11/13 20:27:13
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use feature qw(say);
use autodie;
use Text::CSV;
use DateTime;

my $csv = Text::CSV->new;

open(my $fh, "<", '/home/wolf/Downloads/Fahrradkilometer - Sheet1.csv');
my @rows;
my $cnt = 0;
my $last_it_date;
my $last_it_km;
while(my $row = $csv->getline($fh)) {
	next if $row->[0] eq 'Datum';
	# [0] date
	# [1] kilometer
	# [2] days between last date entry
	# [3] kilometer between last kilometer entry
	# days between last date
	my $new_entry = [];
	$new_entry->[0] = $row->[0];
	$new_entry->[1] = $row->[1];
	if(0 < $cnt) {
		$new_entry->[2] = get_days_delta($last_it_date, $row->[0]);
		$new_entry->[3] = get_km_delta($last_it_km, $row->[1]);
		$new_entry->[4] = get_km_per_days($new_entry->[2], $new_entry->[3]);
	}
	else {
		$new_entry->[2] = 0;
		$new_entry->[3] = 0;
        $new_entry->[4] = 0;
	}
	
    push(@rows, $new_entry);
    $last_it_date = $row->[0];
    $last_it_km = $row->[1];
    $cnt++;
}
close($fh);

printf("%-11s %5s %10s %9s %6s\n", "Date", "Km", "deltaDate", "deltaKM", 'km/day');
my $format = "%-11s %5s %10s %9s %6.1f\n";
printf($format, $_->[0], $_->[1], $_->[2], $_->[3], $_->[4]) for @rows;


# ------------------------------------------------------------------------
sub get_km_per_days {
	my $days = shift;
	my $km = shift;
	
	return 0 if $days == 0;
	
	return $km / $days;
}

sub get_km_delta {
	my $last_km = shift;
	my $cur_km = shift;
	
	return '' unless 0 <= $last_km;
	return '' unless 0 <= $cur_km;
	
	return $cur_km - $last_km;
}

sub get_days_delta {
	my $last_date = shift;
	my $cur_date = shift;
	
	return '' unless $last_date;
	return '' unless $cur_date;
	
	my $dt_last;
	my $dt_cur;
	
	if($last_date =~ /(\d{2})\.(\d{2})\.(\d{4})/) {
		my $day = $1;
		my $mon = $2;
		my $year = $3;
			
		$dt_last = DateTime->new(
			day => $day,
			month => $mon,
			year => $year,
			);
		
		if($cur_date =~ /(\d{2})\.(\d{2})\.(\d{4})/) {
			$day = $1;
			$mon = $2;
			$year = $3;
		
			$dt_cur = DateTime->new(
				day => $day,
				month => $mon,
				year => $year,
				);	
		}
		else {
			return "unknown";
		}
	}
	else {
		return "unknown";
	}
	
	# here both dates should be exists
	my $dur = $dt_cur->delta_days($dt_last);
	
	return $dur->delta_days;
}
