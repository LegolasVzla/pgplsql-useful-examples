-- DROP FUNCTION IF EXISTS temporal_schema.udf_friends_list_get(integer,integer,integer,integer);
CREATE OR REPLACE FUNCTION temporal_schema.udf_friends_list_get(
    param_user_id integer,  -- This is the user that is visiting the profile
    param_user_id_to_view integer, -- This is the profile owner
	rows_maximum_request integer,
	param_gimme_more_rows integer    
    )
  RETURNS json AS
$BODY$
DECLARE
  aux_tree_returning varchar = '';
  status_value varchar = 'fail';
  data_value json = '{ "User_id": "' || param_user_id || ' not found" }';
  param_json_returning json = json_build_object('status',status_value,'data',data_value);
    
  BEGIN        
  /*
  -- To Test:
    SELECT udf_friends_list_get(1,2,6,0);
    SELECT udf_friends_list_get(1,1,6,0);    
  */
  -- Prevention SQL injection
  IF NOT EXISTS(
    SELECT
      id
    FROM
      users
    WHERE
      id = param_user_id
    ) THEN

    RAISE NOTICE '%',param_json_returning;
    RETURN param_json_returning;

  END IF;

  -- Prevention SQL injection
  IF NOT EXISTS(
    SELECT
      id
    FROM
      users
    WHERE
      id = param_user_id_to_view
    ) THEN

    data_value = '{ "User_id": "' || param_user_id_to_view || ' not found" }';
    param_json_returning = json_build_object('status',status_value,'data',data_value);
    RAISE NOTICE '%',param_json_returning;
    RETURN param_json_returning;

  END IF;
  status_value = 'success';

    IF EXISTS (
        SELECT 
            count(id) 
        FROM 
            friendships
        WHERE 
            friend_id=param_user_id_to_view
            AND status = 2
    ) THEN

        RAISE NOTICE 'Were found friends';

        SELECT JSON_AGG(a.*) INTO STRICT aux_tree_returning
        FROM (
            SELECT
                (SELECT 
                    count(id) 
                FROM 
                    friendships
                WHERE 
                    friend_id=param_user_id_to_view 
                    AND status = 2
                ) as "item_found",
                (
                    SELECT ARRAY_AGG(b.*) as "items"
                    FROM (
                      SELECT
                          f.friendable_id,
                          u.email,
                          u.mobile,
                          u.first_name,
                          u.last_name,
                          u.bio,
                          u.avatar,
                          u.status_account,
                          u.is_private_account,
                          u.created_at,
                          u.updated_at,
                          u.gmail_id,
                          u.facebook_id,
                          u.verification_code,
                          u.telephone_prefix_id,
                          u.full_name,
                          (SELECT
                              CASE
                              WHEN (
                                  u.id = param_user_id
                              ) THEN True
                              ELSE False
                              END
                          /*FROM 
                              friendships f
                          WHERE 
                          (f.friendable_id = param_user_id OR f.friend_id = param_user_id_to_view) AND f.status = 2 -- Are friends*/
                          ) as "its_me"
                      FROM 
                          friendships f
                      INNER JOIN users u
                          ON (f.friendable_id = u.id)-- OR f.friend_id = u.id) 
                      WHERE 
                      f.friend_id = param_user_id_to_view
                      AND f.status = 2 -- Are friends
                      AND 
                      u.is_active
                      AND
                      NOT u.is_deleted
                      ORDER BY u.first_name
                    LIMIT rows_maximum_request OFFSET param_gimme_more_rows -- Getting rows by range
                    )
                b)
        )a;

        data_value = (replace(aux_tree_returning, '\"', ''))::json;

    ELSE

        data_value = '[{
        "item_found": 0,
        "items": []}]';

        -- RAISE NOTICE 'Were not found friends';

    END IF;

    param_json_returning = json_build_object('status',status_value,'data',data_value);
    RAISE notice '%',param_json_returning; 
    RETURN param_json_returning;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION temporal_schema.udf_friends_list_get(integer,integer,integer,integer)
  OWNER TO postgres;