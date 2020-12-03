--We could just create an index on 'input' and query that, but 'n' is prettier than 'line' for querying :)
CREATE TABLE numbers (n INTEGER PRIMARY KEY);
INSERT INTO numbers SELECT * FROM INPUT;