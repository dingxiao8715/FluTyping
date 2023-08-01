#!/usr/bin/perl   
use threads;
my $fa = shift;
my %accepted_words = ("a" => "nucl", "t" => "nucl", "c" => "nucl", "g" => "nucl");
my %all_seqs;
my $len = 0;
my $diff = 0;
my $count_first = 0;
my $count_second = 0;
$/ = ">";
open (FA, $fa)  || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $title = shift @data;
	my $seq = join ("", @data);
	my @data_title = split (/\|/, $title);
	my $id = shift @data_title;
	my $clade = shift @data_title;
	if ($clade eq "first") {
		push (@{$all_seqs{"first"}}, $seq);
		$count_first ++;
	}
	else {
		push (@{$all_seqs{"second"}}, $seq);
		$count_second ++;
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
	if (($count_first > 100) && ($count_second > 100)) {
		my $clu_first = int ($count_first/8) + 1;
		my $clu_second = int ($count_second/8) + 1;
		my %partition_first;
		my %partition_second;
		my $round_first = 1;
		while (@{$all_seqs{"first"}}) {
			@{$partition_first{$round_first}} = splice (@{$all_seqs{"first"}}, 0, $clu_first);
			$round_first ++;
		}
		my $round_second = 1;
		while (@{$all_seqs{"second"}}) {
			@{$partition_second{$round_second}} = splice (@{$all_seqs{"second"}}, 0, $clu_second);
			$round_second ++;
		}
		my $sum_round = 0;
		my $k = 1;
		while ($k < $round_first) {
			my $m = 1;
			while ($m < $round_second) {
				$sum_round ++;
				@first = @{$partition_first{$k}};
				@second = @{$partition_second{$m}};
				my $thr = threads -> new(\&cal_ss, "first", "second");
				$m ++;
			}
			$k ++;
		}
		my $sum_ss = 0;
		foreach my $thread (threads -> list(threads::all)) {
			my $value = $thread -> join();
			$sum_ss += $value;
		}
		my $avg_ss = sprintf ("%.4f", $sum_ss/$sum_round);
		print "$avg_ss";	
	}
	else {
		@first = @{$all_seqs{"first"}};
		@second = @{$all_seqs{"second"}};
		my $value = cal_ss ("first", "second");
		print "$value";
	}
}
else {
	die "This is not an alignment.\n";
}

sub cal_ss () {
	my ($a, $b) = @_;
	my $similarity = 0;
	my $sum = 0;
	my $dim_1 = @$a;
	my $dim_2 = @$b;
	foreach my $ori_seq (@$a) {
		foreach my $com_seq (@$b) {
			my $k = 0;
			$sum ++;
			my $same = 0;
			my $sum_site = 0;
			while ($k < $len) {
				my $ori_word = substr ($ori_seq, $k, 1);
				my $com_word = substr ($com_seq, $k, 1);
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
	}
	my $avg_sim = sprintf ("%.4f", $similarity/$sum);
	return $avg_sim;
}
