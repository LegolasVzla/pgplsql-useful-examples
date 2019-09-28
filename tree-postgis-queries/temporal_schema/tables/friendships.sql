CREATE TABLE temporal_schema.friendships(
  id serial primary key,
  sender_user_id integer NOT NULL,
  receiver_user_id integer NOT NULL,
  status integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false
);
ALTER TABLE ONLY temporal_schema.friendships
    ADD CONSTRAINT friendships_sender_user_id_fk_users_id FOREIGN KEY (sender_user_id) REFERENCES temporal_schema.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY temporal_schema.friendships
    ADD CONSTRAINT friendships_receiver_user_id_fk_users_id FOREIGN KEY (receiver_user_id) REFERENCES temporal_schema.users(id) ON DELETE CASCADE;
