psql -U postgres -a -f ./main_database.sql
psql -U postgres -d dev_postgres_database -a -c "CREATE SCHEMA temporal_schema;"
psql -U postgres -d dev_postgres_database -a -c "CREATE EXTENSION postgis;"
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/users.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/spots.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/images.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/type_user_actions.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/user_actions.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/likes_actions.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/user_taggeds.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/comments.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tags.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/spot_tags.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/categories.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/spot_categories.sql

psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/users.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/spots.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/images.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/categories.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/likes_actions.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/user_taggeds.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/spot_categories.sql

#psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_spots_nearby_current_user_position.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_images_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_categories_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_like_actions_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_users_tagged_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_comments_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_spots_nearby_within_X_kilometers_from_current_user_position.sql