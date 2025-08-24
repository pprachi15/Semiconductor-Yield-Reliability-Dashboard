
--If we would re-run we woul dbegin by dropping the tables.
DROP TABLE IF EXISTS wafer_sensors;
DROP TABLE IF EXISTS wafers;

-- Wafers: one row per wafer test event, creating the tables
CREATE TABLE wafers (
    wafer_id        VARCHAR(40) PRIMARY KEY,
    fab             VARCHAR(40),                -- e.g., Phoenix, Austin
    tool_id         VARCHAR(40),                -- e.g., Tool-P2
    shift           VARCHAR(16),                -- Day / Night / Swing
    lot_id          VARCHAR(40),
    step            VARCHAR(60),                -- process step
    test_ts         TIMESTAMP,                  -- test timestamp
    pass_fail       VARCHAR(8) CHECK (pass_fail IN ('Pass','Fail'))
);

-- Creating Sensor table for readings associated to a wafer
CREATE TABLE wafer_sensors (
    wafer_id        VARCHAR(40) REFERENCES wafers(wafer_id),
    sensor_name     VARCHAR(80),                -- e.g., Pressure_Etch, Thickness_CMP
    sensor_value    NUMERIC,                    -- normalized or raw
    pass_fail       VARCHAR(8) CHECK (pass_fail IN ('Pass','Fail')),
    PRIMARY KEY (wafer_id, sensor_name)
);

-- creating indexes for performance
CREATE INDEX idx_wafers_ts      ON wafers(test_ts);
CREATE INDEX idx_wafers_shift   ON wafers(shift);
CREATE INDEX idx_wafers_tool    ON wafers(tool_id);
CREATE INDEX idx_ws_sensorname  ON wafer_sensors(sensor_name);



-- Total wafers, pass/fail counts, Yield %, Defect %
SELECT 
    COUNT(*)                                                  AS total_wafers,
    SUM(CASE WHEN pass_fail = 'Pass' THEN 1 ELSE 0 END)      AS passed_wafers,
    SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END)      AS failed_wafers,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Pass' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS yield_pct,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS defect_pct
FROM wafers;


-- Daily Yield Trend

SELECT 
    CAST(test_ts AS DATE) AS day,
    COUNT(*)                                                  AS total_wafers,
    SUM(CASE WHEN pass_fail = 'Pass' THEN 1 ELSE 0 END)      AS passed_wafers,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Pass' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS daily_yield_pct
FROM wafers
GROUP BY CAST(test_ts AS DATE)
ORDER BY day;


 --Failure Rate by Hour (local hour extracted from timestamp)
SELECT 
    EXTRACT(HOUR FROM test_ts)                                AS hour_of_day,
    COUNT(*)                                                  AS total_wafers,
    SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END)      AS failed_wafers,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS failure_rate_pct
FROM wafers
GROUP BY EXTRACT(HOUR FROM test_ts)
ORDER BY hour_of_day;

-- Top Defect Drivers by Sensor
SELECT 
    ws.sensor_name,
    COUNT(*)                                                  AS total_tests,
    SUM(CASE WHEN ws.pass_fail = 'Fail' THEN 1 ELSE 0 END)   AS sensor_failures,
    ROUND(100.0 * SUM(CASE WHEN ws.pass_fail = 'Fail' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS failure_rate_pct
FROM wafer_sensors ws
GROUP BY ws.sensor_name
ORDER BY sensor_failures DESC, ws.sensor_name;


--Tool × Shift Reliability Heatmap (Failure Rate %)
SELECT 
    tool_id,
    shift,
    COUNT(*)                                                  AS total_wafers,
    SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END)      AS failed_wafers,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS failure_rate_pct
FROM wafers
GROUP BY tool_id, shift
ORDER BY failure_rate_pct DESC, tool_id, shift;

--   MTBF per Tool (proxy using counts)
--   MTBF ˜ Operational units / Failures within period.
--   Here: number of wafers processed per failure for each tool.

SELECT 
    tool_id,
    COUNT(*)                                                  AS total_wafers,
    SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END)      AS total_failures,
    CASE 
        WHEN SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END) = 0 THEN NULL
        ELSE ROUND(1.0 * COUNT(*) / SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END), 2)
    END                                                      AS mtbf_units_per_failure
FROM wafers
GROUP BY tool_id
ORDER BY mtbf_units_per_failure DESC NULLS LAST, tool_id;


-- Pareto of Failures by Sensor (80/20)
WITH sensor_failures AS (
    SELECT 
        sensor_name,
        COUNT(*) AS total_failures
    FROM wafer_sensors
    WHERE pass_fail = 'Fail'
    GROUP BY sensor_name
)
SELECT 
    sensor_name,
    total_failures,
    ROUND(100.0 * total_failures / NULLIF(SUM(total_failures) OVER(),0), 2)                  AS pct_of_failures,
    ROUND(SUM(100.0 * total_failures / NULLIF(SUM(total_failures) OVER(),0)) 
          OVER (ORDER BY total_failures DESC), 2)                                            AS cumulative_pct
FROM sensor_failures
ORDER BY total_failures DESC, sensor_name;


-- Drill-down: Which lots drive failures for a risky tool/shift?
-- Replace 'Tool-P2' and 'Night' as needed.
SELECT 
    lot_id,
    COUNT(*)                                                  AS wafers_in_lot,
    SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END)      AS failed_in_lot,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS lot_failure_rate_pct
FROM wafers
WHERE tool_id = 'Tool-P2'
  AND shift   = 'Night'
GROUP BY lot_id
ORDER BY lot_failure_rate_pct DESC, lot_id;


-- Time-windowed KPIs (parameterized by date range)
-- Example window: July 1–31, 2025
WITH windowed AS (
    SELECT * 
    FROM wafers
    WHERE test_ts >= TIMESTAMP '2025-07-01 00:00:00'
      AND test_ts <  TIMESTAMP '2025-08-01 00:00:00'
)
SELECT 
    COUNT(*)                                                  AS total_wafers,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Pass' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS yield_pct,
    ROUND(100.0 * SUM(CASE WHEN pass_fail = 'Fail' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0), 2) AS defect_pct
FROM windowed;


-- Data Quality Checks (sanity checks for pipelines)

-- a) Orphan sensor rows
SELECT ws.wafer_id, ws.sensor_name
FROM wafer_sensors ws
LEFT JOIN wafers w USING (wafer_id)
WHERE w.wafer_id IS NULL;

-- b) Invalid pass/fail values
SELECT DISTINCT pass_fail
FROM wafers
WHERE pass_fail NOT IN ('Pass','Fail');

-- c) Null critical fields
SELECT COUNT(*) AS null_timestamp_rows
FROM wafers
WHERE test_ts IS NULL;

