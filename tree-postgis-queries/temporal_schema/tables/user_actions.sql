CREATE TABLE temporal_schema.user_actions(
  id serial primary key,
  spot_id integer NOT NULL,
  comment_liked_id integer,
  type_user_actions_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false
);
ALTER TABLE ONLY temporal_schema.user_actions
    ADD CONSTRAINT user_actions_type_user_actions_id_fk_spot_id FOREIGN KEY (type_user_actions_id) REFERENCES temporal_schema.type_user_actions(id) ON DELETE CASCADE;
