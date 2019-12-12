-- DROP FUNCTION public.udf_spots_nearby_by_filter_place_name(integer, double precision, double precision,varchar,integer,integer);
CREATE OR REPLACE FUNCTION public.udf_spots_nearby_by_filter_place_name(
    param_user_id integer,
    param_lat double precision,
    param_long double precision,
    param_place_name varchar,
    param_rows_maximum_request integer,
    param_gimme_more_rows integer)
  RETURNS json AS
$BODY$

DECLARE

  local_max_distance decimal = 2000.0;     -- Default max distance: 2 km or you could receive it as a parameter
  aux_tree_returning varchar = '';
  status_value varchar = 'fail';
  data_value json = '{ "User_id": "' || param_user_id || ' not found" }';
  param_json_returning json = json_build_object('status',status_value,'data',data_value);
  --i RECORD;
    
  BEGIN        

  /*
  -- To Test:
    SELECT udf_spots_nearby_by_filter_place_name(1,10.4823307,-66.861713,'Cayo Sal',10,0);
  */

  -- Prevention SQL injection
  IF NOT EXISTS(
    SELECT
      id
    FROM
      temporal_schema.users
    WHERE
      id = param_user_id
    ) THEN

    RAISE NOTICE '%',param_json_returning;
    RETURN param_json_returning;

  END IF;

  status_value = 'success';

  DROP TABLE IF EXISTS temporal_spots_table;
  -- Create a temporary table to store nearby places
  CREATE TEMPORARY TABLE IF NOT EXISTS temporal_spots_table (
    id integer,
    user_id integer,
    name character varying,
    lat double precision,
    lng double precision,
    country character varying,
    city character varying,
    is_active boolean DEFAULT true,
    created_date timestamp without time zone
  );

  INSERT INTO temporal_spots_table(
    id,
    user_id,
    name,
    lat,
    lng,
    country,
    city,
    is_active,
    created_date
  )
  -- Get all the spots from the current user
  SELECT
    s.id,
    s.user_id,
    s.name,
    s.lat,
    s.lng,
    s.country,
    s.city,
    s.is_active,
    s.created_date
  FROM
    temporal_schema.spots s
    --INNER JOIN temporal_schema.system_statuses ss
    --  ON ss.id = s.status_id
    --INNER JOIN temporal_schema.entity_statuses es
    --  ON es.id = ss.entity_status_id
    --INNER JOIN temporal_schema.users u
    --  ON s.user_id = u.id
  WHERE
    s.user_id IN (
      -- Get spots that belongs to the current user or their friends
		SELECT DISTINCT
		  f.friendable_id
		FROM
		  friendships f
		  INNER JOIN users u
			ON (f.friendable_id = u.id OR f.friend_id = u.id) 
		  INNER JOIN spots s
			ON u.id = s.users_id
		WHERE 
		  (f.friendable_id = param_user_id OR f.friend_id = param_user_id)
		   AND f.status = 2 -- Are friends
		   AND u.id = param_user_id 
		   AND u.is_active
		   AND NOT u.is_deleted
		   AND s.is_active
		   AND NOT s.is_deleted
		   AND
		   ST_DistanceSphere("s"."position", ST_GeomFromEWKB(ST_MakePoint(param_long,param_lat)::bytea)) <= (local_max_distance::float)
	) --OR s.users_id = param_user_id
    /* If you want to exclude the current place where you are
	AND 
    s.lat != 10.469245
    AND
    s.long != -66.5489833
	*/
    AND
    s.name ILIKE concat(param_place_name, '%')
    --AND
    --ss.id = 5 -- Activo
    --AND
    --es.id = 2 -- Spot
    AND
    s.is_active
    --AND
    --ss.is_active
    --AND
    --es.is_active
    AND
    NOT s.is_deleted
    --AND
    --NOT ss.is_deleted
    --AND
    --NOT es.is_deleted
    AND
    ST_DistanceSphere("s"."position", ST_GeomFromEWKB(ST_MakePoint(param_long,param_lat)::bytea)) <= (local_max_distance::float)
    ORDER BY ST_DistanceSphere("s"."position", ST_GeomFromWKB(ST_MakePoint(param_long,param_lat)::bytea));
