# Oil & Gas Pipeline Predictive Maintenance

### An End-to-End Data Science, Business Intelligence & Local ML Application

**Python · scikit-learn · SQL Server · Power BI · Tableau · FastAPI · Streamlit**

> **Current scope:** an educational pipeline **current-condition classification** project with a locally tested web form, model-serving API, and SQL prediction logging. Despite the project title, this is not a validated forecast of future failure, remaining useful life, or a certified maintenance recommendation system.

## Project Overview

This project combines exploratory data analysis, machine learning, SQL analysis, business intelligence reporting, and a local application for classifying supplied pipeline records as **Normal**, **Moderate**, or **Critical**.

The original analytical work includes a Python notebook, SQL Server queries, and the Power BI reporting component described below. A separate Tableau dashboard explores thickness loss and data quality. The project has since been extended with **FastAPI**, **Streamlit**, and **SQL Server prediction logging**.

In the local application, a user enters values in a Streamlit form. FastAPI validates the request, runs the saved preprocessing-and-classification pipeline, and stores the validated inputs and model response in SQL Server before returning a successful response. Streamlit displays the result and the database storage receipt.

**Status:** the main local workflow has been verified for one valid sample and a zero-thickness validation test. Public hosting, production readiness, and industrial model validity have not been established. Publishing these files on GitHub is not the same as hosting the application online.

## Business Problem

The project uses pipeline degradation and inspection prioritization as its analytical context. Its purpose is to demonstrate how a pipeline record can be explored, classified, served through an API, and traced to a stored result.

The components have distinct responsibilities:

| Component | Responsibility |
|---|---|
| Machine learning | Classify the supplied current-condition data using a saved Random Forest pipeline. |
| SQL analysis | Explore the source dataset, condition groups, loss patterns, and project-specific maintenance-priority rules. |
| Power BI | Present the four-page reporting component described in the original project documentation. |
| Tableau | Explore thickness loss and explicitly separate records that pass or require review under a basic numerical check. |
| FastAPI | Validate inputs, run the model, and coordinate prediction storage. |
| Streamlit | Provide a Persian-language form and display results, model scores, warnings, and storage confirmation. |
| SQL prediction logging | Preserve the submitted values, prediction, model identifier, and UTC timestamp for each successfully stored request. |

The application's output is not authorization to operate a pipeline or an instruction to repair or replace it.

## Dataset

| Item | Description |
|---|---|
| Source listed in the original project documentation | Kaggle — Predictive Maintenance Oil and Gas Pipeline Data |
| CSV filename | `market_pipe_thickness_loss_dataset.csv` |
| Records | 1,000 |
| Original columns | 11 |
| Non-target columns in the source dataset | 10 |
| Input features used by the deployed model | **9** |
| Target | `Condition` |
| Target classes | `Normal`, `Moderate`, `Critical` |

The original README describes the dataset as **synthetic**. That description is retained as source-provided information; the generation procedure, measurement provenance, and redistribution license have not been independently verified in this project review.

### Dataset Features

| Field | Role in the deployed application |
|---|---|
| `Pipe_Size_mm` | Model input: recorded pipe size in millimetres |
| `Thickness_mm` | Model input: thickness in millimetres; treated as reference thickness for the numerical quality check |
| `Material` | Categorical model input |
| `Grade` | Categorical model input |
| `Max_Pressure_psi` | Model input: recorded maximum-pressure field |
| `Temperature_C` | Model input: temperature in degrees Celsius |
| `Corrosion_Impact_Percent` | Model input: recorded corrosion-impact percentage |
| `Thickness_Loss_mm` | Used in analysis; **excluded from the deployed model inputs** |
| `Material_Loss_Percent` | Model input: recorded loss percentage |
| `Time_Years` | Model input: recorded numerical duration |
| `Condition` | Target label, not an input |

`Time_Years` is not an inspection date. The meaning of the maximum-pressure field should not be expanded into a claim about measured operating pressure without source documentation. No real asset identifier or inspection date is present, so record counts are not established counts of unique physical pipelines.

## Data Preparation and Target Leakage

The notebook investigates the strong relationship between `Thickness_Loss_mm` and `Condition`. In this dataset, the observed labels can be reproduced using thickness-loss thresholds. The deployed model excludes `Thickness_Loss_mm`, leaving **nine input fields**.

**Important update to the original README:** removing that column does not establish a leakage-free, pre-inspection prediction task. `Material_Loss_Percent` remains an input and is numerically consistent, to the stored rounding precision, with:

