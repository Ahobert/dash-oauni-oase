library( magrittr )
library( dplyr )
library("reshape2")
library( tidyr )
library( DataCombine )
library( circlize )
require(ggplot2)
library(tidyverse)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(extrafont)
library(grid)
library(gridExtra)
library(scales)
library(networkD3)
lable_size=100
node_padding=75
node_Width=50
myfont="Times New Roman"
#effect of mobility score and stage on performance
org_dest_cnt<-read.table("export_origin_dest_flow.csv",header=TRUE,sep=";",quote="\r",dec = ".")
ORG_DEST_INCOME_DISTRIBUTION<-org_dest_cnt %>% group_by(ORG_INCOME,DEST_INCOME,MOVE_STAGE) %>% count()
ORG_DEST_INCOME_DISTRIBUTION <- ORG_DEST_INCOME_DISTRIBUTION[order(ORG_DEST_INCOME_DISTRIBUTION$DEST_INCOME),]
org_c<-ORG_DEST_INCOME_DISTRIBUTION$ORG_INCOME
dest_c<-ORG_DEST_INCOME_DISTRIBUTION$DEST_INCOME
MOVE_STAGE<-ORG_DEST_INCOME_DISTRIBUTION$MOVE_STAGE
movements<-ORG_DEST_INCOME_DISTRIBUTION$n

#ORG_DEST_INCOME_DISTRIBUTION <- sapply(ORG_DEST_INCOME_DISTRIBUTION,function(x) {x <- gsub("High","H",x)})
ORG_DEST_INCOME_DISTRIBUTION[] <- lapply(ORG_DEST_INCOME_DISTRIBUTION, gsub, pattern = "High", replacement = "H", fixed = TRUE)
ORG_DEST_INCOME_DISTRIBUTION[] <- lapply(ORG_DEST_INCOME_DISTRIBUTION, gsub, pattern = "Upper middle", replacement = "UM", fixed = TRUE)
ORG_DEST_INCOME_DISTRIBUTION[] <- lapply(ORG_DEST_INCOME_DISTRIBUTION, gsub, pattern = "Lower middle", replacement = "LM", fixed = TRUE)
ORG_DEST_INCOME_DISTRIBUTION[] <- lapply(ORG_DEST_INCOME_DISTRIBUTION, gsub, pattern = "Low", replacement = "L", fixed = TRUE)

#######sankey network######
###########################
ORG_DEST1<-filter(ORG_DEST_INCOME_DISTRIBUTION,MOVE_STAGE=='early')
ORG_DEST2<-filter(ORG_DEST_INCOME_DISTRIBUTION,MOVE_STAGE=='mid')
ORG_DEST3<-filter(ORG_DEST_INCOME_DISTRIBUTION,MOVE_STAGE=='late')
origin <- ORG_DEST1$ORG_INCOME
dest <- paste(ORG_DEST1$DEST_INCOME, " ", sep="")
movements<-ORG_DEST1$n
nodes <- data.frame(name=c(as.character(origin), as.character(dest)) %>% unique())
nodes$group<-as.character(substring(origin, 1, 4)) %>% unique()
data_long_income_1<-data.frame(source=origin,target=dest,value=movements,IDsource=match(origin, nodes$name)-1,IDtarget=match(dest, nodes$name)-1)
data_long_income_1$group<-substring(origin, 1, 4)
data_long_income_1$stage<-'early'

ColourScal ='d3.scaleOrdinal() .domain(["H","UM","LM","L","H","UM","LM",
"L"]).range(["#7fcdbb", "yellow", "blue", "red",
   "#7fcdbb", "yellow", "blue", "red"])'
# Make the Network
sankey1_income<-sankeyNetwork(Links = data_long_income_1, Nodes = nodes,
                       Source = "IDsource", Target = "IDtarget",
                       Value = "value", NodeID = "name",LinkGroup="group",NodeGroup="group",
                       sinksRight=F,colourScale=ColourScal, nodeWidth=node_Width, fontSize=lable_size, nodePadding=node_padding,margin = list(bottom = 50))

origin <- ORG_DEST2$ORG_INCOME
dest <- paste(ORG_DEST2$DEST_INCOME, " ", sep="")
movements<-ORG_DEST2$n
nodes <- data.frame(name=c(as.character(origin), as.character(dest)) %>% unique())
nodes$group<-as.character(substring(origin, 1, 4)) %>% unique()
data_long_income_2<-data.frame(source=origin,target=dest,value=movements,IDsource=match(origin, nodes$name)-1,IDtarget=match(dest, nodes$name)-1)
data_long_income_2$group<-substring(origin, 1, 4)
data_long_income_2$stage<-'mid'
# Make the Network
sankey2_income<-sankeyNetwork(Links = data_long_income_2, Nodes = nodes,
                              Source = "IDsource", Target = "IDtarget",
                              Value = "value", NodeID = "name",LinkGroup="group",NodeGroup="group",
                              sinksRight=F,colourScale=ColourScal, nodeWidth=node_Width, fontSize=lable_size, nodePadding=node_padding,margin = list(bottom = 50),width = "100%")

origin <- ORG_DEST3$ORG_INCOME
dest <- paste(ORG_DEST3$DEST_INCOME, " ", sep="")
movements<-ORG_DEST3$n
nodes <- data.frame(name=c(as.character(origin), as.character(dest)) %>% unique())
nodes$group<-as.character(substring(origin, 1, 4)) %>% unique()
data_long_income_3<-data.frame(source=origin,target=dest,value=movements,IDsource=match(origin, nodes$name)-1,IDtarget=match(dest, nodes$name)-1)
data_long_income_3$group<-substring(origin, 1, 4)
data_long_income_3$stage<-'late'
# Make the Network
sankey3_income<-sankeyNetwork(Links = data_long_income_3, Nodes = nodes,
                              Source = "IDsource", Target = "IDtarget",
                              Value = "value", NodeID = "name",LinkGroup="group",NodeGroup="group",
                              sinksRight=F,colourScale=ColourScal, nodeWidth=node_Width, fontSize=lable_size, nodePadding=node_padding,margin = list(bottom = 50))

