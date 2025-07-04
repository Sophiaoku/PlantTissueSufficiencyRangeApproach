# Plant Tissue Sufficiency Range Determination<br />
This repository provides an R-based pipeline to determine plant tissue sufficiency ranges using a survey method with distribution fitting and percentile categorization. It builds on multiple literature sources, with major reference to the workflow of Veazie et al. (2024), and has been adapted for corn tissue nutrient data. The aim of this project is to create an accessible input analyzer to help determine low, sufficient, and toxic ranges in plant tissue analysis. This project is intended to provide agronomists and laboratory technicians with a practical starting point for interpreting plant tissue nutrient reports.

## Project Overview<br />
Plant tissue testing is critical for nutrient management and for diagnosing deficiencies or toxicities in crops. It is an in-season tool used to assess crop uptake of soil-applied fertilizers. There are multiple methods for determining plant tissue sufficiency ranges, including the Survey Approach (SA), the Diagnosis and Recommendation Integrated System (DRIS), and the Critical Value Approach (CVA). Although the DRIS method is often considered the most accurate, its implementation is limited by the lack of large datasets needed to develop DRIS ranges. As a result, the survey approach remains the most widely used method for determining plant tissue sufficiency ranges. This project:

- collect, clean and sort historical data
- Analyzes data using an input analyzer in R to identify the best-fitting distribution (Normal, Gamma, or Weibull) based on BIC.

- Segments data into categories:

    - Deficient: lowest 2.5% (0.025 quantile)

    - Low: 2.5% to 25% (0.025–0.25)

    - Sufficient: 25% to 75% (0.25–0.75)

    - High: 75% to 97.5% (0.75–0.975)

    - Excessive: top 2.5% (>0.975)


## Script Features<br />
- Input Analyzer: Automatically fits Normal, Gamma, and Weibull distributions, selects the best model using BIC, and overlays fitted curves on histograms.

- Percentile Stability Analysis: Evaluates how percentile estimates stabilize with increasing sample sizes, recommending minimum dataset sizes to determine an optimum sample size.

- Visualization: Generates clean ggplot2 histograms with fitted distributions and quantile markings.

- Goodness-of-Fit Testing: Reports Shapiro-Wilk and Kolmogorov-Smirnov p-values for model assessment.

- BIC Summary Table: Summarizes BIC values across models for each nutrient.

## Quick Links to Folders<br />
- [Code](./Code/) Model training, evaluation, and utility scripts <br />
- [Reports](./Reports/) Project reports and presentation materials <br />
- [Docs](./Docs/) Supporting literature and PDFs <br />

## Requirements<br />
- R (≥4.0)

- ### Packages:

  - ggplot2

  - fitdistrplus

  - gridExtra

  - reshape2

  - goftest

  - scales

## References<br/ >
Veazie, P., Chen, H., Hicks, K., Holley, J., Eylands, N., Mattson, N., Boldt, J., Brewer, D., Lopez, R., & Whipker, B. E. (2024). A Data-driven Approach for Generating Leaf Tissue Nutrient Interpretation Ranges for Greenhouse Lettuce. HortScience, 59(3), 267–277. https://doi.org/10.21273/HORTSCI17582-23

## Acknowledgments
Based on the distribution fitting and SRA workflow presented in Veazie et al. (2024).

# Developed using current and historical corn tissue samples for applied agronomic research and lab reporting improvement.
