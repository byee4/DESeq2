suppressPackageStartupMessages(library("argparse"))
suppressPackageStartupMessages(library("DESeq2"))
suppressPackageStartupMessages(library("ggplot2"))

parser <- ArgumentParser()

parser$add_argument("--count", type="character")
parser$add_argument("--conditions", type="character")
parser$add_argument("--column", type="character")
parser$add_argument("--ref", type="character")
parser$add_argument("--alt", type="character")
parser$add_argument("--filterAvg", type="integer")
parser$add_argument("--output", type="character")
parser$add_argument("--colSkip", type="integer", default=6)
parser$add_argument("--plotPCA", action='store_true')
parser$add_argument("--additional_factor", type="character", default="NONE")
args <- parser$parse_args()

countData <- read.table(args$count,  comment.char="#", header=TRUE, row.names=1, sep='\t')
countData <- countData[, args$colSkip:ncol(countData)]
colData <- read.table( args$conditions, header=TRUE,row.names=1, sep='\t')
some_condition <- args$column
some_factor <- args$additional_factor
ref <- args$ref
alt <- args$alt

countTable <- as.matrix(countData)
storage.mode(countTable) = 'integer'
rs <- rowMeans(countTable)

print("R likes to change values of the header column sometimes, make sure these are identical")
# colnames(countTable)
# rownames(colData)

use <- (rs > args$filterAvg)
countTableFilt <- countTable[use, ]

some_factor <- "NONE" # TODO: implement multifactor expts

if (some_factor == "NONE") {

    dds <- DESeqDataSetFromMatrix(
        countData = countTableFilt,colData = colData,design = formula(
            paste("~",some_condition)
        )
    )
} else {
    print(paste("~",some_factor,"+",some_condition, sep=" "))
    dds <- DESeqDataSetFromMatrix(
        countData = countTableFilt,colData = colData,design = formula(
            paste("~",some_condition,"+",some_factor, sep=" ")
        )
    )
}
(dds)
if (args$plotPCA) {
    dds_rlog <- rlogTransformation(dds)
    png(paste0(args$output,".pca.png"))
    print(paste0(args$output,".pca.png"))
    data <- plotPCA(dds_rlog, intgroup=some_condition, returnData=TRUE)
    percentVar <- round(100 * attr(data, "percentVar"))
    ggplot(data, aes(PC1, color=some_condition),
           main = "PCA Plot") +
      geom_point(size=3) +
      scale_shape_manual(values=seq(0,8)) +
      xlab(paste0("PC1: ",percentVar[1],"% variance")) +
      ylab(paste0("PC2: ",percentVar[2],"% variance"))
    dev.off()
}

dds <- DESeq(dds, betaPrior=FALSE)
normalized_counts <- counts(dds, normalized=TRUE)

diffexp = results(dds, contrast=c(some_condition, alt, ref), independentFiltering=FALSE)
write.csv(as.data.frame(diffexp),file=args$output)
write.csv(as.data.frame(normalized_counts),file=paste0(args$output,".norm_counts"))