```text
Material_Loss_Percent ≈ 100 × Thickness_Loss_mm / Thickness_mm
```

Consequently, thickness and loss percentage together approximately recover the excluded loss measurement. If that percentage is unavailable before inspection, it must not be treated as an available feature for a pre-inspection forecast.

The deployed version therefore demonstrates **classification of supplied current-condition information**, not validated prediction of future failure. A genuinely prospective model would require a defined prediction horizon, appropriately timed features and labels, and a new evaluation.

### Basic Thickness Data-Quality Check

Assuming `Thickness_mm` is a baseline/reference thickness, a record is marked `Review` when thickness or loss is missing, thickness is non-positive, loss is negative, or loss exceeds reference thickness. `Pass` means only that these numerical checks were passed.

The dataset review identified **119 records** with loss greater than the reference thickness, leaving **881 Pass records**. The original CSV was retained; the Tableau analytical charts use a `Pass` filter rather than silently deleting those rows.

This filter was **not** applied retrospectively to the saved model. The documented notebook split uses 800 training and 200 test records from the 1,000-row dataset. Tableau results and model results therefore have different scopes.

## Tools and Technologies

| Area | Technologies |
|---|---|
| Programming and analysis | Python, Pandas, NumPy |
| Notebook visualization | Matplotlib, Seaborn |
| Machine learning | scikit-learn, RandomForestClassifier |
| Preprocessing | ColumnTransformer, OneHotEncoder, Pipeline |
| Model export | Joblib |
| Database and SQL analysis | Microsoft SQL Server, SQL Server Management Studio, T-SQL |
| Database connection | pyodbc, Microsoft ODBC Driver 17 for SQL Server |
| Business intelligence | Power BI, Power Query, DAX; Tableau |
| Model-serving layer | FastAPI, Pydantic, Uvicorn |
| Web interface | Streamlit, Requests |
| Development and documentation | Jupyter/Kaggle notebook, Windows CMD, GitHub, Markdown |

## Project Workflow

### 1. Data Science and Machine Learning

The notebook workflow covers dataset inspection, class-distribution analysis, feature relationships, leakage investigation, a stratified training/test split, categorical encoding, Random Forest experiments, and evaluation using accuracy, precision, recall, and F1-score.

The complete preprocessing-and-classification pipeline used by the application is saved as:

```text
models/predictive_maintenance_model.joblib
```

| Property | Deployed artifact |
|---|---|
| Classifier | RandomForestClassifier |
| Number of trees | **200** |
| Random state | `42` |
| Categorical preprocessing | OneHotEncoder for `Material` and `Grade` |
| Numerical preprocessing | Passthrough within ColumnTransformer |
| Raw input fields | 9 |
| scikit-learn version recorded in the model | `1.6.1` |
| Model identifier | `rf-200-99fe7338cf89` |

The earlier notebook also contains a 500-tree final configuration. That configuration is **not** the 200-tree artifact used by the local API; their metrics must not be combined.

### 2. SQL Server Analysis

The SQL analysis inspects source records, checks missing values and duplicates, compares conditions across materials and grades, explores numerical relationships, and defines project-specific risk and maintenance-priority groups.

The analytical view is:

```text
dbo.vw_Pipeline_Risk_Dashboard
```

Its risk and maintenance-priority labels are **custom analytical rules**, not learned model outputs or official engineering standards. They are distinct from the Random Forest prediction and from the new prediction-log table.

### 3. Power BI Dashboard

The original project documentation describes a **four-page Power BI report**. That reporting work is retained here rather than replaced by the later Tableau dashboard. The page descriptions below come from those project notes; the application integration tests do not independently verify the Power BI file or its refresh connections.

| Page | Focus and documented elements |
|---|---|
| **Executive Overview** | Total Pipelines, Critical Pipelines, Critical Rate, Average Thickness Loss, condition distribution, critical records by material, and condition by grade |
| **Risk & Predictive Maintenance** | Pipeline Risk Details, Average Material Loss by Grade, Thickness Loss vs. Material Loss, and Corrosion Impact by Temperature |
| **Pipeline Condition Analysis** | Comparisons across materials, pipe sizes, condition categories, and recorded characteristics |
| **Pipeline Details & Inspection** | Record-level thickness loss, material loss, condition, and custom inspection-priority information |

Dashboard labels such as “Total Pipelines” refer to dataset records unless asset uniqueness has been established separately.

### 4. Tableau Dashboard

The separate Tableau workbook is named:

```text
Pipe_Thickness_Loss_Analysis.twbx
```

