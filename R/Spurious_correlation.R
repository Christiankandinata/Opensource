# 1. Spurious Correlation

  N <- 25
  g <- 1000000
  
  sim_data <- tibble(group = rep(1:g, each = N), x = rnorm(N * g), y = rnorm(N * g))
  
  # calculate correlation between X,Y for each group
  res <- sim_data %>% 
    group_by(group) %>% 
    summarize(r = cor(x, y)) %>% 
    arrange(desc(r))
  
  # plot points from the group with maximum correlation
  sim_data %>% filter(group == res$group[which.max(res$r)]) %>% 
    ggplot(aes(x,y)) + 
    geom_point() + 
    geom_smooth(method = "lm")
  
  # histogram of correlation in Monte Carlo simulations
  res %>% ggplot(aes(x=r)) +
    geom_histogram(binwidth = 0.1, color = "black")
  
  library(broom)
  sim_data %>% 
    filter(group == res$group[which.max(res$r)]) %>% 
    do(tidy(lm(y ~ x, data = .)))


# 1. Outliers Correlation

  # simulate independent X, Y and standardize all except entry 23
  set.seed(1985)
  x <- rnorm(100, 100, 1)
  y <- rnorm(100, 84, 1)
  x[-23] <- scale(x[-23])
  y[-23] <- scale(y[-23])
  
  # plot shows the outlier
  qplot(x, y, alpha = 0.5)

  # outlier makes it appear there is correlation
  cor(x,y)
  cor(x[-23], y[-23])
  
  # use rank instead
  qplot(rank(x), rank(y))
  cor(rank(x), rank(y))
  
  # Spearman correlation with cor function
  cor(x, y, method = "spearman")



# 3. Reverse Cause and Effect Correlation

# 4. Confounders Correlation
# If X and Y are correlated, we call Z a confounder if changes in Z causes changes in both X and Y.

library(dslabs)
data(admissions)
admissions


# 5. Simpson's Paradox
# Simpson's Paradox happens when we see the sign of the correlation flip when comparing the entire dataset with specific strata.


library(dslabs)
data("research_funding_rates")
research_funding_rates

new_table <- research_funding_rates %>% 
  summarise(
    tot_application_men = sum(applications_men)
    , tot_application_women = sum(applications_women)
    , tot_awards_men = sum(awards_men)
    , tot_awards_women = sum(awards_women)
  )

two_by_two <- research_funding_rates %>% 
  select(-discipline) %>% 
  summarize_all(funs(sum)) %>%
  summarize(yes_men = awards_men, 
            no_men = applications_men - awards_men, 
            yes_women = awards_women, 
            no_women = applications_women - awards_women) %>%
  gather %>%
  separate(key, c("awarded", "gender")) %>%
  spread(gender, value)


chisq_test <- two_by_two %>% select(-awarded) %>% chisq.test()


two_by_two %>% 
  mutate(men = round(men/sum(men)*100, 1), women = round(women/sum(women)*100, 1)) %>%
  filter(awarded == "yes") %>%
  pull(men)

two_by_two %>% 
  mutate(men = round(men/sum(men)*100, 1), women = round(women/sum(women)*100, 1)) %>%
  filter(awarded == "yes") %>%
  pull(women)



dat <- research_funding_rates %>% 
  mutate(discipline = reorder(discipline, success_rates_total)) %>%
  rename(success_total = success_rates_total,
         success_men = success_rates_men,
         success_women = success_rates_women) %>%
  gather(key, value, -discipline) %>%
  separate(key, c("type", "gender")) %>%
  spread(type, value) %>%
  filter(gender != "total")

dat2 <- dat %>% 
  ggplot(aes(success, discipline, col = gender, size = applications)) +
  geom_point()




