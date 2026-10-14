
-- Step 1: Select the Project Database
USE OilGas_Pipeline_Prediction;
GO
-- Step 2: Count Total Records
SELECT COUNT(*) AS Total_Rows
FROM market_pipe_thickness_loss_dataset;

-- Step 3: Count Total Records
SELECT COUNT(*) AS Total_Rows
FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 4: Preview the Dataset
SELECT TOP 10 *
FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 5: Check Data Types
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'market_pipe_thickness_loss_dataset'
ORDER BY ORDINAL_POSITION;

-- Step 6: Check Missing Values
SELECT
    COUNT(*) AS Total_Rows,
   
    COUNT(Pipe_Size_mm) AS Pipe_Size_mm_NotNull,
    COUNT(Thickness_mm) AS Thickness_mm_NotNull,
    COUNT(Material) AS Material_NotNull,
    COUNT(Grade) AS Grade_NotNull,
    COUNT(Max_Pressure_psi) AS Max_Pressure_psi_NotNull,
    COUNT(Temperature_C) AS Temperature_C_NotNull,
    COUNT(Corrosion_Impact_Percent) AS Corrosion_Impact_Percent_NotNull,
    COUNT(Thickness_Loss_mm) AS Thickness_Loss_mm_NotNull,
    COUNT(Material_Loss_Percent) AS Material_Loss_Percent_NotNull,
    COUNT(Time_Years) AS Time_Years_NotNull,
    COUNT(Condition) AS Condition_NotNull

FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 7: Check Duplicate Records
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(
        Pipe_Size_mm, '|',
        Thickness_mm, '|',
        Material, '|',
        Grade, '|',
        Max_Pressure_psi, '|',
        Temperature_C, '|',
        Corrosion_Impact_Percent, '|',
        Thickness_Loss_mm, '|',
        Material_Loss_Percent, '|',
        Time_Years, '|',
        Condition
    )) AS Unique_Rows
FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 8: Numerical Data Analysis
SELECT
    COUNT(*) AS Total_Rows,

    MIN(Pipe_Size_mm) AS Min_Pipe_Size,
    MAX(Pipe_Size_mm) AS Max_Pipe_Size,
    AVG(CAST(Pipe_Size_mm AS FLOAT)) AS Avg_Pipe_Size,

    MIN(Thickness_mm) AS Min_Thickness,
    MAX(Thickness_mm) AS Max_Thickness,
    AVG(Thickness_mm) AS Avg_Thickness,

    MIN(Max_Pressure_psi) AS Min_Pressure,
    MAX(Max_Pressure_psi) AS Max_Pressure,
    AVG(CAST(Max_Pressure_psi AS FLOAT)) AS Avg_Pressure,

    MIN(Temperature_C) AS Min_Temperature,
    MAX(Temperature_C) AS Max_Temperature,
    AVG(Temperature_C) AS Avg_Temperature,

    MIN(Corrosion_Impact_Percent) AS Min_Corrosion,
    MAX(Corrosion_Impact_Percent) AS Max_Corrosion,
    AVG(Corrosion_Impact_Percent) AS Avg_Corrosion,

    MIN(Thickness_Loss_mm) AS Min_Thickness_Loss,
    MAX(Thickness_Loss_mm) AS Max_Thickness_Loss,
    AVG(Thickness_Loss_mm) AS Avg_Thickness_Loss,

    MIN(Material_Loss_Percent) AS Min_Material_Loss,
    MAX(Material_Loss_Percent) AS Max_Material_Loss,
    AVG(Material_Loss_Percent) AS Avg_Material_Loss,

    MIN(Time_Years) AS Min_Time_Years,
    MAX(Time_Years) AS Max_Time_Years,
    AVG(CAST(Time_Years AS FLOAT)) AS Avg_Time_Years

FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 9: Condition Distribution
SELECT
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY Condition
ORDER BY Record_Count DESC;

-- Step 10: Material Distribution
SELECT
    Material,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY Material
ORDER BY Record_Count DESC;

-- Step 11: Condition by Material
SELECT
    Material,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY Material)
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY
    Material,
    Condition
ORDER BY
    Material,
    Record_Count DESC;

	-- Step 12: Grade Distribution
	SELECT
    Grade,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY Grade
ORDER BY Record_Count DESC;

-- Step 13: Condition by Grade
SELECT
    Grade,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (PARTITION BY Grade)
        AS DECIMAL(5,2)
    ) AS Percentage
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY
    Grade,
    Condition
ORDER BY
    Grade,
    Record_Count DESC;

-- Step 14: Numerical Variables by Condition

SELECT
    Condition,
    COUNT(*) AS Record_Count,

    -- Pipe Size
    AVG(CAST(Pipe_Size_mm AS FLOAT)) AS Avg_Pipe_Size,
    MIN(Pipe_Size_mm) AS Min_Pipe_Size,
    MAX(Pipe_Size_mm) AS Max_Pipe_Size,

    -- Thickness
    AVG(Thickness_mm) AS Avg_Thickness,
    MIN(Thickness_mm) AS Min_Thickness,
    MAX(Thickness_mm) AS Max_Thickness,

    -- Pressure
    AVG(CAST(Max_Pressure_psi AS FLOAT)) AS Avg_Pressure,
    MIN(Max_Pressure_psi) AS Min_Pressure,
    MAX(Max_Pressure_psi) AS Max_Pressure,

    -- Temperature
    AVG(Temperature_C) AS Avg_Temperature,

    -- Corrosion Impact
    AVG(Corrosion_Impact_Percent) AS Avg_Corrosion_Impact,

    -- Thickness Loss
    AVG(Thickness_Loss_mm) AS Avg_Thickness_Loss,

    -- Material Loss
    AVG(Material_Loss_Percent) AS Avg_Material_Loss,

    -- Pipeline Age
    AVG(CAST(Time_Years AS FLOAT)) AS Avg_Time_Years

FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY Condition
ORDER BY
    CASE Condition
        WHEN 'Critical' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Normal' THEN 3
    END;

	-- Step 15: Loss Analysis by Condition
	SELECT
    Condition,

    -- Thickness Loss
    MIN(Thickness_Loss_mm) AS Min_Thickness_Loss,
    MAX(Thickness_Loss_mm) AS Max_Thickness_Loss,
    AVG(Thickness_Loss_mm) AS Avg_Thickness_Loss,
    STDEV(Thickness_Loss_mm) AS Std_Thickness_Loss,

    -- Material Loss
    MIN(Material_Loss_Percent) AS Min_Material_Loss,
    MAX(Material_Loss_Percent) AS Max_Material_Loss,
    AVG(Material_Loss_Percent) AS Avg_Material_Loss,
    STDEV(Material_Loss_Percent) AS Std_Material_Loss

FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY Condition
ORDER BY
    CASE Condition
        WHEN 'Critical' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Normal' THEN 3
    END;

	-- Step 16: Thickness Loss Risk Groups
	WITH LossGroups AS
(
    SELECT
        CASE
            WHEN Thickness_Loss_mm < 2 THEN 'Low Loss'
            WHEN Thickness_Loss_mm < 5 THEN 'Medium Loss'
            ELSE 'High Loss'
        END AS Thickness_Loss_Category,

        Condition

    FROM dbo.market_pipe_thickness_loss_dataset
)

SELECT
    Thickness_Loss_Category,
    Condition,
    COUNT(*) AS Record_Count,

    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Thickness_Loss_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage

FROM LossGroups

GROUP BY
    Thickness_Loss_Category,
    Condition

ORDER BY
    CASE Thickness_Loss_Category
        WHEN 'Low Loss' THEN 1
        WHEN 'Medium Loss' THEN 2
        WHEN 'High Loss' THEN 3
    END,
    Record_Count DESC;

	-- Step 17: Material Loss Risk Groups
	WITH MaterialLossGroups AS