The main dashboard displays the share of `Critical` labels, mean percentage thickness loss by material, and record counts by condition. Selecting a material filters the other analytical views. Supporting worksheets cover total record counts, the thickness-quality check, and mean loss in millimetres.

| Metric | Value | Scope |
|---|---:|---|
| Source records | 1,000 | Full CSV |
| Records requiring thickness review | 119 (11.90%) | Full CSV |
| Records passing the numerical check | 881 | Pass |
| Critical-labelled records | 375 (42.57%) | Pass |
| PVC records | 163 | PVC and Pass |
| Mean PVC thickness loss | 4.9050 mm | PVC and Pass |
| Mean PVC percentage loss | 34.77% | PVC and Pass |

These are descriptive comparisons, not causal material rankings. The percentage-loss measure is the mean of individual record ratios, not the ratio of summed losses to summed thicknesses.

The tested application does not establish an automatic refresh connection between either BI report and the live prediction logs.

### 5. FastAPI Model Service

FastAPI serves the existing model without retraining it for each request. At startup, the application checks the expected scikit-learn version, model checksum, input-feature names, classes, and a sample inference.

| Endpoint | Purpose |
|---|---|
| `GET /` | Basic service information |
| `GET /health` | Model readiness; not a database connectivity/write test |
| `GET /model-info` | Feature names, categories, classes, model details, and sample input |
| `POST /predict` | Validate input, run inference, save the SQL log, and return the response |

The schema rejects invalid numerical inputs and unexpected fields. A zero thickness is rejected with HTTP `422`. `Material_Loss_Percent > 100` is flagged `review_required`, not silently clipped; otherwise the quality status is `not_fully_checked`, not an engineering `Pass`.

Defined error handling includes HTTP `503` for model unavailability or unconfirmed storage and HTTP `500` for inference failure. Only the scenarios listed in the test report have been manually verified.

### 6. Streamlit Application

The Persian-language interface provides a nine-field input form, a submission button, the selected condition, scores for all three classes, model warnings, and SQL storage confirmation.

Streamlit communicates with FastAPI through HTTP. It does not independently load the model, retrain it, or connect directly to SQL Server. A successful stored response includes a `prediction_id` and `saved_at_utc` value.

### 7. SQL Server Prediction Logging

The application uses a separate table:

```text
dbo.PredictionLogs
```

| Column | Stored information |
|---|---|
| `PredictionId` | Generated log-entry identifier |
| `CreatedAtUtc` | SQL-generated UTC creation time |
| `ModelId` | Identifier of the model used |
| `PredictedCondition` | Selected condition class |
| `InputJson` | Normalized, validated input fields |
| `OutputJson` | Complete prediction response, warnings, and storage receipt |

The API inserts and finalizes a record in a transaction and returns success only after the commit is acknowledged. It does not create or overwrite the source-data table.

Each accepted submission is a new log entry, including repeated submissions with identical inputs. There is no idempotency key or automatic retry of writes. After a timeout or `PREDICTION_STORAGE_UNCONFIRMED`, inspect the database before submitting again: the commit may have completed even if its acknowledgement was lost.

A prediction-log identifier is **not** a real pipeline or inspection identifier. `/health` and browser refreshes do not themselves create prediction records.

## Application Architecture

```text
Streamlit form (127.0.0.1:8501)
        |
        | HTTP POST /predict
        v
FastAPI (127.0.0.1:8000)
        |
        | Validate the nine input fields
        v
Saved sklearn Pipeline
ColumnTransformer + RandomForestClassifier
        |
        | Class + scores + warnings
        v
SQL Server: dbo.PredictionLogs
INSERT / finalize response JSON / COMMIT
        |
        | Response + storage receipt
        v
Streamlit result display
```

The notebook, SQL analytical queries, Power BI report, and Tableau dashboard form the analytical workstream. They are not automatically executed whenever the API receives a request.

## Machine Learning Model Performance

The project owner reported the following results for the 200-tree model execution on **200 held-out test records**. These training/evaluation results have not been independently recomputed by the application integration tests.

| Metric | Reported score |
|---|---:|
| Accuracy | 87.5% |
| Weighted precision | 0.88 |
| Weighted recall | 0.88 |
| Weighted F1-score | 0.87 |

### Classification Report

| Class | Precision | Recall | F1-score | Support |
|---|---:|---:|---:|---:|
| Critical | 0.86 | 0.97 | 0.91 | 97 |
| Moderate | 0.84 | 0.72 | 0.77 | 60 |
| Normal | 0.95 | 0.88 | 0.92 | 43 |

