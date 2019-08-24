-- DROP FUNCTION IF EXISTS temporal_schema.udf_comments_get(integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_comments_get(
    param_spot_id integer)
  RETURNS json AS
$BODY$

DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /* 
  -- To Test:
    SELECT temporal_schema.udf_comments_get(1);
  */

  IF EXISTS (
      SELECT
        c.id
      FROM temporal_schema.spots s
        INNER JOIN temporal_schema.user_actions ua
          ON s.id = ua.spot_id
          INNER JOIN temporal_schema.type_user_actions tua
            ON ua.type_user_actions_id = tua.id
        INNER JOIN temporal_schema.comments c
          ON ua.id = c.user_actions_id
          AND
          s.is_active
          AND
          ua.is_active
          AND
          tua.is_active
          AND
          c.is_active
          AND
          not s.is_deleted
          AND
          not ua.is_deleted
          AND
          not tua.is_deleted
          AND
          not c.is_deleted
          AND
          s.id = param_spot_id
          AND
          c.parent_id is null
          AND
          tua.id = 4  -- Type User Actions Table: Comments
    ) THEN

      -- RAISE NOTICE 'Were found Comments actions of the current spot';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "commentsList"
      FROM (
        SELECT
          c.id,
          c.body,
          c.sender_by_id,
          c.received_id,
          c.created_at,
          --(select temporal_schema.udf_sub_comments_get(c.id) as "subCommentsList"),
          (select temporal_schema.udf_comment_liked_get(c.id,param_spot_id) as "commentLikedList")          
        FROM temporal_schema.spots s
          INNER JOIN temporal_schema.user_actions ua
            ON s.id = ua.spot_id
            INNER JOIN temporal_schema.type_user_actions tua
              ON ua.type_user_actions_id = tua.id
          INNER JOIN temporal_schema.comments c
            ON ua.id = c.user_actions_id
            AND
            s.is_active
            AND
            ua.is_active
            AND
            tua.is_active
            AND
            c.is_active
            AND
            not s.is_deleted
            AND
            not ua.is_deleted
            AND
            not tua.is_deleted
            AND
            not c.is_deleted
            AND
            s.id = param_spot_id
            AND
            c.parent_id is null            
            AND
            tua.id = 4  -- Type User Actions Table: Comments
      )a;

  ELSE

    --RAISE NOTICE 'Were not found Comments actions of the current spot';

  END IF;

    RETURN json_returning;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_comments_get(integer)
  OWNER TO postgres;