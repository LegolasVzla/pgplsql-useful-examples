-- DROP FUNCTION IF EXISTS temporal_schema.udf_comment_liked_get(integer,integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_comment_liked_get(
    param_comment_id integer, param_spot_id integer)
  RETURNS json AS
$BODY$

DECLARE

  json_returning json = '[]';
    
  BEGIN        

  /*
  -- To Test:
    SELECT temporal_schema.udf_comment_liked_get(1,1);
  */

  IF EXISTS (
      SELECT
        c.id
      FROM temporal_schema.user_actions ua
        INNER JOIN temporal_schema.spots s
          ON ua.spot_id = s.id
        INNER JOIN temporal_schema.type_user_actions tua
          ON ua.type_user_actions_id = tua.id
        INNER JOIN temporal_schema.comments c
          ON ua.comment_liked_id = c.id
        INNER JOIN temporal_schema.like_actions la
          ON ua.comment_liked_id = la.id
          AND
          ua.is_active
          AND
          s.is_active
          AND
          tua.is_active
          AND
          c.is_active
          AND
          la.is_active
          AND
          not ua.is_deleted
          AND
          not s.is_deleted
          AND
          not tua.is_deleted
          AND
          not c.is_deleted
          AND
          not la.is_deleted
          AND
          ua.comment_liked_id = param_comment_id
          AND
          ua.spot_id = param_spot_id          
          AND
          tua.id = 3  -- Type User Actions Table: Likes
    ) THEN

      -- RAISE NOTICE 'Were found Likes actions of the current comment with the current spot';

      SELECT JSON_AGG(a.*) INTO STRICT json_returning as "commentLikedList"
      FROM (
        SELECT
          c.id as "commentId",
          la.id as "likeId",
          la.user_id as "likedBy"--,
          --(select temporal_schema.udf_comment_liked_get(c.id,param_spot_id) as "commentLikedList")
        FROM temporal_schema.user_actions ua
          INNER JOIN temporal_schema.spots s
            ON ua.spot_id = s.id
          INNER JOIN temporal_schema.type_user_actions tua
            ON ua.type_user_actions_id = tua.id
          INNER JOIN temporal_schema.comments c
            ON ua.comment_liked_id = c.id
          INNER JOIN temporal_schema.like_actions la
            ON ua.comment_liked_id = la.id
            AND
            ua.is_active
            AND
            s.is_active
            AND
            tua.is_active
            AND
            c.is_active
            AND
            la.is_active
            AND
            not ua.is_deleted
            AND
            not s.is_deleted
            AND
            not tua.is_deleted
            AND
            not c.is_deleted
            AND
            not la.is_deleted
            AND
            ua.comment_liked_id = param_comment_id
            AND
            ua.spot_id = param_spot_id          
            AND
            tua.id = 3  -- Type User Actions Table: Likes
      )a;

  ELSE

    --RAISE NOTICE 'Were not found Likes actions of the current comment with the current spot';

  END IF;

    RETURN json_returning;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_comment_liked_get(integer,integer)
  OWNER TO postgres;