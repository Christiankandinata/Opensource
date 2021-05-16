## Organizing & Transforming Penguin Data

library(palmerpenguins)
library(dplyr)
library(tidyr)

library(here)
library(skimr) # skim_without_charts(), glimpse(), head() function
library(janitor) # rename(), rename_with() function


skim_without_charts(penguins)
glimpse(penguins)
head(penguins)

penguins %>% 
  select(-species) ## select all columns except species

penguins %>% 
  rename(island_new=island) ## rename colnames from "island" to "island_new"

rename_with(penguins, toupper) ## rename colnames into uppercase
rename_with(penguins, tolower) ## rename colnames into lowercase

clean_names(penguins) ## clean names that ensure there's only characters, numbers, and underscores in the names

####

penguins %>% 
  arrange(bill_depth_mm) ## asc order by

penguins %>% 
  arrange(-bill_depth_mm) ## desc order by

penguins %>% 
  group_by(island) %>% 
  drop_na() %>% 
  summarize(mean_bill_length_mm=mean(bill_length_mm))

penguins %>% 
  group_by(island) %>% 
  drop_na() %>% 
  summarize(max_bill_length_mm=max(bill_length_mm))


penguins %>% 
  group_by(species, island) %>% 
  drop_na() %>% 
  summarize(max_bill_length_mm=max(bill_length_mm), mean_bill_length_mm=mean(bill_length_mm))


penguins %>% 
  filter(species=="Adelie")

####

id <- c(1:10)

name <- c("John Mendes", "Rob Stewart", "Rachel Abrahamson", "Christy Hickman", "Johnson Harper", "Candace Miller", "Carlson Landy", "Pansy Jordan", "Darius Berry", "Claudia Garcia")

job_title <- c("Professional", "Programmer", "Management", "Clerical", "Developer", "Programmer", "Management", "Clerical", "Developer", "Programmer")

employee <- data.frame(id, name, job_title)

separate(employee, name, into=c('first_name', 'last_name'), sep=' ') ## Separator function

first_name <- c('John', 'Rob', 'Rachel', 'Christy', 'Johnson', 'Candace', 'Carlson', 'Pansy', 'Darius', 'Claudia')
last_name <- c('Medes', 'Stewart', 'Abrahamson', 'Hickman', 'Harper', 'Miller', 'Landy', 'Jordan', 'Berry', 'Garcia')
job_title <- c("Professional", "Programmer", "Management", "Clerical", "Developer", "Programmer", "Management", "Clerical", "Developer", "Programmer")

employee <- data.frame(id, first_name, last_name, job_title)

unite(employee, 'name', first_name, last_name, sep = ' ') ## Unite function


View(penguins)

penguins %>% 
  mutate(body_mass_kg = body_mass_g/1000, flipper_length_m=flipper_length_mm/1000)


#### Same data, but with different outcomes

library(Tmisc)
View(quartet)
library(ggplot2)

## Checking I, II, III, IV data with statistical summaries
quartet %>% 
  group_by(set) %>% 
  summarize(mean(x), sd(x), mean(y), sd(y), cor(x,y))

## showing difference between I, II, III, and IV are different.
ggplot(quartet, aes(x,y)) + geom_point() + geom_smooth(method=lm, se=FALSE) + facet_wrap(~set)


install.packages('datasauRus')
library('datasauRus')
View(datasaurus_dozen)

ggplot(datasaurus_dozen, aes(x=x,y=y,colour=dataset)) + geom_point() + theme_void() + theme(legend.position = "none") + facet_wrap(~dataset)



#### Bias Function
install.packages('SimDesign')
library('SimDesign') ## bias() function

actual_temp = c(68.3, 70, 72.4, 71, 67, 70)
predicted_temp = c(67.9, 69, 71.5, 70, 67, 69)
bias(actual_temp, predicted_temp) ## 0.71 is pretty high. The predictions seem biased towards lower temperatures, which means they aren't as accurate as they could be. 
