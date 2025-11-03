-- Main breakdown: Installation Done first, then Pending
SELECT 
    CI.[DTR_Code] AS DTR_Code,
    COUNT(DISTINCT CI.[IVRS_Number]) AS [Consumer Survey],
    COUNT(DISTINCT AMI.[MI_Record_ID]) AS [Meter Installation],
    -- Extract date only from Survey_Submit_Time
    CAST(MIN(CAST(CI.[Survey_Submit_Time] AS DATE)) AS DATE) AS Indexing_Date,
 
    -- Extract date only from Installation_DateTime
    CAST(MIN(CAST(AMI.[Installation_DateTime] AS DATE)) AS DATE) AS Installation_Date,
 
    CASE 
        WHEN COUNT(DISTINCT AMI.[MI_Record_ID]) = 0 THEN 'Pending Installation'
        ELSE 'Installation Done'
    END AS Installation_Status
FROM [dbo].[CI] CI
LEFT JOIN [dbo].[ApprovedMeterInstallation] AMI
    ON CI.[DTR_Code] = AMI.[DTR_Code]
GROUP BY CI.[DTR_Code]
ORDER BY 
    CASE 
        WHEN COUNT(DISTINCT AMI.[MI_Record_ID]) = 0 THEN 1 -- Pending last
        ELSE 0 -- Installation Done first
    END,
    CI.[DTR_Code];
 
-- Summary row: Total counts across all DTRs
SELECT 
    'TOTAL' AS DTR_Code,
    SUM([Consumer Survey]) AS [Consumer Survey],
    SUM([Meter Installation]) AS [Meter Installation],
    NULL AS Indexing_Date,
    NULL AS Installation_Date,
    NULL AS Installation_Status
FROM (
    SELECT 
        CI.[DTR_Code],
        COUNT(DISTINCT CI.[IVRS_Number]) AS [Consumer Survey],
        COUNT(DISTINCT AMI.[MI_Record_ID]) AS [Meter Installation]
    FROM [dbo].[CI] CI
    LEFT JOIN [dbo].[ApprovedMeterInstallation] AMI
        ON CI.[DTR_Code] = AMI.[DTR_Code]
    GROUP BY CI.[DTR_Code]
) AS Summary;