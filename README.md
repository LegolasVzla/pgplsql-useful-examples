# pgplsql-useful-examples
Pgplsql useful scripts examples

This a repository for Pgplsql useful scripts examples.

## ETL's

Some examples of a data migration between 2 PostgreSQL databases, related with a Aeronautic sector project. Some useful things that you can found there are:

- Use of the Cursors

- Cleaning of data

- And more things...

## Tree queries

Use:

Give permissions to execute_all.sh file:

	chmod +x execute_all.sh

Login as a postgres user:

	sudo -i -u postgres

Move to the path where your clone this repository and then go to tree-queries folder:

	cd tree-queries/

Finally, execute the execute_all.sh file:

	./execute_all.sh

* dev_postgres_database folder:

Structure:

Files are contained inside of the dev_postgres_database folder, with the below structure:

a) schema -> functions: generating queries with tree json format.

b) schema -> tables: examples tables.

c) schema -> data: mock data.

## Tree postgis queries

Use:

Give permissions to execute_all.sh file:

	chmod +x execute_all.sh

Login as a postgres user:

	sudo -i -u postgres

Move to the path where your clone this repository and then go to tree-postgis-queries folder:

	cd tree-postgis-queries/

Finally, execute the execute_all.sh file:

	./execute_all.sh

Structure:

Files are contained inside of the dev_postgres_database folder, with the below structure:

a) schema -> functions: generating queries with tree json format:

- udf_spots_nearby_current_user_position: get the first 5 nearest records disregard how far the are away from the current location.
- udf_spots_nearby_within_X_kilometers_from_current_user_position: get the places within 5 km from the current position where you are.

b) schema -> tables: examples tables. In "spots" table you can find PostGIS geometry columns (geom and position) used in the functions.

c) schema -> data: mock data.

Contributions
-----------------------

All work to improve performance is good

Enjoy it!
