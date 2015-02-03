export HOST_URL=${HOST:=0.0.0.0}
export ROOT_URL=http://$HOST_URL
export NODE_TLS_REJECT_UNAUTHORIZED=0 
export METEOR_SETTINGS='{"public":{"redirectTo":"'$HOST_URL':3000","DOCKER_CERT_PATH":"/CAs/","environment":"production"}}'

MONGO_URL=mongodb://$MONGODB_PORT_27017_TCP_ADDR:27017/agilearning node bundle/main.js 