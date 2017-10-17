SET client_min_messages TO WARNING;

CREATE TABLE T (c1 INT, c2 INT);
INSERT INTO T SELECT i, i % 7 FROM generate_series(1, 100) AS i;

SELECT COUNT(*) FROM T;
SELECT c1, c2 FROM T WHERE c1 IN (SELECT c1 FROM T WHERE c2 < 3);

DROP TABLE T;