The reported recall is higher for `Critical` than for `Moderate`. These results apply to the supplied dataset and evaluation setup; they do not demonstrate the same performance on industrial data. The retained loss-percentage feature also limits interpretation as a prospective prediction model.

## Example Request and Observed Result

```json
{
  "Pipe_Size_mm": 800,
  "Thickness_mm": 15.48,
  "Material": "Carbon Steel",
  "Grade": "ASTM A333 Grade 6",
  "Max_Pressure_psi": 300,
  "Temperature_C": 84.9,
  "Corrosion_Impact_Percent": 16.04,
  "Material_Loss_Percent": 31.72,
  "Time_Years": 2
}
```

Percentages use percentage units: `31.72` means 31.72%, not `0.3172`.

For this sample, the API and Streamlit displayed:

| Class | Observed model score |
|---|---:|
| **Moderate** | **0.660 / 66.00%** |
| Critical | 0.315 / 31.50% |
| Normal | 0.025 / 2.50% |

**The 66% score is neither overall model accuracy nor a validated probability of physical failure.**

After SQL logging was enabled, a new submission was saved as record `1`. Its model ID, input values, selected class, score, and UTC timestamp were read back through SSMS. Future requests generate their own storage receipts; do not hard-code the example's identifier.

## Verified Local Tests

| Test | Observed result |
|---|---|
| Model readiness | `/health` returned `status: ok`, `model_loaded: true`, and scikit-learn `1.6.1`. |
| Valid API request | HTTP `200`, condition `Moderate`, with the scores shown above. |
| Same input through Streamlit | Same class and scores displayed. |
| SQL persistence | A successful form submission produced record `1`, independently read in SSMS. |
| Stored input/output reconciliation | `Carbon Steel`, loss percentage `31.72`, condition `Moderate`, score `0.66`. |
| Zero-thickness input | HTTP `422` referring to `Thickness_mm`, with a greater-than-zero validation message. |
| Record count after invalid input | Still `1`; no prediction row was added in that test. |

Detailed evidence and limitations are recorded in `TEST_RESULTS.md`. These are manual observations from the local development environment, not exhaustive automated testing or an independent industrial model evaluation.

## Application File Layout

Keep the following runtime files together. This describes the local application layout to include in a runnable project copy; it is not a claim that all files are already present in the remote repository.

```text
application-working-folder/
├── main.py
├── streamlit_app.py
├── database_logger.py
├── requirements.txt
├── model_metadata.json
├── example_input.json
├── models/
│   └── predictive_maintenance_model.joblib
├── SQL_LOGGING_NOTES.md
├── TEST_RESULTS.md
└── .gitignore
```

Retain the original notebook, analytical SQL script, BI artifacts, and this project README alongside the application documentation. The earlier `enable_sql_logging.py` file is a migration helper, not the daily launcher; it does not need to be rerun after the update has been applied.

## Running the Existing Local Setup

The following commands are for **Windows CMD**, executed from the folder containing `main.py` and `streamlit_app.py`. They assume dependencies, model files, SQL Server, the ODBC driver, and the log table are already available. Do not reinstall a working environment just to restart the application.

### Start FastAPI in one CMD window

```bat
.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000
```

### Start Streamlit in a second CMD window

```bat
"%USERPROFILE%\venvs\pipe-ui\Scripts\python.exe" -m streamlit run streamlit_app.py --server.address 127.0.0.1 --server.port 8501 --server.headless true --browser.gatherUsageStats false
```

Keep both windows open. Open these addresses in the browser on the same computer:

```text
Form:        http://127.0.0.1:8501
API docs:    http://127.0.0.1:8000/docs
Model check: http://127.0.0.1:8000/health
Model info:  http://127.0.0.1:8000/model-info
```

