#!/usr/bin/perl
my $list = shift;
my %label;
my %all_data;
open (LIST, $list) || die;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	my $info = shift @data;
	my $value = shift @data;
	my @data_info = split (/\|/, $info);
	my $first_id = shift @data_info;
	my $second_id = shift @data_info;
	$label{$first_id} = 1;
	$label{$second_id} = 1;
	if (exists $all_data{$first_id}) {
		push (@{$all_data{$first_id}}, $second_id."|".$value);
	}
	else {
		${$all_data{$first_id}}[0] = $second_id."|".$value;
	}
	if (exists $all_data{$second_id}) {
		push (@{$all_data{$second_id}}, $first_id."|".$value);
	}
	else {
		${$all_data{$second_id}}[0] = $first_id."|".$value;
	}
}
close LIST;
my $count = -1;
foreach my $id (sort keys %label) {
	$count ++;
	print "\t$id";
}
print "\n";
foreach my $ori_id (sort keys %all_data) {
	my %tmp;
	foreach my $info (@{$all_data{$ori_id}}) {
		my @data_info = split (/\|/, $info);
		my $id = shift @data_info;
		my $value = shift @data_info;
		$tmp{$id} = $value;
	}
	print "$ori_id";
	foreach my $id (sort keys %label) {
		if (@{$all_data{$ori_id}} == $count) {
			if (exists $tmp{$id}) {
				print "\t$tmp{$id}";
			}
			else {
				if ($id eq $ori_id) {
					print "\t0";
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
	print "\n";
}


	
