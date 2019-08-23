-- DROP FUNCTION temporal_schema.udf_users_tagged_get(integer, integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_users_tagged_get(
    param_user_id integer,
    param_spot_id integer)
  RETURNS json AS
$BODY$
DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /* 
  -- To Test:
    SELECT temporal_schema.udf_users_tagged_get(1,1); 
  */

  IF EXISTS (
      SELECT
        ut.id
      FROM temporal_schema.spots s
        INNER JOIN temporal_schema.user_actions ua
          ON s.id = ua.spots_id
          INNER JOIN temporal_schema.type_user_actions tua
            ON ua.type_user_actions_id = tua.id
        INNER JOIN temporal_schema.user_taggeds ut
          ON ua.id = ut.user_actions_id
          AND
          s.is_active
          AND
          ua.is_active
          AND
          tua.is_active
          AND
          ut.is_active
          AND
          not s.is_deleted
          AND
          not ua.is_deleted
          AND
          not tua.is_deleted
          AND
          not ut.is_deleted
          AND
          s.user_id = param_user_id
          AND
          s.id = param_spot_id
          AND
          tua.id = 4  -- Type User Actions Table: Users Tagged
    ) THEN

      -- RAISE NOTICE 'Were found User Tagged actions of the current spot with current user';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "usersTaggedList"
      FROM (
        SELECT
          ut.id,
          ut.tagged_by_id as "taggedById",
          ut.tagged_user_id as "userTaggedId",
          ut.created_at
        FROM temporal_schema.spots s
          INNER JOIN temporal_schema.user_actions ua
            ON s.id = ua.spots_id
            INNER JOIN temporal_schema.type_user_actions tua
              ON ua.type_user_actions_id = tua.id
          INNER JOIN temporal_schema.user_taggeds ut
            ON ua.id = ut.user_actions_id
            AND
            s.is_active
            AND
            ua.is_active
            AND
            tua.is_active
            AND
            ut.is_active
            AND
            not s.is_deleted
            AND
            not ua.is_deleted
            AND
            not tua.is_deleted
            AND
            not ut.is_deleted
            AND
            s.user_id = param_user_id
            AND
            s.id = param_spot_id
            AND
            tua.id = 4  -- Type User Actions Table: Users Tagged
      )a;

  ELSE

    RAISE NOTICE 'Were not found User Tagged actions of the current spot with the current user';

  END IF;

    RETURN json_returning;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_users_tagged_get(integer, integer)
  OWNER TO postgres;
