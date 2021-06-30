################################################ LINEAR MODELS ################################################

library(Lahman)
library(dplyr)
library(ggplot2)

data(Teams)

# compute regression line for predicting runs from singles
bb_slope <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(BB_per_game = BB/G, R_per_game = R/G) %>% 
  lm(R_per_game ~ BB_per_game, data = .) %>% 
  .$coef %>% 
  .[2]
bb_slope


#singles_slope <- Teams %>% 
#  filter(yearID %in% 1961:2001) %>% 
#  mutate(Singles_per_game = (H-HR-X2B-X3B)/G, R_per_game = R/G) %>% 
#  lm(R_per_game ~ Singles_per_game, data = .) %>% 
#  .$coef %>% 
#  .[2]
#singles_slope


R_slope <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(HR_per_game = HR/G, R_per_game = R/G) %>% 
  lm(R_per_game ~ HR_per_game, data = .) %>% 
  .$coef %>% 
  .[2]
R_slope

#HR_slope <- Teams %>% 
#  filter(yearID %in% 1961:2001) %>% 
#  mutate(BB_per_game = BB/G, HR_per_game = HR/G) %>% 
#  lm(HR_per_game ~ BB_per_game, data = .) %>% 
#  .$coef %>% 
#  .[2]
#HR_slope


# calculate correlation between HR, BB, and singles
Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(Singles = (H-HR-X2B-X3B)/G, BB = BB/G, HR = HR/G) %>% 
  summarize(cor(BB, HR), cor(Singles, HR), cor(BB, Singles))



# stratify HR per game to nearest 10, filter out strata with few points
dat <- Teams %>% filter(yearID %in% 1961:2001) %>% 
  mutate(HR_strata = round(HR/G, 1),
         BB_per_game = BB / G,
         R_per_game = R / G) %>% 
  filter(HR_strata >= 0.4 & HR_strata <= 1.2)


