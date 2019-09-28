-- DROP FUNCTION temporal_schema.udf_spots_nearby_within_X_kilometers_from_current_user_position(integer, double precision, double precision);
CREATE OR REPLACE FUNCTION temporal_schema.udf_spots_nearby_within_X_kilometers_from_current_user_position(
    param_user_id integer,
    param_lat double precision,
    param_lng double precision)
  RETURNS json AS
$BODY$

DECLARE

  local_max_distance decimal = 5000.0;    -- Default max distance: 5 km or you could receive it as a parameter
  aux_tree_returning varchar = '';  
  status_value varchar = 'fail';
  data_value json = '{ "User_id": "' || param_user_id || ' not found" }';
  param_json_returning json = json_build_object('status',status_value,'data',data_value);
  --i RECORD;
    
  BEGIN        

  /*
  -- To Test:
    SELECT temporal_schema.udf_spots_nearby_within_X_kilometers_from_current_user_position(1,10.4823307,-66.861713);
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

    RAISE NOTICE 'User % not found',param_user_id;
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
        country_code character varying,        
        city character varying,
        is_active boolean DEFAULT true,
        is_deleted boolean DEFAULT false,
        created_date timestamp without time zone        
  );

  INSERT INTO temporal_spots_table(
    id,
    user_id,
    name,
    lat,
    lng,
    country,
    country_code,
    city,
    is_active,
    is_deleted,
    created_date
  )

  -- This is the main query:
  -- Get the places within 5 km from the current position where you are, using PostGIS
  SELECT
    s.id,
    s.user_id,    
    s.name,
    s.lat,
    s.lng,
    s.country,
    s.country_code,
    s.city,
    s.is_active,
    s.is_deleted,
    s.created_date
  FROM
    temporal_schema.spots s
    INNER JOIN temporal_schema.users u
      ON u.id = s.user_id
  WHERE
    s.user_id IN (
      -- Get spot of your friends
    SELECT DISTINCT
      friendable_id
    FROM
      friendships
    WHERE 
      (friendable_id = param_user_id OR
      friend_id = param_user_id) AND
      status = 2 -- Are friends
    )
    --AND 
    --s.lat != param_lat
    --AND
    --s.lng != param_lng
    AND
    s.is_active
    AND
    u.is_active
    AND
    NOT s.is_deleted
    AND
    NOT u.is_deleted
    AND
    ST_DistanceSphere("s"."position", ST_GeomFromEWKB(ST_MakePoint(param_lng,param_lat)::bytea)) <= (local_max_distance::float);

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
          (SELECT count(tst.id) FROM temporal_spots_table tst WHERE tst.user_id = param_user_id) as "totalSpots",
          (
            SELECT ARRAY_AGG(b.*) as "spotsData"
            FROM (
              SELECT
                tst.id "spotId",
                tst.name "spotName",
                tst.lat,
                tst.lng,
                tst.country,
                tst.country_code,
                tst.city,
                tst.is_active,
                tst.created_date,
                (select temporal_schema.udf_categories_get(tst.id) as "categoriesList"),
                (select temporal_schema.udf_tags_get(tst.id) as "tagsList"),          
                (select temporal_schema.udf_like_actions_get(param_user_id,tst.id) as "likesList"),
                (select temporal_schema.udf_images_get(tst.id) as "imageList"),
                (select temporal_schema.udf_users_tagged_get(param_user_id,tst.id) as "usersTaggedList"),
                (select temporal_schema.udf_comments_get(tst.id) as "commentsList")
              FROM 
                  temporal_spots_table tst
              GROUP BY
                  tst.id,
                  tst.user_id,
                  tst.name,
                  tst.lat,
                  tst.lng,
                  tst.country,
                  tst.country_code,
                  tst.city,
                  tst.is_active,
                  tst.created_date
              ORDER BY 
                  tst.id DESC
              --LIMIT 10
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
          "spotName": null,
          "lat": null,
          "lng": null,
          "country": null,
          "country_code": null,
          "city": null,
          "is_active": null,
          "created_date": null,
          "categoriesList": [],
          "tagsList": [],
          "likesList": [],
          "ibeenList": [],
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
ALTER FUNCTION temporal_schema.udf_spots_nearby_within_X_kilometers_from_current_user_position(integer, double precision, double precision)
  OWNER TO postgres;