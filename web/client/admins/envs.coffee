
Template.envsTableAdminPage.helpers
  settings: ->

    # envTypePortsField =
    #   key: "configs.servicePorts"
    #   label: "Ports"
    #   tmpl: Template.envTypePortsField

    # envTypeEnvsField =
    #   key: "configs.envs"
    #   label: "ENVs"
    #   tmpl: Template.envTypeEnvsField

    res=
      collection:Envs
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["_id", "imageTag"]



Template.testAutoForm.helpers
  formId: ->
    @data._id + "1234"


Template.envTypesTable.helpers
  # EnvTypesInsertSchema: =>
  #   @EnvTypesInsertSchema
  autoFormId: (test) ->
    test + "1234"

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
