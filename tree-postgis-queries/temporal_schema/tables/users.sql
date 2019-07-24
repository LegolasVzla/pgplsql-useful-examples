CREATE TABLE temporal_schema.users (
    id serial primary key,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL default True,
    is_deleted boolean NOT NULL default False,
    date_joined timestamp with time zone NOT NULL,
    updated_date timestamp with time zone NOT NULL
);