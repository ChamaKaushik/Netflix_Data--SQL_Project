-- clean the data  

-- replace space with null 
 
UPDATE netflix SET director = NULL WHERE TRIM(director) = '';
UPDATE netflix SET casts = NULL WHERE TRIM(casts) = '';
UPDATE netflix SET country = NULL WHERE TRIM(country) = '';
UPDATE netflix SET rating = NULL WHERE TRIM(rating) = '';
UPDATE netflix SET duration = NULL WHERE TRIM(duration) = '';
UPDATE netflix SET date_added = NULL WHERE TRIM(date_added) = '';


SELECT COUNT(*) FROM netflix WHERE director IS NULL;
SELECT COUNT(*) FROM netflix WHERE casts IS NULL;
SELECT COUNT(*) FROM netflix WHERE country IS NULL;
SELECT COUNT(*) FROM netflix WHERE rating IS NULL;
SELECT COUNT(*) FROM netflix WHERE duration IS NULL;
SELECT COUNT(*) FROM netflix WHERE date_added IS NULL;

COMMIT ;

 -- now create a view which do not include any null and then reuse it in every query 
CREATE VIEW netflix_clean AS
SELECT *
FROM netflix
WHERE director IS NOT NULL
  AND rating IS NOT NULL
  AND country IS NOT NULL
  AND duration IS NOT NULL
  AND casts IS NOT NULL
  AND date_added IS NOT NULL;

select * from netflix_clean  ;

 -- now use this view in every query , no need to write where col_name is not null in every query 
 
      --  OR WE CAN REPLACE NULL WITH SOME VALUES OR LIKE AVERAGE, SOME COMMONLY OCCURING VALUE IN THAT PARTICULAR COL
      --  like this 
      
-- Column	                  Options after cleaning
-- director	              Replace NULL with 'Unknown' or skip in stats
-- country	                  Use 'Unspecified', or exclude in maps
-- rating	                  Replace with 'Not Rated', or ignore
-- duration	              Handle missing duration as unknown runtime
-- date_added	              Exclude from time-based analysis, or flag

commit ;