
@DockerDefaultCallbacks =
  default: (self, resData)->
    if resData
      if resData.error
        self._docker_errors?.push resData.error

    resData

  defaultStreamingCallback: (err,stream) ->
    JSONStream = Meteor.npmRequire('JSONStream')
    parser = JSONStream.parse()
    if not err
      stream.pipe(parser).on("data",console.log)#.pipe(streamToMongo)
    else
      console.log err



@DockerServerCallbacks = _.extend {}, DockerDefaultCallbacks
@DockerServerCallbacks = _.extend @DockerServerCallbacks,
  ping: (self, resData)->
    if resData
      if not resData.error
        self._docker_ping = true

      else
        self._docker_ping = false

    resData

  getFreePorts: (self, resData)->
    # reserve the free ports & read and write dbs

    resData


@DockerImageCallbacks = _.extend {}, DockerDefaultCallbacks
@DockerImageCallbacks = _.extend @DockerImageCallbacks,
  push: (err,stream) ->
    JSONStream = Meteor.npmRequire('JSONStream')
    parser = JSONStream.parse()
    if not err
      stream.pipe(parser).on("data",console.log)#.pipe(streamToMongo)
    else
      console.log err


@DockerContainerCallbacks = _.extend {}, DockerDefaultCallbacks
# @DockerContainerCallbacks = _.extend @DockerContainerCallbacks,



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

        # FIXME: #315
        # console.log "updateData = "
        # console.log updateData

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


# @DockerImageCallbacks =
#   onAfterInit: (self) ->
#     if not self._configs_ok
#       query =
#         serverId: self._id
#         type: "configError"
#         handlingStatus: "todo"

#       updateData =
#         error: self._configs_errors
#         updatedAt: new Date

#       db.dockerServersException.update query, {$set:updateData}, {upsert:true}

#   pullImage: (self, resData)->
#     # if resData
#     #   if not resData.error
#     #   else
#     resData

#   tagImage: (self, resData)->
#     # if resData
#     #   if not resData.error
#     #   else
#     resData
#   pushImage: (self, resData)->
#     # if resData
#     #   if not resData.error
#     #   else
#     resData

@UsefulCallbacks = {}
_.extend UsefulCallbacks, DockerServerCallbacks
_.extend UsefulCallbacks, DockerMonitorCallbacks

# @ImageCallbacks = {}
# _.extend ImageCallbacks, DockerServerCallbacks
# _.extend ImageCallbacks, DockerImageCallbacks


StreamingCallBacks =
  default: (err,stream) ->
    JSONStream = Meteor.npmRequire('JSONStream')
    parser = JSONStream.parse()
    if not err
      stream.pipe(parser).on("data",console.log)#.pipe(streamToMongo)
    else
      console.log err



needStreamingCallback = (fn, streamingFns=[])->
  if streamingFns.length is 0
    /isStream: true|stream: true/.exec(fn) isnt null
  else
    pat = new RegExp "isStream: true|stream: true|" + streamingFns.join("|")
    pat.exec(fn) isnt null



