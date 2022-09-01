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
lable_size=60
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
dat_move<-data.frame(org_c,dest_c,MOVE_STAGE,movements)

####Chord diagram########
#########################
#format the data as numeric
dat_move$movements <- as.numeric( gsub(",","",dat_move$movements))
#library(reshape2)
data<-acast(dat_move,org_c~dest_c,value.var = "movements")
replaceStrings <- data.frame( from = c("High income","Upper middle income","Lower middle income", "Low income"), to = c("H", "UM", "LM", "L"))

dat_move <- FindReplace(data = as.data.frame(dat_move), Var = "org_c", replaceData = replaceStrings, from = "from", to = "to", exact = FALSE)
dat_move <- FindReplace(data = as.data.frame(dat_move), Var = "dest_c", replaceData = replaceStrings, from = "from", to = "to", exact = FALSE)

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

ColourScal ='d3.scaleOrdinal() .domain(["HI","UP","LM","LO","HII","UPM","LMI",
"LOI"]).range(["#7fcdbb", "red", "blue", "yellow",
   "#7fcdbb", "red", "blue", "yellow"])'
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
ColourScal ='d3.scaleOrdinal() .domain(["HI","UP","LM","LO","HII","UPM","LMI",
"LOI"]).range(["#7fcdbb", "red", "blue", "yellow",
   "#7fcdbb", "red", "blue", "yellow"])'
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
dat_move<-data.frame(org_c,dest_c,MOVE_STAGE,movements)
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


