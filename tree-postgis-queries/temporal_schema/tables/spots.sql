CREATE TABLE temporal_schema.spots (
    id serial primary key,
    name character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    city character varying(100) NOT NULL,
    lat double precision,
    lng double precision,
    is_active boolean NOT NULL default True,
    is_deleted boolean NOT NULL default False,
    updated_date timestamp with time zone NOT NULL,
    created_date timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    country_code character varying(5) NOT NULL,
    geom geometry(Geometry,4326),
    "position" geometry(Point,4326)
);
ALTER TABLE ONLY temporal_schema.spots
    ADD CONSTRAINT spots_user_id_fk_users_user_id FOREIGN KEY (user_id) REFERENCES temporal_schema.users(id) ON DELETE CASCADE;
