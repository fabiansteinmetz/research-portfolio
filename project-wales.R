# installing the required libraries
required_packages <- c("dplyr", "ggplot2", "fixest", "lmtest", "sandwich")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) install.packages(pkg)
  library(pkg, character.only = TRUE)
}

# load the data
filename <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRaXVk1w8HDqmwWlB16uBzLGH4MFBUfCcGVR-EghaukXc5Yxh8LNOpvT8qWFG8pFyf0Y0bt57NvObCp/pub?gid=1015296938&single=true&output=csv"
df <- read.csv(filename)

# data cleaning
df_clean <- df %>%
  mutate(
    # define treatment and groups
    treatment = ifelse(substr(local_authority_ons_district, 1, 1) == "W", 1, 0), # startign with W = Wales
    group = ifelse(treatment == 1, "Wales", "England/Scotland"), # everything else is control
    
    # define post period (sept 2023 -> q4 2023)
    post = ifelse(year > 2023 | (year == 2023 & quarter == "Q4"), 1, 0),
    
    # log transformations
    log_collisions = log(collisions + 1),
    log_traffic_density = ifelse(traffic_density > 0, log(traffic_density + 1), 0),
    
    # time variables
    period = paste0(year, "-", quarter),
    time_numeric = year + (as.numeric(substr(quarter, 2, 2)) - 1) / 4
  ) %>%
  filter(!is.na(log_collisions), is.finite(log_traffic_density),
         is.finite(income))

# filter pilot areas (early adopters)
# removing cardiff, monmouthshire, flintshire, pembrokeshire, vale of glamorgan, carmarthenshire
pilots <- c("W06000015", "W06000021", "W06000005", "W06000009", "W06000014", "W06000010")
df_clean <- df_clean %>% filter(!local_authority_ons_district %in% pilots)

# plot 1: raw parallel trends (outcome over time)
plot_data <- df_clean %>%
  group_by(group, time_numeric) %>%
  summarise(mean_log_collisions = mean(log_collisions, na.rm = TRUE), .groups = 'drop')

ggplot(plot_data, aes(x = time_numeric, y = mean_log_collisions, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2023.5, linetype = "dashed", color = "gray50") + 
  geom_text(aes(x=2023.3, label="Speed Limit Policy", y=1), colour="gray50", angle=90, vjust = 1.2, text=element_text(size=11))+

  labs(title = "",
       x = "year", y = "mean log(collisions)", color = "") +
  theme_minimal() +
  theme(legend.position = "bottom")

# model: two-way fixed effects
df_clean$did_treatment <- df_clean$treatment * df_clean$post

twfe_model <- feols(log_collisions ~ did_treatment + log_traffic_density + rainfall |
                      local_authority_ons_district + period,
                    data = df_clean,
                    cluster = ~local_authority_ons_district)

# print all coefficients
print(summary(twfe_model))

# interpretation
coef_est <- coef(twfe_model)["did_treatment"]
pct_effect <- (exp(coef_est) - 1) * 100
cat(paste("\npolicy impact:", round(coef_est, 4),
          "| pct change:", round(pct_effect, 2), "%\n"))

# plot 2: event study
event_study <- feols(log_collisions ~ i(period, treatment, ref = "2023-Q3") +
                       log_traffic_density + rainfall |
                       local_authority_ons_district + period,
                     data = df_clean,
                     cluster = ~local_authority_ons_district)

summary(event_study)
iplot(event_study, main = "Interaction Terms Coefficients", pt.join = TRUE)


# PLACEBO
######
# PLACEBO TESTS - we can also add more if relevant
######
# create placebo post variable (fake policy in 2022 Q4)
df_placebo <- df_clean %>%
  mutate(placebo_post = ifelse(year > 2021 | (year == 2021 & quarter == "Q4"), 1, 0),
         placebo_did = treatment * placebo_post)

# placebo TWFE model
placebo_twfe <- feols(
  log_collisions ~ placebo_did + log_traffic_density + rainfall |
    local_authority_ons_district + period,
  data = df_placebo,
  cluster = ~local_authority_ons_district
)

summary(placebo_twfe)

# interpret placebo effect
placebo_coef <- coef(placebo_twfe)["placebo_did"]
placebo_pct <- (exp(placebo_coef) - 1) * 100
cat("Placebo effect:", round(placebo_coef, 4),
    "| pct change:", round(placebo_pct, 2), "%\n")

event_study_2 <- feols(log_collisions ~ i(period, treatment, ref = "2021-Q3") +
                         log_traffic_density + rainfall |
                         local_authority_ons_district + period,
                       data = df_clean,
                       cluster = ~local_authority_ons_district)

summary(event_study_2)
iplot(event_study_2, main = "event study coefficients PLACEBO 2021", pt.join = TRUE)


# summary table

install.packages("modelsummary")
library(modelsummary)
df_pre  <- df_clean %>% filter(post == 0)
df_post <- df_clean %>% filter(post == 1)
datasummary(
  collisions + log_collisions + traffic_density + log_traffic_density +
    rainfall + income ~
    mean + sd,
  data = list(
    "Pre"  = df_pre,
    "Post" = df_post
  ),
  output = "markdown"
)

datasummary(
  collisions + log_collisions + traffic_density + log_traffic_density +
    rainfall + income ~
    Mean = mean + SD = sd,
  data = list(
    "Pre-treatment"  = df_pre,
    "Post-treatment" = df_post
  ),
  fmt = 2,
  title = "Descriptive Statistics Before and After Policy",
  output = "latex"
)





