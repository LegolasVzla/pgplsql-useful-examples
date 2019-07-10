psql -U postgres -a -f ./main_database.sql
psql -U postgres -d dev_postgres_database -a -c "CREATE SCHEMA temporal_schema;"
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_categories.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_log_categories.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_endangered_animals.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_log_endangered_animals.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_reasons.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_log_reasons.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_relation_endangered_reasons.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/tables/tbl_log_relation_endangered_reasons.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/tbl_categories.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/tbl_endangered_animals.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/tbl_reasons.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/data/tbl_relation_endangered_reasons.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_endangered_animals_get.sql
psql -U postgres -d dev_postgres_database -a -f ./temporal_schema/functions/udf_endangered_animals_reasons_tree_get.sql
