#!/usr/bin/perl
my $list = shift;
my %hash;
open (LIST, $list) || die;
while (<LIST>) {
	chomp;
	my @data = split (/\s+/, $_);
	shift @data;
	foreach my $id (@data) {
		if (exists $hash{$id}) {
			$hash{$id} ++;
		}
		else {
			$hash{$id} = 1;
		}
	}
}
close LIST;
my $count = 0;
foreach (sort {$hash{$b} <=> $hash{$a} }keys %hash) {
	if ($hash{$_} > 1) {
		die "Clusters have same isolates\n";
	}
	else {
		next;
	}
}
