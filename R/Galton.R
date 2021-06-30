library(HistData)
library(dplyr)
library(ggplot2)

data('GaltonFamilies')
set.seed(1983)


## Father & Son Prediction ##

galton_heights <- GaltonFamilies %>%
  filter(gender == "male") %>%
  group_by(family) %>%
  sample_n(1) %>%
  ungroup() %>%
  select(father, childHeight) %>%
  rename(son = childHeight)

# A z-score describes the position of a raw score in terms of its distance from the mean, 
# when measured in standard deviation units. 
# The z-score is positive if the value lies above the mean, 
# and negative if it lies below the mean.


# The benefit of z-scores, are:
# a. It allows researchers to calculate the probability of a score occurring within a standard normal distribution.
# b. Enables us to compare two scores that are from different samples.


galton_heights %>% 
  mutate(z_father = round((father- mean(father)) / sd(father))) %>% 
  filter(z_father %in% -2:2) %>% 
  ggplot() + 
  stat_qq(aes(sample = son)) +
  facet_wrap( ~ z_father)



mu_x <- mean(galton_heights$father)
mu_y <- mean(galton_heights$son)
sd_x <- sd(galton_heights$father)
sd_y <- sd(galton_heights$son)
r <- cor(galton_heihgts$father, galton_heights$son)
m_1 <- r * sd_y/sd_x
b_1 <- mu_y - m_1*mu_x


## Mother & Daughter ##

set.seed(1989, sample.kind="Rounding") #if you are using R 3.6 or later

female_heights <- GaltonFamilies %>% 
  filter(gender == 'female') %>% 
  group_by(family) %>% 
  sample_n(1) %>% 
  ungroup() %>% 
  select(mother, childHeight) %>% 
  rename(daughter = childHeight)




mu_x <- mean(female_heights$mother)
mu_y <- mean(female_heights$daughter)
sd_x <- sd(female_heights$mother)
sd_y <- sd(female_heights$daughter)

r <- cor(female_heights$mother, female_heights$daughter)

m_1 <- r * sd_y/sd_x
b_1 <- mu_y - m_1*mu_x

variance_daughter <- sd_y/mu_y



# least square equations -> to find minimized value for the distance of the fitted model to the data.
# RSS measures the distance between the true value and the predicted value given by the regression line.
# The values that minimize the RSS are called the least square estimations (LSE).

rss <- function(beta0, beta1, data) {
  resid <- galton_heights$son - (beta0+beta1*galton_heights$father)
  return (sum(resid^2))
}

# plot RSS as a function of beta1 when beta0 = 25
beta1 = seq(0, 1, len=nrow(galton_heights))
beta1_ds <- as.data.frame(beta1)
results <- data.frame(beta1 = beta1,
                      rss = sapply(beta1, rss, beta0 = 36))
results %>% ggplot(aes(beta1, rss)) +
  geom_line(aes(beta1, rss))

fit <- lm(son ~ father, data=galton_heights)
summary(fit)



beta1 = seq(0, 1, len=nrow(galton_heights))
results <- data.frame(beta1 = beta1,
                      rss = sapply(beta1, rss, beta0 = 36))
results %>% ggplot(aes(beta1, rss)) + geom_line() + 
  geom_line(aes(beta1, rss), col=2)



## LSE are random variables, proved by normal distribution of monte carlo simulation result.
B <- 1000
N <- 50
lse <- replicate(B, {
  sample_n(galton_heights, N, replace = TRUE) %>% 
    lm(son ~ father, data = .) %>% 
    .$coef
})
lse <- data.frame(beta_0 = lse[1,], beta_1 = lse[2,])

p1 <- lse %>% ggplot(aes(beta_0)) + geom_histogram(binwidth = 5, color = "black")
p2 <- lse %>% ggplot(aes(beta_1)) + geom_histogram(binwidth = 0.1, color = "black")

library(gridExtra)
grid.arrange(p1, p2, ncol = 2)


## Predicted variables are random variables
galton_heights %>% ggplot(aes(son, father)) +
  geom_point() +
  geom_smooth(method = "lm")


galton_heights %>% 
  mutate(Y_hat = predict(lm(son ~ father, data = .))) %>% 
  ggplot(aes(father, Y_hat)) +
  geom_line()

fit <- galton_heights %>% lm(son ~ father, data = .)
Y_hat <- predict(fit, se.fit = TRUE)
names(Y_hat)




library(dplyr)
library(tidyr)
library(HistData)
data("GaltonFamilies")
set.seed(1) # if you are using R 3.5 or earlier
set.seed(1, sample.kind = "Rounding") # if you are using R 3.6 or later

galton <- GaltonFamilies %>%
  group_by(family, gender) %>%
  sample_n(1) %>%
  ungroup() %>% 
  gather(parent, parentHeight, 2:3) %>%
  mutate(child = ifelse(gender == "female", "daughter", "son")) %>%
  unite(pair, c("parent", "child"))


n_row_father_daughter <- 
  galton %>% filter (
  pair == "father_daughter"
)

n_row_mother_son <-
  galton %>% filter (
  pair == "mother_son"
)


###### Quiz ######
mother_daughter_heights <- GaltonFamilies %>% 
  filter(gender == 'female') %>% 
  group_by(family) %>% 
  #sample_n(1) %>% 
  ungroup() %>% 
  select(mother, childHeight) %>% 
  rename(daughter = childHeight)

mother_son_heights <- GaltonFamilies %>% 
  filter(gender == 'male') %>% 
  group_by(family) %>% 
  #sample_n(1) %>%  # only select 1 of many available options
  ungroup() %>% 
  select(mother, childHeight) %>% 
  rename(son = childHeight)

father_son_heights <- GaltonFamilies %>% 
  filter(gender == 'male') %>% 
  group_by(family) %>% 
  #sample_n(1) %>% 
  ungroup() %>% 
  select(father, childHeight) %>% 
  rename(son = childHeight)


father_daughter_heights <- GaltonFamilies %>% 
  filter(gender == 'female') %>% 
  group_by(family) %>% 
  #sample_n(1) %>% 
  ungroup() %>% 
  select(father, childHeight) %>% 
  rename(daughter = childHeight)

r_mother_daughter = cor(mother_daughter_heights$mother, mother_daughter_heights$daughter)
r_mother_son = cor(mother_son_heights$mother, mother_son_heights$son)
r_father_daughter = cor(father_daughter_heights$father, father_daughter_heights$daughter)
r_father_son = cor(father_son_heights$father, father_son_heights$son)


fit_father_daughter <- lm(daughter ~ father , data=father_daughter_heights)
summary(fit_father_daughter)

fit_son_mother <- lm(son ~ mother, data=mother_son_heights)
summary(fit_son_mother)

fit_mother_daughter <- lm(daughter ~ mother, data=mother_daughter_heights)
summary(fit_mother_daughter)

fit_son_father <- lm(son ~ father, data=father_son_heights)
summary(fit_son_father)


library(tibble)
library(broom)
library(dplyr)

# wrong answer - question 1
galton %>%
  group_by(pair) %>%
  do(tidy(lm(childHeight ~ parentHeight, data = .), conf.int = TRUE)) %>%
  filter(term == "parentHeight", pair == "father_daughter") %>%
  pull(estimate)

# wrong answer - question 2
galton %>%
  group_by(pair) %>%
  do(tidy(lm(childHeight ~ parentHeight, data = .), conf.int = TRUE)) %>%
  filter(term == "parentHeight", pair == "mother_son") %>%
  pull(estimate)

###### End of Quiz ######




