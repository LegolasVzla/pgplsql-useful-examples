-- DROP FUNCTION IF EXISTS temporal_schema.udf_tags_get(integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_tags_get(
    param_spot_id integer)
  RETURNS json AS
$BODY$

DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /*
  -- To Test:
    SELECT temporal_schema.udf_tags_get(1);
  */

  IF EXISTS (
    SELECT
      t.id,
      t.name
    FROM temporal_schema.user_actions ua
      INNER JOIN temporal_schema.spot_tags st
        ON ua.id = st.user_actions_id
      INNER JOIN temporal_schema.tags t
        ON st.tag_id = t.id
        AND
        ua.is_active
        AND
        not ua.is_deleted
        AND
        st.is_active
        AND
        not st.is_deleted
        AND
        t.is_active
        AND
        not t.is_deleted
        AND
        ua.spot_id = param_spot_id
    ) THEN

      -- RAISE NOTICE 'Were found taga of the current spot';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "tagsList"
      FROM (
        SELECT
          t.id,
          t.name
        FROM temporal_schema.user_actions ua
          INNER JOIN temporal_schema.spot_tags st
            ON ua.id = st.user_actions_id
          INNER JOIN temporal_schema.tags t
            ON st.tag_id = t.id
            AND
            ua.is_active
            AND
            not ua.is_deleted
            AND
            st.is_active
            AND
            not st.is_deleted
            AND
            t.is_active
            AND
            not t.is_deleted
            AND
            ua.spot_id = param_spot_id
      )a;

  ELSE

    --RAISE NOTICE 'Were not found taga of the current spot';

    -- json_returning  = '[]';

  END IF;

    RETURN json_returning;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_tags_get(integer)
  OWNER TO postgres;