library(ggplot2)
library(reshape2)
library(fitdistrplus)
library(gridExtra)
library(goftest)
library(scales)

set.seed(123)


create_custom_pool <- function(n = 2000, min_val, max_val) {
  cluster1 <- runif(n * 0.3, min_val, (min_val + max_val) / 2)
  cluster2 <- runif(n * 0.5, (min_val + max_val) / 2, max_val)
  outliers <- c(min_val, max_val)  # simulate edge values
  noise <- sample(seq(min_val, max_val, length.out = 100), n * 0.2, replace = TRUE)
  pool <- c(cluster1, cluster2, outliers, noise)
  return(pool)
}

n_samples <- 500 #samole dataset with replacement
df <- data.frame(
  Nitrate = sample(create_custom_pool(2000, 2.5, 4.5), n_samples),
  P = sample(create_custom_pool(2000, 0.20, 0.45), n_samples),
  K = sample(create_custom_pool(2000, 1.90, 3.25), n_samples),
  Ca = sample(create_custom_pool(2000, 0.10, 0.55), n_samples),
  Mg = sample(create_custom_pool(2000, 0.10, 0.35), n_samples),
  Cu = sample(create_custom_pool(2000, 4, 27), n_samples),
  Zn = sample(create_custom_pool(2000, 16, 70), n_samples),
  B = sample(create_custom_pool(2000, 3, 27), n_samples)
)

head(df)

###########################################################################################


input_analyzer <- function(df) {
  results_list <- list()
  plots <- list()
  
  for (nutrient in names(df)) {
    cat("\nAnalyzing:", nutrient, "\n")
    data <- df[[nutrient]]
    
  
    fits <- list(
      normal = fitdist(data, "norm"),
      gamma = tryCatch(fitdist(data, "gamma"), error = function(e) NULL),
      weibull = tryCatch(fitdist(data, "weibull"), error = function(e) NULL)
    )
    
    fits_for_gof <- fits[sapply(fits, Negate(is.null))]
    if (length(fits_for_gof) == 0) {
      warning(paste("No valid fit for", nutrient))
      next
    }
    
    gof <- gofstat(fits_for_gof)
    best_fit <- names(which.min(gof$bic))
    cat("Best fit based on BIC:", best_fit, "\n")
    results_list[[nutrient]] <- list(fits = fits, gof = gof, best_fit = best_fit)
    
    p <- ggplot(data.frame(x = data), aes(x)) +
      geom_histogram(aes(y = ..density..), bins = 15, fill = "lightgray", color = "black") +
      ylab("Density") +
      ggtitle(paste("Best Fit for", nutrient, ":", best_fit)) +
      theme_minimal()
    
   
    if (!is.null(fits$normal)) {
      mu <- fits$normal$estimate["mean"]
      sigma <- fits$normal$estimate["sd"]
      p <- p + stat_function(fun = dnorm,
                             args = list(mean = mu, sd = sigma),
                             aes(color = "Normal"), linewidth = 1)
    }
    if (!is.null(fits$gamma)) {
      shape <- fits$gamma$estimate["shape"]
      rate <- fits$gamma$estimate["rate"]
      p <- p + stat_function(fun = dgamma,
                             args = list(shape = shape, rate = rate),
                             aes(color = "Gamma"), linewidth = 1)
    }
    if (!is.null(fits$weibull)) {
      shape <- fits$weibull$estimate["shape"]
      scale <- fits$weibull$estimate["scale"]
      p <- p + stat_function(fun = dweibull,
                             args = list(shape = shape, scale = scale),
                             aes(color = "Weibull"), linewidth = 1)
    }
    
    
    p <- p + scale_color_manual(
      name = "Distributions",
      values = c("Normal" = "blue", "Gamma" = "red", "Weibull" = "green")
    )
    
   
    clean_fit_name <- gsub("^3-mle-", "", best_fit)
    if (!is.null(fits[[clean_fit_name]])) {
      best_params <- fits[[clean_fit_name]]$estimate
      qvals <- NULL
      if (clean_fit_name == "normal") {
        qvals <- qnorm(c(0.025, 0.25, 0.75, 0.975),
                       mean = best_params["mean"],
                       sd = best_params["sd"])
      } else if (clean_fit_name == "gamma") {
        qvals <- qgamma(c(0.025, 0.25, 0.75, 0.975),
                        shape = best_params["shape"],
                        rate = best_params["rate"])
      } else if (clean_fit_name == "weibull") {
        qvals <- qweibull(c(0.025, 0.25, 0.75, 0.975),
                          shape = best_params["shape"],
                          scale = best_params["scale"])
      }
      
      if (!is.null(qvals) && all(!is.na(qvals))) {
        p <- p + 
          annotate("rect",
                   xmin = qvals[2], xmax = qvals[3],
                   ymin = 0, ymax = Inf,
                   fill = "gray80", alpha = 0.3)
        
        labels <- c("2.5%", "25%", "75%", "97.5%")
        colors <- c("darkred", "darkorange", "darkgreen", "darkblue")
        
        for (i in seq_along(qvals)) {
          p <- p +
            geom_vline(xintercept = qvals[i], linetype = "dotted", 
                       color = colors[i], linewidth = 1.1, show.legend = FALSE) +
            annotate("text", x = qvals[i], y = Inf, label = labels[i],
                     vjust = -0.5, hjust = 0.5, size = 3, color = colors[i])
        }
      }
    }
    
    plots[[nutrient]] <- p
  }
  
  do.call("grid.arrange", c(plots, ncol = 2))
  return(results_list)
}


