# running mongoDb container in replica set

## create replica-set nodes

first we need to create at least two repliac set nodes in my case i will use docker containers for that
for reference here is the docker compose for them:

```dockerfile

services:
  mongoNode: 
      image: mongo
      restart: unless-stopped
      volumes:
      - ./scripts:/scripts
      - ./key:/key
      expose: 
      - "27017"
      entrypoint: [ "/usr/bin/mongod", "--replSet", "rsmongo", "--bind_ip_all", "--keyFile", "/key/mongoRs.key"]
  
  mongoNode1: 
      image: mongo
      restart: unless-stopped
      volumes:
      - ./scripts:/scripts
      - ./key:/key
      expose: 
      - "27017"
      entrypoint: [ "/usr/bin/mongod", "--replSet", "rsmongo", "--bind_ip_all", "--keyFile", "/key/mongoRs.key"]
      
```

when our nodes are up and running, we need to restart our existing mongoDb container with the `-replSet "rsmongo"` argument. 
finally we need to initiate the replicaSet by logging in the primary node and running  `rs.initiate(configObject)`  in my case the configObject should look like this:


```js
{_id:rsmongo,version:1,
    members:[
        {_id:0, host: "runtime-application-mongodb-1:27017"},
        {_id:0,host: "dockertest-mongoNode1-1:27017"},
        {_id:0,host: "dockertest-mongoNode:27017"},
    ]
}
  
```
