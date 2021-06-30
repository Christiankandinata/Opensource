library(tidyverse)
library(broom)
library(Lahman)

# get_slope <- function(x, y) cor(x, y) * sd(y) / sd(x)

data <- Teams %>% 
  filter(yearID %in% 1961:2001)

Teams_small <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(avg_attendance = attendance/G, HR_per_game = HR/G, R_per_game = R/G) %>% 
  # summarize(slope = get_slope(avg_attendance, R_per_game))
  lm (avg_attendance ~ R_per_game, data = .) %>% 
  summary %>% 
  .$coef

Teams_small_2 <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(avg_attendance = attendance/G, HR_per_game = HR/G, R_per_game = R/G) %>%
  lm (avg_attendance ~ HR_per_game, data = .) %>% 
  summary %>% 
  .$coef

Teams_small_3 <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(avg_attendance = attendance/G) %>% 
  lm(avg_attendance ~ W, data = .) %>% 
  summary %>% 
  .$coef

Teams_small_4 <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(avg_attendance = attendance/G) %>% 
  lm(avg_attendance ~ yearID, data = .) %>% 
  summary %>% 
  .$coef


# calculate correlation between HR, BB, and singles
Teams_cor <- Teams %>% 
  filter(yearID %in% 1961:2001) %>% 
  mutate(HR_per_game = HR/G, RG_per_game = R/G) %>% 
  summarize(cor(W, HR_per_game), cor(W, RG_per_game))



dat <- Teams %>% filter(yearID %in% 1961:2001) %>% 
  mutate(W_strata = round(W/10, 0), avg_attendance = attendance/G, R_per_game = R/G, HR_per_game = HR/G) # %>% 
  # filter(W_strata >= 7.5 & W_strata <= 8.5)

dat %>%
  ggplot(aes(avg_attendance, R_per_game)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  facet_wrap( ~ W_strata)

dat %>% 
  group_by(W_strata) %>% 
  summarize(slope = cor(avg_attendance, R_per_game)*sd(R_per_game)/sd(avg_attendance))



dat %>%
  ggplot(aes(avg_attendance, HR_per_game)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm") +
  facet_wrap( ~ W_strata)

dat %>% 
  group_by(W_strata) %>% 
  summarize(slope = cor(avg_attendance, HR_per_game)*sd(HR_per_game)/sd(avg_attendance))



# Multivariate Regression Case 1
library(broom)

dat <- Teams %>%
  filter(yearID %in% 1961:2001) %>%
  mutate(avg_attendance = attendance/G, R_per_game = R/G, HR_per_game = HR/G, W2 = W/G) %>% 
  lm(avg_attendance ~ R_per_game + HR_per_game + W + yearID, data = .) %>%
  tidy() %>%
  filter(term == "R_per_game") %>%
  pull(estimate)


dat1 <- Teams %>%
  filter(yearID %in% 1961:2001) %>%
  mutate(avg_attendance = attendance/G, R_per_game = R/G, HR_per_game = HR/G, W2 = W/G) %>% 
  lm(avg_attendance ~ R_per_game + HR_per_game + W + yearID, data = .) %>%
  tidy() %>%
  filter(term == "HR_per_game") %>%
  pull(estimate)


dat2 <- Teams %>%
  filter(yearID %in% 1961:2001) %>%
  mutate(avg_attendance = attendance/G, R_per_game = R/G, HR_per_game = HR/G, W2 = W/G) %>% 
  lm(avg_attendance ~ R_per_game + HR_per_game + W + yearID, data = .) %>%
  tidy() %>%
  filter(term == "W") %>%
  pull(estimate)


# Multivariate Regression Case 2 & 3

dat3 <- Teams %>%
  filter(yearID %in% 1961:2001) %>%
  mutate(
      avg_attendance = attendance/G
      , R_per_game = R/G
      , HR_per_game = HR/G
         ) %>% 
  lm(avg_attendance ~ R_per_game + HR_per_game + W + yearID, data = .) %>%
  summary %>% 
  .$coef
  

# Multivariate Regression Model ~ Prediction

avg_attendance_model <- Teams %>%
  filter(yearID %in% 2002) %>%
  mutate(avg_attendance = attendance/G, R_per_game = R/G, HR_per_game = HR/G) %>% 
  lm(avg_attendance ~ R_per_game + HR_per_game + W + yearID, data = .)

avg_attendance_predict <- Teams %>%
  filter(yearID %in% 2002) %>%
  mutate(avg_attendance = attendance/G, R_per_game = R/G, HR_per_game = HR/G) %>% 
  mutate(avg_attendance_hat = predict(avg_attendance_model, newdata = .))

r_avg_attendance = cor(avg_attendance_predict$avg_attendance, avg_attendance_predict$avg_attendance_hat)