###Mobility flow regions#####
ORG_DEST_REGION_DISTRIBUTION<-org_dest_cnt %>% group_by(ORG_REGION,DEST_REGION,MOVE_STAGE) %>% count()
ORG_DEST_REGION_DISTRIBUTION <- ORG_DEST_REGION_DISTRIBUTION[order(ORG_DEST_REGION_DISTRIBUTION$DEST_REGION),]
org_c<-ORG_DEST_REGION_DISTRIBUTION$ORG_REGION
dest_c<-ORG_DEST_REGION_DISTRIBUTION$DEST_REGION
MOVE_STAGE<-ORG_DEST_REGION_DISTRIBUTION$MOVE_STAGE
movements<-ORG_DEST_REGION_DISTRIBUTION$n
#######sankey network######
###########################
ORG_DEST1<-filter(ORG_DEST_REGION_DISTRIBUTION,MOVE_STAGE=='early')
ORG_DEST2<-filter(ORG_DEST_REGION_DISTRIBUTION,MOVE_STAGE=='mid')
ORG_DEST3<-filter(ORG_DEST_REGION_DISTRIBUTION,MOVE_STAGE=='late')
origin <- ORG_DEST1$ORG_REGION
dest <- paste(ORG_DEST1$DEST_REGION, " ", sep="")
movements<-ORG_DEST1$n
nodes <- data.frame(name=c(as.character(origin), as.character(dest)) %>% unique())
nodes$group<-as.character(substring(origin, 1, 2)) %>% unique()
data_long<-data.frame(source=origin,target=dest,value=movements,IDsource=match(origin, nodes$name)-1,IDtarget=match(dest, nodes$name)-1)
data_long$group<-substring(origin, 1, 3)
ColourScal ='d3.scaleOrdinal() .domain(["Mi","Eu","La","No","Su","Ea","So",
"Mid","Eur","Lat","Nor","Sub","Eas","Sou"]).range(["#7fcdbb", "#756bb1", "#31a354", "#c51b8a", "#f03b20", "#2c7fb8", "#636363",
"#e0f3db","#bcbddc","#addd8e","#fa9fb5","#feb24c","#7fcdbb","#bdbdbd"])'
# Make the Network
sankey1_reg<-sankeyNetwork(Links = data_long, Nodes = nodes,
                       Source = "IDsource", Target = "IDtarget",
                       Value = "value", NodeID = "name",LinkGroup="group",NodeGroup="group",
                       sinksRight=TRUE,colourScale=ColourScal, nodeWidth=40, fontSize=40, nodePadding=25,margin = list(bottom = 50))

origin <- ORG_DEST2$ORG_REGION
dest <- paste(ORG_DEST2$DEST_REGION, " ", sep="")
movements<-ORG_DEST2$n
nodes <- data.frame(name=c(as.character(origin), as.character(dest)) %>% unique())
nodes$group<-as.character(substring(origin, 1, 2)) %>% unique()
data_long<-data.frame(source=origin,target=dest,value=movements,IDsource=match(origin, nodes$name)-1,IDtarget=match(dest, nodes$name)-1)
data_long$group<-substring(origin, 1, 3)
ColourScal ='d3.scaleOrdinal() .domain(["Mi","Eu","La","No","Su","Ea","So",
"Mid","Eur","Lat","Nor","Sub","Eas","Sou"]).range(["#7fcdbb", "#756bb1", "#31a354", "#c51b8a", "#f03b20", "#2c7fb8", "#636363",
"#e0f3db","#bcbddc","#addd8e","#fa9fb5","#feb24c","#7fcdbb","#bdbdbd"])'
# Make the Network
sankey2_reg<-sankeyNetwork(Links = data_long, Nodes = nodes,
                       Source = "IDsource", Target = "IDtarget",
                       Value = "value", NodeID = "name",LinkGroup="group",NodeGroup="group", 
                       sinksRight=TRUE,colourScale=ColourScal, nodeWidth=40, fontSize=40, nodePadding=25,margin = list(bottom = 50))

origin <- ORG_DEST3$ORG_REGION
dest <- paste(ORG_DEST3$DEST_REGION, " ", sep="")
movements<-ORG_DEST3$n
nodes <- data.frame(name=c(as.character(origin), as.character(dest)) %>% unique())
nodes$group<-as.character(substring(origin, 1, 2)) %>% unique()
data_long<-data.frame(source=origin,target=dest,value=movements,IDsource=match(origin, nodes$name)-1,IDtarget=match(dest, nodes$name)-1)
data_long$group<-substring(origin, 1, 3)
ColourScal ='d3.scaleOrdinal() .domain(["Mi","Eu","La","No","Su","Ea","So",
"Mid","Eur","Lat","Nor","Sub","Eas","Sou"]).range(["#7fcdbb", "#756bb1", "#31a354", "#c51b8a", "#f03b20", "#2c7fb8", "#636363",
"#e0f3db","#bcbddc","#addd8e","#fa9fb5","#feb24c","#7fcdbb","#bdbdbd"])'
# Make the Network
sankey3_reg<-sankeyNetwork(Links = data_long, Nodes = nodes,
                       Source = "IDsource", Target = "IDtarget",
                       Value = "value", NodeID = "name",LinkGroup="group",NodeGroup="group", 
                       sinksRight=TRUE,colourScale=ColourScal, nodeWidth=40, fontSize=40, nodePadding=25,margin = list(bottom = 50))