--    ST_DistanceSphere("s"."position", ST_GeomFromWKB(ST_MakePoint(param_long,param_lat)::bytea)) <= (local_max_distance::float) 
--    ORDER BY ST_DistanceSphere("s"."position", ST_GeomFromEWKB(ST_MakePoint(param_long,param_lat)::bytea));
--    ST_DistanceSphere("s"."position", ST_GeomFromEWKB(ST_MakePoint(param_long,param_lat)::bytea)) <= (local_max_distance::float)  
--    ORDER BY ST_DistanceSphere("s"."position", ST_GeomFromEWKB(ST_MakePoint(param_long,param_lat)::bytea));

    -- Only for temporal_spots_table test purpose 
    /*
    FOR i IN (
      SELECT *
      FROM
        temporal_spots_table
      ) LOOP

      RAISE NOTICE 'spot_id: %',i.id;

    END LOOP;
    */

  IF EXISTS (
    SELECT
      id
    FROM
      temporal_spots_table
    ) THEN

      --RAISE NOTICE 'Were found places near where you are';

      SELECT JSON_AGG(a.*) INTO STRICT aux_tree_returning
      FROM (
        SELECT
          (
            SELECT 
              count(tst.id) 
            FROM 
              temporal_spots_table tst) AS "totalSpots",
          (
            SELECT ARRAY_AGG(b.*) as "spotsData"
            FROM (
              SELECT
                  tst.id "spotId",
                  (SELECT ARRAY_AGG(c.*) 
                    FROM (
                      SELECT DISTINCT
                        id,
                        CONCAT(first_name,' ' || last_name) as owner--,
                        --avatar as "avatar_url"
                      FROM
                        temporal_schema.users
                      WHERE
                        id = tst.user_id
                    )c
                  ) "ownerDetails",
                  tst.name "spotName",
                  tst.lat,
                  tst.lng,
                  tst.country,
                  tst.city,
                  tst.is_active,
                  concat((now()-created_date),' Ago') AS "created_date",
                  --concat((current_date-cast(created_date as date)),' ago') as "created_date",
                  (SELECT temporal_schema.udf_categories_get(tst.id) AS "categoriesList"),
                  (SELECT temporal_schema.udf_tags_get(tst.id) AS "tagsList"),
                  (SELECT
                      CASE
                      WHEN (
                        count(la.id) > 0 
                      ) THEN count(la.id)
                      ELSE 0
                      END
                    FROM
                      temporal_schema.user_actions ua
                      INNER JOIN temporal_schema.like_actions la
                        ON ua.id = la.user_actions_id
                    WHERE
                      ua.spot_id = tst.id
                      AND
                      ua.is_active
                      AND NOT
                      ua.is_deleted
                      AND
                      la.is_active
                      AND NOT
                      la.is_deleted
                  ) "totallikes",
                  (SELECT temporal_schema.udf_like_actions_get(param_user_id,tst.id) AS "likesList"),
                  (SELECT temporal_schema.udf_images_get(tst.id) AS "imageList"),
                  (SELECT temporal_schema.udf_users_tagged_get(param_user_id,tst.id) AS "usersTaggedList"),
                  (SELECT temporal_schema.udf_comments_get(tst.id) AS "commentsList")
              FROM 
                  temporal_spots_table tst
              LIMIT param_rows_maximum_request OFFSET param_gimme_more_rows -- Getting rows by range
            )
          b)
      )a;
      data_value = (replace(aux_tree_returning, '\"', ''))::json;

  ELSE

    data_value = '[{
    "totalSpots": 0,
    "spotsData":
      [{
          "spotId": null,
          "ownerDetails": [],
          "spotName": null,
          "lat": null,
          "lng": null,
          "country": null,
          "city": null,
          "is_active": null,
          "created_date": null,
          "categoriesList": [],
          "tagsList": [],
          "totallikes": null,
          "likesList": [],
          "imageList": [],
          "usersTaggedList": [],
          "commentsList": []
        }]
      }]';

    --RAISE NOTICE 'Were not found places near where you are';

  END IF;

    param_json_returning = json_build_object('status',status_value,'data',data_value);
    RAISE notice '%',param_json_returning; 
    RETURN param_json_returning;

  DROP TABLE IF EXISTS temporal_spots_table;
  --COMMIT;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.udf_spots_nearby_by_filter_place_name(integer, double precision, double precision,varchar,integer,integer)
  OWNER TO postgres;
