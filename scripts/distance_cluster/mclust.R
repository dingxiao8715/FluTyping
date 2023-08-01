library (mclust)
argv = commandArgs (TRUE)
data <- read.table(argv[1], header = T, sep = "\t",row.names = 1)
d_clust <- Mclust(as.matrix(data), G=1:argv[2])
m.best <- dim(d_clust$z)[2]
cat("model-based optimal number of clusters:", m.best, "\n")
pdf(file = argv[3], height=6, width=10)
plot(d_clust$BIC)
dev.off()
