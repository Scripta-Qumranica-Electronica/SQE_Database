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

Things are pretty simple here.  Make sure you have all the prerequisites.  Clone this repository `git clone https://github.com/Scripta-Qumranica-Electronica/Database.git`, go into the folder `cd Database`, and run `yarn`.  Now you can start up the database with `docker-compose up -d` (make sure you don't have any other instances of the SQE_database running on your system).

When the docker container is running, you can access the database at `localhost` port `3307` with the user `root` and password `none`.  Make any changes you want to the database using your favorite tools.  

Then, to push those changes up to Github, just run `yarn deploy -t 'your-new-version-name' -m 'your github commit message'`.  That command will do everything for you; it will remove all non default data from the database (see `sanitize-db.js`), it will copy the database updates into the `data` folder for the Docker build, stage and commit any changes with the commit message you provided with `-m`, push the changes up to GitHub with the new tag version you provided with `-t`, it will also build a new Docker image for your changes and push that up to Docker hub with the same tag (the frontend developers no longer need to build the database on their own machines).  You will need a Docker hub account and authorization to push a new image up to Docker hub.

Warning!  This automated script will simply package any SQE_DEV mariadb database accessible at localhost:3307, make sure you have the intended Docker instance of the database running before you run `yarn deploy -t 'your-new-version-name' -m 'your github commit message'`.  If a mistake is made, however, we can always roll back to an earlier version tag.

## User Defined Functions

This repository builds two custom C user defined functions into the MariaDB datbase container.  The file affine_transform.c enables the database to apply a transform matrix to a WKT polygon.  The file multiply_matrix.c enables the database to multiply two transform matrices.  Bot funtcions were build with performance in mind, and thus provide minimal error checking. The function affine_transform(matrix, polygon) takes two arguments a transform matrix as we format them in the database "{\"matrix\":[[1,0,0],[0,1,0]]}" (in fact the only formatting the function requires is that we have 6 numbers separated by any non-number character), and a WKT polygon (in fact the only thing the function requires is a repeating sequence of two space separated numbers).  The function multiply_matrix(matrix1, matrix2) takes two arguments, noth of which are a transform matrix as we format them in the database "{\"matrix\":[[1,0,0],[0,1,0]]}" (in fact the only formatting the function requires is that we have 6 numbers separated by any non-number character).  The order of matrices in the function matters, put the matrix for the ROI first and the matrix for the artefact second.