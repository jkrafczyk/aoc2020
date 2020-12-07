PRAGMA recursive_triggers = ON;

CREATE TABLE bag_total_size(
    color VARCHAR,
    total_size INTEGER
);

CREATE TABLE debug_trace(msg VARCHAR);
CREATE VIEW debug(recursion_level, msg) AS SELECT (NULL, NULL);
CREATE TRIGGER tr_debug 
INSTEAD OF INSERT ON debug
BEGIN    
    INSERT INTO debug_trace(msg) VALUES
        (printf('%' || (2*new.recursion_level) ||'s%s', '', new.msg));
END;

CREATE VIEW calculate_golden_bag_size(color, recursion_level) AS SELECT (NULL, NULL);
CREATE TRIGGER tr_calculate_golden_bag_size 
INSTEAD OF INSERT ON calculate_golden_bag_size
BEGIN    
    --Skip repeated bag-size recalculation:
    INSERT INTO debug SELECT new.recursion_level, ('Not re-visiting bag "' || new.color || '"') WHERE EXISTS(SELECT * FROM bag_total_size WHERE color = new.color);
    SELECT RAISE(IGNORE) WHERE EXISTS(SELECT * FROM bag_total_size WHERE color = new.color);

    INSERT INTO debug VALUES (new.recursion_level, 'Visited bag "' || new.color || '"');

    --Recursively descend into our sub-bags:
    INSERT INTO calculate_golden_bag_size(color, recursion_level)
        SELECT contents, new.recursion_level+1 FROM bag_contents WHERE container = new.color; 
    
    --Simple case: this right here is a leaf-node and must have cost 1.
    INSERT 
        INTO bag_total_size(color, total_size) 
        SELECT new.color, 1 
        WHERE NOT EXISTS (SELECT * FROM bag_contents WHERE container = new.color);
    INSERT INTO debug SELECT new.recursion_level, '  cost = 1 (leaf)' WHERE NOT EXISTS (SELECT * FROM bag_contents WHERE container = new.color);

    --Less simple case: this is a non-leaf node. This one's cost is calculated as:
    ---- for each child-bag:
    ----   (cost of one child-bag) * (number of child-bag in this bag)
    ---- +1
    INSERT INTO bag_total_size(color, total_size)
        SELECT new.color, 1 + SUM(total_size) FROM (
            SELECT 
                    bc.count * bts.total_size AS total_size
                FROM bag_contents bc 
                INNER JOIN bag_total_size bts
                ON bc.contents = bts.color
                WHERE bc.container = new.color
        );

    INSERT INTO debug 
        SELECT 
            new.recursion_level, 
            printf('  cost = %i (non-leaf)', (SELECT total_size FROM bag_total_size WHERE color = new.color)) 
        WHERE EXISTS (SELECT * FROM bag_contents WHERE container = new.color);

    INSERT INTO debug 
        SELECT 
            new.recursion_level, 
            printf('  final cost, exluding %s bag itself, = %i', new.color, (SELECT total_size FROM bag_total_size WHERE color = new.color)-1)
        WHERE
            new.recursion_level = 0;    
END;


INSERT INTO calculate_golden_bag_size VALUES ('shiny gold', 0);
SELECT 'Trace:';
SELECT * FROM debug_trace;