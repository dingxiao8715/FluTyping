#!/usr/bin/perl
use Math::Complex;
my $fa = shift;
my $list_tips = shift;
my $list_log = shift;
my $list_combined = shift;
my $list_cluster = shift;
my $thre_seqs_count = shift;
my $thre_computer = shift;

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

my %cluster;
open (LIST, $list_cluster) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split (/\n/, $_);
	my $rep_id = shift @data;
	@{$cluster{$rep_id}} = @data;
}
close LIST;
$/ = "\n";

my %combined_id;
open (LIST, $list_combined) || die;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	foreach my $id (@data) {
		$combined_id{$id} = 1;
	}
}
close LIST;

my %log;
open (LIST, $list_log) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	shift @data;
	my $info = shift @data;
	my @data_info = split (/\|/, $info);
	my $first = shift @data_info;
	my $second = shift @data_info;
	if ((exists $combined_id{$first}) || (exists $combined_id{$second})) {
		next;
	}
	else {
		@{$log{$first."|".$second}} = @data;
		@{$log{$second."|".$first}} = @data;
	}
}
close LIST;

my $number = 1;
print "Clade\tRepresentative_strains\tInter-identity\tEntropy_variation\tSpecific_site_number\n";
open (LIST, $list_tips) || die;
while (<LIST>) {
	chomp;
	my @data = split (/\s+/, $_);
	my $node = shift @data;
	my %clade_seqs;
	foreach my $id (@data) {
		if ((exists $all_seqs{$id}) && (exists $cluster{$id})) {
			foreach my $cluster_id (@{$cluster{$id}}) {
				if (exists $all_seqs{$cluster_id}) {
					if (exists $clade_seqs{$id}) {
						push (@{$clade_seqs{$id}}, $cluster_id."|".$all_seqs{$cluster_id});
					}
					else {
						${$clade_seqs{$id}}[0] = $cluster_id."|".$all_seqs{$cluster_id};
					}
				}
				else {
					die "$cluster_id\n";
				}
			}
		}
		else {
			die "$id\n";
		}
	}
	my %used_clade;
	foreach my $ori_clade (sort keys %clade_seqs) {
		$used_clade{$ori_clade} = 1;
		foreach my $com_clade (sort keys %clade_seqs) {
			my $ori_count = 0;
			my $com_count = 0;
			if (exists $used_clade{$com_clade}) {
				next;
			}
			else {
				my $forward = $ori_clade."|".$com_clade;
				my $reverse = $com_clade."|".$ori_clade;
				if (exists $log{$forward}) {
					print "clade$number\t$forward";
					for my $dim (0 .. $#{$log{$forward}}) {
						print "\t${$log{$forward}}[$dim]";
					}
					print "\n";
				}
				else {
					if (exists $log{$reverse}) {
						print "clade$number\t$reverse";
						for my $dim (0 .. $#{$log{$reverse}}) {
							print "\t${$log{$reverse}}[$dim]";
						}
						print "\n";
					}
					else {
						open (OUT, ">seqs") || die;
						foreach my $info (@{$clade_seqs{$ori_clade}}) {
							my @data_info = split (/\|/, $info);
							my $id = shift @data_info;
							my $seq = shift @data_info;
							print OUT ">$id|first\n$seq\n";
							$ori_count ++;
						}
						foreach my $info (@{$clade_seqs{$com_clade}}) {
							my @data_info = split (/\|/, $info);
							my $id = shift @data_info;
							my $seq = shift @data_info;
							print OUT ">$id|second\n$seq\n";
							$com_count ++;
						}
						close OUT;
						`mafft --auto --thread -1 --quiet seqs > alignment`;
						my $similarity = `perl cal_similarity_mp.pl alignment`;
						if (($ori_count > $thre_seqs_count) && ($com_count > $thre_seqs_count)) {
							my $delta_entropy = `perl cal_delta_entropy.pl alignment $thre_computer`;
							my $specific_site = `perl cal_specific_site.pl alignment $thre_computer`;
							print "clade$number\t$ori_clade|$com_clade\t$similarity\t$delta_entropy\t$specific_site\n";
						}
						else {
							print "clade$number\t$ori_clade|$com_clade\t$similarity\tNA\tNA\n";
						}
					}
				}
			}
		}
	}
	$number ++;
}
`rm -f seqs alignment`;
