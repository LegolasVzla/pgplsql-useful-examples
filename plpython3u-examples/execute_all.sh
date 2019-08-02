psql -U postgres -a -f ./main_database.sql
psql -U postgres -d dev_postgres_database -a -c "CREATE SCHEMA temporal_schema;"
psql -U postgres -d dev_postgres_database -a -c " CREATE EXTENSION plpython3u;"
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_reverse_geocoding_geopy.sql
