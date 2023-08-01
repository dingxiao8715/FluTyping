#!/usr/bin/perl
my $list = shift;
my $ori_cluster = shift;
my %hash;
$/ = ">";
open (LIST, $ori_cluster) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split (/\n/, $_);
	my $rep_id = shift @data;
	@{$hash{$rep_id}} = @data;
}
close LIST;
$/ = "\n";
open (LIST, $list) || die;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	my $rep_id = shift @data;
	if (exists $hash{$rep_id}) {
		foreach my $id (@data) {
			if (exists $hash{$id}) {
				foreach my $sub_id (@{$hash{$id}}) {
					push (@{$hash{$rep_id}}, $sub_id);
				}
				delete $hash{$id};
			}
			else {
				die;
			}
		}
	}
	else {
		die;
	}
}
close LIST;
foreach my $rep_id (sort keys %hash) {
	print ">$rep_id\n";
	foreach my $id (@{$hash{$rep_id}}) {
		print "$id\n";
	}
}