@Class.DockerServer = class DockerServer

  constructor: (@_data, @_callbacks=DockerServerCallbacks, @_streamingCallbacks=StreamingCallBacks) ->

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

      @_dockerApis = Object.keys Docker.prototype
      @_dockerStreamingApis = @_dockerApis.filter (api) -> needStreamingCallback Docker::[api]
      @_dockerStreamingApis = @_dockerApis.filter (api) => needStreamingCallback Docker::[api], @_dockerStreamingApis


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


  _streamingCallDockerode: (apiName, kwargs, callback) ->
    if @_docker and @_docker_ping

      #PASSED: docker._streamingCallDockerode("pull", ["debian:jessie",{}])
      #FIXME: docker._streamingCallDockerode("pull", ["debian:jessie"])

      introspect = Meteor.npmRequire 'introspect'
      kws = introspect @_docker[apiName]

      if kwargs instanceof Array and kws.length >= kwargs.length
        args = kwargs
      else
        args = kws.map (k) -> kwargs[k]

      callbackIndex = kws.indexOf "callback"

      if args.length < callbackIndex
        for i in [args.length..callbackIndex]
          args.push {}

      if callback
        args[callbackIndex] = callback
      else
        if @_streamingCallbacks[apiName]
          args[callbackIndex] = @_streamingCallbacks[apiName]
        else
          args[callbackIndex] = @_streamingCallbacks.default

      @_docker[apiName].apply @_docker, args


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


  listImageTags: (tagOnly=false)->
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

    if tagOnly
      resData.data = resData.data.map (data)-> data.tag

    resData


  isImageTagInServer: (imageTag) ->
    serverImageTags = @listImageTags(tagOnly=true)?.data
    imageTag in serverImageTags


  getImage: (imageTag)->
    if @_docker and @_docker_ping
      image = @_docker.getImage imageTag
      new Class.DockerImage @_id, image


  pull: (imageTag, opts, callback)->
    if not callback
      if not opts
        @_streamingCallDockerode "pull", [imageTag]
      else
        @_streamingCallDockerode "pull", [imageTag, opts]
    else
      @_streamingCallDockerode "pull", [imageTag, opts, callback]


  rm: (imageTag)->
    if @_docker and @_docker_ping
      image = @_docker.getImage imageTag
      imageObj = new Class.DockerImage @_id, image
      imageObj.remove()



@Class.DockerodeClass = class DockerodeClass

  constructor: (@_Class, @_initData, @_callbacks) ->
    @_apis = Object.keys @_Class::

    @_streamingApis = @_apis.filter (api) => needStreamingCallback @_Class::[api]
    @_streamingApis = @_apis.filter (api) => needStreamingCallback @_Class::[api], @_streamingApis

    @_apiArgs = {}

    @_apis.map (api) =>
      introspect = Meteor.npmRequire 'introspect'
      @_apiArgs[api] = introspect @_Class::[api]

    @_callbackApis = @_apis.filter (api)=> "callback" in @_apiArgs[api]


    if @_initData instanceof @_Class
      @_instance = @_initData
      delete @_initData
    else
      if @_initData
        @_instance = new @_Class @_initData

    @_syncApis = @_apis.filter (api)=> api not in @_streamingApis

    for api in @_syncApis

      apiDes = do (api) ->
        res =
          get: ->
            (args...) -> this._syncCall(api,args)
            # (args...) -> this._syncCall.call this, args.unshift(api)


      # Object.defineProperty @.constructor::, api, apiDes
      Object.defineProperty @, api, apiDes

    for api in @_streamingApis

      apiDes = do (api) ->
        res =
          get: ->
            (args...) -> this._streamingCall(api,args)
            # (args...) -> this._syncCall.call this, args.unshift(api)

      Object.defineProperty @, api, apiDes


  _syncCallCheck: (apiName) ->
    @_canSyncCall = apiName in @_apis
    @_canSyncCall = @_canSyncCall and @_instance
    @_canSyncCall = @_canSyncCall and (apiName not in @_streamingApis)


  _syncCall: (apiName, kwargs, callback) ->
    # unless typeof callback is "function"
    #   args.push callback

    @_syncCallCheck apiName

    if @_canSyncCall

      kws = @_apiArgs[apiName]

      if kwargs instanceof Array and kws.length >= kwargs.length
        args = kwargs
      else
        args = kws.map (k) -> kwargs[k]


      Future = Meteor.npmRequire 'fibers/future'
      resFuture = new Future

      futureCallback = (err,data)->
        res =
          error: err
          data: data

        resFuture.return res



      if apiName in @_callbackApis
        callbackIndex = @_apiArgs[apiName].indexOf "callback"

        if args.length < callbackIndex
          for i in [args.length..callbackIndex]
            args.push {}

        args[callbackIndex] = futureCallback


        @_instance[apiName].apply @_instance, args
        resData = resFuture.wait()

      else

        try
          resData =
            data: @_instance[apiName].apply @_instance, args
            error: null
        catch e
          resData =
            data: null
            error: e


      if resData.error
        resData.error["errorInfo"] =
          errorAt: new Date
          fn: "_syncCall"
          args:
            apiName: apiName
            args: args


      if typeof callback is "function"
        callback self=@, resData=resData
      else

        if @_callbacks?.default
          resData = @_callbacks.default @, resData

        if @_callbacks?[apiName]
          resData = @_callbacks[apiName] @, resData

        resData

  _streamingCallCheck: (apiName) ->
    @_canStreamingCall = apiName in @_streamingApis
    @_canStreamingCall = @_canStreamingCall and @_instance



  _streamingCall: (apiName, kwargs , callback) ->
    # unless typeof callback is "function"
    #   if callback
    #     args.push callback

    @_streamingCallCheck apiName

    if @_canStreamingCall

      #PASSED: docker._streamingCallDockerode("pull", ["debian:jessie",{}])
      #FIXME: docker._streamingCallDockerode("pull", ["debian:jessie"])

      kws = @_apiArgs[apiName]

      if kwargs instanceof Array and kws.length >= kwargs.length
        args = kwargs
      else
        args = kws.map (k) -> kwargs[k]

      callbackIndex = kws.indexOf "callback"

      if args.length < callbackIndex
        for i in [args.length..callbackIndex]
          args.push {}

      if callback
        args[callbackIndex] = callback
      else
        if @_callbacks[apiName]
          args[callbackIndex] = @_callbacks[apiName]
        else
          args[callbackIndex] = @_callbacks.defaultStreamingCallback

      @_instance[apiName].apply @_instance, args