Stop each service with `Ctrl+C` in its own CMD window. These loopback addresses are not public demo links. See the official [FastAPI server guide](https://fastapi.tiangolo.com/deployment/manually/) and [Streamlit run reference](https://docs.streamlit.io/develop/api-reference/cli/run).

### Initial Setup on Another Windows Computer

The observed local environment uses Python `3.13.3`, Streamlit `1.66.0`, scikit-learn `1.6.1`, and SQL Server Express with ODBC Driver 17. A fresh installation on another computer has not been verified by the recorded tests.

Run the setup commands from the application working folder, using a short path to avoid Windows path-length problems:

```bat
python -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt

python -m venv "%USERPROFILE%\venvs\pipe-ui"
"%USERPROFILE%\venvs\pipe-ui\Scripts\python.exe" -m pip install streamlit==1.66.0 requests -c requirements.txt
```

`requirements.txt` pins application dependencies but is not a complete recovered lockfile for the original Kaggle training session or every UI dependency. Installing `pyodbc` does not itself install the Microsoft ODBC driver.

The database `OilGas_Pipeline_Prediction` must exist. An authorized database administrator/developer can create the separate log table in SSMS:

```sql
USE [OilGas_Pipeline_Prediction];
GO

IF OBJECT_ID(N'dbo.PredictionLogs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PredictionLogs
    (
        PredictionId BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CreatedAtUtc DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
        ModelId NVARCHAR(100) NOT NULL,
        PredictedCondition NVARCHAR(20) NOT NULL,
        InputJson NVARCHAR(MAX) NOT NULL,
        OutputJson NVARCHAR(MAX) NOT NULL
    );
END;
```

This does not migrate or overwrite an existing table. Verify its schema and the API account's `SELECT`, `INSERT`, and `UPDATE` permissions. The API does not create the database or tables.

For a different server, set the supported environment variable in the same CMD window used to start FastAPI. This example assumes a local SQL Express instance; replace the server/instance with your actual value:

```bat
set "PIPE_SQL_CONNECTION_STRING=DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost\SQLEXPRESS;DATABASE=OilGas_Pipeline_Prediction;Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;"
```

The code does not automatically load a `.env` file. `Trusted_Connection=yes` uses the Windows identity running the API. `TrustServerCertificate=yes` is a **local-development setting that skips certificate validation**, not a production recommendation. Use validated TLS and secure configuration for a real deployment. The verified local configuration and transaction behavior are documented in `SQL_LOGGING_NOTES.md`.

## Key Findings

The full dataset contains 487 `Critical` records (48.7%), 299 `Moderate` records (29.9%), and 214 `Normal` records (21.4%). After the basic thickness-quality filter, Tableau uses 881 records and the Critical share is 42.57%. Those percentages must not be mixed without describing their different denominators.

The reported model accuracy is 87.5%, but the retained loss percentage prevents treating that result as evidence of leakage-free future-failure prediction. The local application demonstrates a working path from user input to a stored and retrievable classification, not a new scientific validation of the model.

## Limitations and Publication Considerations

The dataset is small and is described as synthetic in the original project notes. Its generation process, real-world representativeness, and asset uniqueness are not established. Material/grade compatibility and measurement validity have not been comprehensively checked.

SQL risk categories are custom analytical rules. Model scores are not calibrated or externally validated failure probabilities. The model and source records must not replace professional inspection, engineering judgment, or established safety procedures.

The current API has no public authentication or production hardening. Concurrency, database outages, load handling, recovery, idempotency, security testing, and comprehensive integrated automated coverage are not confirmed by the manual tests. Public deployment remains future work.

Load Joblib artifacts only from a trusted source: loading can execute code. The application checks model identity and the expected scikit-learn version; these checks do not make arbitrary downloaded models safe. Refer to the [scikit-learn persistence guidance](https://scikit-learn.org/stable/model_persistence.html).

Before publishing, review code, notebooks, workbooks, and screenshots for personal paths, machine names, credentials, and embedded data. Exclude virtual environments, `.env` files, SQL backups, updater backup folders, and sensitive logs. Establish redistribution rights for data, model artifacts, and data embedded in BI workbooks; this README does not grant those rights or invent a license.

## Future Improvements

The Streamlit form, FastAPI service, and SQL prediction logging are **already implemented locally** and are no longer listed as future features.

Remaining improvements include a prospective task definition with time-appropriate features, re-evaluation without loss-derived leakage, better class-specific validation and comparisons, broader automated integration testing, idempotent request handling, secure deployment, and explicit BI reporting from prediction logs. External validation would be required before any operational use.

## Documentation Basis

Model details come from the supplied deployment artifact metadata and its inspection report; reported evaluation scores come from the project owner's training output. Runtime behavior is documented in the SQL-enabled application source and `SQL_LOGGING_NOTES.md`; observed local results are in `TEST_RESULTS.md`.

The four-page Power BI description and source attribution follow the original project README. The Tableau description reflects the separately completed workflow. Neither a complete remote repository inventory nor public deployment is established by this document.

## Disclaimer

This project is for educational, analytical, and portfolio purposes only. It is not intended for direct operational decision-making and does not replace professional pipeline inspection, engineering assessment, or safety procedures.

## Author

**Saba Nikara**  
Email: sb.nikara@gmail.com
