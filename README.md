# Plant Tissue Sufficiency Range Determination<br />
This repository provides an R-based pipeline to determine plant tissue sufficiency ranges using a survey method with distribution fitting and percentile categorization. This is based of multiple literature papers with a major reference to the workflow of Veazie et al. (2024) and adapted for corn tissue nutrient data. This aim of this project is to create an assessible input analyzer to help determine low, sufficient and toxic ranges in plant tissue analysis. The hope of this project is to supply agronomist and labortory technicians with a starter based in intepreting plant tissue nutrient reports.

## Project Overview<br />
Plant tissue testing is critical for nutrient management and diagnosing deficiencies or toxicities in crops. It is an in-season tool used in assessing crop uptake of soil applied fertilizer. There are multiple methods of determing plant tissue suffiency ranges such as Survery Approach (SA), Diagnosis and Recommendation Integrated System (DRIS) and Critical Value Approach (CVA). The DRIS method is the most preferred and accurate compared to other methods. However, lack of dataset needed to create DRIS ranges makes it hard to implement. Hence, the survey approach is the most adapted method of determining plant tissue ranges. 
This project:

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

### Quick Links to Folders
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

## References <br/ >
Veazie, P., Chen, H., Hicks, K., Holley, J., Eylands, N., Mattson, N., Boldt, J., Brewer, D., Lopez, R., & Whipker, B. E. (2024). A Data-driven Approach for Generating Leaf Tissue Nutrient Interpretation Ranges for Greenhouse Lettuce. HortScience, 59(3), 267–277. https://doi.org/10.21273/HORTSCI17582-23

## Acknowledgments
Based on the distribution fitting and SRA workflow presented in Veazie et al. (2024).

# Developed using current and historical corn tissue samples for applied agronomic research and lab reporting improvement.
