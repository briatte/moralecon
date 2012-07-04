library(ggplot2)
library(RColorBrewer)

setwd("~/Documents/Research/Code/Projects/moralecon/")

# Graph settings
cols <- brewer.pal(8,"Set1")
cols <- c(cols[2], cols[1], cols[3:8]) # inverts red/blue order

# Data
# International Social Survey Programme, 1985-2006
#
# lic = license to act ("government is responsible for...") scaled [0,1]
# exp = license to spend ("government should spend more/less") scaled [-1,1]
#
issp8506 <- read.csv("data_issp8506.csv", header=TRUE, sep="\t")
issp8506 <- subset(issp8506,issue %in% c("Health","Unemployment"))
issp8506 <- na.omit(issp8506)
issp8506 <- droplevels(issp8506)

# Fig. 1
# License/Expenditure Policy Space for Health and Unemployment, 1985-2006
# 
fig1 <- ggplot(data=issp8506,aes(lic, exp, colour=issue)) + 
  geom_point() + geom_density2d(alpha=.5) +
  geom_hline(yintercept=0, colour="darkgrey") + 
  geom_vline(xintercept=.5, colour="darkgrey") +
  scale_colour_manual("Issue", cols) +
  labs(x = "License+", y = "Expenditure+"); fig1

# Data
# International Social Survey Programme, 2006
#
# man = mandate = license*expenditure [-1,1]
# eff = efficiency ("government successful at...") scaled [-1,1]
#
issp06 <- read.csv("data_issp2006.csv", header=TRUE, sep="\t")
issp06 <- subset(issp06,issue %in% c("Health","Unemployment","Pensions"))
issp06 <- na.omit(issp06)
issp06 <- droplevels(issp06)

# Convex hulls.
df <- issp06
find_hull <- function(issp06) issp06[chull(issp06$eff, issp06$man), ]
hulls <- ddply(df, "issue", find_hull)

# Fig. 2
# Mandate/Efficiency Policy Space for Health, Pensions and Unemployment, 2006
# 
fig2 <- ggplot(data=issp06, aes(man, eff, colour=issue, fill=issue)) + 
  geom_point() + 
  geom_hline(yintercept=0, colour="darkgrey") + 
  geom_vline(xintercept=0, colour="darkgrey") +
  scale_colour_manual("Issue", cols) +
  scale_fill_manual("Issue", cols) +
  labs(x = "Mandate+", y = "Efficiency+"); fig2

# Fig. 2A
# Density lines
fig2a <- fig2 + geom_density2d(alpha=.5); fig2a

# Fig. 2B
# Convex hulls
fig2b <- fig2 + geom_polygon(data=hulls, alpha=.2); fig2b

ggsave(fig1,filename="moralecon.fig1.pdf")
ggsave(fig2b,filename="moralecon.fig2b.pdf")

# PCA
Xoriginal=t(as.matrix(subset(issp06, issue=="Health", select=c(lic,exp,eff))))
summary(pca <- prcomp(Xoriginal))
plot(pca)
sd <- pca$sdev; barplot(pca$sdev/pca$sdev[1])
loadings <- pca$rotation
rownames(loadings) <- 
pca2=prcomp(Xoriginal, tol=.1)
plot.ts(pca2$x)
plot.ts(intensities)
