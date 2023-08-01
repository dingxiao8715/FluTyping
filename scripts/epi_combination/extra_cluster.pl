#!/usr/bin/perl
my $list = shift;
$/ = ">Cluster";
open (LIST, $list) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split (/\n/, $_);
	shift @data;
	if (@data == 1) {
		my $line = shift @data;
		my @data_line = split (/\s+/, $line);
		shift @data_line; shift @data_line;
		my $id = shift @data_line;
		shift @data_line;
		my $identity = shift @data_line;
		$id =~ s/>//g;
		$id =~ s/\...//g;
		print ">$id\n$id\n";
	}
	else {
		my $all_ids;
		my $rep_id;
		foreach my $line (@data) {
			my @data_line = split (/\s+/, $line);
			shift @data_line; shift @data_line;
			my $id = shift @data_line;
			my $symbol = shift @data_line;
			my $identity = shift @data_line;
			$id =~ s/>//g;
			$id =~ s/\...//g;
			if ($symbol eq "*") {
				$rep_id = $id;
			}
			else {
				$all_ids = $all_ids."|".$id;
			}
		}
		print ">$rep_id\n$rep_id\n";
		my @data_all_ids = split (/\|/, $all_ids);
		shift @data_all_ids;
		foreach my $id (@data_all_ids) {
			print "$id\n";
		}
	}
}
close LIST;
$/ = "\n";
