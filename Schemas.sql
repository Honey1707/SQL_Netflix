-- SCHEMAS of Netflix

DROP TABLE IF EXISTS netflix_data;
CREATE TABLE netflix_data
(
	id             VARCHAR(6),
	category       VARCHAR(15),
	name           VARCHAR(255),
	filmmaker      VARCHAR(600),
	actors         VARCHAR(1100),
	origin_country VARCHAR(600),
	added_date     VARCHAR(60),
	year_released  INT,
	content_rating VARCHAR(20),
	run_time       VARCHAR(20),
	genres         VARCHAR(255),
	summary        VARCHAR(600)
);

SELECT * FROM netflix_data;
