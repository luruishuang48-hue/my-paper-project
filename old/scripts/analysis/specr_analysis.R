#!/usr/bin/env Rscript
# Specification Curve Analysis: AI Model Releases vs Stock Returns
# Main variables: aa_intelligence_index, aa_coding_index, aa_math_index, aa_media_elo
# Specifications: outcome windows, control variable sets, subsamples, fixed effects

library(specr)
library(estimatr)
library(tidyverse)
library(broom)

# ============================================================================
# 1. LOAD AND PREPARE DATA
# ============================================================================

# Try multiple encodings
encodings <- c('UTF-8', 'GB18030', 'GBK', 'latin1')
df <- NULL
for (enc in encodings) {
  tryCatch({
    df <- read.csv('事件集数据-new.csv', encoding = enc, stringsAsFactors = FALSE, check.names = FALSE)
    cat('Successfully read with encoding:', enc, '\n')
    break
  }, error = function(e) NULL)
}

if (is.null(df)) {
  stop('Failed to read CSV with any encoding')
}

# Extract column names from first row (Chinese headers)
col_names_row1 <- as.character(df[1, ])
col_names_row1 <- ifelse(col_names_row1 == '' | is.na(col_names_row1), colnames(df), col_names_row1)

# Rename columns
names(df) <- col_names_row1

# Keep data rows only
df <- df[-1, ]

# Ensure numeric columns
numeric_cols <- c(
  'car_1', 'car_2', 'car_3', 'car_5', 'car_10', 'car_15', 'car_20',
  'aa_intelligence_index', 'aa_coding_index', 'aa_math_index', 'aa_media_elo',
  'size (log_assets)', 'BM_Ratio', 'volatility', 'Momentum', 'release_year'
)

for (col in numeric_cols) {
  if (col %in% names(df)) {
    df[[col]] <- as.numeric(df[[col]])
  }
}

# Standardize column names for formulas
df <- df %>%
  rename(
    size = `size (log_assets)`,
    bm_ratio = BM_Ratio,
    momentum = Momentum
  )

# Remove rows with missing key variables
key_vars <- c('car_1', 'aa_intelligence_index', 'size', 'bm_ratio', 'volatility', 'momentum', 'relationship')
df <- df[complete.cases(df[, key_vars]), ]

cat('Data loaded:', nrow(df), 'observations,', ncol(df), 'columns\n')

# ============================================================================
# 2. SETUP SPECR ANALYSIS FOR EACH MAIN VARIABLE
# ============================================================================

# Main predictor variables (one at a time)
main_vars <- c('aa_intelligence_index', 'aa_coding_index', 'aa_math_index', 'aa_media_elo')

# Outcome windows
outcomes <- c('car_1', 'car_2', 'car_3', 'car_5', 'car_10', 'car_15', 'car_20')

# Control variable sets
controls_list <- list(
  'no_controls' = '',
  'size_only' = '+ size',
  'all_controls' = '+ size + bm_ratio + volatility + momentum'
)

# Subsamples definitions
subsample_types <- c(
  'all',
  'relationship_publisher', 'relationship_partner', 'relationship_competitor',
  'open_source', 'closed_source',
  'us_creator', 'non_us_creator',
  'text_llm', 'media_model',
  'with_year_fe', 'no_year_fe'
)

# Create all results storage
all_results <- list()
all_specs <- list()

# ============================================================================
# 3. CREATE SUBSAMPLE FILTERS
# ============================================================================

create_subsample <- function(data, subsample_type) {
  switch(subsample_type,
    'all' = data,
    'relationship_publisher' = data %>% filter(relationship == 'publisher'),
    'relationship_partner' = data %>% filter(relationship == 'partner'),
    'relationship_competitor' = data %>% filter(relationship == 'competitor'),
    'open_source' = data %>% filter(as.numeric(is_open_weight_or_open_source) == 1),
    'closed_source' = data %>% filter(as.numeric(is_open_weight_or_open_source) == 0),
    'us_creator' = data %>% filter(creator_type == 'listed_us_company'),
    'non_us_creator' = data %>% filter(creator_type != 'listed_us_company'),
    'text_llm' = data %>% filter(grepl('text|llm', tolower(model_modality), ignore.case = TRUE)),
    'media_model' = data %>% filter(grepl('image|video|media', tolower(model_modality), ignore.case = TRUE)),
    data  # fallback
  )
}

# ============================================================================
# 4. RUN SPECR FOR EACH MAIN VARIABLE
# ============================================================================

for (main_var in main_vars) {
  
  cat('\n=== Processing:', main_var, '===\n')
  
  specs_data <- data.frame()
  
  # Iterate over outcomes, controls, and subsamples
  for (outcome in outcomes) {
    for (ctrl_name in names(controls_list)) {
      for (subsample in subsample_types) {
        
        # Create subsample
        df_sub <- create_subsample(df, subsample)
        
        # Check for fixed effects
        has_year_fe <- grepl('year_fe', subsample)
        base_subsample <- gsub('_with_year_fe|_no_year_fe', '', subsample)
        
        if (base_subsample != subsample) {
          df_sub <- create_subsample(df, base_subsample)
        }
        
        # Skip if subsample too small
        if (nrow(df_sub) < 10) next
        
        # Build formula
        ctrl_str <- controls_list[[ctrl_name]]
        fe_str <- if (has_year_fe) '+ factor(release_year)' else ''
        formula_str <- paste(outcome, '~', main_var, ctrl_str, fe_str)
        
        # Fit model with clustered standard errors
        tryCatch({
          mod <- lm_robust(
            as.formula(formula_str),
            data = df_sub,
            clusters = final_event_id,  # Cluster by event
            se_type = 'CR0'
          )
          
          # Extract results
          coef_main <- coef(mod)[main_var]
          se_main <- se(mod)[main_var]
          pval <- p_value(mod)[main_var]
          ci_lower <- conf_low(mod)[main_var]
          ci_upper <- conf_high(mod)[main_var]
          
          specs_data <- rbind(specs_data, data.frame(
            main_var = main_var,
            outcome = outcome,
            controls = ctrl_name,
            subsample = subsample,
            n_obs = nrow(df_sub),
            coef = coef_main,
            se = se_main,
            pval = pval,
            ci_lower = ci_lower,
            ci_upper = ci_upper,
            significant = pval < 0.05,
            stringsAsFactors = FALSE
          ))
        }, error = function(e) {
          cat('Error in formula:', formula_str, '\n')
        })
      }
    }
  }
  
  all_results[[main_var]] <- specs_data
  cat('Completed:', main_var, '|', nrow(specs_data), 'specifications\n')
}

# ============================================================================
# 5. SAVE AND SUMMARIZE RESULTS
# ============================================================================

# Combine all results
combined_results <- do.call(rbind, all_results)

# Save to CSV
write.csv(combined_results, 'specr_results.csv', row.names = FALSE)

# Summary statistics
summary_stats <- combined_results %>%
  group_by(main_var) %>%
  summarise(
    n_specs = n(),
    n_sig = sum(significant),
    pct_sig = round(100 * sum(significant) / n(), 1),
    mean_coef = mean(coef, na.rm = TRUE),
    sd_coef = sd(coef, na.rm = TRUE),
    min_coef = min(coef, na.rm = TRUE),
    max_coef = max(coef, na.rm = TRUE),
    .groups = 'drop'
  )

write.csv(summary_stats, 'specr_summary.csv', row.names = FALSE)

cat('\n=== SUMMARY ===\n')
print(summary_stats)

cat('\nResults saved to specr_results.csv and specr_summary.csv\n')
