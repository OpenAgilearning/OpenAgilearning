

Template.envTypesTable.helpers
  # EnvTypesInsertSchema: =>
  #   @EnvTypesInsertSchema

  settings: ->

    envTypePortsField =
      key: "configs.servicePorts"
      label: "Ports"
      tmpl: Template.envTypePortsField

    envTypeEnvsField =
      key: "configs.envs"
      label: "ENVs"
      tmpl: Template.envTypeEnvsField


    res=
      collection:EnvTypes
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["name", envTypePortsField, envTypeEnvsField]