# scatterplot for each HR stratum
dat %>%
  ggplot(aes(BB_per_game, R_per_game)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  facet_wrap( ~ HR_strata)

# calculate slope of regression line after stratifying by HR
dat %>% 
  group_by(HR_strata) %>% 
  summarize(slope = cor(BB_per_game, R_per_game)*sd(R_per_game)/sd(BB_per_game))

# The slopes of BB after stratifying on HR are reduced, but they are not 0, 
# which indicates that BB are helpful for producing runs, just not as much as previously thought.




# stratify by BB
dat <- Teams %>% filter(yearID %in% 1961:2001) %>%
  mutate(BB_strata = round(BB/G, 1),
         HR_per_game = HR / G,
         R_per_game = R / G) %>% 
  filter(BB_strata >= 2.8 & BB_strata <= 3.9)

# scatterplot for each BB stratum
dat %>% 
  ggplot(aes(HR_per_game, R_per_game)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  facet_wrap( ~ BB_strata)

# calculate slope of regression line after stratifying by BB
dat %>% 
  group_by(BB_strata) %>% 
  summarize(slope = cor(HR_per_game, R_per_game)*sd(R_per_game)/sd(HR_per_game))


############################################################################################



# 1. soal 1 ~ slope and intercept

new_data <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(BB_per_game = BB/G, HR_per_game = HR/G, R_per_game = R/G)


new_data <- new_data %>%   
  lm(R_per_game ~ BB_per_game + HR_per_game, data = .) %>% 
  summary %>% 
  .$coef



# 2. soal 2 ~ predictive

set.seed(1989) #if you are using R 3.5 or earlier
set.seed(1989, sample.kind="Rounding") #if you are using R 3.6 or later
library(HistData)
data("GaltonFamilies")
options(digits = 3)    # report 3 significant digits

female_heights <- GaltonFamilies %>%     
  filter(gender == "female") %>%     
  group_by(family) %>%     
  sample_n(1) %>%     
  ungroup() %>%     
  select(mother, childHeight) %>%     
  rename(daughter = childHeight)
  
  
  predict_mother_height_model <- female_heights %>% lm(mother ~ daughter, data = .)
  Y_hat <- predict(predict_mother_height_model, se.fit = TRUE)
  names(Y_hat)
  
# soal 3 ~ data wrangling - summarize
  
  library(Lahman)
  
  bat_02 <- Batting %>% filter(yearID == 2002) %>%
    mutate(pa = AB + BB, singles = (H - X2B - X3B - HR)/pa, bb = BB/pa) %>%
    filter(pa >= 100) %>%
    select(playerID, singles, bb)
  
  bat_03 <- Batting %>% filter(yearID %in% 1999:2001) %>%
    mutate(pa = AB + BB, singles = (H - X2B - X3B - HR)/pa, bb = BB/pa) %>%
    filter(pa >= 100) %>%
    group_by(playerID) %>%
    summarize(
      mean_singles = mean(singles)
      , mean_bb = mean(bb)
    )
  
    a <- sum(bat_02$mean_singles > 0.2)
    a <- as.data.frame(a)
    
    b <- sum(bat_02$mean_bb > 0.2)
    b <- as.data.frame(b)

# soal 4 ~ inner join and correlation measurement
    bat_join <- inner_join(bat_02, bat_03, by="playerID")
    sum(cor(bat_join$singles, bat_join$mean_singles))
    sum(cor(bat_join$bb, bat_join$mean_bb))

#  soal 5 ~ bivariate normal distribution
    cor_singles <- bat_join %>% 
      ggplot(aes(singles, mean_singles)) +
      geom_point()
    
    cor_bb <- bat_join %>% 
      ggplot(aes(bb, mean_bb)) +
      geom_point()
    
    library(gridExtra)
    grid.arrange(cor_singles, cor_bb, ncol = 2)
    
    
    dat %>%
      ggplot(aes(singles, mean_singles)) +
      geom_point()
    dat %>%
      ggplot(aes(bb, mean_bb)) +
      geom_point()  
    
    
# soal 6 ~ predict
    x <- bat_join %>% 
      lm(singles ~ mean_singles, data = .) %>% 
      summary %>% 
      .$coef
    
    y <- bat_join %>% 
      lm(bb ~ mean_bb, data = .) %>% 
      summary %>% 
      .$coef
    
    
############################################################################################

data(Teams)
dat <- as_tibble(Teams)
# as.data.frame(Teams)

dat %>% 
  group_by(HR) %>% 
  # lm(R ~ BB, data = .) # return actual output of lm()
   do(tidy(fit = lm(R ~ BB, data = .))) # return list of data/df, do bridging R function (lm) and tibble data type.


get_lse <- function(data) {
  fit = lm(R ~ BB, data = dat)
  data.frame(
    term = names(fit$coefficients),
    slope = fit$coefficients,
    se = summary(fit)$coefficient[,2]
  )
}

dat2 <- dat %>% 
  group_by(HR) %>% 
  do(get_lse(.))

rlang::last_error()

#library(tidyverse)
#library(tibble)
#library(broom)

fit <- lm(R ~ BB, data = dat)
tidy(fit, conf.int = TRUE)





# Building a Better Offensive Metric for Baseball
# linear regression with two variables
fit <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(BB = BB/G, HR = HR/G,  R = R/G) %>%  
  lm(R ~ BB + HR, data = .)
  tidy(fit, conf.int = TRUE)
  
  
# linear regression with BB, singles, doubles, triples, HR
fit <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(BB = BB / G,
         singles = (H - X2B - X3B - HR) / G,
         doubles = X2B / G,
         triples = X3B / G,
         HR = HR / G,
         R = R / G) %>% 
  lm(R ~ BB + singles + doubles + triples + HR, data = .)
  tidy(fit, conf.int = TRUE)
  
  
# predict number of runs for each team in 2002 and plot
Teams %>% 
  filter(yearID %in% 2002) %>% 
  mutate(BB = BB / G,
         singles = (H - X2B - X3B - HR) / G,
         doubles = X2B / G,
         triples = X3B / G,
         HR = HR / G,
         R = R / G
         ) %>% 
  mutate(R_hat = predict(fit, newdata = .)) %>% 
  ggplot(aes(R_hat, R, label = teamID)) +
  geom_point() +
  geom_text(nudge_x = 0.1, cex = 2) +
  geom_abline()


# average number of team plate appearances per game
pa_per_game <- Batting %>% 
  filter(yearID == 2002) %>% 
  group_by(teamID) %>% 
  summarize(pa_per_game = sum(AB+BB)/max(G)) %>% 
  pull(pa_per_game) %>% 
  mean


# compute per-plate-appearance rates for players available in 2002 using previous data
players <- Batting %>% 
  filter(yearID %in% 1999:2001) %>% 
  group_by(playerID) %>% 
  mutate(PA = BB + AB) %>% 
  summarize(
    G = sum(PA)/pa_per_game,
    BB = sum(BB)/G,
    singles = sum(H-X2B-X3B-HR)/G,
    doubles = sum(X2B)/G, 
    triples = sum(X3B)/G, 
    HR = sum(HR)/G,
    AVG = sum(H)/sum(AB),
    PA = sum(PA)
  ) %>% 
  filter(PA >= 300) %>% 
  select(everything()) %>% 
  mutate(R_hat = predict(fit, newdata = .))


qplot(R_hat, data = players, geom = "histogram", binwidth = 0.5, color = I("black"))


# add 2002 salary of each player
players <- Salaries %>% 
  filter(yearID == 2002) %>%
  select(playerID, salary) %>%
  right_join(players, by="playerID")


# add defensive position
position_names <- c("G_p","G_c","G_1b","G_2b","G_3b","G_ss","G_lf","G_cf","G_rf")
tmp_tab <- Appearances %>% 
  filter(yearID == 2002) %>% 
  group_by(playerID) %>%
  summarize_at(position_names, sum) %>%
  ungroup()  


pos <- tmp_tab %>%
  select(position_names) %>%
  apply(., 1, which.max) 

library(stringr)

players <- data_frame(playerID = tmp_tab$playerID, POS = position_names[pos]) %>%
  mutate(POS = str_to_upper(str_remove(POS, "G_"))) %>%
  filter(POS != "P") %>%
  right_join(players, by="playerID") %>%
  filter(!is.na(POS)  & !is.na(salary))

# add players' first and last names
players <- Master %>%
  select(playerID, nameFirst, nameLast, debut) %>%
  mutate(debut = as.Date(debut)) %>%
  right_join(players, by="playerID")


# top 10 players
players %>% select(nameFirst, nameLast, POS, salary, R_hat) %>% 
  arrange(desc(R_hat, salary)) %>% 
  top_n(10) 


# players with a higher metric have higher salaries
players %>% ggplot(aes(salary, R_hat, color = POS)) + 
  geom_point() +
  scale_x_log10()


# remake plot without players that debuted after 1998
library(lubridate)
players %>% filter(year(debut) < 1998) %>%
  ggplot(aes(salary, R_hat, color = POS)) + 
  geom_point() +
  scale_x_log10()