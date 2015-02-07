# Template.registerHelper "SettingSchema", SettingSchema

Template.profile.rendered = ->
  $(".profile-editor").toggle()

Template.profile.events
  "click input.btn.btn-primary": (e,t)->
    $(".profile-editor").toggle()
    $(".show-profile").toggle()

AutoForm.hooks profileUpdate:
  onSuccess: (updateProfile, result, template) ->
    $(".show-profile").toggle()
    $(".profile-editor").toggle()


Template.profilePageEnvConfigsForm.helpers
  envConfigsSchema: ->
    userConfigId = @userConfigId
    # userConfigId = Session.get "userConfigId"
    
    envUserConfingDoc = EnvUserConfigs.findOne _id: userConfigId

    configTypeId = envUserConfingDoc.configTypeId
    
    envConfigsData = EnvConfigTypes.findOne _id:configTypeId
    schemaSettings = {}

    if envConfigsData?.configs?.envs and userConfigId
      envConfigsData.configs.envs.map (env)->
        schemaSettings[env.name] = {type: String}
          
        if not env.mustHave
          schemaSettings[env.name].optional = true

        if env.limitValues
          schemaSettings[env.name].allowedValues = env.limitValues

      schemaSettings.configTypeId = 
        type: String
        defaultValue: configTypeId
        allowedValues: [configTypeId]
        # autoform:
        #   type: "hidden"

      new SimpleSchema schemaSettings


Template.profilePageEnvUserConfigsTable.helpers
  settings: ->
    ConfigDataField =
      key: "configData"
      label: "Config Data"
      tmpl: Template.profilePageEnvUserConfigsTableConfigDataField

    EditBtnField =
      key: "_id"
      label: "Edit"
      tmpl: Template.profilePageEnvUserConfigsTableEditBtnField


    res=
      collection:EnvUserConfigs
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["configTypeId",ConfigDataField,EditBtnField]


Template.profilePageEnvUserConfigsTableEditBtnField.events
  "click .envConfigEditBtn": (e,t)->
    e.stopPropagation()
    userConfigId = $(e.target).attr "userConfigId"
    Session.set "userConfigId", userConfigId

    # Meteor.call "removeDocker", configTypeId, (err, res)->
    #   if not err
    #     console.log res
    


Template.profilePageDockerServerContainersTable.helpers
  settings: ->
    res=
      collection:DockerServerContainers
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["serverName","Image","lastUpdateAt", "Status"]


Template.profilePageDockerInstancesTable.helpers
  settings: ->
    envField = 
      key: "containerConfig.Env"
      label: "ENVs"
      tmpl: Template.profilePageDockerInstancesTableEnvField

    removeBtnField = 
      key: "_id"
      label: "Remove"
      tmpl: Template.profilePageDockerInstancesTableRemoveBtnField


    res=
      collection:DockerInstances
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["serverName", "configTypeId", "imageTag", envField, "status", removeBtnField]


Template.profilePageDockerInstancesTableRemoveBtnField.events
  "click .removeInstanceBtn": (e,t)-> 
    instanceId = $(e.target).attr "instanceId"
    $(e.target).html "Stopping"
    Meteor.call "removeDockerInstance", instanceId
