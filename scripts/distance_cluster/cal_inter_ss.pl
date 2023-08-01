#!/usr/bin/perl   
use threads;
my $fa = shift;
my $list = shift;
my $thread = shift;
my %accepted_words = ("a" => "nucl", "t" => "nucl", "c" => "nucl", "g" => "nucl");
my %all_seqs;
my $len = 0;
my $diff = 0;

$/ = ">";
open (FA, $fa)  || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $id = shift @data;
	my $seq = join ("", @data);
	$all_seqs{$id} = $seq;
	if ($len == length $seq) {
		next;
	}
	else {
		$len = length $seq;
		$diff ++;
	}
}
close FA;

my %clu_info;
open (LIST, $list) || die;
<LIST>;
while (<LIST>) {
	chomp;
	my @data = split (/\n/, $_);
	my $clu = shift @data;
	@{$clu_info{$clu}} = @data;
}
close LIST;
$/ = "\n";

if ($diff == 1) {
	my %used;
	foreach my $ori_clu (sort keys %clu_info) {
		$used{$ori_clu} = 1;
		foreach my $com_clu (sort keys %clu_info) {
			if (exists $used{$com_clu}) {
				next;
			}
			else {
				my $ori_dim = @{$clu_info{$ori_clu}};
				my $com_dim = @{$clu_info{$com_clu}};
				my $sum = $ori_dim * $com_dim;
				open (OUT, ">list_combination") || die;
				foreach my $ori_id (@{$clu_info{$ori_clu}}) {
					foreach my $com_id (@{$clu_info{$com_clu}}) {
						if ($ori_id eq $com_id) {
							die;
						}
						else {
							print OUT "$ori_id|$com_id\n";
						}
					}
				}
				close OUT;
				if ($sum > 10000) {
					my $round_count = int ($sum/$thread) + 1;
					my $round = `perl divide_list.pl list_combination $round_count`;
					my $k = 1;
					while ($k <= $round) {
						my $thr = threads -> new(\&cal_ss, "list_p$k");
						$k ++;
					}
					my $sum_ss = 0;
					foreach my $thr (threads -> list(threads::all)) {
						my $value = $thr -> join();
						$sum_ss += $value;
					}
					my $avg_ss = sprintf ("%.4f", $sum_ss/$round);
					print "$ori_clu|$com_clu\t$avg_ss\n";
					`rm -f list_combination list_p*`;		
				}
				else {
					my $value = cal_ss ("list_combination");
					print "$ori_clu|$com_clu\t$value\n";
					`rm -f list_combination`;
				}
			}
		}
	}
}
else {
	die "This is not an alignment.\n";
}

sub cal_ss () {
	my $name = shift;
	my $sum_sub = 0;
	my $similarity = 0;
	open (LIST_ALL, $name) || die;
	while (my $list_line = <LIST_ALL>) {
		chomp $list_line;
		my @info = split (/\|/, $list_line);
		my $ori_id = shift @info;
		my $com_id = shift @info;
		if ((exists $all_seqs{$ori_id}) && (exists $all_seqs{$com_id})) {
			$sum_sub ++;
			my $k = 0;
			my $same = 0;
			my $sum_site = 0;
			while ($k < $len) {
				my $ori_word = substr ($all_seqs{$ori_id}, $k, 1);
				my $com_word = substr ($all_seqs{$com_id}, $k, 1);
				if ((exists $accepted_words{$ori_word}) && (exists $accepted_words{$com_word})) {
					$sum_site ++;
					if ($ori_word eq $com_word) {
						$same ++;
						$k ++;
					}
					else {
						$k ++;
					}
				}
				else {
					$k ++;
				}
			}
			$similarity += $same/$sum_site;
		}
		else {
			die;
		}
	}
	close LIST_ALL;
	my $avg_sim = sprintf ("%.4f", $similarity/$sum_sub);
	return $avg_sim;
}
