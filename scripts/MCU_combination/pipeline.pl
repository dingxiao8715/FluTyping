#!/usr/bin/perl
my $all_fa = shift;
my $query_fa = shift;
my $meta_info = shift;
my $start = 0;
my $count = 1;
#Initialization of the combinations
`mafft --auto --thread -1 --quiet $query_fa > r$start\_rep.fasta`;
`./FastTreeMP -nt -gtr r$start\_rep.fasta > r$start.tree`;
`Rscript output_tree_info.R r$start.tree $start`;
`perl output_mcu.pl $query_fa r$start.tree tree_info_r$start.xls $start > list_mcu_r$start`;
`perl check_error.pl list_mcu_r$start`;
`perl cal_parameter_init.pl $all_fa list_mcu_r$start list_cluster_r$start 5 3 > log_r$start.xls`;
$count = `perl combine_seqs.pl $all_fa $meta_info log_r$start.xls 0.99 0.01 $start`;
#Recursive combinations
while ($count > 0) {
	my $next = $start + 1;
	`cat combined_seqs_r$start.fasta single_clade_r$start.fasta > r$next\_rep.fasta`;
	`perl update_cluster.pl combined_info_r$start.xls list_cluster_r$start > list_cluster_r$next`;
	my $count_strain = `perl stat_count.pl list_cluster_r$next`;
	if ($count_strain != 6000) { # The number of "6000" should be modified into the amount of all sequences.
		die "The sequences were not complete.\n";
	}
	`mafft --auto --thread -1 --quiet r$next\_rep.fasta > aligned_r$next\_rep.fasta`;
	`./FastTreeMP -nt -gtr aligned_r$next\_rep.fasta > r$next.tree`;
	`Rscript output_tree_info.R r$next.tree $next`;
	`perl output_mcu.pl r$next\_rep.fasta r$next.tree tree_info_r$next.xls $next > list_mcu_r$next`;
	`perl check_error.pl list_mcu_r$next`;
	`perl cal_parameter.pl $all_fa list_mcu_r$next log_r$start.xls combined_info_r$start.xls list_cluster_r$next 5 3 > log_r$next.xls`;
	$count = `perl combine_seqs.pl $all_fa $meta_info log_r$next.xls 0.99 0.01 $next`;
	$start ++;
}
#Convergence of combinations
`cp r$start\_rep.fasta final_rep.fasta`;
`mkdir files_log`;
`mv log_* list_* single_clade_r* combined_* tree_info_r* *.tree *_rep.fasta files_log/`;
