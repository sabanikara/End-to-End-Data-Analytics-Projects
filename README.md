# Oil & Gas Pipeline Predictive Maintenance

An End-to-End Data Science and Business Intelligence Project

## Project Overview

This project explores how data science, machine learning, SQL Server, and Power BI can be combined to analyze oil and gas pipeline conditions and support predictive maintenance planning.

The project uses pipeline characteristics and operating data to classify pipeline conditions into three categories: **Normal, Moderate, and Critical**. It also includes SQL-based data analysis and an interactive Power BI dashboard to investigate pipeline degradation, assess risk, and identify records that may require further inspection.

The objective is to demonstrate an end-to-end analytical workflow, from exploratory data analysis and machine learning to database querying and business intelligence reporting.

## Business Problem

Pipeline degradation can lead to safety risks, environmental damage, and costly operational downtime. Identifying potentially critical pipeline conditions can help maintenance teams prioritize inspections and make more informed decisions.

This project addresses the problem through three complementary components:

- **Machine Learning:** Classifies pipeline conditions using pipeline characteristics and operating data.
- **SQL Server:** Stores, queries, and analyzes pipeline records, risk categories, and maintenance priorities.
- **Power BI:** Presents key performance indicators and interactive visualizations for pipeline condition and risk analysis.

The project is intended for educational and portfolio purposes and is based on a synthetic dataset.

## Dataset

