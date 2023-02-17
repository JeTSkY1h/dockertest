# Doker-compose mongoDB-replicaSet
> How to setup a mongoDB-ReplicaSet with docker

## Docker-compose
> configure 3 docker container

first we need to create at least 3 docker containers. and specify a keyfile for them. if the coontainers are not on the same machine, 
you need to configure the mongod instance by launching it with `--bind_ip <ip_adress>` to make it reachable from the other nodes. It's recommended to use hostnames for nodes.

```dockerfile
version: "3"

services:

  mongo1: 
    image: mongo
    restart: unless-stopped
    container_name: mongo1
    volumes:
    - ./scripts:/scripts
    - ./key:/key
    ports: 
    - "27017:27017"
    expose: 
    - "27017"
    entrypoint: [ "/usr/bin/mongod", "--replSet", "rsmongo", "--bind_ip_all", "--keyFile", "/key/mongoRs.key", "--auth"]

  mongo2: 
    image: mongo
    depends_on: 
    - mongo1
    restart: unless-stopped
    container_name: mongo2
    volumes: 
    - ./key:/key
    ports: 
    - "27022:27017"
    expose: 
    - "27017"
    entrypoint: [ "/usr/bin/mongod", "--replSet", "rsmongo", "--bind_ip_all", "--keyFile", "/key/mongoRs.key"]

  mongo3: 
    image: mongo
    depends_on: 
    - mongo1
    restart: unless-stopped
    container_name: mongo3
    volumes: 
    - ./key:/key
    ports: 
    - "27023:27017"
    expose: 
    - "27017"
    entrypoint: [ "/usr/bin/mongod", "--replSet", "rsmongo", "--bind_ip_all", "--keyFile", "/key/mongoRs.key"]
  
```
this is just an example. in Production it would be pointless to have multiple repliacSet nodes on the same machine. So the next part where we configure the replicaSet needs to be changed according to the hostnames of the nodes.

## First initialisation

after we fired up our docker-compose file with `docker-compose -f <docker-compose-file> up`
We need to configure the ReplicaSet and create an unser for our Database if it does not have one. this can be done by launching a script after the containers are fired up on the node you want to have as primary
you can use `docker exec` for this. 

Here is an example script configureing a replicaSet for the mongo-compose containers above:

```shell
echo "initiating Mongo Replica Set"
mongosh <<EOF
    cfg = {
        "_id": "rsmongo",
        "version": 1,
        "members": [
      {
        "_id": 0,
        "host": "mongo1:27017",
        "priority": 2
      },
      {
        "_id": 1,
        "host": "mongo2:27017",
        "priority": 0
      },
      {
        "_id": 2,
        "host": "mongo3:27017",
        "priority": 0
      }
    ]
  };
  rs.initiate(cfg);
  rs.status();
EOF

sleep 20

mongosh <<EOF
print('Start #################################################################');
db = getSiblingDB('skwid-app')
db.createUser(
  {
    user: 'admin',
    pwd: 'password',
    roles: [{ role: 'userAdmin', db: 'admin'}],
  },
);
db.auth("auth", "password")
db.createCollection('stocks');
db.createCollection('globalInfo');
db.globalInfo.insertOne(
    {
        _id: ObjectId("61d3178b73b75299cb0780f7"),
        totalClicks: 9667
    }
)
print('END #################################################################');
EOF

```

In this script you can configure the replicaSet hosts and the mongoDB user. 
if you have an already running mongoDB with an user you can just delete the user part from the last script. 

after the script runs successfully the mongoDB with replicaSet should be up an running.
