CREATE TABLE temporal_schema.images (
    id serial primary key,
    url character varying(200) NOT NULL,
    principalimage boolean NOT NULL default False,
    is_active boolean NOT NULL default True,
    is_deleted boolean NOT NULL default False,
    updated_date timestamp with time zone NOT NULL,
    created_date timestamp with time zone NOT NULL,
    spot_id integer NOT NULL
);
ALTER TABLE ONLY temporal_schema.images
    ADD CONSTRAINT images_spot_id_fk_api_spots_id FOREIGN KEY (spot_id) REFERENCES temporal_schema.spots(id) ON DELETE CASCADE;
