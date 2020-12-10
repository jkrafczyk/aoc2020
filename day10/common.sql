CREATE TABLE adapters AS 
    SELECT 
        CAST(line AS INTEGER) AS joltage
    FROM input;
CREATE INDEX ix_adapter_joltage ON adapters(joltage);