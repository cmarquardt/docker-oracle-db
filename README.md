Oracle Database Containers for Docker
=====================================

This repository contains sample Docker files to facilitate the installation, configuration, and environment setup for DevOps users. They are based on Dockerfiles provided in [Oracle's GitHub repository](https://github.com/oracle/docker-images). In contrast to the original Dockerfiles, the ones provided here

* do not export the `/opt/oracle/oradata` directory from the images (as volumes can also assigned as part of the `docker container run` command, or in a `docker-compose` file);
* provide a second image containing a pre-initialised, but otherwise empty database.

The first image is intended to be used as a base image for other ones; in particular, it doesn't contain volume statements. This allows the imaged derived from the base image to optionally initialise databases inside the container. A possible application is to set up a test data base which is self-contained in the container, allowing testing against an Oracle instance with a significantly reduced start-up time. The second image is an example for this; it initialises an empty database inside the container.

For more information about Oracle Database please see the [Oracle Database Online Documentation](http://docs.oracle.com/database/121/index.htm).

The following is taken from the orginal Dockerfie documentation / Oracle GitHub repository:

## How to Build and Run the Base Images
This project offers sample Dockerfiles for both Oracle Database 12c (12.1.0.2) Enterprise Edition and Standard Edition, or the 11g Express edition. To assist in building the images, you can use the [buildDockerImage.sh](buildDockerImage.sh) script. See below for instructions and usage.

The `buildDockerImage.sh` script is a utility shell script that performs MD5 checks and is an easy way to get started. Expert users may prefer to directly call `docker build` with their prefered set of parameters.

### Building Oracle Database Docker Base Images
**IMPORTANT:** You will have to provide the installation binaries of Oracle Database and put them into the `12.1.0.2` folder (or into the `11.2.0.2` folder for the Express Edition). You only need to provide the binaries for the edition you are going to install. The binaries can be downloaded from the [Oracle Technology Network](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html). You also have to make sure to have internet connectivity for yum. Note that the `.zip` files do not have to be unpacked manually; the script will handle this task.

Before you build the image make sure that you have provided the installation binaries and put them into the right folder. Once you have chosen which edition and version you want to build an image of, go into the `12.1.0.2` (for the Standard and Enterprise Edition) or `11.2.0.2` (for the Express Edition) folder and run the `buildDockerImage.sh` script as `root` or with `sudo` privileges:

	[oracle@localhost dockerfiles]$ ./buildDockerImage.sh -h

	Usage: buildDockerImage.sh -v [version] [-e | -s | -x] [-i] [-n]
	Builds a Docker Image for Oracle Database.

	Parameters:
     -v: version to build
         Choose one of: 11.2.0.2  12.1.0.2
     -e: creates image based on 'Enterprise Edition'
     -s: creates image based on 'Standard Edition 2'
     -x: creates image based on 'Express Edition'
     -n: do *not* squash the generated image
     -i: ignores the MD5 checksums

	* select one edition only: -e, -s, or -x

	LICENSE CDDL 1.0 + GPL 2.0

	Copyright (c) 2014-2016 Oracle and/or its affiliates. All rights reserved.

For the Standard and Enterprise Editions, this script will use the `Dockerfile.se-base` and `Dockerfile.ee-base` respectively; those Dockerfiles should also be exploited when building the images manually.

Note that the resulting base images will be an image with the Oracle binaries installed, but without a database having been created. This happens on the first startup of the container, during which a new database will be initialised. This may require several minutes; after the database initialisation has been completed, the following output will highlight that the new database is ready to be used:

	#########################
	DATABASE IS READY TO USE!
	#########################

If the same container is launched and finds an initialiased data base (e.g. because the actual database files were initialised before), it will simply use them as they are. That way, a new database is created upon the first launch of a container, and will be used as is subsequently.

In most real applications, it probably makes sense to export the `/opt/oracle/oradata` as external volume to maintain the actual database across launches of new containers.

### Building Oracle Database Test Images

The Dockerfiles `Dockerfile.se-db` and `Dockerfile.ee-db` create images based on the base images described above; the difference is that a database has already been initialised inside the container. This significantly reduces the startup time of the initial launch of the container, which might be useful in a testing scenario.

Note that no volume is exported here; modifications to the database will be removed with the container. *If* `/opt/oracle/oradata` is exported, the contents of the pre-initialised database will be replaced with whatever is contained in the external data volume; if it doe not contain an Oracle database initilised by one of the Docker images described here, a new initialisation will take place, as for the base image.

The test images can be created by running `docker build` on the respective Dockerfiles manually.

### Running Oracle Database in a Docker container

#### Running Oracle Database Enterprise and Standard Edition in a Docker container
To run your Oracle Database Docker image use the **docker run** command as follows:

	docker run --name <container name> \
	-p <host port>:1521 -p <host port>:5500 \
	-e ORACLE_SID=<your SID> \
	-e ORACLE_PDB=<your PDB name> \
	-v [<host mount point>:]/opt/oracle/oradata \
	oracle/database:12.1.0.2-ee

	Parameters:
	   --name:        The name of the container (default: auto generated)
	   -p:            The port mapping of the host port to the container port.
	                  Two ports are exposed: 1521 (Oracle Listener), 5500 (OEM Express)
	   -e ORACLE_SID: The Oracle Database SID that should be used (default: ORCLCDB)
	   -e ORACLE_PDB: The Oracle Database PDB name that should be used (default: ORCLPDB1)
	   -v             The data volume to use for the database.
	                  Has to be owned by the Unix user "oracle" or set appropriately.
	                  If omitted the database will not be persisted over container recreation.

Once the container has been started and the database created you can connect to it just like to any other database:

	sqlplus sys/<your password>@//localhost:1521/<your SID> as sysdba
	sqlplus system/<your password>@//localhost:1521/<your SID>
	sqlplus pdbadmin/<your password>@//localhost:1521/<Your PDB name>

The Oracle Database inside the container also has Oracle Enterprise Manager Express configured. To access OEM Express, start your browser and follow the URL:

	https://localhost:5500/em/

**NOTE**: Oracle Database bypasses file system level caching for some of the files by using the `O_DIRECT` flag. It is not advised to run the container on a file system that does not support the `O_DIRECT` flag.

#### Changing the admin accounts passwords
On the first startup of the container a random password will be generated for the database. You can find this password in the output line:

	ORACLE AUTO GENERATED PASSWORD FOR SYS, SYSTEM AND PDBAMIN:

The password for those accounts can be changed via the **docker exec** command. **Note**, the container has to be running:

	docker exec <container name> ./setPassword.sh <your password>

#### Running Oracle Database Express Edition in a Docker container
To run your Oracle Database Express Edition Docker image use the **docker run** command as follows:

    docker run --name <container name> \
               --shm-size=1g \
               -p 1521:1521 -p 8080:8080 \
               -v [<host mount point>:]/u01/app/oracle/oradata \
            oracle/database:11.2.0.2-xe

    Parameters:
	     --name:     The name of the container (default: auto generated)
	     --shm-size: Amount of Linux shared memory
	     -p:         The port mapping of the host port to the container port.
	                 Two ports are exposed: 1521 (Oracle Listener), 5500 (OEM Express)
	     -v          The data volume to use for the database.
	                 Has to be owned by the Unix user "oracle" or set appropriately.
	                 If omitted the database will not be persisted over container recreation.

There are two ports that are exposed in this image:

* 1521 which is the port to connect to the Oracle Database.
* 8080 which is the port of Oracle Application Express (APEX).

On the first startup of the container a random password will be generated for the database. You can find this password in the output line:

	ORACLE AUTO GENERATED PASSWORD FOR SYS AND SYSTEM:

The password for those accounts can be changed via the **docker exec** command. **Note**, the container has to be running:

	docker exec oraclexe /u01/app/oracle/setPassword.sh <your password>

Once the container has been started you can connect to it just like to any other database:

	sqlplus sys/<your password>@//localhost:1521/XE as sysdba
	sqlplus system/<your password>@//localhost:1521/XE

### Running SQL*Plus in a Docker container

You may use the same Docker image you used to start the database, to run `sqlplus` to connect to it, for example:

	docker run --rm -ti oracle/database:12.1.0.2-ee sqlplus pdbadmin/<yourpassword>@//<db-container-ip>:1521/ORCLPDB1

Another option is to use `docker exec` and run `sqlplus` from within the same container already running the database:

	docker exec -ti <container name> sqlplus pdbadmin@ORCLPDB1

## Support
Oracle Database in single instance configuration is supported for Oracle Linux 7 and Red Hat Enterprise Linux (RHEL) 7.
For more details please see the original Oracle Support note: **Oracle Support for Database Running on Docker (Doc ID 2216342.1)**

## License
To download and run Oracle Database, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.

The original versions of all scripts and files hosted in this GitHub project ([marq/oracle-db](./)) are based on Oracle's original [docker-images](https://github.com/oracle/docker-images) repository on GitHub. They are thus, unless otherwise noted, released under the Common Development and Distribution License (CDDL) 1.0 and GNU Public License 2.0 licenses.

## Copyright
Copyright (c) 2014-2016 Oracle and/or its affiliates. All rights reserved.
