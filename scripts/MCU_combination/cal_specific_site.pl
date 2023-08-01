#!/usr/bin/perl
my $fa = shift;
my $thre = shift;
my %accepted_words = ("a" => "nucl", "t" => "nucl", "c" => "nucl", "g" => "nucl");

my %all_seqs;
my $len = 0;
my $diff = 0;
$/ = ">";
open (FA, $fa) || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $title = shift @data;
	my @data_title = split (/\|/, $title);
	my $id = shift @data_title;
	my $clade = shift @data_title;
	my $seq = lc (join ("", @data));
	if (exists $all_seqs{$clade}) {
		push (@{$all_seqs{$clade}}, $seq);
	}
	else {
		${$all_seqs{$clade}}[0] = $seq;
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
	my $count_strict = 0;
	foreach my $ori_clade (keys %all_seqs) {
		my $k = 0;
		while ($k < $len) {
			my %snp;
			my $ori_count = 0;
			foreach my $seq (@{$all_seqs{$ori_clade}}) {
				my $word = substr ($seq, $k, 1);
				if (exists $accepted_words{$word}) {
					$ori_count ++;
					if (exists $snp{$word}) {
						$snp{$word} ++;
					}
					else {
						$snp{$word} = 1;
					}
				}
				else {
					next;
				}
			}
			my $max_word;
			my $max = 0;
			foreach my $word (sort {$snp{$a} <=> $snp{$b}} keys %snp) {
				$max = $snp{$word};
				$max_word = $word;
			}
			foreach my $com_clade (keys %all_seqs) {
				if ($com_clade eq $ori_clade) {
					next;
				}
				else {
					my $com_count = 0;
					my $same = 0;
					foreach my $seq (@{$all_seqs{$com_clade}}) {
						my $word = substr ($seq, $k, 1);
						if (exists $accepted_words{$word}) {
							$com_count ++;
							if ($word eq $max_word) {
								$same ++;
							}
							else {
								next;
							}
						}
						else {
							next;
						}
					}
					if (($ori_count >= $thre) && ($com_count >= $thre)) {
						if (($max/$ori_count == 1) && ($same == 0)) {
							$count_strict ++;
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
			}
		}
	}
	print "$count_strict";
}
else {
	die "This is not an alignment.\n";
}
