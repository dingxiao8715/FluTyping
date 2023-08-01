#!/usr/bin/perl
my $fa = shift;
my $list_info = shift;
my $list_log = shift;
my $thre_sim = shift;
my $thre_coe = shift;
my $circle = shift;

my %all_seqs;
$/ = ">";
open (FA, $fa) || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $id = shift @data;
	my $seq = lc (join ("", @data));
	$all_seqs{$id} = $seq;
}
close FA;
$/ = "\n";

my %id2time;
open (LIST, $list_info) || die;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	my $id = shift @data;
	shift @data;
	my $date = shift @data;
	my @data_date = split (/-/, $date);
	my $year = shift @data_date;
	my $month = shift @data_date;
	if ($month eq "") {
		$month = 0;
	}
	else {
		if ($month =~ /^0/) {
			$month =~ s/0//g;
			$month -= 1;
			$month /= 12;
		}
		else {
			$month -= 1;
			$month /= 12;
		}
	}
	$time = $year + $month;
	$id2time{$id} = $time;
}
close LIST;

my %all_data;
open (LIST, $list_log) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	my $clade = shift @data;
	my $words = shift @data;
	for my $k (0 .. $#data) {
		$words = $words."-".$data[$k];
	}
	if (exists $all_data{$clade}) {
		push (@{$all_data{$clade}}, $words);
	}
	else {
		${$all_data{$clade}}[0] = $words;
	}
}
close LIST;
my $combined_count = 0;
open (OUT_FA, ">combined_seqs_r$circle.fasta") || die;
open (OUT_INFO, ">combined_info_r$circle.xls") || die;
foreach my $clade (sort keys %all_data) {
	if (@{$all_data{$clade}} == 1) {
		my @data = split (/-/, ${$all_data{$clade}}[0]);
		my $words = shift @data;
		my $sim = shift @data;
		my $coe = shift @data;
		my $coss_s = shift @data;
		my @data_words = split (/\|/, $words);
		my $first = shift @data_words;
		my $second = shift @data_words;
		if ((exists $id2time{$first}) && (exists $id2time{$second}) && (exists $all_seqs{$first}) && (exists $all_seqs{$second})) {
			if ($coe eq "NA") {
				if ($sim > $thre_sim) {
					$combined_count ++;
					if ($id2time{$first} < $id2time{$second}) {
						print OUT_FA ">$first\n$all_seqs{$first}\n";
						print OUT_INFO "$first\t$second\n";
					}
					else {
						print OUT_FA ">$second\n$all_seqs{$second}\n";
						print OUT_INFO "$second\t$first\n";
					}
				}
				else {
					print OUT_FA ">$first\n$all_seqs{$first}\n>$second\n$all_seqs{$second}\n";
				}
			}
			else {
				if ((($sim > $thre_sim) && ($coe < $thre_coe)) || ((($sim <= $thre) || ($coe >= $thre_coe)) && ($coss_s == 0))) {
					$combined_count ++;
					if ($id2time{$first} < $id2time{$second}) {
						print OUT_FA ">$first\n$all_seqs{$first}\n";
						print OUT_INFO "$first\t$second\n";
					}
					else {
						print OUT_FA ">$second\n$all_seqs{$second}\n";
						print OUT_INFO "$second\t$first\n";
					}
				}
				else {
					print OUT_FA ">$first\n$all_seqs{$first}\n>$second\n$all_seqs{$second}\n";
				}
			}
		}
		else {
			die;
		}
	}
	else {
		my %connection;
		my %non_connection;
		foreach my $line (@{$all_data{$clade}}) {
			my @data = split (/-/, $line);
			my $words = shift @data;
			my $sim = shift @data;
			my $coe = shift @data;
			my $coss = shift @data;
			my $coss_s = shift @data;
			my @data_words = split (/\|/, $words);
			my $first = shift @data_words;
			my $second = shift @data_words;
			if ((exists $id2time{$first}) && (exists $id2time{$second}) && (exists $all_seqs{$first}) && (exists $all_seqs{$second})) {
				if ($coe eq "NA") {
					if ($sim > $thre_sim) {
						$combined_count ++;
						if (!%connection) {
							$connection{$words} = 1;
						}
						else {
							my $count = 0;
							foreach my $connect (keys %connection) {
								my %tmp;
								my @data_connect = split (/\|/, $connect);
								foreach my $id (@data_connect) {
									$tmp{$id} = 1;
								}
								if ((exists $tmp{$first}) || (exists $tmp{$second})) {
									$connection{$connect."|".$words} = 1;
									delete ($connection{$connect});
									$count ++;
								}
								else {
									$connection{$words} = 1;
								}
							}
							if ($count > 0) {
								delete ($connection{$words});
							}
						}
					}
					else {
						$non_connection{$words} = 1;
					}
				}
				else {
					if ((($sim > $thre_sim) && ($coe < $thre_coe)) || ((($sim <= $thre) || ($coe >= $thre_coe)) && ($coss_s == 0))) {
						$combined_count ++;
						if (!%connection) {
							$connection{$words} = 1;
						}
						else {
							my $count = 0;
							foreach my $connect (keys %connection) {
								my %tmp;
								my @data_connect = split (/\|/, $connect);
								foreach my $id (@data_connect) {
									$tmp{$id} = 1;
								}
								if ((exists $tmp{$first}) || (exists $tmp{$second})) {
									$connection{$connect."|".$words} = 1;
									delete ($connection{$connect});
									$count ++;
								}
								else {
									$connection{$words} = 1;
								}
								if ($count > 0) {
									delete ($connection{$words});
								}
							}
						}
					}
					else {
						$non_connection{$words} = 1;
					}
				 }
			}
			else {
				die;
			}
		}
		my %used;
		foreach my $connect (keys %connection) {
			if (exists $used{$connect}) {
				next;
			}
			else {
				$used{$connect} = 1;
				foreach my $com_connect (keys %connection) {
					if (exists $used{$com_connect}) {
						next;
					}
					else {
						my %tmp;
						my @data_connect = split (/\|/, $connect);
						foreach my $id (@data_connect) {
							$tmp{$id} = 1;
						}
						my @data_connect = split (/\|/, $com_connect);
						foreach my $id (@data_connect) {
							if (exists $tmp{$id}) {
								$connection{$connect."|".$com_connect} = 1;
								delete ($connection{$com_connect});
								delete ($connection{$connect});
								$used{$com_connect} = 1;
								last;
							}
							else {
								next;
							}
						}
					}
				}
			}
		}
		my %used;
		foreach my $connect (keys %connection) {
			my %sort_time;
			my @data_connect = split (/\|/, $connect);
			foreach my $id (@data_connect) {
				$sort_time{$id} = $id2time{$id};
				$used{$id} = 1;
			}
			my $earliest;
			foreach my $id (sort {$sort_time{$b} <=> $sort_time{$a}} keys %sort_time) {
				$earliest = $id;
			}
			print OUT_FA ">$earliest\n$all_seqs{$earliest}\n";
			print OUT_INFO "$earliest";
			foreach my $id (keys %sort_time) {
				if ($id eq $earliest) {
					next;
				}
				else {
					print OUT_INFO "\t$id";
				}
			}
			print OUT_INFO "\n";
		}
		my %nr_id;
		foreach my $connect (keys %non_connection) {
			my @data_connect = split (/\|/, $connect);
			foreach my $id (@data_connect) {
				if (exists $used{$id}) {
					next;
				}
				else {
					$nr_id{$id} = 1;
				}
			}
		}
		foreach my $id (keys %nr_id) {
			print OUT_FA ">$id\n$all_seqs{$id}\n";
		}
	}
}
close OUT_FA;
close OUT_INFO;
print "$combined_count";
					



								