@Class.DockerImage = class DockerImage extends Class.DockerodeClass

  constructor: (@_serverId, @_image, @_callbacks=DockerImageCallbacks) ->
    super @_image.constructor, @_image, @_callbacks


@Class.DockerContainer = class DockerContainer extends Class.DockerodeClass

  constructor: (@_serverId, @_container, @_callbacks=DockerContainerCallbacks) ->
    super @_container.constructor, @_container, @_callbacks


@Class.NewDockerServer = class NewDockerServer extends Class.DockerodeClass

  constructor: (@_data, @_callbacks=DockerServerCallbacks, @_streamingCallbacks=StreamingCallBacks) ->

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

      super Docker, @_configs, @_callbacks

      @ping()


      moreDockerApis =
        ps:
          desc:
            get: -> @listContainers()

        ps_a:
          desc:
            get: -> @listContainers({all:1})

        images:
          desc:
            get: -> @listImages()

        stopAll:
          desc:
            get: ->
              @listContainerIds().data.map (containerId)=>
                @stop containerId

        rmAll:
          desc:
            get: ->
              @stopAll()
              @listContainerIds().data.map (containerId)=>
                @rm containerId

        startAll:
          desc:
            get: ->
              @listContainerIds().data.map (containerId)=>
                @start containerId

        allContainers:
          desc:
            get: ->
              @listContainerIds().data.map (containerId)=>
                @_getContainer containerId

        allImages:
          desc:
            get: ->
              @listImageTags(tagOnly=true)?.data.map (imageTag)=>
                @_getImage imageTag

      for api in Object.keys(moreDockerApis)
        Object.defineProperty @, api, moreDockerApis[api].desc


    else
      @ping = ->

  _syncCallCheck: (apiName) ->
    super apiName

    if apiName isnt "ping"
      @_canSyncCall = @_canSyncCall and (@ping().error is null)


  listImageTags: (tagOnly=false)->
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

    if tagOnly
      resData.data = resData.data.map (data)-> data.tag

    resData

  listContainerIds: (opts={all:1})->
    methodName = "listContainerIds"
    resData = @listContainers(opts)

    if resData?.data
      resData.data = resData.data.map (data)-> data.Id


    if @_callbacks[methodName]
      resData = @_callbacks[methodName] @, resData

    resData


  isImageTagInServer: (imageTag) ->
    serverImageTags = @listImageTags(tagOnly=true)?.data
    imageTag in serverImageTags


  _getImage: (imageTag) ->
    resData = @getImage imageTag
    if resData
      if not resData.error
        new Class.DockerImage @_id, resData.data
      else
        resData
    else
      resData


  rmi: (imageTag)->
    @_getImage(imageTag).remove()


  # allImages: ()->
  #   @listImageTags(tagOnly=true)?.data.map (imageTag)=>
  #     @_getImage imageTag


  _getContainer: (containerId)->
    resData = @getContainer containerId
    if resData
      if not resData.error
        new Class.DockerContainer @_id, resData.data
      else
        resData
    else
      resData


  stop: (containerId)->
    @_getContainer(containerId).stop()


  rm: (containerId)->
    @_getContainer(containerId).remove()


  start: (containerId)->
    @_getContainer(containerId).start()


  # stopAll: ()->
  #   @listContainerIds().data.map (containerId)=>
  #     @stop containerId


  # rmAll: ()->
  #   @stopAll()
  #   @listContainerIds().data.map (containerId)=>
  #     @rm containerId


  # startAll: ()->
  #   @listContainerIds().data.map (containerId)=>
  #     @start containerId


  # allContainers: ()->
  #   @listContainerIds().data.map (containerId)=>
  #     @_getContainer containerId


  commit: (containerId, repo, tag, comment, author)->
    container = @_getContainer containerId

    if not repo
      repo = "AgilearningIO/"+Random.id(20)

    if not tag
      tag = "latest"

    if not comment
      comment = "agilearning.io awesome!"

    if not author
      author = "agilearning.io"

    commitData =
      repo: repo
      tag: tag
      comment: comment
      author: author

    container.commit(commitData)


  allUsedPorts: ->
    usedPorts = []
    @listContainers({all:1}).data.map (xx)->
      xx.Ports.map (yy)->
        usedPorts.push yy.PublicPort

    usedPorts.map String

  getFreePorts: (n, start=8000, end=9000)->
    allPorts = [start..end].map String
    allUsedPorts = @allUsedPorts()
    allFreePorts = allPorts.filter (port)=> port not in allUsedPorts

    if allFreePorts.length >= n
      resData =
        error: null
        data: allFreePorts

      if @_callbacks.getFreePorts
        resData = @_callbacks.getFreePorts @, resData

      else
        resData.data = resData.data[0..n-1]

    else
      resData =
        error: "port not enough"
        data: null

    resData


  _runTest:(imageTag) ->
    # con.commit({repo:"ClassDockerImage",tag:"firstCommit",comment:"agilearning awesome!",author:"agilearning.io"})
    # imageTag = "ClassDockerImage:firstCommit"

    if not imageTag
      imageTag = "c3h3/ipython:agilearning"


    configData = db.envUserConfigs.findOne({configTypeId:"ipynb"}).configData
    EnvsArray = configData.map (envData) -> envData["key"] + "=" + envData["value"]
    dockerLimit = db.dockerLimits.findOne()

    containerData = _.extend {}, dockerLimit.limit
    containerData.Image = imageTag
    containerData.Env = EnvsArray

    configTypeId = 'ipynb'
    servicePorts = db.envConfigTypes.findOne({_id:configTypeId}).configs.servicePorts
    fports = docker.getFreePorts(servicePorts.length)

    if not fports.error
      fports = fports.data
    else
      fports = []

    portDataArray = [0..fports.length-1].map (i)->
      portData =
        guestPort: servicePorts[i].port
        hostPort: fports[i]
        type: servicePorts[i].type

    containerData.HostConfig = {}
    containerData.HostConfig.PortBindings = {}

    for portData in portDataArray
      servicePort = portData.guestPort + "/tcp"
      containerData.HostConfig.PortBindings[servicePort] = [{"HostPort": portData.hostPort}]


    containerResData = @createContainer containerData

    if not containerResData.error
      new Class.DockerContainer @_id, containerResData.data
    else
      containerResData