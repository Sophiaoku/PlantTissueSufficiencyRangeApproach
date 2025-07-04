# Plant Tissue Sufficiency Range Determination<br />

This repository provides an R-based pipeline to determine plant tissue sufficiency ranges using a survey method with distribution fitting and percentile categorization. This is based of multiple literature papers with a major reference to the workflow of Veazie et al. (2024) and adapted for corn tissue nutrient data. This aim of this project is to create an assessible input analyzer to help determine low, sufficient and toxic ranges in plant tissue analysis. The hope of this project is to supply agronomist and labortory technicians with a starter based in intepreting plant tissue nutrient reports.

## Project Overview
Plant tissue testing is critical for nutrient management and diagnosing deficiencies or toxicities in crops. It is an in-season tool used in assessing crop uptake of soil applied fertilizer. There are different methods of determing plant tissue suffiency ranges Traditional sufficiency ranges often rely on small survey datasets without quantifying uncertainty across deficiency, sufficiency, and excess zones. This project:

Collects ≥50 tissue samples at the optimal sampling time.

Analyzes data using an input analyzer in R to identify the best-fitting distribution (Normal, Gamma, or Weibull) based on BIC.

Segments data into categories:

Deficient: lowest 2.5% (0.025 quantile)

Low: 2.5% to 25% (0.025–0.25)

Sufficient: 25% to 75% (0.25–0.75)

High: 75% to 97.5% (0.75–0.975)

Excessive: top 2.5% (>0.975)

The approach refines sufficiency ranges using historical and current corn tissue data to better classify nutrient statuses in grower samples and regional extension recommendations.

Features
📊 Input Analyzer: Automatically fits Normal, Gamma, and Weibull distributions, selects the best model using BIC, and overlays fitted curves on histograms.

🪄 Percentile Stability Analysis: Evaluates how percentile estimates stabilize with increasing sample sizes, recommending minimum dataset sizes for robust sufficiency range development.

📈 Visualization: Generates clean ggplot2 histograms with fitted distributions and quantile markings.

📝 Goodness-of-Fit Testing: Reports Shapiro-Wilk and Kolmogorov-Smirnov p-values for model assessment.

📉 BIC Summary Table: Summarizes BIC values across models for each nutrient.

Repository Structure
input_analyzer.R: Contains the main pipeline for fitting distributions and generating plots.

percentile_stability.R: Bootstrap analysis for determining stable sample size thresholds.

gof_and_bic_tests.R: Scripts to compute goodness-of-fit p-values and BIC tables.

Veazie et al. (2024).pdf: Source paper inspiring this workflow, demonstrating the approach on greenhouse lettuce.

README.md: Project overview and instructions.

Requirements
R (≥4.0)

Packages:

ggplot2

fitdistrplus

gridExtra

reshape2

goftest

scales

Usage
1️⃣ Clone the repository:

bash
Copy
Edit
git clone https://github.com/yourusername/plant-tissue-sufficiency.git
cd plant-tissue-sufficiency
2️⃣ Install required R packages:

r
Copy
Edit
install.packages(c("ggplot2", "fitdistrplus", "gridExtra", "reshape2", "goftest", "scales"))
3️⃣ Run the pipeline:

r
Copy
Edit
source("input_analyzer.R")
source("percentile_stability.R")
source("gof_and_bic_tests.R")
4️⃣ Interpret outputs:

Distribution plots with shaded sufficiency ranges.

Stability plots indicating the sample size at which quantiles stabilize (e.g., n > 400 recommended).

Goodness-of-fit p-values for model validation.

BIC tables to guide model selection.

Reference
Veazie, P., Chen, H., Hicks, K., Holley, J., Eylands, N., Mattson, N., Boldt, J., Brewer, D., Lopez, R., & Whipker, B. E. (2024). A Data-driven Approach for Generating Leaf Tissue Nutrient Interpretation Ranges for Greenhouse Lettuce. HortScience, 59(3), 267–277. https://doi.org/10.21273/HORTSCI17582-23

License
This repository is shared under the MIT License.

Acknowledgments
Based on the distribution fitting and SRA workflow presented in Veazie et al. (2024).

Developed using current and historical corn tissue samples for applied agronomic research and lab reporting improvement.
