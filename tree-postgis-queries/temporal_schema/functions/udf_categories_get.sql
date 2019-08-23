-- DROP FUNCTION IF EXISTS temporal_schema.udf_categories_get(integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_categories_get(
    param_spot_id integer)
  RETURNS json AS
$BODY$

DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /*
  -- To Test:
    SELECT temporal_schema.udf_categories_get(1);
  */

  IF EXISTS (
    SELECT
      sc.id
    FROM temporal_schema.spot_categories sc
      INNER JOIN temporal_schema.categories c
        ON sc.category_id = c.id
        AND
        sc.is_active
        AND
        not sc.is_deleted                      
        AND
        c.is_active
        AND
        not c.is_deleted
        AND
        sc.spot_id = param_spot_id
    ) THEN

      -- RAISE NOTICE 'Were found categories of the current spot';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "categoriesList"
      FROM (
        SELECT
          sc.id "categoryId",
          c.name "categoryName",
          sc.is_active
        FROM temporal_schema.spot_categories sc
          INNER JOIN temporal_schema.categories c
            ON sc.category_id = c.id
            AND
            sc.is_active
            AND
            not sc.is_deleted                      
            AND
            c.is_active
            AND
            not c.is_deleted
            AND
            sc.spot_id = param_spot_id
      )a;

  ELSE

    --RAISE NOTICE 'Were not found categories of the current spot';

    -- json_returning  = '[]';

  END IF;

    RETURN json_returning;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_categories_get(integer)
  OWNER TO postgres;