# Database

The tools for versioning and deploying the SQE database.  This repository no longer stores the database data on GitHub, only the schema and the tools for uploading a Docker image to DockerHub.  A fully working instance of this database can be found at our [Docker Hub page](https://hub.docker.com/r/qumranica/sqe-database).

## Prerequisites

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Node 8.9.4](https://nodejs.org/en/download/) (perhaps later versions will also work)
* Npm 5+ (bundled with node)
* [Yarn](https://yarnpkg.com/en/docs/install)
* [Docker](https://docs.docker.com/install/)

Most of this is standard tooling.

## Usage

Things are pretty simple here.  Make sure you have all the prerequisites.  Clone this repository `git clone https://github.com/Scripta-Qumranica-Electronica/SQE_Database.git`, go into the folder `cd SQE_Database`, and run `yarn`.  Now you can start up the database with `docker-compose up -d` (make sure you don't have any other instances of the SQE_database running on your system).

When the docker container is running, you can access the database at `localhost` port `3307` with the user `root` and password `none`.  Make any changes you want to the database using your favorite tools.

Then, to push those changes up to Github, just run `yarn deploy -t 'your-new-version-name' -m 'your github commit message'`.  That command will do everything for you; it will remove all non default data from the database (see `sanitize-db.js`), it will copy the database updates into the `data` folder for the Docker build, stage and commit any changes with the commit message you provided with `-m`, push the changes up to GitHub with the new tag version you provided with `-t`, it will also build a new Docker image for your changes and push that up to Docker hub with the same tag (the frontend developers no longer need to build the database on their own machines).  You will need a Docker hub account and authorization to push a new image up to Docker hub.

Warning!  This automated script will simply package any SQE_DEV mariadb database accessible at localhost:3307, make sure you have the intended Docker instance of the database running before you run `yarn deploy -t 'your-new-version-name' -m 'your github commit message'`.  If a mistake is made, however, we can always roll back to an earlier version tag.

We have begun a new policy for changes to the database in order to make it simpler to synchronize any current production database with changes made here.  All changes should be made by means of scripts (SQL or otherwise), and those scripts should be stored in the `Changes` folder under the corresponding version along with any necessary data. The addition of a changelog would be nice as well (see, e.g., `Changes/0.17.0`).

## User Defined Functions

This repository builds two custom C user defined functions into the MariaDB datbase container.  The file geom_transform.c enables the database to apply an affine transform to a Polygon, MultiPolygon, Point, and MultiPoint.  The file nested_geom_transform.c does the same but applies a translate prior to performing the affine transform.  Both functions were build with performance in mind, and thus provide minimal error checking.

### geom_transform 

`geom_transform` takes 5 or 7 arguments: `geom_transform(geometry [native POLYGON, etc.], scale [decimal/double], rotation [decimal, double], translate_x [int], translate_y[int], transform_origin_x [double], transform_origin_y [double])`, `transform_origin_x` and `transform_origin_y` are optional.
            
This function will perform an affine transformation (scale, rotate, translate).  If a transform_origin is specified, the geometry will rotate and scale around that point, rather than the default 0,0.

### nested_geom_transform 

`nested_geom_transform` takes 7 or 9 arguments: `geom_transform(geometry [native POLYGON, etc.], scale [decimal/double], rotation [decimal, double], translate_x [int], translate_y[int], pre_translate_x [int], pre_translate_y [int], transform_origin_x [double], transform_origin_y [double])`, `transform_origin_x` and `transform_origin_y` are optional.

This function will perform an affine transformation (scale, rotate, translate), but enables a separate translate operation (pre_translate_x/pre_translate_y) to be carried out on the geometry before the affine transformation is applied.  If a transform_origin is specified, the geometry will rotate and scale around that point, rather than the default 0,0.

## DockerHub

This code pulls data from the database build on Docker Hub and also pushes changes beck there to qumranica/sqe-database.  The container is based on the standard MariaDB docker container, and uses a two stage build process to create the SQE_Database, which contains all of our default data.  When running the qumranica/sqe-database container from Docker Hub, we use a special init script (startup.sh) in the ENTRYPOINT stage to inject the following possibilities:

MYSQL_ROOT_PASSWORD (the password for the root account, if none is provided the password remains `none`)
MYSQL_USER (the default user that will access the database)
MYSQL_PASSWORD (the default user's password)

If no MYSQL_USER and MYSQL_PASSWORD are provided, the database can only be accessed by root.
