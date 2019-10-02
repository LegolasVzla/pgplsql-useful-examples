-- DROP FUNCTION public.udf_spots_profile_get(integer);
CREATE OR REPLACE FUNCTION public.udf_spots_profile_get(param_user_id integer)
  RETURNS json AS
$BODY$

DECLARE

  aux_tree_returning varchar = '';
  status_value varchar = 'fail';
  data_value json = '{ "User_id": "' || param_user_id || ' not found" }';
  param_json_returning json = json_build_object('status',status_value,'data',data_value);
  --i RECORD;
    
  BEGIN        

  /*
  -- To Test:
    select public.udf_spots_profile_get(260);
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

  status_value = 'success';

  DROP TABLE IF EXISTS temporal_spots_table;

  -- Create a temporary table to store nearby places
  CREATE TEMPORARY TABLE IF NOT EXISTS temporal_spots_table (
        id integer,
        users_id integer,
        name character varying,
        remarks character varying,
        review character varying,
        reference_point character varying,
        lat double precision,
        long double precision,
        country_name character varying,
        state_name character varying,
        city_name character varying,
        description character varying,
        full_address character varying,
        is_privated boolean DEFAULT false,
        is_active boolean DEFAULT true,
        created_at timestamp without time zone
  );

  INSERT INTO temporal_spots_table(
    id,
    users_id,
	name,
    remarks,
    review,
    reference_point,
    lat,
    long,
    country_name,
    state_name,
    city_name,
    description,
    full_address,
    is_privated,
    is_active,
    created_at
  )
  -- Get all the spots from the current user
  SELECT
    s.id,
    s.users_id,
    s.name,
    s.remarks,
    s.review,
    s.reference_point,
    s.lat,
    s.long,
    s.country_name,
    s.state_name,
    s.city_name,
    ss.description,
    s.full_address,
    s.is_privated,
    s.is_active,
    s.created_at
  FROM
    spots s
    INNER JOIN system_statuses ss
      ON ss.id = s.status_id
    INNER JOIN entity_statuses es
      ON es.id = ss.entity_status_id
  WHERE
    s.users_id = param_user_id
    AND
    ss.id = 5 -- Activo
    AND
    es.id = 2 -- Spot
    AND
    s.is_active
    AND
    ss.is_active
    AND
    es.is_active
    AND
    NOT s.is_deleted
    AND
    NOT ss.is_deleted
    AND
    NOT es.is_deleted
   GROUP BY
    s.id,
    s.users_id,
    s.name,
    s.remarks,
    s.review,
    s.reference_point,
    s.lat,
    s.long,
    s.country_name,
    s.state_name,
    s.city_name,
    ss.description,
    s.full_address,
    s.is_privated,
    s.is_active,
    s.created_at   
    ;

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

      RAISE NOTICE 'Were found places';

      SELECT JSON_AGG(a.*) INTO STRICT aux_tree_returning
      FROM (
        SELECT
          (select count(tst.id) from temporal_spots_table tst where tst.users_id = param_user_id) as "totalSpots",
          (
            SELECT ARRAY_AGG(b.*) as "spotsData"
            FROM (
              SELECT
                  tst.id "spotId",
                  tst.name "spotName",
                  tst.remarks,
                  tst.reference_point,
                  tst.lat,
                  tst.long,
                  tst.country_name,
                  tst.state_name,
                  tst.city_name,
                  tst.description "status",
                  tst.full_address,
                  tst.is_privated,
                  tst.is_active,
                  concat((now()-created_at),' Ago') as "created_at",
                  --concat((current_date-cast(created_at as date)),' ago') as "created_at",
                  (select public.udf_categories_get(tst.id) as "categoriesList"),
                  (select public.udf_tags_get(tst.id) as "tagsList"),
                  (select public.udf_like_actions_get(param_user_id,tst.id,0) as "likesList"),
                  (select public.udf_images_get(tst.id) as "imageList"),
                  (select public.udf_users_tagged_get(param_user_id,tst.id) as "usersTaggedList"),
                  (select public.udf_comments_get(tst.id) as "commentsList")
              FROM 
                  temporal_spots_table tst
              GROUP BY
                  tst.id,
                  tst.users_id,
                  tst.name,
                  tst.remarks,
                  tst.reference_point,
                  tst.review,
                  tst.lat,
                  tst.long,
                  tst.country_name,
                  tst.state_name,
                  tst.city_name,
                  tst.description,
                  tst.full_address,
                  tst.is_privated,
                  tst.is_active,
                  tst.created_at
              ORDER BY 
                  tst.id desc
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
          "remarks": null,
          "review": null,
          "reference_point": null,
          "lat": null,
          "long": null,
          "country_name": null,
          "state_name": null,
          "city_name": null,
          "description": null,
          "is_privated": null,
          "is_active": null,
          "categoriesList": [],
          "tagsList": [],
          "likesList": [],
          "imageList": [],
          "usersTaggedList": [],
          "commentsList": []
        }]
      }]';

    RAISE NOTICE 'Were not found places';

  END IF;

    param_json_returning = json_build_object('status',status_value,'data',data_value);
    RAISE notice '%',param_json_returning; 
    RETURN param_json_returning;

  DROP TABLE IF EXISTS temporal_spots_table;
  COMMIT;

END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.udf_spots_profile_get(integer)
  OWNER TO postgres;
