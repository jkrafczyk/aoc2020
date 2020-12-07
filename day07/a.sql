PRAGMA recursive_triggers = ON;

CREATE TABLE path_subgraphs_visited(
    from_color VARCHAR PRIMARY KEY, 
    leads_to_target BOOLEAN
);
CREATE TABLE path_steps_visited(
    from_color VARCHAR, 
    to_color VARCHAR, 
    leads_to_target BOOLEAN,
    PRIMARY KEY(from_color, to_color)
);

CREATE VIEW find_paths_to(target_color) AS SELECT (NULL);
CREATE TRIGGER tr_find_paths_to 
INSTEAD OF INSERT ON find_paths_to
BEGIN
    DELETE FROM path_subgraphs_visited;
    DELETE FROM path_steps_visited;
    INSERT INTO 
        find_paths_to_starting_at(target_color, start_color)
    SELECT new.target_color, bags.color
    FROM bags;
END;

CREATE VIEW find_paths_to_starting_at(target_color, start_color) AS SELECT (NULL, NULL);
CREATE TRIGGER tr_find_paths_to_starting_at
INSTEAD OF INSERT ON find_paths_to_starting_at
BEGIN
    --Avoid re-visiting start colors
    SELECT RAISE(IGNORE) 
        WHERE EXISTS(
            SELECT * FROM path_subgraphs_visited WHERE from_color = new.start_color
    );

    INSERT INTO path_subgraphs_visited(from_color, leads_to_target) 
        VALUES (new.start_color, FALSE);

    --Visit all children of the start color
    INSERT INTO visit_step(target_color, from_color, to_color)
        SELECT new.target_color, new.start_color, bc.contents
        FROM bag_contents bc
        WHERE container = new.start_color;

    --If one of our children leads to the target bag, then so do we:
    UPDATE path_subgraphs_visited 
        SET leads_to_target = TRUE
        WHERE
        from_color = new.start_color 
        AND EXISTS (
            SELECT * FROM path_steps_visited WHERE from_color = new.start_color AND leads_to_target = TRUE
        );
END;

CREATE VIEW visit_step(target_color, from_color, to_color) AS SELECT (NULL, NULL, NULL);
CREATE TRIGGER tr_visit_step 
INSTEAD OF INSERT ON visit_step
BEGIN
    --Avoid re-visiting edges:
    SELECT RAISE(IGNORE) 
        WHERE EXISTS(
            SELECT * FROM path_steps_visited WHERE from_color = new.from_color AND to_color = new.to_color
    );
    INSERT INTO path_steps_visited(from_color, to_color, leads_to_target)
        VALUES (new.from_color, new.to_color, FALSE);
    
    --Have we reached the goal?
    UPDATE path_steps_visited 
        SET leads_to_target = TRUE 
    WHERE 
        from_color = new.from_color
        AND to_color = new.to_color
        AND to_color = new.target_color;

    -- Recursively visit children:
    INSERT INTO visit_step(target_color, from_color, to_color) 
    SELECT
        new.target_color,
        new.to_color AS from_color,
        bc.contents
    FROM bag_contents bc WHERE container = new.to_color;

    -- If one of our children can contain the target color, then so can we:
    UPDATE path_steps_visited
        SET leads_to_target = TRUE
    WHERE
        from_color = new.from_color
        AND to_color = new.to_color
        AND EXISTS (
            SELECT * FROM path_steps_visited
            WHERE from_color = new.to_color
            AND leads_to_target = TRUE
        );
END;

INSERT INTO find_paths_to VALUES ('shiny gold');
SELECT COUNT(*) FROM (SELECT DISTINCT from_color FROM path_subgraphs_visited WHERE leads_to_target = TRUE);