
import pyodbc

# SQL Server connection settings
CONNECTION_STRING = (
    r"DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=Saba-PC\SQLEXPRESS;"
    r"DATABASE=CreditCardFraudDB;"
    r"Trusted_Connection=yes;"
    r"Encrypt=yes;"
    r"TrustServerCertificate=yes;"
)

# SQL table creation
CREATE_TABLE_SQL = """
IF OBJECT_ID(N'dbo.PredictionLogs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PredictionLogs (

        Prediction_ID BIGINT IDENTITY(1,1) PRIMARY KEY,

        Request_ID NVARCHAR(36) NOT NULL UNIQUE,

        Prediction TINYINT NOT NULL
            CHECK (Prediction IN (0, 1)),

        Prediction_Label NVARCHAR(10) NOT NULL,

        Fraud_Score FLOAT NOT NULL,

        Threshold FLOAT NOT NULL,

        Processing_Time_MS FLOAT NOT NULL,

        Transaction_Data NVARCHAR(MAX) NOT NULL,

        Created_At DATETIME2(3) NOT NULL
            DEFAULT SYSUTCDATETIME(),

        CONSTRAINT CK_Prediction_Label
        CHECK (
            (Prediction = 0 AND Prediction_Label = N'Normal')
            OR
            (Prediction = 1 AND Prediction_Label = N'Fraud')
        )
    );
END;
"""

# Connect and create table
connection = pyodbc.connect(
    CONNECTION_STRING,
    timeout=10
)

cursor = connection.cursor()

cursor.execute(CREATE_TABLE_SQL)

connection.commit()

print("PredictionLogs table is ready!")

cursor.close()
connection.close()
