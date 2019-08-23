CREATE TABLE temporal_schema.like_actions(
  id serial primary key,
  user_actions_id integer NOT NULL,
  user_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false
);
ALTER TABLE ONLY temporal_schema.like_actions
    ADD CONSTRAINT like_actions_user_actions_id_fk_user_actions_id FOREIGN KEY (user_actions_id) REFERENCES temporal_schema.user_actions(id) ON DELETE CASCADE;