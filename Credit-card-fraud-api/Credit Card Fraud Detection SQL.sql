-- # 1. SELECT DATABASE

USE CreditCardFraudDB;
GO


-- # 2. VIEW ALL PREDICTION LOGS

SELECT
    Prediction_ID,
    Request_ID,
    Prediction,
    Prediction_Label,
    Fraud_Score,
    Threshold,
    Processing_Time_MS,
    Transaction_Data,
    Created_At
FROM dbo.PredictionLogs
ORDER BY Prediction_ID DESC;
-- # 3. PREDICTION SUMMARY KPI

USE CreditCardFraudDB;
GO


SELECT
    COUNT(*) AS Total_Predictions,

    SUM(
        CASE
            WHEN Prediction = 1 THEN 1
            ELSE 0
        END
    ) AS Fraud_Predictions,

    SUM(
        CASE
            WHEN Prediction = 0 THEN 1
            ELSE 0
        END
    ) AS Normal_Predictions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Prediction = 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS Fraud_Rate_Percent,

    CAST(
        AVG(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Avg_Fraud_Score,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS

FROM dbo.PredictionLogs;
-- # 4. FRAUD VS NORMAL COMPARISON

USE CreditCardFraudDB;
GO


SELECT
    Prediction_Label,

    COUNT(*) AS Prediction_Count,

    CAST(
        AVG(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Avg_Fraud_Score,

    CAST(
        MIN(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Min_Fraud_Score,

    CAST(
        MAX(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Max_Fraud_Score,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS

FROM dbo.PredictionLogs

GROUP BY
    Prediction_Label

ORDER BY
    Prediction_Label;
	-- # 5. EXTRACT TIME AND AMOUNT FROM JSON

USE CreditCardFraudDB;
GO


SELECT
    Prediction_ID,
    Prediction_Label,

    TRY_CONVERT(
        FLOAT,
        JSON_VALUE(
            Transaction_Data,
            '$.Time'
        )
    ) AS Transaction_Time,

    TRY_CONVERT(
        FLOAT,
        JSON_VALUE(
            Transaction_Data,
            '$.Amount'
        )
    ) AS Transaction_Amount,

    Fraud_Score,
    Processing_Time_MS,
    Created_At

FROM dbo.PredictionLogs

ORDER BY
    Prediction_ID DESC;
	-- # 6. FRAUD VS NORMAL - TIME AND AMOUNT ANALYSIS

USE CreditCardFraudDB;
GO


WITH ParsedTransactions AS
(
    SELECT
        Prediction_Label,

        TRY_CONVERT(
            FLOAT,
            JSON_VALUE(
                Transaction_Data,
                '$.Time'
            )
        ) AS Transaction_Time,

        TRY_CONVERT(
            FLOAT,
            JSON_VALUE(
                Transaction_Data,
                '$.Amount'
            )
        ) AS Transaction_Amount

    FROM dbo.PredictionLogs
)


SELECT
    Prediction_Label,

    COUNT(*) AS Transaction_Count,

    CAST(
        AVG(Transaction_Amount)
        AS DECIMAL(18, 2)
    ) AS Avg_Amount,

    CAST(
        MIN(Transaction_Amount)
        AS DECIMAL(18, 2)
    ) AS Min_Amount,

    CAST(
        MAX(Transaction_Amount)
        AS DECIMAL(18, 2)
    ) AS Max_Amount,

    CAST(
        AVG(Transaction_Time)
        AS DECIMAL(18, 2)
    ) AS Avg_Time,

    CAST(
        MIN(Transaction_Time)
        AS DECIMAL(18, 2)
    ) AS Min_Time,

    CAST(
        MAX(Transaction_Time)
        AS DECIMAL(18, 2)
    ) AS Max_Time

FROM ParsedTransactions

GROUP BY
    Prediction_Label

ORDER BY
    Prediction_Label;
	-- # 7. API PROCESSING TIME ANALYSIS

USE CreditCardFraudDB;
GO


SELECT
    COUNT(*) AS Total_Requests,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS,

    CAST(
        MIN(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Fastest_Request_MS,

    CAST(
        MAX(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Slowest_Request_MS

FROM dbo.PredictionLogs;
-- # 8. FASTEST AND SLOWEST REQUESTS

USE CreditCardFraudDB;
GO


-- # FASTEST REQUEST

SELECT TOP 1
    Prediction_ID,
    Request_ID,
    Prediction_Label,
    Fraud_Score,
    Processing_Time_MS,
    Created_At
FROM dbo.PredictionLogs
ORDER BY Processing_Time_MS ASC;


-- # SLOWEST REQUEST

SELECT TOP 1
    Prediction_ID,
    Request_ID,
    Prediction_Label,
    Fraud_Score,
    Processing_Time_MS,
    Created_At
FROM dbo.PredictionLogs
ORDER BY Processing_Time_MS DESC;
-- # 9. DAILY PREDICTION ACTIVITY

USE CreditCardFraudDB;
GO


SELECT
    CAST(Created_At AS DATE) AS Prediction_Date,

    COUNT(*) AS Total_Predictions,

    SUM(
        CASE
            WHEN Prediction = 1 THEN 1
            ELSE 0
        END
    ) AS Fraud_Predictions,

    SUM(
        CASE
            WHEN Prediction = 0 THEN 1
            ELSE 0
        END
    ) AS Normal_Predictions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Prediction = 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS Fraud_Rate_Percent,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS

FROM dbo.PredictionLogs

GROUP BY
    CAST(Created_At AS DATE)

ORDER BY
    Prediction_Date ASC;
	-- # 10. HOURLY PREDICTION ACTIVITY

USE CreditCardFraudDB;
GO


SELECT
    DATEPART(
        HOUR,
        Created_At
    ) AS Prediction_Hour_UTC,

    COUNT(*) AS Total_Predictions,

    SUM(
        CASE
            WHEN Prediction = 1 THEN 1
            ELSE 0
        END
    ) AS Fraud_Predictions,

    SUM(
        CASE
            WHEN Prediction = 0 THEN 1
            ELSE 0
        END
    ) AS Normal_Predictions,

    CAST(
        AVG(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Avg_Fraud_Score,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS

FROM dbo.PredictionLogs

GROUP BY
    DATEPART(
        HOUR,
        Created_At
    )

ORDER BY
    Prediction_Hour_UTC;
	-- # 11. SCORE DISTANCE FROM THRESHOLD

USE CreditCardFraudDB;
GO


SELECT
    Prediction_ID,
    Request_ID,
    Prediction_Label,
    Fraud_Score,
    Threshold,

    CAST(
        Fraud_Score - Threshold
        AS DECIMAL(18, 12)
    ) AS Score_Distance_From_Threshold,

    CASE
        WHEN Fraud_Score >= Threshold
            THEN 'ABOVE THRESHOLD'
        ELSE 'BELOW THRESHOLD'
    END AS Threshold_Status,

    Processing_Time_MS,
    Created_At

FROM dbo.PredictionLogs

ORDER BY
    ABS(Fraud_Score - Threshold) ASC;
	-- # 12. LOG-ODDS DECISION MARGIN ANALYSIS

USE CreditCardFraudDB;
GO


WITH DecisionMargins AS
(
    SELECT
        Prediction_ID,
        Request_ID,
        Prediction_Label,
        Fraud_Score,
        Threshold,

        LOG(
            Fraud_Score
            / NULLIF(1.0 - Fraud_Score, 0)
        )
        -
        LOG(
            Threshold
            / NULLIF(1.0 - Threshold, 0)
        ) AS Logit_Margin,

        Processing_Time_MS,
        Created_At

    FROM dbo.PredictionLogs

    WHERE
        Fraud_Score > 0
        AND Fraud_Score < 1
        AND Threshold > 0
        AND Threshold < 1
)


SELECT
    Prediction_ID,
    Request_ID,
    Prediction_Label,

    CAST(
        Fraud_Score
        AS DECIMAL(18, 12)
    ) AS Fraud_Score,

    CAST(
        Threshold
        AS DECIMAL(18, 12)
    ) AS Threshold,

    CAST(
        Logit_Margin
        AS DECIMAL(18, 6)
    ) AS Logit_Decision_Margin,

    CASE
        WHEN Logit_Margin >= 0
            THEN 'FRAUD SIDE'
        ELSE 'NORMAL SIDE'
    END AS Decision_Side,

    Processing_Time_MS,
    Created_At

FROM DecisionMargins

ORDER BY
    ABS(Logit_Margin) ASC;
	-- # 13. BORDERLINE PREDICTIONS

USE CreditCardFraudDB;
GO


DECLARE @Review_Band FLOAT = 1.0;


WITH DecisionMargins AS
(
    SELECT
        Prediction_ID,
        Request_ID,
        Prediction_Label,
        Fraud_Score,
        Threshold,

        LOG(
            Fraud_Score
            / NULLIF(1.0 - Fraud_Score, 0)
        )
        -
        LOG(
            Threshold
            / NULLIF(1.0 - Threshold, 0)
        ) AS Logit_Margin,

        Processing_Time_MS,
        Created_At

    FROM dbo.PredictionLogs

    WHERE
        Fraud_Score > 0
        AND Fraud_Score < 1
        AND Threshold > 0
        AND Threshold < 1
)


SELECT
    Prediction_ID,
    Request_ID,
    Prediction_Label,

    CAST(
        Fraud_Score
        AS DECIMAL(18, 12)
    ) AS Fraud_Score,

    CAST(
        Logit_Margin
        AS DECIMAL(18, 6)
    ) AS Logit_Margin,

    CASE
        WHEN ABS(Logit_Margin) <= @Review_Band
            THEN 'BORDERLINE'
        ELSE 'CLEAR DECISION'
    END AS Decision_Confidence,

    Processing_Time_MS,
    Created_At

FROM DecisionMargins

ORDER BY
    ABS(Logit_Margin) ASC;
	-- # 14. TRANSACTION AMOUNT ANALYSIS BY PREDICTION

USE CreditCardFraudDB;
GO


SELECT
    Prediction_ID,
    Prediction_Label,

    TRY_CONVERT(
        DECIMAL(18, 2),
        JSON_VALUE(
            Transaction_Data,
            '$.Amount'
        )
    ) AS Transaction_Amount,

    CAST(
        Fraud_Score
        AS DECIMAL(18, 12)
    ) AS Fraud_Score,

    CAST(
        Processing_Time_MS
        AS DECIMAL(18, 3)
    ) AS Processing_Time_MS,

    Created_At

FROM dbo.PredictionLogs

ORDER BY
    Transaction_Amount DESC,
    Prediction_ID DESC;
	-- # 15. DUPLICATE TRANSACTION ANALYSIS

USE CreditCardFraudDB;
GO


SELECT
    Transaction_Data,

    COUNT(*) AS Duplicate_Count,

    MIN(Prediction_Label) AS Prediction_Label,

    CAST(
        AVG(Fraud_Score)
        AS DECIMAL(18, 12)
    ) AS Avg_Fraud_Score,

    MIN(Created_At) AS First_Seen,

    MAX(Created_At) AS Last_Seen

FROM dbo.PredictionLogs

GROUP BY
    Transaction_Data

HAVING
    COUNT(*) > 1

ORDER BY
    Duplicate_Count DESC;
	-- # 16. DUPLICATE PREDICTION CONSISTENCY CHECK

USE CreditCardFraudDB;
GO


SELECT
    Transaction_Data,

    COUNT(*) AS Duplicate_Count,

    COUNT(
        DISTINCT Prediction
    ) AS Distinct_Predictions,

    COUNT(
        DISTINCT Prediction_Label
    ) AS Distinct_Labels,

    CAST(
        MIN(Fraud_Score)
        AS DECIMAL(18, 12)
    ) AS Min_Fraud_Score,

    CAST(
        MAX(Fraud_Score)
        AS DECIMAL(18, 12)
    ) AS Max_Fraud_Score,

    CAST(
        MAX(Fraud_Score)
        - MIN(Fraud_Score)
        AS DECIMAL(18, 12)
    ) AS Score_Spread,

    CASE
        WHEN
            COUNT(DISTINCT Prediction) = 1
            AND COUNT(DISTINCT Prediction_Label) = 1
            AND ABS(
                MAX(Fraud_Score)
                - MIN(Fraud_Score)
            ) < 0.000000000001
        THEN 'CONSISTENT'

        ELSE 'REVIEW'
    END AS Prediction_Consistency

FROM dbo.PredictionLogs

GROUP BY
    Transaction_Data

HAVING
    COUNT(*) > 1

ORDER BY
    Duplicate_Count DESC;
	-- # 17. DUPLICATE REQUEST PROCESSING TIME VARIABILITY

USE CreditCardFraudDB;
GO


SELECT
    TRY_CONVERT(
        FLOAT,
        JSON_VALUE(
            Transaction_Data,
            '$.Time'
        )
    ) AS Transaction_Time,

    TRY_CONVERT(
        DECIMAL(18, 2),
        JSON_VALUE(
            Transaction_Data,
            '$.Amount'
        )
    ) AS Transaction_Amount,

    Prediction_Label,

    COUNT(*) AS Request_Count,

    CAST(
        MIN(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Min_Processing_Time_MS,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS,

    CAST(
        MAX(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Max_Processing_Time_MS,

    CAST(
        MAX(Processing_Time_MS)
        - MIN(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Processing_Time_Spread_MS,

    CAST(
        STDEV(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Processing_Time_StdDev_MS

FROM dbo.PredictionLogs

GROUP BY
    Transaction_Data,
    Prediction_Label

HAVING
    COUNT(*) > 1

ORDER BY
    Request_Count DESC;
	-- # 18. PREDICTION CLASS PERFORMANCE SUMMARY

USE CreditCardFraudDB;
GO


SELECT
    Prediction_Label,

    COUNT(*) AS Request_Count,

    CAST(
        100.0 * COUNT(*)
        / NULLIF(
            SUM(COUNT(*)) OVER (),
            0
        )
        AS DECIMAL(10, 2)
    ) AS Request_Share_Percent,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS,

    CAST(
        MIN(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Min_Processing_Time_MS,

    CAST(
        MAX(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Max_Processing_Time_MS

FROM dbo.PredictionLogs

GROUP BY
    Prediction_Label

ORDER BY
    Request_Count DESC;
	-- # 19. CREATE ANALYTICS VIEW

USE CreditCardFraudDB;
GO


CREATE OR ALTER VIEW dbo.vw_PredictionAnalytics
AS

SELECT
    Prediction_ID,
    Request_ID,

    Prediction,
    Prediction_Label,

    Fraud_Score,
    Threshold,

    Fraud_Score - Threshold
        AS Score_Distance_From_Threshold,

    Processing_Time_MS,

    TRY_CONVERT(
        FLOAT,
        JSON_VALUE(
            Transaction_Data,
            '$.Time'
        )
    ) AS Transaction_Time,

    TRY_CONVERT(
        FLOAT,
        JSON_VALUE(
            Transaction_Data,
            '$.Amount'
        )
    ) AS Transaction_Amount,

    Created_At,

    CAST(
        Created_At AS DATE
    ) AS Prediction_Date,

    DATEPART(
        HOUR,
        Created_At
    ) AS Prediction_Hour_UTC

FROM dbo.PredictionLogs;
GO


-- # TEST ANALYTICS VIEW

SELECT *
FROM dbo.vw_PredictionAnalytics
ORDER BY Prediction_ID DESC;
-- # 20. CREATE KPI SUMMARY VIEW

USE CreditCardFraudDB;
GO


CREATE OR ALTER VIEW dbo.vw_PredictionKPIs
AS

SELECT
    COUNT(*) AS Total_Predictions,

    SUM(
        CASE
            WHEN Prediction = 1 THEN 1
            ELSE 0
        END
    ) AS Fraud_Predictions,

    SUM(
        CASE
            WHEN Prediction = 0 THEN 1
            ELSE 0
        END
    ) AS Normal_Predictions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Prediction = 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS Fraud_Rate_Percent,

    CAST(
        AVG(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Avg_Fraud_Score,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS,

    CAST(
        MIN(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Fastest_Request_MS,

    CAST(
        MAX(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Slowest_Request_MS

FROM dbo.PredictionLogs;
GO


-- # TEST KPI VIEW

SELECT *
FROM dbo.vw_PredictionKPIs;
-- # 21. CREATE DAILY ACTIVITY VIEW

USE CreditCardFraudDB;
GO


CREATE OR ALTER VIEW dbo.vw_DailyPredictionActivity
AS

SELECT
    CAST(Created_At AS DATE) AS Prediction_Date,

    COUNT(*) AS Total_Predictions,

    SUM(
        CASE
            WHEN Prediction = 1 THEN 1
            ELSE 0
        END
    ) AS Fraud_Predictions,

    SUM(
        CASE
            WHEN Prediction = 0 THEN 1
            ELSE 0
        END
    ) AS Normal_Predictions,

    CAST(
        100.0 *
        SUM(
            CASE
                WHEN Prediction = 1 THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10, 2)
    ) AS Fraud_Rate_Percent,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS

FROM dbo.PredictionLogs

GROUP BY
    CAST(Created_At AS DATE);
GO


-- # TEST DAILY ACTIVITY VIEW

SELECT *
FROM dbo.vw_DailyPredictionActivity
ORDER BY Prediction_Date;
-- # 22. CREATE HOURLY ACTIVITY VIEW

USE CreditCardFraudDB;
GO


CREATE OR ALTER VIEW dbo.vw_HourlyPredictionActivity
AS

SELECT
    DATEPART(
        HOUR,
        Created_At
    ) AS Prediction_Hour_UTC,

    COUNT(*) AS Total_Predictions,

    SUM(
        CASE
            WHEN Prediction = 1 THEN 1
            ELSE 0
        END
    ) AS Fraud_Predictions,

    SUM(
        CASE
            WHEN Prediction = 0 THEN 1
            ELSE 0
        END
    ) AS Normal_Predictions,

    CAST(
        AVG(Fraud_Score)
        AS DECIMAL(18, 6)
    ) AS Avg_Fraud_Score,

    CAST(
        AVG(Processing_Time_MS)
        AS DECIMAL(18, 3)
    ) AS Avg_Processing_Time_MS

FROM dbo.PredictionLogs

GROUP BY
    DATEPART(
        HOUR,
        Created_At
    );
GO


-- # TEST HOURLY ACTIVITY VIEW

SELECT *
FROM dbo.vw_HourlyPredictionActivity
ORDER BY Prediction_Hour_UTC;
-- # 23. FINAL SQL VIEW CHECK

USE CreditCardFraudDB;
GO


-- # KPI SUMMARY

SELECT *
FROM dbo.vw_PredictionKPIs;
GO


-- # DAILY ACTIVITY

SELECT *
FROM dbo.vw_DailyPredictionActivity
ORDER BY Prediction_Date;
GO


-- # HOURLY ACTIVITY

SELECT *
FROM dbo.vw_HourlyPredictionActivity
ORDER BY Prediction_Hour_UTC;
GO


-- # DETAILED ANALYTICS

SELECT TOP 100 *
FROM dbo.vw_PredictionAnalytics
ORDER BY Prediction_ID DESC;
GO