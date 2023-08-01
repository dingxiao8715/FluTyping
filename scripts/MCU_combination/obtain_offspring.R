suppressMessages (library (ggtree))
suppressMessages (library (tidytree))
argv <- commandArgs (TRUE);
tree <- read.tree (argv[1]);
node_off <- offspring (tree, argv[2]);
write.table (node_off, file = "list_tips", sep = "\n", row.names = F, col.names = F, quote = F);
