@EnvTypes = new Meteor.Collection "envTypes"

@Envs = new Meteor.Collection "envs"
@EnvCreateLog = new Meteor.Collection "envCreateLog"

@EnvLimits = new Meteor.Collection "envLimits"
@EnvUserConfigs = new Meteor.Collection "envUserConfigs"
@EnvInstances = new Meteor.Collection "envInstances"
@EnvInstancesLog = new Meteor.Collection "envInstancesLog"


@EnvTypesSchema = new SimpleSchema
  name:
    type: String

  publicStatus:
    type: String
    allowedValues: ["public","semipublic","private"]    
    # autoform: 
    #   afFieldInput:
    #     options: ->
    #       res = 
    #         public: "public"
    #         semipublic: "semipublic"
    #         private: "private"            

  "configs.servicePorts":
    type: Array
    
  "configs.servicePorts.$":
    type: Object
    
  "configs.servicePorts.$.port":
    type: String
    optional: true
    regEx: /^[1-9][0-9]*/

  "configs.servicePorts.$.type":
    type: String
    optional: true
    allowedValues: ["http","ftp","vnc","mongodb","mysql","postgresql"]   
    # autoform: 
    #   afFieldInput:
    #     options: ->
    #       res = 
    #         http: "http"
    #         ftp: "ftp"
    #         vnc: "vnc"
    #         mongodb: "mongodb"
    #         mysql: "mysql"
    #         postgresql: "postgresql"



  "configs.envs":
    type: Array

  "configs.envs.$":
    type: Object
    optional: true

  "configs.envs.$.name":
    type: String
  
  "configs.envs.$.mustHave":
    type: Boolean
    defaultValue: true

  "configs.envs.$.limitValues":
    type: Array
    optional: true
    
  "configs.envs.$.limitValues.$":
    type: String
    optional:true    
  
    

Meteor.methods
  "createEnvType": (EnvTypesInsertSchemaData) ->
    console.log EnvTypesInsertSchemaData
    EnvTypes.insert EnvTypesInsertSchemaData

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
