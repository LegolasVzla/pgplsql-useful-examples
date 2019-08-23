-- DROP FUNCTION IF EXISTS temporal_schema.udf_like_actions_get(integer,integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_like_actions_get(
    param_user_id integer, param_spot_id integer)
  RETURNS json AS
$BODY$

DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /*
  -- To Test:
    SELECT temporal_schema.udf_like_actions_get(1,1);
  */

  IF EXISTS (
      SELECT
        la.id
      FROM temporal_schema.spots s
        INNER JOIN temporal_schema.user_actions ua
          ON s.id = ua.spots_id
          INNER JOIN temporal_schema.type_user_actions tua
            ON ua.type_user_actions_id = tua.id
        INNER JOIN temporal_schema.like_actions la
          ON ua.id = la.user_actions_id
          AND
          s.is_active
          AND
          ua.is_active
          AND
          tua.is_active
          AND
          la.is_active
          AND
          not s.is_deleted
          AND
          not ua.is_deleted
          AND
          not tua.is_deleted
          AND
          not la.is_deleted
          AND
          s.user_id = param_user_id
          AND
          s.id = param_spot_id
          AND
          tua.id = 3  -- Type User Actions Table: Likes
    ) THEN

      -- RAISE NOTICE 'Were found Likes actions of the current spot with current user';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "actionsList"
      FROM (
        SELECT
          la.id,
          la.user_id as "likedBy",
          la.created_at
        FROM temporal_schema.spots s
          INNER JOIN temporal_schema.user_actions ua
            ON s.id = ua.spots_id
            INNER JOIN temporal_schema.type_user_actions tua
              ON ua.type_user_actions_id = tua.id
          INNER JOIN temporal_schema.like_actions la
            ON ua.id = la.user_actions_id
            AND
            s.is_active
            AND
            ua.is_active
            AND
            tua.is_active
            AND
            la.is_active
            AND
            not s.is_deleted
            AND
            not ua.is_deleted
            AND
            not tua.is_deleted
            AND
            not la.is_deleted
            AND
            s.user_id = param_user_id
            AND
            s.id = param_spot_id
            AND
            tua.id = 3  -- Type User Actions Table: Likes
      )a;

  ELSE

    --RAISE NOTICE 'Were not found Likes actions of the current spot with the current user';

  END IF;

    RETURN json_returning;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_like_actions_get(integer,integer)
  OWNER TO postgres;