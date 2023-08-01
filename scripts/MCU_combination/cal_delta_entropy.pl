#!/usr/bin/perl
use Math::Complex;
my $fa = shift;
my $thre_computer = shift;
my %accepted_words = ("a" => "nucl", "t" => "nucl", "c" => "nucl", "g" => "nucl");

my %all_seqs;
my $len = 0;
my $diff = 0;
$/ = ">";
open (FA, $fa) || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $title = shift @data;
	my @data_title = split (/\|/, $title);
	my $id = shift @data_title;
	my $clade = shift @data_title;
	my $seq = lc (join ("", @data));
	if (exists $all_seqs{$clade}) {
		push (@{$all_seqs{$clade}}, $seq);
	}
	else {
		${$all_seqs{$clade}}[0] = $seq;
	}
	if ($len == length $seq) {
		next;
	}
	else {
		$len = length $seq;
		$diff ++;
	}
}
close FA;
$/ = "\n";
if ($diff == 1) {
	my $k = 0; 
	my %site_info;
	while ($k < $len) {
		@{$site_info{$k}} = (0, 0, 0);
		foreach my $clade (keys %all_seqs) {
			foreach my $seq (@{$all_seqs{$clade}}) {
				my $word = substr ($seq, $k, 1);
				if (exists $accepted_words{$word}) {
					${$site_info{$k}}[0] ++;
					if ($clade eq "first") {
						${$site_info{$k}}[1] ++;
					}
					else {
						${$site_info{$k}}[2] ++;
					}
					push (@{$site_info{$k}}, $word."|".$clade);
				}
				else {
					next;
				}
			}
		}
		$k ++;
	}
	my $sum = my $change = 0;
	foreach my $site (sort {$a <=> $b} keys %site_info) {
		my $entropy_site_all = my $entropy_site_first = my $entropy_site_second = 0;
		if ((${$site_info{$site}}[1] > $thre_computer) && (${$site_info{$site}}[2] > $thre_computer)) {
			$sum ++;
			my %stat_all;
			my %stat_first;
			my %stat_second;
			for my $dim (3 .. $#{$site_info{$site}}) {
				my @info = split (/\|/, ${$site_info{$site}}[$dim]);
				my $word = shift @info;
				my $clade = shift @info;
				if (exists $stat_all{$word}) {
					$stat_all{$word} ++;
				}
				else {
					$stat_all{$word} = 1;
				}
				if ($clade eq "first") {
					if (exists $stat_first{$word}) {
						$stat_first{$word} ++;
					}
					else {
						$stat_first{$word} = 1;
					}
				}
				else {
					if (exists $stat_second{$word}) {
						$stat_second{$word} ++;
					}
					else {
						$stat_second{$word} = 1;
					}
				}
			}
			foreach my $nucl (sort {$stat_all{$a} <=> $stat_all{$b}} keys %stat_all) {
                        	my $por = $stat_all{$nucl}/${$site_info{$site}}[0];
                        	$entropy_site_all += (-1 * $por * logn ($por, 2));
                	}
			foreach my $nucl (sort {$stat_first{$a} <=> $stat_first{$b}} keys %stat_first) {
				my $por = $stat_first{$nucl}/${$site_info{$site}}[1];
				$entropy_site_first += (-1 * $por * logn ($por, 2));
			}
			foreach my $nucl (sort {$stat_second{$a} <=> $stat_second{$b}} keys %stat_second) {
				my $por = $stat_second{$nucl}/${$site_info{$site}}[2];
				$entropy_site_second += (-1 * $por * logn ($por, 2));
			}
			$change += ($entropy_site_all - $entropy_site_first) + ($entropy_site_all - $entropy_site_second);
		}
		else {
			next;
		}
	}
	my $nor_change = sprintf ("%.4f", $change/$sum);
	print "$nor_change";
}
else {
	die "This is not an alignment.\n";
}
