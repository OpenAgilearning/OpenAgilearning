rm -rf production_tmp
mkdir production_tmp
mongodump -u production -p $PASSWORD --host mongo.agilearning.io --db production --out production_tmp/
mongorestore -u staging -p $PASSWORD --host mongo.agilearning.io --db staging --drop  production_tmp/production/
