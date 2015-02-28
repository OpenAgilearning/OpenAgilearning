
if EnvConfigTypes.find({_id:"ipynb"}).count() is 0
  EnvConfigTypes.insert {_id:"ipynb", "publicStatus" : "public", "name" : "ipynb", "configs" : { "servicePorts" : [ { "port" : "8888", "type" : "http" } ], "envs" : [ { "name" : "PASSWORD", "mustHave" : true }, { "name" : "IPYNB_PROFILE", "mustHave" : false, "limitValues" : [ "default", "c3h3-dark" ] } ] } }

if EnvConfigTypes.find({_id:"rstudio"}).count() is 0
  EnvConfigTypes.insert {_id:"rstudio", "publicStatus" : "public", "name" : "rstudio", "configs" : { "servicePorts" : [ { "port" : "8787", "type" : "http" } ], "envs" : [ { "name" : "USER", "mustHave" : true }, { "name" : "PASSWORD", "mustHave" : true } ] } }

