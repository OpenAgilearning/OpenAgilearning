@Envs = new Meteor.Collection "envs"
@EnvCreateLog = new Meteor.Collection "envCreateLog"
@EnvTypes = new Meteor.Collection "envTypes"
@EnvLimits = new Meteor.Collection "envLimits"
@EnvUserConfigs = new Meteor.Collection "envUserConfigs"
@EnvInstances = new Meteor.Collection "envInstances"
@EnvInstancesLog = new Meteor.Collection "envInstancesLog"


# @EnvCreateLogSchema = new SimpleSchema
#   _id:
#     type: String
#   createdAt:
#     type:

@EnvTypesSchema = new SimpleSchema
  _id:
    type: String
  servicePort:
    type: String
  envVariable:
    type: [Object]

@EnvLimitsSchema = new SimpleSchema
  _id:
    type: String
  limit:
    type: Object

@EnvUserConfigsSchema = new SimpleSchema
  _id:
    type: String
  userId:
    type: String
  typeId:
    type: String
  envVariable:
    type: [String]

@EnvInstancesSchema = new SimpleSchema
  _id:
    type: String
  Command:
    type: String
  Created:
    type: Number
  Id:
    type: String
  Image:
    type: String
  Names:
    type: [String]
  Ports:
    type: [Object]
  Status:
    type: String
  dockerServerId:
    type: String
  dockerServerIp:
    type: String


Meteor.methods
  "runEnv": (EnvId) ->

    #[TODOLIST: checking before running]    
    #TODO: assert user logged in
    user = Meteor.user()
    if not user
      throw new Meteor.Error(401, "You need to login")

    #TODO: assert EnvId exists
    if Envs.find({"_id":EnvId}).count() is 0
      throw new Meteor.Error(1001, "Env ID Error!")


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