#######################line break#############################################
analysis_results <- input_analyzer(df)


#####################################################################################
#####################################################################################
#############################PERCENTILE STABILITY####################################


#what you will find is that the confidence increases as the spread decreases looking at both the 10th and 90th percentile.
#The recommendation here is to target at least greater than 400 samples to get a good estimate of the true value.
#especially if we are relying on the quarantines to classify deficient, sufficient and excessive nutrients.
#I have changed the "n_sub" values to include 700 and you don't really see a any further stabilization after a sample size of 400..

percentile_stability <- function(data, n_sub = c(50, 350, 400, 500), reps = 500) {
  result <- data.frame()
  
  for (n in n_sub) {
    for (i in 1:reps) {
      sample_data <- sample(data, size = n, replace = TRUE)
      p10 <- quantile(sample_data, 0.10)
      p90 <- quantile(sample_data, 0.90)
      result <- rbind(result, data.frame(n = n, p10 = p10, p90 = p90))
    }
  }
  
  return(result)
}

# Example using Nitrate
set.seed(123)
bootstrap_results <- percentile_stability(df$Nitrate, n_sub = c(50, 350, 400, 500), reps = 500)

library(ggplot2)
ggplot(bootstrap_results, aes(x = factor(n))) +
  geom_boxplot(aes(y = p10), fill = "lightblue", outlier.shape = NA) +
  ggtitle("10th Percentile Stability Across Sample Sizes") +
  ylab("10th Percentile") + xlab("Sample Size")

ggplot(bootstrap_results, aes(x = factor(n))) +
  geom_boxplot(aes(y = p90), fill = "lightgreen", outlier.shape = NA) +
  ggtitle("90th Percentile Stability Across Sample Sizes") +
  ylab("90th Percentile") + xlab("Sample Size")

#####################################################################################
#####################################################################################
############################# TEST THE FIT #########################################

compute_gof_pvalues <- function(df) {
  results <- data.frame(
    Nutrient = character(),
    Shapiro_p = numeric(),
    KS_Gamma_p = numeric(),
    KS_Weibull_p = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (nutrient in names(df)) {
    cat("Processing", nutrient, "\n")
    
    data <- na.omit(df[[nutrient]])
    
    if (length(data) < 10) {
      warning(paste("Skipping", nutrient, "- not enough data"))
      next
    }
    
    shapiro_p <- tryCatch(shapiro.test(data)$p.value, error = function(e) NA)
    

    gamma_fit <- tryCatch(fitdist(data, "gamma"), error = function(e) NULL)
    ks_gamma_p <- if (!is.null(gamma_fit)) {
      tryCatch(ks.test(data, "pgamma",
                       shape = gamma_fit$estimate["shape"],
                       rate = gamma_fit$estimate["rate"])$p.value,
               error = function(e) NA)
    } else {
      NA
    }
    
    weibull_fit <- tryCatch(fitdist(data, "weibull"), error = function(e) NULL)
    ks_weibull_p <- if (!is.null(weibull_fit)) {
      tryCatch(ks.test(data, "pweibull",
                       shape = weibull_fit$estimate["shape"],
                       scale = weibull_fit$estimate["scale"])$p.value,
               error = function(e) NA)
    } else {
      NA
    }
    
    
    results <- rbind(results, data.frame(
      Nutrient = nutrient,
      Shapiro_p = shapiro_p,
      KS_Gamma_p = ks_gamma_p,
      KS_Weibull_p = ks_weibull_p
    ))
  }
  
  return(results)
}

pvalue_results <- compute_gof_pvalues(df)
print(pvalue_results)

#####################################################################################
#####################################################################################
#################################### BIC VALUES ###########################################

compute_bic_table <- function(df) {
  results <- data.frame(
    Nutrient = character(),
    BIC_Normal = numeric(),
    BIC_Gamma = numeric(),
    BIC_Weibull = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (nutrient in names(df)) {
    cat("Processing", nutrient, "\n")
    data <- na.omit(df[[nutrient]])
    
    # Fit each distribution
    normal_fit <- tryCatch(fitdist(data, "norm"), error = function(e) NULL)
    gamma_fit <- tryCatch(fitdist(data, "gamma"), error = function(e) NULL)
    weibull_fit <- tryCatch(fitdist(data, "weibull"), error = function(e) NULL)
    
    # Extract BICs (use NA if model failed)
    bic_normal  <- if (!is.null(normal_fit)) gofstat(normal_fit)$bic else NA
    bic_gamma   <- if (!is.null(gamma_fit))  gofstat(gamma_fit)$bic  else NA
    bic_weibull <- if (!is.null(weibull_fit)) gofstat(weibull_fit)$bic else NA
    
    # Store result
    results <- rbind(results, data.frame(
      Nutrient = nutrient,
      BIC_Normal = bic_normal,
      BIC_Gamma = bic_gamma,
      BIC_Weibull = bic_weibull
    ))
  }
  
  return(results)
}


bic_results <- compute_bic_table(df)
rownames(bic_results) <- NULL
print(bic_results)
