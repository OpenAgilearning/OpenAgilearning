
Template.envsTable.helpers
  settings: ->
    envPictureField =
      key: ["pictures","type","_id"]
      label: "Environment"
      tmpl: Template.envPictureField

    res=
      collection:Envs
      rowsPerPage:5
      showFilter: true
      fields:[envPictureField,"type","description"]


Template.envPicture.helpers
  getEnvPictureURL: (envDoc)->
    if envDoc.pictures
      if envDoc.pictures.length > 0
        envDoc.pictures[0]
      else
        if envDoc.type is "ipynb"
          "/images/ipynb_docker_default.png"
        else if envDoc.type is "rstudio"
          "/images/rstudio_docker_default.png"

    else
      if envDoc.type is "ipynb"
        "/images/ipynb_docker_default.png"
      else if envDoc.type is "rstudio"
        "/images/rstudio_docker_default.png"


Template.envPictureField.events
  "click .runEnv": (e,t) ->
    e.stopPropagation()

    #[TODOLIST: building running containerData]
    #TODO: check user's config
    #TODO: (if has config) getEnvUserConfigs 
    #TODO: checkingRunningCondition
    #TODO: (if can run) choosing Running Limit
    #TODO: use limit, EnvTypes' config => build containerData
    
    #[TODOLIST: get free server & ports]
    #TODO: get free server has the image ()
    #TODO: (if has server) get free ports in that server (include multiports)
    #TODO: get free server has the image
    #FIXME: two server might acquire the same port

    #[TODOLIST: runServer and write data to db]
    #TODO: createContainer
    #TODO: getContainer
    #TODO: write status and logging data to dbs
    
    




