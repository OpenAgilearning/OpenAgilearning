Template.envPageBetPersonalQuotaBtn.events
  "click #getFreeQuotaBtn": (e,t)->
    Meteor.call "getFreeTrialQuota"


Template.envPagePersonalQuotaBlock.helpers
  hasPersonalQuota: ->
    db.dockerPersonalUsageQuota.find().count() > 0


Template.envPagePersonalQuotaTable.helpers
  settings: ->
    ExpiredAtField =
      key: "expiredAt"
      label: "Expired At"
      fn: (value, object)->
        if value > 0
          new Date(value)
        else
          "Admin Quota!"

    NCPUField =
      key:"NCPU"
      label:"CPU"
      fn: (value)->
        if value < 0
          "unlimited"
        else if value is 1
          "1 core"
        else if value > 1
          "#{value} cores"
        else
          value

    MemoryField =
      key: "Memory"
      label: "Memory"
      fn: (value)->
        if value > 0
          "#{value/(1024*1024*1024)} GB"
        else
          "unlimited"

    res =
      collection: db.dockerPersonalUsageQuota.find()
      # rowsPerPage:5
      # showFilter: false
      # showNavigation:'never'
      fields:["name",NCPUField,MemoryField, ExpiredAtField]


Template.envPageEnvConfigTypesTable.helpers

  settings: ->
    ConfigEnvsField =
      ke1y: "configs.envs"
      label: "Config Envs"
      tmpl: Template.envPageEnvConfigTypesTableConfigEnvsField

    EditBtnField =
      key: "_id"
      label: "Edit"
      tmpl: Template.envPageEnvConfigTypesTableEditBtnField

    RelatedCoursesField =
      key: "_id"
      label: "Related Courses"
      tmpl: Template.envPageEnvConfigTypesTableRelatedCoursesField


    res=
      collection:@filteredEnvConfigTypes
      rowsPerPage:5
      showFilter: false
      showNavigation:'never'
      fields:["_id", RelatedCoursesField, ConfigEnvsField, EditBtnField]


Template.EnvConfigTypesRelatedCoursesField.helpers
  configTypeCourses: ->
    imageTags = DockerImages.find({type:@_id}).fetch().map (xx)-> xx._id#.split(":").length is 2 ? xx._id : xx._id+":latest"
    Courses.find dockerImage:{$in:imageTags}

Template.envPageEnvConfigTypesTableEditBtnField.events
  "click .envConfigEditBtn": (e,t)->
    e.stopPropagation()
    envConfigTypeId = $(e.target).attr "envConfigTypeId"

    Session.set "userConfigId", ""
    Session.set "envConfigTypeId", envConfigTypeId





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



Template.envPageServerQuotaBlock.helpers
  serverGroups:-> db.bundleServerUserGroup.find()
  UserIn:(AdminArray)->Meteor.userId() in AdminArray

Template.serverQuotaAdmin.helpers
  links: ->
    now = new Date().getTime()
    db.invitation.find({groupId:@serverGroup._id, expireAt:$gt:now})
  info_of:(timeInt)-> "Will expire at #{moment(timeInt).toDate()}"

Template.serverQuotaAdmin.events
  'click .get-inv-link': (e,t) ->
    Meteor.call "generateBundleServerGroupInvitationUrl", t.data.serverGroup._id