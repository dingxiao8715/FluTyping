#!/usr/bin/perl
my $list = shift;
my $thre = shift;
my $list_line = 0;
my $index_p = 0;
open (LIST, $list) || die;
while (my $line = <LIST>) {
	chomp $line;
	$list_line ++;
	if ($list_line % $thre == 1)  {
		$index_p ++;
		open (TMP, ">list_p$index_p") || die;
		print TMP "$line\n";
	}
	else {
		print TMP "$line\n";
	}
}
close LIST;
print "$index_p";
