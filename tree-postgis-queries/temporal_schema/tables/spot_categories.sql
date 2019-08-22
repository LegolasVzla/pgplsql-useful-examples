CREATE TABLE temporal_schema.spot_categories(
  id serial primary key,
  spots_id integer NOT NULL,
  category_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false
);
ALTER TABLE ONLY temporal_schema.spot_categories
    ADD CONSTRAINT spot_categories_spot_id_fk_spots_id FOREIGN KEY (spot_id) REFERENCES temporal_schema.spots(id) ON DELETE CASCADE;
ALTER TABLE ONLY temporal_schema.spot_categories
    ADD CONSTRAINT spot_categories_categories_id_fk_categories_id FOREIGN KEY (categories_id) REFERENCES temporal_schema.categories(id) ON DELETE CASCADE;
