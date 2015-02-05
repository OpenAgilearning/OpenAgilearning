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
