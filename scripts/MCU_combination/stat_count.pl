#!/usr/bin/perl
my $list = shift;
my %hash;
$/ = ">";
open (LIST, $list) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split (/\n/, $_);
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
$/ = "\n";
my $count = 0;
foreach my $id (sort keys %hash) {
	if ($hash{$id} > 2) {
		die "The result was not correct.\n";
	}
	$count ++;
}
print "$count";
