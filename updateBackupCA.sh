# cd to dockerServerCAs
mongo agilearning --eval "db.dockerServers.update({},{\$set:{security:{ \"caPath\" : \""$PWD"/dockerServerCAs/ca.pem\", \"certPath\" : \""$PWD"/dockerServerCAs/cert.pem\", \"keyPath\" : \""$PWD"/dockerServerCAs/key.pem\" }}},true,true)"
