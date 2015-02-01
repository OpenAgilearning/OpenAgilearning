@Envs = new Meteor.Collection "envs"
@EnvCreateLog = new Meteor.Collection "EenvCreateLog"
@EnvTypes = new Meteor.Collection "envTypes"
@EnvLimits = new Meteor.Collection "envLimits"
@EnvUserConfigs = new Meteor.Collection "envUserConfigs"
@EnvInstances = new Meteor.Collection "envInstances"
@EnvInstancesLog = new Meteor.Collection "envInstancesLog"

@EnvsSchema = new SimpleSchema
  _id:
    type: String
  Created:
    type: Number
  Id:
    type: String
  ParentId:
    type: String
  Size:
    type: Number
  VirtualSize:
    type: Number
  dockerServerId:
    type: String
  lastUpdateAt:
    type: Date
  tag:
    type: String
  serverName:
    type: String
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
