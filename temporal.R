
# load the library
library(dplyr)
library(igraph)
library(RColorBrewer)


# We read the preproccessed 2014 reddits into R and look just at the first six rows.
subreddits.2014 <- read.csv("dataset/preprocessed.csv")
head(subreddits.2014)

NewMax <- 30
NewMin <- 5
degree_to_vertex <- function(val, OldMax, OldMin) {
  OldRange <- (OldMax - OldMin)  
  NewRange <- (NewMax - NewMin)  
  NewValue <- (((val - OldMin) * NewRange) / OldRange) + NewMin
  return(NewValue)
}

# subreddits.2014[['date']] <- strptime(subreddits.2014[['date']],
#                                  format = "%Y-%m-%d")
subreddits.2014$date <- as.Date(subreddits.2014$date)
ranges <- c("2014-01-01", "2014-01-05", "2014-01-10", "2014-03-31", "2014-06-30", "2014-12-31")

for (i in 1:length(ranges)) {
  t0 <- with(subreddits.2014, subreddits.2014[(date <= ranges[i]), ])
  nrow(t0)
  
  t0.matrix <- as.matrix(t0[, c(1, 2)])
  head(t0.matrix) 
  
  G <- graph.edgelist(t0.matrix, directed=TRUE)
  G # have a look at the graph
  
  # plotting the out degree
  deg <- degree(G, mode = "all")
  DegMax <- max(deg)
  DegMin <- min(deg)
  
  imgpath <- sprintf("images/t%d.png",i)
  
  set.seed(1)
  png(paste0(imgpath), 512, 512)
  par(mar=c(0,0,0,0))
  plot.igraph(G, vertex.size=degree_to_vertex(deg, DegMax, DegMin), vertex.label=NA, vertex.color="red", edge.arrow.size=0.0)
  dev.off()
}

# t0 <- with(subreddits.2014, subreddits.2014[(date <= t4.range), ])
# nrow(t0)
# 
# t0.matrix <- as.matrix(t0[, c(1, 2)])
# head(t0.matrix)     
# 
# G <- graph.edgelist(t0.matrix, directed=TRUE)
# G # have a look at the graph
# 
# # plotting the out degree
# deg <- degree(G, mode = "all")
# DegMax <- max(deg)
# DegMin <- min(deg)
# 
# layOut <- layout_with_fr(G)
# head(layOut) # We see it is a matrix, again.
# 
# # plot.igraph(G, 
# #             vertex.size=degree_to_vertex(deg), 
# #             vertex.label=NA, 
# #             vertex.color="red",
# #             edge.width=1,
# #             edge.arrow.size=0.0,
# # )
# 
# set.seed(1)
# png(paste0("images/t4.png"), 512, 512)
# par(mar=c(0,0,0,0))
# plot.igraph(G, vertex.size=degree_to_vertex(deg, DegMax, DegMin), vertex.label=NA, vertex.color="red", edge.arrow.size=0.0)
# dev.off()
