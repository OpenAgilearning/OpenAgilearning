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


Template.profilePageEnvUserConfigsTable.helpers
  settings: ->
    ConfigDataField =
      key: "configData"
      label: "Config Data"
      tmpl: Template.profilePageEnvUserConfigsTableConfigDataField


    res=
      collection:EnvUserConfigs
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["configTypeId",ConfigDataField]


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
