
# load the library
library(dplyr)
library(RColorBrewer)
library("scatterplot3d")

subreddits.2014 <- read.csv("dataset/preprocessed-post-vector.csv")
head(subreddits.2014)

table(subreddits.2014$subreddit)

top_source_subreddit <- table(subreddits.2014$subreddit) %>% 
                          as.data.frame() %>% 
                          arrange(desc(Freq))
head(top_source_subreddit, n=20)
top_sub_posts <- subreddits.2014[subreddits.2014$subreddit%in% c("circlebroke2", "dogecoin", "conspiratard", "shitpost" ), ]
nrow(top_sub_posts)

top_post_subset <- sample_n(top_sub_posts, 2000)
top.post.pr <- prcomp(top_post_subset[c(2:87)], center = TRUE, scale = TRUE)
summary(top.post.pr)

colors <- brewer.pal(4, 'Dark2')
category <- unique(top_post_subset$subreddit)
names(colors) <- category

png("images/subreddit-plot.png",width=20,height=12,units="cm",res=200)
scatterplot3d(x=top.post.pr$x[,1], y=top.post.pr$x[,2], z=top.post.pr$x[,3], 
              pch = 16, main = "Subreddits Plotting",
              xlab = NA, ylab = NA, zlab = NA,
              color = colors[factor(top_post_subset$subreddit)],
)

legend("topright", legend = category, pch = 16, col =  colors, xpd = TRUE)
dev.off()
