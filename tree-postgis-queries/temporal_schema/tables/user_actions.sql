CREATE TABLE temporal_schema.user_actions(
  id serial primary key,
  spots_id integer NOT NULL,
  comment_liked_id integer,
  type_user_actions_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_active boolean DEFAULT true,
  is_deleted boolean DEFAULT false
);