- **Source:** [Kaggle – Predictive Maintenance Oil and Gas Pipeline Data](https://www.kaggle.com/datasets/muhammadwaqas023/predictive-maintenance-of-oil-and-gas-pipeline-data)
- **Number of records:** 1,000
- **Number of columns:** 11
- **Input features:** 10
- **Target variable:** `Condition`
- **Target classes:** Normal, Moderate, Critical

### Dataset Features

The dataset contains the following pipeline attributes:

- `Pipe_Size_mm`
- `Thickness_mm`
- `Material`
- `Grade`
- `Max_Pressure_psi`
- `Temperature_C`
- `Corrosion_Impact_Percent`
- `Thickness_Loss_mm`
- `Material_Loss_Percent`
- `Time_Years`
- `Condition`

### Data Preparation and Target Leakage

During exploratory data analysis, `Thickness_Loss_mm` was identified as a potential target-leakage feature because its values closely determine the target condition in this synthetic dataset.

Therefore, `Thickness_Loss_mm` was excluded from the machine learning model to reduce the risk of training on information that directly reveals the target label.

This decision is important when evaluating whether a model can generalize beyond the rules used to generate the dataset.

## Tools and Technologies

| Area | Technologies |
|---|---|
| Programming | Python |
| Data Analysis | Pandas, NumPy |
| Visualization | Matplotlib, Seaborn |
| Machine Learning | Scikit-learn, Random Forest Classifier |
| Preprocessing | One-Hot Encoding, Machine Learning Pipelines |
| Model Export | Joblib |
| Database | Microsoft SQL Server, SQL |
| Business Intelligence | Power BI, Power Query, DAX |
| Development Environment | Jupyter Notebook |

## Project Workflow

### 1. Data Science and Machine Learning

The Python workflow includes:

1. Loading and inspecting the dataset.
2. Performing exploratory data analysis (EDA).
3. Analyzing target-class distribution and feature relationships.
4. Investigating potential target leakage.
5. Separating input features from the target variable.
6. Splitting the dataset into training and testing sets using stratification.
7. Encoding categorical features using One-Hot Encoding.
8. Building a preprocessing and classification pipeline.
9. Training a Random Forest Classifier.
10. Evaluating the model using accuracy, precision, recall, and F1-score.
11. Exporting the trained pipeline with Joblib for future predictions.

The exported model file is named `predictive_maintenance_model.joblib`.

### 2. SQL Server Analysis

Microsoft SQL Server is used to store and analyze the pipeline dataset.

The SQL component focuses on:

- Querying pipeline records and inspecting data quality.
- Analyzing pipeline conditions and thickness loss.
- Comparing risk patterns across materials and grades.
- Examining pipeline characteristics and operating conditions.
- Defining analytical risk categories and maintenance priorities.
- Preparing query results for reporting and dashboard analysis.

A SQL view, `dbo.vw_Pipeline_Risk_Dashboard`, was created to organize pipeline risk and maintenance-priority information for analysis.

The maintenance-priority categories are based on custom analytical rules developed for this project. They should not be interpreted as official engineering standards.

### 3. Power BI Dashboard

Power BI is used to transform the analytical results into interactive reports that support pipeline monitoring and risk exploration.

The dashboard contains four pages.

#### Page 1 — Executive Overview

Provides a high-level summary of the pipeline dataset through key performance indicators and overview visualizations.

Key elements include:

- Total Pipelines
- Critical Pipelines
- Critical Rate
- Average Thickness Loss
- Pipeline condition distribution
- Critical pipelines by material
- Pipeline condition by grade

#### Page 2 — Risk & Predictive Maintenance

Focuses on pipeline degradation, risk patterns, and maintenance-related analysis.

Key visualizations include:

- Pipeline Risk Details
- Average Material Loss by Grade
- Thickness Loss vs. Material Loss
- Corrosion Impact by Temperature

#### Page 3 — Pipeline Condition Analysis

Explores how pipeline conditions vary across materials, pipe sizes, and operating characteristics.

The purpose is to help users investigate patterns in the dataset and compare condition categories across different pipeline attributes.

#### Page 4 — Pipeline Details & Inspection

Provides a more detailed view of individual pipeline records to support further investigation.

The page focuses on pipeline thickness loss, material loss, condition, and inspection-priority information.

## Machine Learning Model Performance

The final Random Forest model achieved the following results on the held-out test set, as reported in the Python analysis.

| Metric | Score |
|---|---:|
| Accuracy | 87.5% |
| Weighted Precision | 0.88 |
| Weighted Recall | 0.88 |
| Weighted F1-score | 0.87 |

### Classification Report

| Class | Precision | Recall | F1-score |
|---|---:|---:|---:|
| Critical | 0.86 | 0.97 | 0.91 |
| Moderate | 0.84 | 0.72 | 0.77 |
| Normal | 0.95 | 0.88 | 0.92 |

### Performance Interpretation

The model achieved a recall of **0.97 for the Critical class**, indicating that it identified most Critical records in the test set.

The Moderate class had a lower recall of **0.72**, making it an important area for further investigation and improvement.

These results apply to the dataset and evaluation setup used in this project. They do not establish equivalent performance on real industrial pipeline data.

## Key Findings

- The dataset contains 1,000 pipeline records across three condition categories.
- Critical records represent 48.7% of the dataset, followed by Moderate at 29.9% and Normal at 21.4%.
- `Thickness_Loss_mm` presents a target-leakage risk and was excluded from the machine learning model.
- The Random Forest model achieved 87.5% accuracy on the held-out test set.
- Critical-class recall was higher than Moderate-class recall.
- SQL analysis provides additional ways to examine pipeline degradation, materials, grades, and custom maintenance priorities.
- Power BI brings the analysis together in an interactive dashboard for exploring pipeline condition and risk.

## Model Export

The complete preprocessing and classification pipeline was exported using Joblib:

`predictive_maintenance_model.joblib`

Saving the complete pipeline preserves the preprocessing steps and trained classifier, allowing new data to be processed consistently when the model is loaded with a compatible environment and the expected input features.

The exported model is an artifact for future prediction workflows. This project does not claim that the model is currently deployed as a live production service.

## Limitations

- The dataset contains only 1,000 records and is synthetic.
- Dataset patterns may not represent the complexity of real pipeline operations.
- The Moderate class has lower recall than the Critical class.
- Further validation is required to assess generalization to unseen operational environments.
- Risk categories and maintenance priorities defined through SQL are project-specific analytical rules, not certified engineering assessments.
- Model predictions should not replace professional pipeline inspection, engineering judgment, or established safety procedures.

## Future Improvements

Potential next steps include:

- Analyzing the confusion matrix and class-specific errors.
- Comparing Random Forest with other classification algorithms.
- Tuning hyperparameters using cross-validation.
- Investigating class imbalance and improving Moderate-class recall.
- Validating the model on real-world pipeline data.
- Building a Streamlit application to demonstrate predictions using the saved model.
- Exploring FastAPI as a model-serving layer.
- Connecting prediction outputs to a database and reporting workflow where appropriate.

## Disclaimer

This project is for educational, analytical, and portfolio purposes only. It is not intended for direct operational decision-making and does not replace professional pipeline inspection, engineering assessment, or safety procedures.

## Author

**Saba Nikara**

- Email: sb.nikara@gmail.com
