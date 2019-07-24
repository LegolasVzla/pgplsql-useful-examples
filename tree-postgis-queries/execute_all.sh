psql -U postgres -a -f ./main_database.sql
psql -U postgres -d dev_postgres_database -a -c "CREATE SCHEMA temporal_schema;"
psql -U postgres -d dev_postgres_database -a -c "CREATE EXTENSION postgis;"
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/users.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/spots.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/images.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/users.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/spots.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/images.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_spots_nearby_current_user_position.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_images_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_spots_nearby_within_X_kilometers_from_current_user_position.sql