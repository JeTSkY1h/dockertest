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