(
    SELECT
        CASE
            WHEN Material_Loss_Percent < 10 THEN 'Low Material Loss'
            WHEN Material_Loss_Percent < 25 THEN 'Medium-Low Material Loss'
            WHEN Material_Loss_Percent < 50 THEN 'Medium-High Material Loss'
            WHEN Material_Loss_Percent < 100 THEN 'High Material Loss'
            ELSE 'Very High Material Loss'
        END AS Material_Loss_Category,
        Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Material_Loss_Category,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Material_Loss_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM MaterialLossGroups
GROUP BY
    Material_Loss_Category,
    Condition
ORDER BY
    CASE Material_Loss_Category
        WHEN 'Low Material Loss' THEN 1
        WHEN 'Medium-Low Material Loss' THEN 2
        WHEN 'Medium-High Material Loss' THEN 3
        WHEN 'High Material Loss' THEN 4
        WHEN 'Very High Material Loss' THEN 5
    END,
    Record_Count DESC;

	-- Step 18: Time Years Risk Groups
	WITH TimeGroups AS
(
    SELECT
        CASE
            WHEN Time_Years <= 5 THEN '0-5 Years'
            WHEN Time_Years <= 10 THEN '6-10 Years'
            WHEN Time_Years <= 15 THEN '11-15 Years'
            WHEN Time_Years <= 20 THEN '16-20 Years'
            ELSE '21-25 Years'
        END AS Time_Category,
        Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Time_Category,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Time_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM TimeGroups
GROUP BY
    Time_Category,
    Condition
ORDER BY
    CASE Time_Category
        WHEN '0-5 Years' THEN 1
        WHEN '6-10 Years' THEN 2
        WHEN '11-15 Years' THEN 3
        WHEN '16-20 Years' THEN 4
        WHEN '21-25 Years' THEN 5
    END,
    Record_Count DESC;

	-- Step 19: Corrosion Impact Risk Groups
	WITH CorrosionGroups AS
(
    SELECT
        CASE
            WHEN Corrosion_Impact_Percent < 5 THEN 'Low Corrosion'
            WHEN Corrosion_Impact_Percent < 10 THEN 'Medium Corrosion'
            WHEN Corrosion_Impact_Percent < 15 THEN 'High Corrosion'
            ELSE 'Very High Corrosion'
        END AS Corrosion_Category,
        Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Corrosion_Category,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Corrosion_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM CorrosionGroups
GROUP BY
    Corrosion_Category,
    Condition
ORDER BY
    CASE Corrosion_Category
        WHEN 'Low Corrosion' THEN 1
        WHEN 'Medium Corrosion' THEN 2
        WHEN 'High Corrosion' THEN 3
        WHEN 'Very High Corrosion' THEN 4
    END,
    Record_Count DESC;

	-- Step 20: Pipe Thickness Risk Groups
	WITH ThicknessGroups AS
(
    SELECT
        CASE
            WHEN Thickness_mm < 10 THEN 'Thin'
            WHEN Thickness_mm < 20 THEN 'Medium'
            WHEN Thickness_mm < 30 THEN 'Thick'
            ELSE 'Very Thick'
        END AS Thickness_Category,
        Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Thickness_Category,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Thickness_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM ThicknessGroups
GROUP BY
    Thickness_Category,
    Condition
ORDER BY
    CASE Thickness_Category
        WHEN 'Thin' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Thick' THEN 3
        WHEN 'Very Thick' THEN 4
    END,
    Record_Count DESC;

	-- Step 21: Maximum Pressure Risk Groups
	WITH PressureGroups AS
(
    SELECT
        CASE
            WHEN Max_Pressure_psi < 500 THEN 'Low Pressure'
            WHEN Max_Pressure_psi < 1000 THEN 'Medium Pressure'
            WHEN Max_Pressure_psi < 1500 THEN 'High Pressure'
            ELSE 'Very High Pressure'
        END AS Pressure_Category,
        Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Pressure_Category,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Pressure_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM PressureGroups
GROUP BY
    Pressure_Category,
    Condition
ORDER BY
    CASE Pressure_Category
        WHEN 'Low Pressure' THEN 1
        WHEN 'Medium Pressure' THEN 2
        WHEN 'High Pressure' THEN 3
        WHEN 'Very High Pressure' THEN 4
    END,
    Record_Count DESC;

	-- Step 22: Temperature Risk Groups
	WITH TemperatureGroups AS
(
    SELECT
        CASE
            WHEN Temperature_C < 0 THEN 'Below 0 C'
            WHEN Temperature_C < 50 THEN '0-49 C'
            WHEN Temperature_C < 100 THEN '50-99 C'
            ELSE '100 C and Above'
        END AS Temperature_Category,
        Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Temperature_Category,
    Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Temperature_Category
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM TemperatureGroups
GROUP BY
    Temperature_Category,
    Condition
ORDER BY
    CASE Temperature_Category
        WHEN 'Below 0 C' THEN 1
        WHEN '0-49 C' THEN 2
        WHEN '50-99 C' THEN 3
        WHEN '100 C and Above' THEN 4
    END,
    Record_Count DESC;

	-- Step 23: Thickness Loss Range by Condition
	SELECT
    Condition,
    COUNT(*) AS Record_Count,
    MIN(Thickness_Loss_mm) AS Min_Thickness_Loss,
    MAX(Thickness_Loss_mm) AS Max_Thickness_Loss,
    AVG(Thickness_Loss_mm) AS Avg_Thickness_Loss,
    STDEV(Thickness_Loss_mm) AS Std_Thickness_Loss
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY
    Condition
ORDER BY
    CASE Condition
        WHEN 'Normal' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Critical' THEN 3
    END;


	-- Step 24: Compare Thickness Loss Rule with Condition
	WITH LossRule AS
(
    SELECT
        Condition,
        CASE
            WHEN Thickness_Loss_mm < 2 THEN 'Normal'
            WHEN Thickness_Loss_mm <= 5 THEN 'Moderate'
            ELSE 'Critical'
        END AS Predicted_Condition
    FROM dbo.market_pipe_thickness_loss_dataset
)
SELECT
    Condition AS Actual_Condition,
    Predicted_Condition,
    COUNT(*) AS Record_Count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY Condition
        )
        AS DECIMAL(5,2)
    ) AS Percentage
FROM LossRule
GROUP BY
    Condition,
    Predicted_Condition
ORDER BY
    CASE Condition
        WHEN 'Normal' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Critical' THEN 3
    END,
    CASE Predicted_Condition
        WHEN 'Normal' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Critical' THEN 3
    END;

	-- Step 25: Check Material Loss vs Condition
	SELECT
    Condition,
    COUNT(*) AS Record_Count,
    MIN(Material_Loss_Percent) AS Min_Material_Loss,
    MAX(Material_Loss_Percent) AS Max_Material_Loss,
    AVG(Material_Loss_Percent) AS Avg_Material_Loss,
    STDEV(Material_Loss_Percent) AS Std_Material_Loss
FROM dbo.market_pipe_thickness_loss_dataset
GROUP BY
    Condition
ORDER BY
    CASE Condition
        WHEN 'Normal' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Critical' THEN 3
    END;

	-- Step 26: Material Loss vs Thickness Loss
	
SELECT
    CASE
        WHEN Thickness_Loss_mm < 2 THEN 'Low Thickness Loss'
        WHEN Thickness_Loss_mm <= 5 THEN 'Medium Thickness Loss'
        ELSE 'High Thickness Loss'
    END AS Thickness_Loss_Category,
    
    COUNT(*) AS Record_Count,
    
    MIN(Material_Loss_Percent) AS Min_Material_Loss,
    MAX(Material_Loss_Percent) AS Max_Material_Loss,
    AVG(Material_Loss_Percent) AS Avg_Material_Loss,
    STDEV(Material_Loss_Percent) AS Std_Material_Loss

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY
    CASE
        WHEN Thickness_Loss_mm < 2 THEN 'Low Thickness Loss'
        WHEN Thickness_Loss_mm <= 5 THEN 'Medium Thickness Loss'
        ELSE 'High Thickness Loss'
    END

ORDER BY
    CASE
        WHEN
            CASE
                WHEN Thickness_Loss_mm < 2 THEN 'Low Thickness Loss'
                WHEN Thickness_Loss_mm <= 5 THEN 'Medium Thickness Loss'
                ELSE 'High Thickness Loss'
            END = 'Low Thickness Loss'
        THEN 1

        WHEN
            CASE
                WHEN Thickness_Loss_mm < 2 THEN 'Low Thickness Loss'
                WHEN Thickness_Loss_mm <= 5 THEN 'Medium Thickness Loss'
                ELSE 'High Thickness Loss'
            END = 'Medium Thickness Loss'
        THEN 2

        ELSE 3
    END;

	-- Step 27: Correlation Analysis
	SELECT
    COUNT(*) AS Record_Count,

    CAST(
        (
            COUNT(*) * SUM(Thickness_Loss_mm * Material_Loss_Percent)
            - SUM(Thickness_Loss_mm) * SUM(Material_Loss_Percent)
        )
        /
        NULLIF(
            SQRT(
                (
                    COUNT(*) * SUM(Thickness_Loss_mm * Thickness_Loss_mm)
                    - POWER(SUM(Thickness_Loss_mm), 2)
                )
                *
                (
                    COUNT(*) * SUM(Material_Loss_Percent * Material_Loss_Percent)
                    - POWER(SUM(Material_Loss_Percent), 2)
                )
            ),
            0
        )
        AS DECIMAL(10,4)
    ) AS Pearson_Correlation

FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 28: Correlation with Thickness Loss
SELECT
    Variable_Name,
    Pearson_Correlation
FROM
(
    -- -----------------------------------------
    -- Time Years
    -- -----------------------------------------
    SELECT
        'Time_Years' AS Variable_Name,
        CAST(
            (
                COUNT(*) * SUM(
                    CAST(Time_Years AS FLOAT)
                    * CAST(Thickness_Loss_mm AS FLOAT)
                )
                - SUM(CAST(Time_Years AS FLOAT))
                  * SUM(CAST(Thickness_Loss_mm AS FLOAT))
            )
            /
            NULLIF(
                SQRT(
                    (
                        COUNT(*) * SUM(
                            CAST(Time_Years AS FLOAT)
                            * CAST(Time_Years AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Time_Years AS FLOAT)), 2
                        )
                    )
                    *
                    (
                        COUNT(*) * SUM(
                            CAST(Thickness_Loss_mm AS FLOAT)
                            * CAST(Thickness_Loss_mm AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Thickness_Loss_mm AS FLOAT)), 2
                        )
                    )
                ),
                0
            )
            AS DECIMAL(10,4)
        ) AS Pearson_Correlation
    FROM dbo.market_pipe_thickness_loss_dataset

    UNION ALL

    -- -----------------------------------------
    -- Corrosion Impact
    -- -----------------------------------------
    SELECT
        'Corrosion_Impact_Percent',
        CAST(
            (
                COUNT(*) * SUM(
                    CAST(Corrosion_Impact_Percent AS FLOAT)
                    * CAST(Thickness_Loss_mm AS FLOAT)
                )
                - SUM(CAST(Corrosion_Impact_Percent AS FLOAT))
                  * SUM(CAST(Thickness_Loss_mm AS FLOAT))
            )
            /
            NULLIF(
                SQRT(
                    (
                        COUNT(*) * SUM(
                            CAST(Corrosion_Impact_Percent AS FLOAT)
                            * CAST(Corrosion_Impact_Percent AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Corrosion_Impact_Percent AS FLOAT)), 2
                        )
                    )
                    *
                    (
                        COUNT(*) * SUM(
                            CAST(Thickness_Loss_mm AS FLOAT)
                            * CAST(Thickness_Loss_mm AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Thickness_Loss_mm AS FLOAT)), 2
                        )
                    )
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM dbo.market_pipe_thickness_loss_dataset

    UNION ALL

    -- -----------------------------------------
    -- Temperature
    -- -----------------------------------------
    SELECT
        'Temperature_C',
        CAST(
            (
                COUNT(*) * SUM(
                    CAST(Temperature_C AS FLOAT)
                    * CAST(Thickness_Loss_mm AS FLOAT)
                )
                - SUM(CAST(Temperature_C AS FLOAT))
                  * SUM(CAST(Thickness_Loss_mm AS FLOAT))
            )
            /
            NULLIF(
                SQRT(
                    (
                        COUNT(*) * SUM(
                            CAST(Temperature_C AS FLOAT)
                            * CAST(Temperature_C AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Temperature_C AS FLOAT)), 2
                        )
                    )
                    *
                    (
                        COUNT(*) * SUM(
                            CAST(Thickness_Loss_mm AS FLOAT)
                            * CAST(Thickness_Loss_mm AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Thickness_Loss_mm AS FLOAT)), 2
                        )
                    )
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM dbo.market_pipe_thickness_loss_dataset

    UNION ALL

    -- -----------------------------------------
    -- Maximum Pressure
    -- -----------------------------------------
    SELECT
        'Max_Pressure_psi',
        CAST(
            (
                COUNT(*) * SUM(
                    CAST(Max_Pressure_psi AS FLOAT)
                    * CAST(Thickness_Loss_mm AS FLOAT)
                )
                - SUM(CAST(Max_Pressure_psi AS FLOAT))
                  * SUM(CAST(Thickness_Loss_mm AS FLOAT))
            )
            /
            NULLIF(
                SQRT(
                    (
                        COUNT(*) * SUM(
                            CAST(Max_Pressure_psi AS FLOAT)
                            * CAST(Max_Pressure_psi AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Max_Pressure_psi AS FLOAT)), 2
                        )
                    )
                    *
                    (
                        COUNT(*) * SUM(
                            CAST(Thickness_Loss_mm AS FLOAT)
                            * CAST(Thickness_Loss_mm AS FLOAT)
                        )
                        - POWER(
                            SUM(CAST(Thickness_Loss_mm AS FLOAT)), 2
                        )
                    )
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM dbo.market_pipe_thickness_loss_dataset

) AS Correlations

ORDER BY
    Pearson_Correlation DESC;

	-- Step 29: Correlation of Numeric Features
	WITH DataWithConditionScore AS
(
    SELECT
        CAST(Pipe_Size_mm AS FLOAT) AS Pipe_Size,
        CAST(Thickness_mm AS FLOAT) AS Thickness,
        CAST(Max_Pressure_psi AS FLOAT) AS Max_Pressure,
        CAST(Temperature_C AS FLOAT) AS Temperature,
        CAST(Corrosion_Impact_Percent AS FLOAT) AS Corrosion_Impact,
        CAST(Thickness_Loss_mm AS FLOAT) AS Thickness_Loss,
        CAST(Material_Loss_Percent AS FLOAT) AS Material_Loss,
        CAST(Time_Years AS FLOAT) AS Time_Years,

        CAST(
            CASE Condition
                WHEN 'Normal' THEN 1
                WHEN 'Moderate' THEN 2
                WHEN 'Critical' THEN 3
            END
            AS FLOAT
        ) AS Condition_Score

    FROM dbo.market_pipe_thickness_loss_dataset
),

Stats AS
(
    SELECT
        COUNT(*) AS N,

        SUM(Condition_Score) AS Sum_Y,
        SUM(Condition_Score * Condition_Score) AS Sum_Y2,

        SUM(Pipe_Size) AS Sum_Pipe_Size,
        SUM(Pipe_Size * Pipe_Size) AS Sum_Pipe_Size2,
        SUM(Pipe_Size * Condition_Score) AS Sum_Pipe_Size_Y,

        SUM(Thickness) AS Sum_Thickness,
        SUM(Thickness * Thickness) AS Sum_Thickness2,
        SUM(Thickness * Condition_Score) AS Sum_Thickness_Y,

        SUM(Max_Pressure) AS Sum_Max_Pressure,
        SUM(Max_Pressure * Max_Pressure) AS Sum_Max_Pressure2,
        SUM(Max_Pressure * Condition_Score) AS Sum_Max_Pressure_Y,

        SUM(Temperature) AS Sum_Temperature,
        SUM(Temperature * Temperature) AS Sum_Temperature2,
        SUM(Temperature * Condition_Score) AS Sum_Temperature_Y,

        SUM(Corrosion_Impact) AS Sum_Corrosion,
        SUM(Corrosion_Impact * Corrosion_Impact) AS Sum_Corrosion2,
        SUM(Corrosion_Impact * Condition_Score) AS Sum_Corrosion_Y,

        SUM(Thickness_Loss) AS Sum_Thickness_Loss,
        SUM(Thickness_Loss * Thickness_Loss) AS Sum_Thickness_Loss2,
        SUM(Thickness_Loss * Condition_Score) AS Sum_Thickness_Loss_Y,

        SUM(Material_Loss) AS Sum_Material_Loss,
        SUM(Material_Loss * Material_Loss) AS Sum_Material_Loss2,
        SUM(Material_Loss * Condition_Score) AS Sum_Material_Loss_Y,

        SUM(Time_Years) AS Sum_Time,
        SUM(Time_Years * Time_Years) AS Sum_Time2,
        SUM(Time_Years * Condition_Score) AS Sum_Time_Y

    FROM DataWithConditionScore
)

SELECT
    Variable_Name,
    Pearson_Correlation

FROM
(
    SELECT
        'Pipe_Size_mm' AS Variable_Name,
        CAST(
            (
                N * Sum_Pipe_Size_Y
                - Sum_Pipe_Size * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Pipe_Size2 - POWER(Sum_Pipe_Size, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        ) AS Pearson_Correlation
    FROM Stats

    UNION ALL

    SELECT
        'Thickness_mm',
        CAST(
            (
                N * Sum_Thickness_Y
                - Sum_Thickness * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Thickness2 - POWER(Sum_Thickness, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

    UNION ALL

    SELECT
        'Max_Pressure_psi',
        CAST(
            (
                N * Sum_Max_Pressure_Y
                - Sum_Max_Pressure * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Max_Pressure2 - POWER(Sum_Max_Pressure, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

    UNION ALL

    SELECT
        'Temperature_C',
        CAST(
            (
                N * Sum_Temperature_Y
                - Sum_Temperature * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Temperature2 - POWER(Sum_Temperature, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

    UNION ALL

    SELECT
        'Corrosion_Impact_Percent',
        CAST(
            (
                N * Sum_Corrosion_Y
                - Sum_Corrosion * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Corrosion2 - POWER(Sum_Corrosion, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

    UNION ALL

    SELECT
        'Thickness_Loss_mm',
        CAST(
            (
                N * Sum_Thickness_Loss_Y
                - Sum_Thickness_Loss * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Thickness_Loss2 - POWER(Sum_Thickness_Loss, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

    UNION ALL

    SELECT
        'Material_Loss_Percent',
        CAST(
            (
                N * Sum_Material_Loss_Y
                - Sum_Material_Loss * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Material_Loss2 - POWER(Sum_Material_Loss, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

    UNION ALL

    SELECT
        'Time_Years',
        CAST(
            (
                N * Sum_Time_Y
                - Sum_Time * Sum_Y
            )
            /
            NULLIF(
                SQRT(
                    (N * Sum_Time2 - POWER(Sum_Time, 2))
                    *
                    (N * Sum_Y2 - POWER(Sum_Y, 2))
                ),
                0
            )
            AS DECIMAL(10,4)
        )
    FROM Stats

) AS Correlations

ORDER BY
    ABS(Pearson_Correlation) DESC;

	-- Step 30: Critical Rate by Material
	SELECT
    Material,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Condition = 'Critical' THEN 1
            ELSE 0
        END
    ) AS Critical_Count,

    CAST(
        SUM(
            CASE
                WHEN Condition = 'Critical' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Critical_Rate_Percent

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY
    Material

ORDER BY
    Critical_Rate_Percent DESC;

-- Step 31: Critical Rate by Grade

SELECT
    Grade,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Condition = 'Critical' THEN 1
            ELSE 0
        END
    ) AS Critical_Count,

    CAST(
        SUM(
            CASE
                WHEN Condition = 'Critical' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Critical_Rate_Percent

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY
    Grade

ORDER BY
    Critical_Rate_Percent DESC;

-- Step 33: Critical Rate by Time

WITH TimeGroups AS
(
    SELECT
        CASE
            WHEN Time_Years BETWEEN 1 AND 5 THEN '1-5 Years'
            WHEN Time_Years BETWEEN 6 AND 10 THEN '6-10 Years'
            WHEN Time_Years BETWEEN 11 AND 15 THEN '11-15 Years'
            WHEN Time_Years BETWEEN 16 AND 20 THEN '16-20 Years'
            WHEN Time_Years BETWEEN 21 AND 25 THEN '21-25 Years'
        END AS Time_Group,

        Condition

    FROM dbo.market_pipe_thickness_loss_dataset
)

SELECT
    Time_Group,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Condition = 'Critical' THEN 1
            ELSE 0
        END
    ) AS Critical_Count,

    CAST(
        SUM(
            CASE
                WHEN Condition = 'Critical' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Critical_Rate_Percent

FROM TimeGroups

GROUP BY Time_Group

ORDER BY
    CASE Time_Group
        WHEN '1-5 Years' THEN 1
        WHEN '6-10 Years' THEN 2
        WHEN '11-15 Years' THEN 3
        WHEN '16-20 Years' THEN 4
        WHEN '21-25 Years' THEN 5
    END;

-- Step 33: Critical Rate by Temperature

WITH TemperatureGroups AS
(
    SELECT
        CASE
            WHEN Temperature_C < 0 THEN 'Below 0 C'
            WHEN Temperature_C < 50 THEN '0-49 C'
            WHEN Temperature_C < 100 THEN '50-99 C'
            ELSE '100 C and Above'
        END AS Temperature_Group,

        Condition

    FROM dbo.market_pipe_thickness_loss_dataset
)

SELECT
    Temperature_Group,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Condition = 'Critical' THEN 1
            ELSE 0
        END
    ) AS Critical_Count,

    CAST(
        SUM(
            CASE
                WHEN Condition = 'Critical' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS Critical_Rate_Percent

FROM TemperatureGroups

GROUP BY Temperature_Group

ORDER BY
    CASE Temperature_Group
        WHEN 'Below 0 C' THEN 1
        WHEN '0-49 C' THEN 2
        WHEN '50-99 C' THEN 3
        WHEN '100 C and Above' THEN 4
    END;

-- Step 34: Feature Comparison by Condition


SELECT
    Condition,

    COUNT(*) AS Record_Count,

    ROUND(AVG(Thickness_Loss_mm), 2) AS Avg_Thickness_Loss,

    ROUND(AVG(Material_Loss_Percent), 2) AS Avg_Material_Loss,

    ROUND(AVG(Thickness_mm), 2) AS Avg_Thickness,

    ROUND(AVG(Pipe_Size_mm), 2) AS Avg_Pipe_Size,

    ROUND(AVG(Max_Pressure_psi), 2) AS Avg_Pressure,

    ROUND(AVG(Temperature_C), 2) AS Avg_Temperature,

    ROUND(AVG(Corrosion_Impact_Percent), 2) AS Avg_Corrosion,

    ROUND(AVG(Time_Years), 2) AS Avg_Time_Years

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Condition

ORDER BY
    CASE Condition
        WHEN 'Normal' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Critical' THEN 3
    END;

-- Step 35: Overall Risk Profile


SELECT
    Condition,

    COUNT(*) AS Record_Count,

    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage_of_Total,

    ROUND(AVG(Thickness_Loss_mm), 2) AS Avg_Thickness_Loss,

    ROUND(AVG(Material_Loss_Percent), 2) AS Avg_Material_Loss

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Condition

ORDER BY
    CASE Condition
        WHEN 'Normal' THEN 1
        WHEN 'Moderate' THEN 2
        WHEN 'Critical' THEN 3
    END;

-- Step 36: Pipeline Risk Classification

WITH RiskGroups AS
(
    SELECT
        CASE
            WHEN Thickness_Loss_mm < 2 THEN 'Low Risk'
            WHEN Thickness_Loss_mm <= 5 THEN 'Medium Risk'
            ELSE 'High Risk'
        END AS Risk_Level

    FROM dbo.market_pipe_thickness_loss_dataset
)

SELECT
    Risk_Level,

    COUNT(*) AS Pipeline_Count,

    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(6,2)
    ) AS Percentage_of_Total

FROM RiskGroups

GROUP BY Risk_Level

ORDER BY
    CASE Risk_Level
        WHEN 'Low Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'High Risk' THEN 3
    END;

-- Step 38: Risk Level by Material

SELECT
    Material,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Thickness_Loss_mm < 2 THEN 1
            ELSE 0
        END
    ) AS Low_Risk_Count,

    SUM(
        CASE
            WHEN Thickness_Loss_mm >= 2
                 AND Thickness_Loss_mm <= 5
            THEN 1
            ELSE 0
        END
    ) AS Medium_Risk_Count,

    SUM(
        CASE
            WHEN Thickness_Loss_mm > 5 THEN 1
            ELSE 0
        END
    ) AS High_Risk_Count

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Material

ORDER BY High_Risk_Count DESC;

-- Step 38: High Risk Rate by Material

SELECT
    Material,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Thickness_Loss_mm > 5 THEN 1
            ELSE 0
        END
    ) AS High_Risk_Count,

    CAST(
        SUM(
            CASE
                WHEN Thickness_Loss_mm > 5 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS High_Risk_Rate_Percent

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Material

ORDER BY High_Risk_Rate_Percent DESC;

-- Step 39: High Risk Rate by Grade

SELECT
    Grade,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Thickness_Loss_mm > 5 THEN 1
            ELSE 0
        END
    ) AS High_Risk_Count,

    CAST(
        SUM(
            CASE
                WHEN Thickness_Loss_mm > 5 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS High_Risk_Rate_Percent

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Grade

ORDER BY High_Risk_Rate_Percent DESC;

-- Step 40: Pipeline Risk Priority

SELECT
    Material,
    Grade,

    Thickness_Loss_mm,
    Material_Loss_Percent,

    Condition,

    CASE
        WHEN Thickness_Loss_mm < 2 THEN 'Low Risk'
        WHEN Thickness_Loss_mm <= 5 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS Risk_Level,

    CASE
        WHEN Thickness_Loss_mm > 5
             AND Material_Loss_Percent >= 100
        THEN 'Critical Priority'

        WHEN Thickness_Loss_mm > 5
             AND Material_Loss_Percent >= 50
        THEN 'High Priority'

        WHEN Thickness_Loss_mm > 5
        THEN 'Medium Priority'

        ELSE 'Normal Priority'
    END AS Maintenance_Priority

FROM dbo.market_pipe_thickness_loss_dataset

ORDER BY
    CASE
        WHEN Thickness_Loss_mm > 5
             AND Material_Loss_Percent >= 100
        THEN 1

        WHEN Thickness_Loss_mm > 5
             AND Material_Loss_Percent >= 50
        THEN 2

        WHEN Thickness_Loss_mm > 5
        THEN 3

        ELSE 4
    END,

    Thickness_Loss_mm DESC;

-- Step 41: Maintenance Priority Summary

WITH PriorityGroups AS
(
    SELECT
        CASE
            WHEN Thickness_Loss_mm > 5
                 AND Material_Loss_Percent >= 100
            THEN 'Critical Priority'

            WHEN Thickness_Loss_mm > 5
                 AND Material_Loss_Percent >= 50
            THEN 'High Priority'

            WHEN Thickness_Loss_mm > 5
            THEN 'Medium Priority'

            ELSE 'Normal Priority'
        END AS Maintenance_Priority

    FROM dbo.market_pipe_thickness_loss_dataset
)

SELECT
    Maintenance_Priority,

    COUNT(*) AS Pipeline_Count,

    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(6,2)
    ) AS Percentage_of_Total

FROM PriorityGroups

GROUP BY Maintenance_Priority

ORDER BY
    CASE Maintenance_Priority
        WHEN 'Critical Priority' THEN 1
        WHEN 'High Priority' THEN 2
        WHEN 'Medium Priority' THEN 3
        WHEN 'Normal Priority' THEN 4
    END;

-- Step 42: High/Critical Priority by Material

SELECT
    Material,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Thickness_Loss_mm > 5
                 AND Material_Loss_Percent >= 50
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Priority_Count,

    CAST(
        SUM(
            CASE
                WHEN Thickness_Loss_mm > 5
                     AND Material_Loss_Percent >= 50
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS High_Critical_Priority_Rate

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Material

ORDER BY High_Critical_Priority_Rate DESC;

-- Step 44: High/Critical Priority by Grade

SELECT
    Grade,

    COUNT(*) AS Total_Records,

    SUM(
        CASE
            WHEN Thickness_Loss_mm > 5
                 AND Material_Loss_Percent >= 50
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Priority_Count,

    CAST(
        SUM(
            CASE
                WHEN Thickness_Loss_mm > 5
                     AND Material_Loss_Percent >= 50
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS High_Critical_Priority_Rate

FROM dbo.market_pipe_thickness_loss_dataset

GROUP BY Grade

ORDER BY High_Critical_Priority_Rate DESC;

-- Step 44: Final Risk Dashboard Summary

SELECT
    COUNT(*) AS Total_Pipelines,

    SUM(
        CASE
            WHEN Condition = 'Normal'
            THEN 1
            ELSE 0
        END
    ) AS Normal_Pipelines,

    SUM(
        CASE
            WHEN Condition = 'Moderate'
            THEN 1
            ELSE 0
        END
    ) AS Moderate_Pipelines,

    SUM(
        CASE
            WHEN Condition = 'Critical'
            THEN 1
            ELSE 0
        END
    ) AS Critical_Pipelines,

    SUM(
        CASE
            WHEN Thickness_Loss_mm > 5
                 AND Material_Loss_Percent >= 50
            THEN 1
            ELSE 0
        END
    ) AS High_Critical_Maintenance_Priority,

    ROUND(
        AVG(Thickness_Loss_mm), 2
    ) AS Avg_Thickness_Loss,

    ROUND(
        AVG(Material_Loss_Percent), 2
    ) AS Avg_Material_Loss

FROM dbo.market_pipe_thickness_loss_dataset;

-- Step 45: Create Final Risk Dashboard View


CREATE VIEW dbo.vw_Pipeline_Risk_Dashboard
AS

SELECT
    Pipe_Size_mm,
    Thickness_mm,
    Material,
    Grade,
    Max_Pressure_psi,
    Temperature_C,
    Corrosion_Impact_Percent,
    Thickness_Loss_mm,
    Material_Loss_Percent,
    Time_Years,
    Condition,

    -- Risk Level based on Thickness Loss
    CASE
        WHEN Thickness_Loss_mm < 2
            THEN 'Low Risk'

        WHEN Thickness_Loss_mm <= 5
            THEN 'Medium Risk'

        ELSE 'High Risk'
    END AS Risk_Level,

    -- Maintenance Priority
    CASE
        WHEN Thickness_Loss_mm > 5
             AND Material_Loss_Percent >= 100
            THEN 'Critical Priority'

        WHEN Thickness_Loss_mm > 5
             AND Material_Loss_Percent >= 50
            THEN 'High Priority'

        WHEN Thickness_Loss_mm > 5
            THEN 'Medium Priority'

        ELSE 'Normal Priority'
    END AS Maintenance_Priority

FROM dbo.market_pipe_thickness_loss_dataset;
GO

-- Step 45.1: Check Risk Dashboard View


SELECT *
FROM dbo.vw_Pipeline_Risk_Dashboard;


-- Step 46: Risk Dashboard Summary


SELECT
    Risk_Level,
    Maintenance_Priority,
    COUNT(*) AS Pipeline_Count,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage_of_Total
FROM dbo.vw_Pipeline_Risk_Dashboard
GROUP BY
    Risk_Level,
    Maintenance_Priority
ORDER BY
    CASE Risk_Level
        WHEN 'Low Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'High Risk' THEN 3
    END,
    CASE Maintenance_Priority
        WHEN 'Critical Priority' THEN 1
        WHEN 'High Priority' THEN 2
        WHEN 'Medium Priority' THEN 3
        WHEN 'Normal Priority' THEN 4
    END;

-- Step 47: Top Critical Pipelines


SELECT TOP 20
    Material,
    Grade,
    Pipe_Size_mm,
    Thickness_mm,
    Max_Pressure_psi,
    Temperature_C,
    Corrosion_Impact_Percent,
    Thickness_Loss_mm,
    Material_Loss_Percent,
    Time_Years,
    Condition,
    Risk_Level,
    Maintenance_Priority

FROM dbo.vw_Pipeline_Risk_Dashboard

WHERE Maintenance_Priority IN
(
    'Critical Priority',
    'High Priority'
)

ORDER BY
    CASE Maintenance_Priority
        WHEN 'Critical Priority' THEN 1
        WHEN 'High Priority' THEN 2
    END,
    Thickness_Loss_mm DESC,
    Material_Loss_Percent DESC;

-- Step 48: Maintenance Action

SELECT
    Material,
    Grade,
    Thickness_Loss_mm,
    Material_Loss_Percent,
    Condition,
    Risk_Level,
    Maintenance_Priority,

    CASE
        WHEN Maintenance_Priority = 'Critical Priority'
            THEN 'Immediate Inspection'

        WHEN Maintenance_Priority = 'High Priority'
            THEN 'Priority Inspection'

        WHEN Maintenance_Priority = 'Medium Priority'
            THEN 'Schedule Maintenance'

        ELSE 'Routine Monitoring'
    END AS Maintenance_Action

FROM dbo.vw_Pipeline_Risk_Dashboard

ORDER BY
    CASE Maintenance_Priority
        WHEN 'Critical Priority' THEN 1
        WHEN 'High Priority' THEN 2
        WHEN 'Medium Priority' THEN 3
        WHEN 'Normal Priority' THEN 4
    END,
    Thickness_Loss_mm DESC;

-- Step 49: Maintenance Action Summary


SELECT
    Maintenance_Priority,

    CASE
        WHEN Maintenance_Priority = 'Critical Priority'
            THEN 'Immediate Inspection'

        WHEN Maintenance_Priority = 'High Priority'
            THEN 'Priority Inspection'

        WHEN Maintenance_Priority = 'Medium Priority'
            THEN 'Schedule Maintenance'

        ELSE 'Routine Monitoring'
    END AS Maintenance_Action,

    COUNT(*) AS Pipeline_Count,

    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage_of_Total

FROM dbo.vw_Pipeline_Risk_Dashboard

GROUP BY
    Maintenance_Priority

ORDER BY
    CASE Maintenance_Priority
        WHEN 'Critical Priority' THEN 1
        WHEN 'High Priority' THEN 2
        WHEN 'Medium Priority' THEN 3
        WHEN 'Normal Priority' THEN 4
    END;

-- Step 50: Final Project Summary


SELECT
    COUNT(*) AS Total_Pipelines,

    SUM(CASE
        WHEN Condition = 'Normal'
        THEN 1 ELSE 0
    END) AS Normal_Pipelines,

    SUM(CASE
        WHEN Condition = 'Moderate'
        THEN 1 ELSE 0
    END) AS Moderate_Pipelines,

    SUM(CASE
        WHEN Condition = 'Critical'
        THEN 1 ELSE 0
    END) AS Critical_Pipelines,

    SUM(CASE
        WHEN Maintenance_Priority = 'Critical Priority'
        THEN 1 ELSE 0
    END) AS Critical_Maintenance,

    SUM(CASE
        WHEN Maintenance_Priority = 'High Priority'
        THEN 1 ELSE 0
    END) AS High_Maintenance,

    SUM(CASE
        WHEN Maintenance_Priority = 'Medium Priority'
        THEN 1 ELSE 0
    END) AS Medium_Maintenance,

    SUM(CASE
        WHEN Maintenance_Priority = 'Normal Priority'
        THEN 1 ELSE 0
    END) AS Normal_Maintenance,

    ROUND(AVG(Thickness_Loss_mm), 2) AS Avg_Thickness_Loss,

    ROUND(AVG(Material_Loss_Percent), 2) AS Avg_Material_Loss

FROM dbo.vw_Pipeline_Risk_Dashboard;