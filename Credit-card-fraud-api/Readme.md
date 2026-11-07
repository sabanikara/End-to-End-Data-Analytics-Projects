# 💳 End-to-End Credit Card Fraud Detection System

An end-to-end Machine Learning and Business Intelligence project designed to detect fraudulent credit card transactions, serve real-time predictions, store prediction logs, and monitor system performance through interactive dashboards.

## 🎯 Project Overview

The goal of this project is to build an integrated fraud detection solution that connects Machine Learning, REST API development, database management, and Business Intelligence.

The system covers the complete workflow, from transaction data preprocessing and model prediction to SQL Server logging and Power BI reporting.

## 🏗️ System Architecture

```text
              Kaggle Dataset
                    |
                    v
             Data Preprocessing
                    |
                    v
              ML Model Training
                    |
                    v
              Machine Learning
                    |
                    v
              FastAPI Backend
                    |
             +------+------+
             |             |
             v             v
         Streamlit      SQL Server
         Frontend       Prediction Logs
             |             |
             v             v
       Prediction UI    SQL Analytics
                           |
                           v
                       Power BI
                       Dashboards
```

## 🛠️ Technologies & Tools

| Technology | Purpose |
|---|---|
| Python | Core development and data processing |
| Pandas & NumPy | Data manipulation and preprocessing |
| Scikit-learn | Machine Learning model development |
| FastAPI | REST API and prediction services |
| Streamlit | Interactive web application |
| Microsoft SQL Server | Database and prediction logging |
| SQL | Data analysis, aggregation and reporting views |
| Power BI | Interactive dashboards and business intelligence |
| Git & GitHub | Version control and project documentation |

## 📊 Dataset

**Source:** [Kaggle – Credit Card Fraud Detection](https://www.kaggle.com/datasets/mlg-ulb/creditcardfraud)

The dataset contains anonymized credit card transactions.

### Dataset Information

- Original records: 284,807
- Features: 30
- Target variable: `Class`
- Fraud label: `1`
- Normal label: `0`

### Data Preprocessing

The preprocessing workflow included:

- Data type validation
- Data quality assessment
- Duplicate transaction removal
- Feature preparation
- Class distribution analysis

After duplicate removal:

| Class | Transactions |
|---|---:|
| Normal | 283,253 |
| Fraud | 473 |
| Total | 283,726 |

The dataset is highly imbalanced, making fraud detection a challenging classification problem.

## 🤖 Machine Learning

A Machine Learning classification model was developed to distinguish between normal and fraudulent transactions.

The prediction workflow includes:

1. Receiving transaction features.
2. Processing input data.
3. Generating a fraud score.
4. Comparing the score against a decision threshold.
5. Returning the predicted transaction class.

**Important:** Fraud scores are model outputs and should not automatically be interpreted as calibrated fraud probabilities.

## ⚡ FastAPI Backend

FastAPI provides the REST API layer between the user interface, Machine Learning model, and database.

### Main Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | API health check |
| POST | `/predict` | Transaction fraud prediction |
| GET | `/predictions` | Retrieve prediction history |

Interactive API documentation is available through Swagger UI:

```text
http://127.0.0.1:8000/docs
```

## 🖥️ Streamlit Frontend

An interactive web interface was developed using Streamlit.

Main features:

- Transaction feature input
- Real-time prediction requests
- Fraud and Normal classification results
- Fraud score and threshold display
- Processing time monitoring
- Prediction history visualization

Streamlit communicates with the FastAPI backend.

## 🗄️ SQL Server Database

Microsoft SQL Server is used to store and manage prediction records.

### Main Table

`dbo.PredictionLogs`

Stored information includes:

- Prediction ID
- Request ID
- Prediction result
- Prediction label
- Fraud score
- Decision threshold
- Processing time
- Transaction data
- Creation timestamp

### Analytical SQL Views

The following views were created for reporting:

- `vw_PredictionAnalytics`
- `vw_PredictionKPIs`
- `vw_DailyPredictionActivity`
- `vw_HourlyPredictionActivity`

SQL analysis includes:

- Fraud vs Normal comparison
- Daily and hourly prediction activity
- API processing time analysis
- Duplicate prediction consistency
- Transaction amount analysis
- Decision threshold analysis

## 📈 Power BI Dashboard

A three-page interactive Power BI dashboard was developed.

### 1. Executive Overview

Provides a high-level summary of transaction activity.

Key indicators:
- Total Transactions
- Fraud Transactions
- Normal Transactions
- Fraud Rate
- Total Transaction Amount
- Average Transaction Amount

### 2. Fraud Analysis

Focuses on fraudulent transaction patterns.

Key visualizations:
- Fraud Transactions by Amount Band
- Fraud Rate by Hour Bucket
- Fraud Amount Distribution
- Fraud Risk Heatmap
- Fraud Volume Analysis

### 3. ML System Monitoring

Monitors the operational performance of the prediction system.

Key indicators:
- Total API Predictions
- Fraud Alerts
- Fraud Prediction Share
- Average Processing Time
- Fastest Request
- Slowest Request

Additional visualizations:
- Fraud Score vs Decision Threshold
- API Processing Time by Request
- Daily API Prediction Activity
- Recent Prediction Logs

## 🚀 Running the Project Locally

### 1. Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd fraud_api
```

### 2. Create a Virtual Environment

```bash
python -m venv .venv
```

Activate it on Windows:

```bash
.venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure SQL Server

- Create the `CreditCardFraudDB` database.
- Configure the SQL Server connection settings in `app/database_service.py`.
- Ensure the Microsoft ODBC Driver for SQL Server is installed.
- Run the database initialization script:

```bash
python create_table.py
```

### 5. Start FastAPI

```bash
uvicorn app.main:app --reload --reload-dir app
```

API documentation:

```text
http://127.0.0.1:8000/docs
```

### 6. Start Streamlit

Open another terminal and run:

```bash
python -m streamlit run streamlit_app.py --server.address 127.0.0.1 --server.port 8501
```

Open the application:

```text
http://127.0.0.1:8501
```

## 📁 Project Structure

```text
fraud_api/
│
├── app/
│   ├── main.py
│   ├── model_service.py
│   ├── schemas.py
│   └── database_service.py
│
├── streamlit_app.py
├── create_table.py
├── requirements.txt
└── README.md
```

## ⚠️ Limitations

- This is an educational and portfolio project.
- The dataset is highly imbalanced.
- Current API monitoring data represents test requests.
- Fraud scores are not necessarily calibrated probabilities.
- Production deployment requires additional security, scalability, and monitoring configurations.

## 🔮 Future Improvements

- Model performance evaluation using Precision, Recall, F1-score and PR-AUC.
- Model versioning and retraining.
- Cloud deployment.
- API authentication and security.
- Automated model monitoring.
- Larger-scale prediction testing.

## 👨‍💻 Project Purpose

This project demonstrates practical integration of:

**Machine Learning + Python + FastAPI + Streamlit + SQL Server + Power BI**

The main objective was to move beyond building an isolated Machine Learning model and develop a complete end-to-end predictive analytics application.

---

**Note:** This project is intended for educational and portfolio purposes and is not designed for real banking or financial decision-making.
