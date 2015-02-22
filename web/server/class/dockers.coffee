
@DockerServerCallbacks =
  default: (self, resData)->
    if resData
      if resData.error
        self._docker_errors.push resData.error

    resData

  ping: (self, resData)->
    if resData 
      if not resData.error
        self._docker_ping = true
        
      else
        self._docker_ping = false

    resData


@DockerMonitorCallbacks =
  onAfterInit: (self) ->
    if not self._configs_ok
      query = 
        serverId: self._id
        type: "configError"
        handlingStatus: "todo"
        
      updateData =
        error: self._configs_errors
        updatedAt: new Date

      db.dockerServersException.update query, {$set:updateData}, {upsert:true}
        
  ping: (self, resData)->
    serverQuery = 
      serverId: self._id

    if resData 
      if not resData.error
        self._docker_ping = true
        
        updateData = 
          pingStatus: resData.data 
          pingError: null
          active: true
          lastPingAt: new Date

        db.dockerServersMonitor.update serverQuery, {$set:updateData}, {upsert:true}
      
      else
        self._docker_ping = false

        updateData = 
          pingStatus: null
          pingError: resData.error
          active: false
          lastPingAt: new Date

        db.dockerServersMonitor.update serverQuery, {$set:updateData}, {upsert:true}
      
    else
      updateData = 
        active: false        
        lastPingAt: new Date

      db.dockerServersMonitor.update serverQuery, {$set:updateData}, {upsert:true}
      
    resData

  info: (self, resData)->
    serverQuery = 
      serverId: self._id

    if resData 
      if not resData.error
        if resData.data.RegistryConfig?.IndexConfigs?
          target = resData.data.RegistryConfig.IndexConfigs
          keys = Object.keys target
          keys.map (k) ->
            if k.split(".").length > 1
              newKey = k.replace(".","!")
              target[newKey] = target[k]
              delete target[k]

        updateData = 
          info: resData.data
          error: null
          lastInfoMoonitorAt: new Date

      else
        updateData = 
          info: null
          error: resData.error
          lastInfoMoonitorAt: new Date

      db.dockerServersMonitor.update serverQuery, {$set:updateData}, {upsert:true}

    resData

  listContainers: (self, resData)->
    if resData
      if not resData.error
        for data in resData.data
          updateSelector = 
            serverId: self._id
            Id:data.Id

          updateData =
            alive: true
            running: true
            serverId: self._id
            lastUpdatedAt: new Date

          updateData = _.extend updateData, data

          db.dockerContainersMonitor.update updateSelector, {$set:updateData}, {upsert:true}          

    resData  

  listImageTags: (self, resData) ->
    if resData 
      if not resData.error

        # handling data in db.dockerImageTagsMonitor but not in resData.data
        resImageIds = []
        resData.data.map (imageData)->
          if imageData.Id not in resImageIds
            resImageIds.push imageData.Id

        updateSelector = 
          serverId: self._id
          Id:
            $nin: resImageIds

        updateData =
          active: false
          lastUpdatedAt: new Date

        db.dockerImageTagsMonitor.update updateSelector, {$set:updateData}, {multi:true}

        # handling data in resData.data
        for data in resData.data
          if data.tag is '<none>:<none>'

            # data.tag is '<none>:<none>' but data.Id in db
            updateSelector = 
              serverId: self._id
              Id: data.Id

            updateData = 
              active: false
              lastUpdatedAt: new Date


            db.dockerImageTagsMonitor.update updateSelector, {$set:updateData}, {multi:true}

          else
            updateSelector = 
              serverId: self._id
              Id: data.Id
              tag: data.tag

            updateData = 
              serverId: self._id
              active: true
              lastUpdatedAt: new Date

            updateData = _.extend updateData, data

            db.dockerImageTagsMonitor.update updateSelector, {$set:updateData}, {upsert:true}          

    resData


@UsefulCallbacks = {}
_.extend UsefulCallbacks, DockerServerCallbacks
_.extend UsefulCallbacks, DockerMonitorCallbacks




@Class.DockerServer = class DockerServer

  constructor: (@_data, @_callbacks=DockerServerCallbacks) ->

    @_id = @_data._id
    @_configs = _.extend {}, @_data.connect
    @_configs_ok = false
    @_configs_errors = []
    @_docker_errors = []

    if not @_configs.socketPath
      if @_data.connect.protocol is "https"
        fs = Meteor.npmRequire 'fs'

        try

          #TODO[finished]: need a error path testing case
          ["ca","cert","key"].map (xx) =>
            @_configs[xx] = fs.readFileSync(@_data.security[xx+"Path"])

        catch err

          @_configs_errors.push err
    
    if @_configs_errors.length is 0
      @_configs_ok = true

      Docker = Meteor.npmRequire "dockerode"

      @_docker = new Docker @_configs
      @ping()
    
    
    if @_callbacks.onAfterInit
      @_callbacks.onAfterInit @



  _futureCallDockerode: (apiName, opts, callback) ->

    Future = Meteor.npmRequire 'fibers/future'
    introspect = Meteor.npmRequire 'introspect'
    resFuture = new Future

    dockerMethodArgs = introspect @_docker[apiName]

    if "opts" in dockerMethodArgs
      @_docker[apiName] opts, (err,data)->
        res = 
          error: err
          data: data

        resFuture.return res

      resData = resFuture.wait()
    else
      @_docker[apiName] (err,data)->
        res = 
          error: err
          data: data

        resFuture.return res

      resData = resFuture.wait()

    if resData.error
      resData.error["errorInfo"] = 
        errorAt: new Date
        fn: "_futureCallDockerode"
        args:
          apiName: apiName
          opts: opts

    if callback
      callback self=@, resData=resData
    else

      if @_callbacks.default
        resData = @_callbacks.default @, resData

      if @_callbacks[apiName]
        resData = @_callbacks[apiName] @, resData
      
      resData
      

  ping: (callback) ->
    apiName = "ping"

    if @_docker
      if callback
        resData = @_futureCallDockerode apiName, {}, callback      
      else
        resData = @_futureCallDockerode apiName

      
  _dockerodeApiWrapper: (apiName, opts, callback)->
    if @_docker and @_docker_ping
      if not opts
        opts = {}

      if callback
        resData = @_futureCallDockerode apiName, opts, callback      
      else
        resData = @_futureCallDockerode apiName, opts


  info: (callback) ->
    apiName = "info"
    @_dockerodeApiWrapper(apiName, {}, callback)

      
  listImages: (opts, callback)->
    apiName = "listImages"
    @_dockerodeApiWrapper(apiName, opts, callback)


  listContainers: (opts, callback)->
    apiName = "listContainers"
    @_dockerodeApiWrapper(apiName, opts, callback)
    

  getContainer: (containerId)->
    if @_docker and @_docker_ping
      container = @_docker.getContainer containerId


  createContainer: (opts, callback)->
    if @_docker and @_docker_ping
      apiName = "createContainer"
      containerRes = @_dockerodeApiWrapper(apiName, opts, callback)

  listImageTags: ->
    methodName = "listImageTags"
    resData = @listImages({})
        
    if resData?.data
      newData = []
      for data in resData.data
        tags = data.RepoTags
        delete data.RepoTags
        for tag in tags
          newData.push _.extend {tag:tag}, data

      if newData.length > 0
        resData.data = newData

    if @_callbacks[methodName]
      resData = @_callbacks[methodName] @, resData

    resData