# Template.registerHelper "SettingSchema", SettingSchema

Template.profile.rendered = ->
  $(".profile-editor").toggle()

Template.profile.events
  "click input.btn.btn-primary": (e,t)->
    $(".profile-editor").toggle()
    $(".show-profile").toggle()


Template.profilePageEnvConfigsForm.helpers
  envConfigsSchema: ->
    if @envConfigTypeId
      configTypeId = @envConfigTypeId
    else
      userConfigId = @userConfigId
      # userConfigId = Session.get "userConfigId"

      envUserConfingDoc = EnvUserConfigs.findOne _id: userConfigId

      configTypeId = envUserConfingDoc?.configTypeId

    envConfigsData = EnvConfigTypes.findOne _id:configTypeId
    schemaSettings = {}

    if envConfigsData?.configs?.envs
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
    # ConfigDataField =
    #   key: "envs"
    #   label: "Config Data"
    #   tmpl: Template.profilePageEnvUserConfigsTableConfigDataField

    # EditBtnField =
    #   key: "_id"
    #   label: "Edit"
    #   tmpl: Template.profilePageEnvUserConfigsTableEditBtnField

    # RelatedCoursesField =
    #   key: "envConfigTypeName"
    #   label: "Related Courses"
    #   tmpl: Template.profilePageEnvConfigTypesTableRelatedCoursesField


    res=
      collection:EnvUserConfigs
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["envConfigTypeName", "envs"]


Template.profilePageEnvUserConfigsTableEditBtnField.events
  "click .envUserConfigEditBtn": (e,t)->
    e.stopPropagation()
    userConfigId = $(e.target).attr "userConfigId"
    Session.set "envConfigTypeId", ""
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
      key: "containerConfigs.Env"
      label: "ENVs"
      tmpl: Template.profilePageDockerInstancesTableEnvField

    quotaTypeField =
      key: "_id"
      label: "Quota"
      tmpl: Template.profilePageDockerInstancesTableQuotaField


    limitField =
      key: "_id"
      label: "Limit"
      tmpl: Template.profilePageDockerInstancesTableLimitField


    removeBtnField =
      key: "_id"
      label: "Remove"
      tmpl: Template.profilePageDockerInstancesTableRemoveBtnField


    res=
      collection:db.dockerInstances
      # rowsPerPage:5
      # showFilter: false
      # showNavigation:'never'
      fields:["imageTag", quotaTypeField, limitField, removeBtnField]


Template.profilePageDockerInstancesTableQuotaField.helpers
  quotaType: ->
    if @quota.type is "forPersonal"
      "Personal"
    else
      "Server Group"
  isPersonal: ->
    @quota.type is "forPersonal"

  expiredAt: ->
    # @quota.id
    new Date(db.dockerPersonalUsageQuota.findOne({_id:@quota.id}).expiredAt)

  groupData: ->
    db.bundleServerUserGroup.findOne({_id:@quota.id})

Template.profilePageDockerInstancesTableRemoveBtnField.events
  "click .removeInstanceBtn": (e,t)->
    instanceId = $(e.target).attr "instanceId"
    $(e.target).html "Stopping"

    @unblock()

    Meteor.call "removeDockerInstance", instanceId


Template.public_profile.helpers
  user: ->
    Meteor.user()