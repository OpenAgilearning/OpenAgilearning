
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
  "click .runEnv"

