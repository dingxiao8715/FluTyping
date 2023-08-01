#!/usr/bin/perl
my $fa = shift;
my $tree = shift;
my $tree_info = shift;
my $round = shift;
my %node2tip;
my %inner_nodes;
open (LIST, $tree_info) || die;
while (<LIST>) {
	chomp;
	my @data = split (/,/, $_);
	my $parent = shift @data;
	my $node = shift @data;
	my $branch_length = shift @data;
	my $label = shift @data;
	if ($label eq "") {
		$label = "NA";
	}
	my $istip = shift @data;
	shift @data; shift @data;
	my $sum_branch = shift @data;
	if ($istip eq "TRUE") {
		$node2tip{$node} = $label;
		#print "tip\t$node\t$label\n";
	}
	else {
		if (($branch_length == 0) && ($sum_branch == 0)) {
			next;
		}
		else {
			$inner_nodes{$node} = $label;
			#print "inner\t$node\t$label\n";
		}
	}
}
close LIST;
my %inner_nodes_tip;
foreach my $inner_node (sort {$a <=> $b} keys %inner_nodes) {
	`Rscript obtain_offspring.R $tree $inner_node`; 
	my @offspring;
	my $count = 0;
	open (LIST, "list_tips") || die;
	while (my $node = <LIST>) {
		chomp $node;
		if (exists $node2tip{$node}) {
			push (@offspring, $node2tip{$node});
		}
		else {
			$count ++;
			last;
		}
	}
	close LIST;
	if ($count > 0) {
		next;
	}
	else {
		@{$inner_nodes_tip{$inner_node}} = @offspring;
		delete $inner_nodes{$inner_node};
		#my $dim = @offspring;
		#print "inner_tip\t$inner_node\t$dim\n";
	}
	`rm -f list_tips`;
}
my %used_nodes;
my %used_tips;
foreach my $inner_node (sort {$a <=> $b} keys %inner_nodes) {
	`Rscript obtain_child.R $tree $inner_node`;
	my @offspring;
	my @used;
	my $count = 0;
	open (LIST, "list_tips") || die;
	while (my $node = <LIST>) {
		chomp $node;
		if (exists $node2tip{$node}) {
			push (@offspring, $node2tip{$node});
		}
		else {
			if (exists $inner_nodes_tip{$node}) {
				foreach my $id (@{$inner_nodes_tip{$node}}) {
					push (@offspring, $id);
				}
				push (@used, $node);
			}
			else {
				$count ++;
				last;
			}
		}
	}
	close LIST;
	if ($count > 0) {
		next;
	}
	else {
		print "$inner_node";
		foreach my $id (@offspring) {
			$used_tips{$id} = 1;
			print "\t$id";
		}
		print "\n";
		foreach my $node (@used) {
			$used_nodes{$node} = 1;
		}
	}
	`rm -f list_tips`;
}
foreach my $node (sort {$a <=> $b} keys %inner_nodes_tip) {
	if (exists $used_nodes{$node}) {
		next;
	}
	else {
		print "$node";
		foreach my $id (@{$inner_nodes_tip{$node}}) {
			$used_tips{$id} = 1;
			print "\t$id";
		}
		print "\n";
	}
}

$/ = ">";
open (OUT_FA, ">single_clade_r$round.fasta") || die;
open (FA, $fa) || die;
<FA>;
while (<FA>) {
	chomp;
	my @data = split (/\n/, $_);
	my $id = shift @data;
	if (exists $used_tips{$id}) {
		next;
	}
	else {
		my $seq = lc (join ("", @data));
		print OUT_FA ">$id\n$seq\n";
	}
}
close FA;
close OUT_FA;
$/ = "\n";

