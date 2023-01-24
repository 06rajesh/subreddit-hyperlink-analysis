install.packages("dplyr")

library(dplyr)
library(igraph)
library(RColorBrewer)

## set working directory to source file location
# subreddits_all <- read.csv("dataset/soc-redditHyperlinks-title.tsv", sep = "\t")


# We read the preproccessed 2014 reddits into R and look just at the first six rows.
subreddits.2014 <- read.csv("dataset/preprocessed.csv")
head(subreddits.2014)

## merge the same subreddit hyperlink rows and add the count
## on frequency column
subreddits_freq <- rename(count(subreddits.2014, from, to), Freq = n)
subreddits_filtered <- subreddits_freq[subreddits_freq$Freq > 30, ]

subreddits.matrix <- as.matrix(subreddits_filtered[, c(1, 2)])
head(subreddits.matrix)

# We now construct a graph object from this edge list; while it is
# certainly reasonable to model subreddits networks as directed graphs
# (with arrows pointing into the citing document), in our case it will
# be simpler and just as interesting to have an undirected graph.
G <- graph.edgelist(subreddits.matrix, directed=TRUE)
G # have a look at the graph

# vertices.degree <- V(G)
# H <- induced.subgraph(G, vertices.degree)

coul <- brewer.pal(12, "Set3") 

# plotting the in degree of the network
deg <- degree(G, mode = "in")
sorted <- sort(deg, decreasing = TRUE)[1:50]
head(sorted)
barplot(sorted, las=2, name = names(sorted), cex.names = 0.7, col=coul )

# plotting the out degree
deg <- degree(G, mode = "out")
sorted <- sort(deg, decreasing = TRUE)[1:50]
head(sorted)
barplot(sorted, las=2, name = names(sorted), cex.names = 0.7, col=coul )

# Degree in 'in' mode, most of the subreddits has 0 or 1 with 105 subreddits has
# 0 in degree and 100 subreddits has only 1 in degree. Only 1 subreddit (askreddit) has the highest
# in degree of 23 and second highest in degree is 12 (worldnews)
# Degree in 'out' mode is much more contrastring, where higest subreddit (subredditdrama) has 64 out degree
# and second highest subreddit (bestof) has 36 in degree. Still 132 subreddit has no outgoing
# hyperlinks from them 

layOut <- layout_with_fr(G)
head(layOut) # We see it is a matrix, again.


## range projection
## project minimum and maximum degree to a
## vertex size range
OldMax <- max(deg)
OldMin <- min(deg)
NewMax <- 25
NewMin <- 5
degree_to_vertex <- function(degree) {
  OldRange <- (OldMax - OldMin)  
  NewRange <- (NewMax - NewMin)  
  NewValue <- (((degree - OldMin) * NewRange) / OldRange) + NewMin
  return(NewValue)
}

# qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
# col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

colorMax <- 1
colorMin <- 0.2
color_by_degree <- function(degree) {
  OldRange <- (OldMax - OldMin)
  NewRange <- (colorMax - colorMin)  
  NewValue <- (((degree - OldMin) * NewRange) / OldRange) + colorMin
  return (rgb(1, 0, 0, NewValue))
}

plot.igraph(G, 
      layout=layOut, 
      vertex.size=degree_to_vertex(deg), 
      vertex.label.cex=0.25, 
      vertex.color=color_by_degree(deg),
      edge.width=1,
      edge.arrow.size=0.0,
      )

eigenCent <- evcent(G)$vector

sorted <- sort(eigenCent, decreasing=TRUE)[1:25] 
bins <- unique(quantile(sorted, seq(0,1,length.out = 50)))
vals <- cut(sorted, bins, labels=FALSE, include.lowest=TRUE)
colorVals <- rev(heat.colors(length(bins)))[vals]
barplot(sorted, las=2, name = names(sorted), cex.names = 0.7, col=colorVals )
sorted

bins <- unique(quantile(eigenCent, seq(0,1,length.out = 50)))
vals <- cut(eigenCent, bins, labels=FALSE, include.lowest=TRUE)
colorVals <- rev(heat.colors(length(bins)))[vals]

V(G)$color <- colorVals

plot.igraph(G, 
            layout=layOut, 
            vertex.size=degree_to_vertex(deg), 
            vertex.label=NA, 
            edge.width=1,
            edge.arrow.size=0.0
            )

# we plot the whole network as pdf, with the same seed as above
set.seed(1)
png(paste0("images/eigenVector.2014.png"), 645, 645)
par(mar=c(0,0,0,0))
plot.igraph(G, vertex.size=degree_to_vertex(deg), vertex.label=NA)
dev.off()

betweenCent <- betweenness(G)

sorted <- sort(betweenCent, decreasing = TRUE)[1:25]
sorted
bins <- unique(quantile(sorted, seq(0.5,1,length.out = 50)))
vals <- cut(sorted, bins, labels=FALSE, include.lowest=TRUE)
colorVals <- rev(heat.colors(length(bins)))[vals]
barplot(sorted, las=2, name = names(sorted), cex.names = 0.7, col=colorVals )

# These new values can be plotted on the graph
# using the same code as before. 
bins <- unique(quantile(betweenCent, seq(0,1,length.out = 30)))
vals <- cut(betweenCent, bins, labels=FALSE, include.lowest=TRUE)
colorVals <- rev(heat.colors(length(bins)))[vals]

V(G)$color <- colorVals
plot.igraph(G,
            vertex.size=degree_to_vertex(deg), 
            vertex.label=NA, 
            edge.width=1,
            edge.arrow.size=0.0)

# we plot the whole network as pdf, with the same seed as above
set.seed(1)
png(paste0("images/betweenVector.2014.png"), 645, 645)
par(mar=c(0,0,0,0))
plot.igraph(G, vertex.size=degree_to_vertex(deg), vertex.label=NA)
dev.off()

cor(betweenCent,eigenCent)

betweenCent <- betweenness(G)
eigenCent <- evcent(G)$vector
colorVals <- rep("white", length(betweenCent))
colorVals[which(eigenCent < 0.35 & betweenCent > 20)] <- "red"
V(G)$color <- colorVals

plot.igraph(G,
            vertex.size=degree_to_vertex(deg), 
            vertex.label=NA, 
            edge.width=1,
            edge.arrow.size=0.0)
