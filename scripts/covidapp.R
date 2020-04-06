#Author : Vijay Nagarajan PhD
#License : GNU GPL

#install packages
if(!"RCy3" %in% installed.packages()){
  install.packages("BiocManager", repos = "http://cran.us.r-project.org")
  BiocManager::install("RCy3")
}
if(!"dtw" %in% installed.packages()){
  install.packages("dtw", repos = "http://cran.us.r-project.org")
}
if(!"ape" %in% installed.packages()){
  install.packages("ape", repos = "http://cran.us.r-project.org")
}
if(!"igraph" %in% installed.packages()){
  install.packages("igraph", repos = "http://cran.us.r-project.org")
}

#load libraries
library(dtw)
library(ape)
library(igraph)
library(RCy3)
#library(svglite)

# Read in the confirmed cases meta data
x <- scan("data/time_series_current_meta.csv", what="", sep="\n")
head(x)

# Read region attribute csv
regiona <- read.csv(file='data/states-attributes.csv',check.names=FALSE)
head(regiona)

# Read region current cases data
regionc <- read.csv(file='data/time_series_current.csv',check.names=FALSE)
head(regionc)

# Extract last data column
currentdata <- regionc[,c(1,ncol(regionc))]
head(currentdata)

# Rename last column as 'current'
names(currentdata)[names(currentdata) == names(currentdata[2])] <- "current"
head(currentdata)

# Separate elements by one or more whitepace
y <- strsplit(x, ",")
head(y)

# Extract the first vector element and set it as the list element name
names(y) <- sapply(y, function(x) x[[1]]) # same as above

# Remove column header
y$`Province/State` <- NULL
head(y)

# Remove the first vector element from each list element
y <- lapply(y, function(x) x[-1]) # same as above
head(y)

# Convert character vectors in list, to numeric vectors
w=lapply(y, as.numeric)
head(w)

# Cluster using DTW and plot hclust
dm <- dist(w, method= "DTW")
summary(dm)
hc <- hclust(dm, method="average")
summary(hc)
svg("images/covid-19-current-dtw-tree-meta.svg")
plot(hc, hang=0.1,cex=0.6)
dev.off()

# Generate igraph
phylo_tree = as.phylo(hc)
graph_edges = phylo_tree$edge
graph_net = graph.edgelist(graph_edges)
myigraph=as.igraph(phylo_tree)
head(myigraph)
summary(myigraph)

#push igraph to cytoscape
cygraph=createNetworkFromIgraph(myigraph)

#rename network
renameNetwork(title = "covid-19-network")

#load states attribute data
loadTableData(data = regiona, data.key.column = "StateNames")

#load states current count data
loadTableData(data = currentdata, data.key.column = "Province/State")

#update node label position default
style.defaults <- list(NODE_LABEL_POSITION="S,N,c,0.00,0.00", NODE_BORDER_WIDTH="5", NODE_BORDER_PAINT="#000000")
updateStyleDefaults('default', style.defaults)
  
#set default node size
setNodeSizeDefault(1)

#set node label mapping to statenames
setNodeLabelMapping('StateNames')

#map node size to current case number
sizecolumn = 'current'
size.control.points = c(1,max(currentdata$current))
sizes = c(55,155)
setNodeSizeMapping(sizecolumn,size.control.points,sizes)

#map node color to aggressively prepared score range
nodecolorcolumn = 'AggressiveScore'
nodecolor.control.points = c('30 - 35','35 - 40','40 - 45','45 - 50','50 - 55','55 - 60','>=60')
nodecolors = c('#FF0000','#FF6666','#FFCCCC','#CCFFCC','#CCFFCC','#66FF66','#00FF00')
setNodeColorMapping(nodecolorcolumn,nodecolor.control.points,nodecolors,mapping.type = "d")

#map node font size to current case number
lsizecolumn = 'current'
lsize.control.points = c(0,max(currentdata$current))
lsizes = c(18,38)
setNodeFontSizeMapping(lsizecolumn,lsize.control.points,lsizes)

#layout network
layoutNetwork('cose')

#fit content to screen
fitContent(selected.only = FALSE)

#saving the network
exportImage('images/covid-19-transmission-similarity-dtw-network','SVG')

#save cytoscape session
saveSession(filename = "images/covid-19-network")

#wait for saving session
Sys.sleep(30)

#close cytoscape session
closeSession(FALSE)
