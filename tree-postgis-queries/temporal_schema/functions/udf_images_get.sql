-- DROP FUNCTION IF EXISTS temporal_schema.udf_images_get(integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_images_get(
    param_spot_id integer)
  RETURNS json AS
$BODY$

DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /*
  -- To Test:
    SELECT temporal_schema.udf_images_get(1);
  */

  IF EXISTS (
    SELECT
      si.id
    FROM temporal_schema.images si
      INNER JOIN temporal_schema.spots s
        ON si.spot_id = s.id
        AND
        si.is_active
        AND
        not si.is_deleted                      
        AND
        s.is_active
        AND
        not s.is_deleted
        AND
        s.id = param_spot_id
    ) THEN

      -- RAISE NOTICE 'Were found images of the current place';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "imageList"
      FROM (
        SELECT
          si.id "imageId",
          si.url "imageURI",
          si.is_principal,
          si.is_active
        FROM temporal_schema.images si
          INNER JOIN temporal_schema.spots s
            ON si.spot_id = s.id
            AND
            si.is_active
            AND
            not si.is_deleted                      
            AND
            s.is_active
            AND
            not s.is_deleted
            AND
            s.id = param_spot_id
        GROUP BY
          si.id, si.spot_id
        ORDER BY 
          si.id, si.is_principal
      )a;

  ELSE

    --RAISE NOTICE 'Were not found images of the current place';

  END IF;

    RETURN json_returning;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_images_get(integer)
  OWNER TO postgres;