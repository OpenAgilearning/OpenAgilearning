if Envs.find().count() is 0
  dockerDefaultImages = [
    {imageTag:"c3h3/learning-shogun:u1404-ocv",description: "This powerful enviroment provide opencv and shogun. You can use this enviroments to study machine learning.", pictures:["/images/ipynb_sudoku.png"],publicStatus:"public"},
    {imageTag:"c3h3/dsc2014tutorial:last", description: "This enviroments was used at 2014 DSC at Taiwan workshop.", pictures:["/images/rstudio_docker_default.png"],publicStatus:"public"}
    # {_id:"c3h3/oblas-py278-shogun-ipynb:last", type:"ipynb", pictures:["/images/ipynb_lmnn1.png"]},
    # {_id:"c3h3/learning-shogun:last", type:"ipynb", pictures:["/images/ipynb_lmnn2.png"]},
    # {_id:"c3h3/livehouse20141105:last", type:"ipynb", pictures:["/images/ipynb_docker_default.png"]},
    # {_id: "c3h3/nccu-crawler-courses-201411:last",type : "ipynb", pictures:["/images/ipynb_docker_default.png" ]},
    # {_id: "dboyliao/docker-tossug:last", type : "ipynb", pictures:["/images/ipynb_tossug2.png" ]},
    # {_id:"rocker/rstudio:last", type:"rstudio", pictures:["/images/rstudio_docker_default.png"]},
    # {_id:"c3h3/ml-for-hackers:last", type:"rstudio", pictures:["/images/rstudio_docker_default.png"]},
    # {_id:"c3h3/rladies-hello-kaggle:last", type:"rstudio", pictures:["/images/rstudio_play_kaggle.png"]},    
  ]
  Envs.insert image for image in dockerDefaultImages


if EnvConfigTypes.find({_id:"ipynb"}).count() is 0
  EnvConfigTypes.insert {_id:"ipynb", "publicStatus" : "public", "name" : "ipynb", "configs" : { "servicePorts" : [ { "port" : "8888", "type" : "http" } ], "envs" : [ { "name" : "PASSWORD", "mustHave" : true }, { "name" : "IPYNB_PROFILE", "mustHave" : false, "limitValues" : [ "default", "c3h3-dark" ] } ] } }

if EnvConfigTypes.find({_id:"rstudio"}).count() is 0
  EnvConfigTypes.insert {_id:"rstudio", "publicStatus" : "public", "name" : "rstudio", "configs" : { "servicePorts" : [ { "port" : "8787", "type" : "http" } ], "envs" : [ { "name" : "USER", "mustHave" : true }, { "name" : "PASSWORD", "mustHave" : true } ] } }


if EnvUsageLimits.find().count() is 0

  dockerDefaultLimit =
    _id: "defaultLimit"
    limit:
      Cpuset: "0"
      CpuShares: 256
      Memory:512000000

  EnvUsageLimits.insert dockerDefaultLimit
