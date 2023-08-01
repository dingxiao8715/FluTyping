#!/usr/bin/perl
my $fa = shift;
my $list = shift;
my $thre = shift;
my %all_seqs;
my %hash;
$/ = ">";
open (FA, $fa) || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $id = shift @data;
	my $seq = join ("", @data);
	$all_seqs{$id} = $seq;
}
close FA;
$/ = "\n";
open (LIST, $list) || die;
while (<LIST>) {
	chomp;
	my @data = split /\s+/;
	my $id = shift @data; 
	my $country = shift @data;
	my $year = shift @data;
	my $info = $year.".".$country;
	if (exists $hash{$info}) {
		push (@{$hash{$info}}, $id);
	}
	else {
		${$hash{$info}}[0] = $id;
	}
}
close LIST;
foreach my $info (sort keys %hash) {
	open (OUT, ">ori_$info.fasta") || die;
	foreach my $id (@{$hash{$info}}) {
		if (exists $all_seqs{$id}) {
			print OUT ">$id\n$all_seqs{$id}\n";
		}
		else {
			die;
		}
	}
	`/mnt/d/Scientific_work/BioTools/cdhit-master/cd-hit -i ori_$info.fasta -o nr_$info.fasta -c $thre -d 0 -T 0`;
	close OUT;
}
`cat nr_*.fasta > $fa.nr`;
`cat nr_*.fasta.clstr > clstr_info`;
`perl extra_cluster.pl clstr_info > list_cluster_r0`;
`rm nr_*.fasta nr_*.fasta.clstr ori_*.fasta clstr_info`;


