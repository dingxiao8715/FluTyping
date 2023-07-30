# FluTyping
## Description
FluTyping is a comprehensive framework for classifying the genomes of influenza isolates by simultaneously considering their genetic distances and phylogenetic relationships. This approach establishes a robust genotype classification for overall influenza A viruses (IAVs).     
  
The framework involves three main processes: clustering, phylogenetic calibration, and genotyping. In the clustering step, distinct phylogenetic classes of each genomic segment are automatically clustered using epidemiological information and evolutionary measures between isolates. The phylogenetic calibration step manually combines mixed clusters and outliers based on the phylogenetic topological structure. Finally, each isolate is assigned a specific genotype by combining optimized clusters of eight genes in the genotyping step.    
  
This repository provides the pipeline scripts for the clustering step in FluTyping, which involves three procedures: epidemiological combination, MCU-based combination, and distance-based clustering.    

## Requirement  
These instructions are for linux. To use FluTyping, you need the following software and packages:  
  
Perl 5 and the module of "Math::Complex"  
R 4.3.0 and the R packages of "ape", "ggtree", "tidytree" and "mclust"      
mafft v7.505  
FastTreeMP v2.1.10   
  
Any stable version of these software tools is also acceptable.   

## Instructions
### Descriptions of scripts
**epi_cluster.pl** - Combines genomic sequences based on the epidemiological information of isolates and the sequence similarity between isolates.    
**extra_cluster.pl** - Obtains the formatted cluster file from the CD-HIT results.    
**update_cluster.pl** - Obtains the formatted cluster file of each circulation in the MCU-based combination.     
**stat_count.pl** - Calculates the number of all isolates involved in the MCU-based combination, which is used to check whether there are any errors in the process.      
**output_mcu.pl** - Outputs all MCUs (Minimum combined unit) of the phylogenetic tree of each circulation.    
**check_error.pl** - Checks whether any circulation has redundant sequences, i.e., if there are errors in the circulation.    
**cal_parameter.pl** - Calculates the measures in the MCU-based combination, which will call the sub-scripts of **cal_similarity_mp.pl**, **cal_delta_entropy.pl** and **cal_specific_site.pl**. The three sub-scripts calculate the average intra-MCU sequence similarity, the entropy change after combining MCUs and the number of same unit-specific genomic loci between MCUs.    
**cal_parameter_init.pl** - Calculates the measures of the initialization in the MCU-based combination.    
**combine_seqs.pl** - Combines the sequences based on the calculated measures in each circulation.  
**pipeline.pl** - The pipeline script of the MCU-based combination.  
**output_tree_info.R** - Parses the phylogenetic tree and outputS the information formationally.  
**obtain_offspring.R** - Outputs the offsprint of all inner nodes of the phylogenetic tree.  
**obtain_child.R** - Outputs the child nodes of all inner nodes of the phylogenetic tree.  
**cal_inter_ss.pl** - Calculates the sequence similarities between pairwise clusters from the MCU-based combination.  
**obtain_matrix.pl** - Outputs the pairwise sequence similarities of MCUs in a matrix.  
**mclust.R** - Evaluates the optimal number of clustering MCUs.  
**h_cluster.R** - Performs hierarchical clustering of MCUs in R.    
  

### Pipeline of the epidemiological combination  
#### Run the script epi_cluster.pl as follows:
     
`perl epi_cluster.pl $query_fasta $meta_file $thre`  
  
Where $query_fasta represents all genomic sequences to be grouped, $meta_file shows the GISAID ID, collection country, and collection year of all isolates, and $thre is the cutoff value of sequence similarity used in CD-HIT. The input formats are detailed in the example files.
     

#### Align the sequences using MAFFT:
        
`mafft --auto --thread -1 --quiet $nr_query_fasta  > $aligned_nr_query_fasta`  
`mafft --auto --thread -1 --quiet $query_fasta  > $aligned_query_fasta`  
  
  
### Quick start of the MCU-based combination  
#### Run the pipeline script as follows:  
  
`perl pipeline.pl $aligned_query_fasta $aligned_nr_query_fasta $meta_file`  
  
The inputs are the results from the epidemiological combination step. Specific calculations can be performed using corresponding scripts based on the script descriptions.  

### Pipeline of the distance-based combination  
#### Calculate the inter-MCUs sequence similarities using cal_inter_ss.pl:  
  
`perl cal_inter_ss.pl $MCU_clu_fasta $cluster_info $thread > $output`  
  
Here, $MCU_clu_fasta represents the representative genomic sequences from the MCU-based combination, $cluster_info contains the isolate IDs in all clusters, and $thread is the number of cores on your computer expected to be used.
  
#### Assess the optimal number of clusters using the Bayesian Information Criterion (BIC) via the R package mclust:    
  
`perl obtain_matrix.pl $pair_ss > $matrix_ss`  
`Rscript mclust.R $matrix_ss $num_clu $output`
  
The inputs $pair_ss are the pairwise sequence similarities of MCUs from the previous step, $num_clu is the number of the MCUs, and the $output shows the graphical quantification of the assessment. The optimal number of clusters will be printed in the terminal.
  
#### Perform hierarchical clustering of the converged MCUs in R:  
  
`Rscript h_cluster.R $matrix_ss $opt_num_clu $output`
  
Here, $matrix_ss is the matrix of pairwise sequence similarities of all MCUs, $opt_num_clu is the optimal number of clusters evaluated from mclust, and the resulted clusters of all MCUs will be output in the $output file.  
    
## Example  
The example files contain the input genomic sequences in fasta format (example.fasta) and the corresponding epidemiological informaition of all isolates (example.meta).  

## Reference  

## Author
Xiao Ding, dx@ism.cams.cn
