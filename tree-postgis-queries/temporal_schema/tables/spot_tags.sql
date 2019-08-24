CREATE TABLE temporal_schema.spot_tags(
  id serial primary key,
  user_actions_id integer NOT NULL,
  user_id integer NOT NULL,
  tag_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false
);
ALTER TABLE ONLY temporal_schema.spot_tags
    ADD CONSTRAINT spot_tags_user_actions_id_fk_user_actions_id FOREIGN KEY (user_actions_id) REFERENCES temporal_schema.user_actions(id) ON DELETE CASCADE;
ALTER TABLE ONLY temporal_schema.spot_tags
    ADD CONSTRAINT spot_tags_user_id_fk_user_id FOREIGN KEY (user_actions_id) REFERENCES temporal_schema.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY temporal_schema.spot_tags
    ADD CONSTRAINT spot_tags_tag_id_fk_tags_id FOREIGN KEY (tag_id) REFERENCES temporal_schema.tags(id) ON DELETE CASCADE;