suppressMessages (library (ape))
suppressMessages (library (ggtree))
argv <- commandArgs (TRUE);
tree <- read.tree (argv[1]);
info <- fortify (tree);
name <- paste("tree_info_r",argv[2],".xls", sep = "", collapse = NULL)
write.table (info, file = name, sep = ",", row.names = F, col.names = F, quote = F);
