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


@UsefulCallbacks = {}
_.extend UsefulCallbacks, DockerServerCallbacks
_.extend UsefulCallbacks, DockerMonitorCallbacks



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
    # @_canSyncCall = @_canSyncCall and @[apiName]?
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



@parseRepoString = (repoString)->
  lastColonIdx = repoString.lastIndexOf ':'

  if lastColonIdx < 0
    res =
      repo: repoString

  tag = repoString.slice lastColonIdx + 1

  if  tag.indexOf('/') is -1
    res =
      repo: repoString.slice(0, lastColonIdx)
      tag: tag

  res


@Class.DockerImage = class DockerImage extends Class.DockerodeClass

  constructor: (@_docker, @_image, @_callbacks=DockerImageCallbacks) ->
    @_serverId = @_docker._id
    super @_image.constructor, @_image, @_callbacks


  TAG: (repoString)->
    @.tag parseRepoString repoString


  PUSH: (callback)->

    if not callback
      if @_callbacks.push
        callback = @_callbacks.push
      else
        callback = DockerImageCallbacks.push

    dockerConfig = _.extend {}, @_docker._configs
    dockerConfig.hostname = dockerConfig.host
    delete dockerConfig.protocol
    delete dockerConfig.host

    repoData = parseRepoString @_image["name"]

    https = Meteor.npmRequire "https"
    headers =
      "X-Registry-Auth": "eyJ1c2VybmFtZSI6ICJzdHJpbmciLCAicGFzc3dvcmQiOiAic3RyaW5nIiwgImVtYWlsIjogInN0cmluZyIsICJzZXJ2ZXJhZGRyZXNzIiA6ICJzdHJpbmciLCAiYXV0aCI6ICIifQ=="

    apiPath = '/images/' + repoData.repo + "/push"
    if repoData.tag
      apiPath = apiPath + "?tag=" + encodeURIComponent(repoData.tag)

    options = _.extend dockerConfig,
      rejectUnauthorized: false
      headers: headers
      path: apiPath
      method: 'POST'

    # console.log "options = ",options

    resData =
      data: null
      error: null

    req = https.request options, (res)->
      # resData.data = res

      callback(null, res)

      # handleFn = (data)->
      #   process.stdout.write(data)
      #   data

      # res.on('data', handleFn)#.on('data', handleFn)

    req.on 'error', (e)->
      callback(e, null)
      # resData.error = res

      # console.error e

    req.end()
    undefined


@Class.DockerContainer = class DockerContainer extends Class.DockerodeClass

  constructor: (@_docker, @_container, @_callbacks=DockerContainerCallbacks) ->
    @_serverId = @_docker._id
    super @_container.constructor, @_container, @_callbacks


@Class.DockerServer = class DockerServer extends Class.DockerodeClass

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

      imageTags:
        desc:
          get: -> @listImageTags(tagOnly=true)

      stopAll:
        desc:
          get: ->
            @listContainerIds().data.map (containerId)=>
              @stop containerId

      rmAll:
        desc:
          get: ->
            @stopAll
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



    if @_configs_errors.length is 0
      @_configs_ok = true
      @ping()

  _syncCallCheck: (apiName) ->
    super apiName

    @_canSyncCall = apiName in @_apis
    @_canSyncCall

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
        new Class.DockerImage @, resData.data
      else
        resData
    else
      resData


  Image: (imageTag) ->
    resData = @getImage imageTag
    if resData
      if not resData.error
        new Class.DockerImage @, resData.data
      else
        resData
    else
      resData


  rmi: (imageTag)->
    @_getImage(imageTag).remove()


  _getContainer: (containerId)->
    resData = @getContainer containerId
    if resData
      if not resData.error
        new Class.DockerContainer @, resData.data
      else
        resData
    else
      resData


  Container: (containerId)->
    resData = @getContainer containerId
    if resData
      if not resData.error
        new Class.DockerContainer @, resData.data
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


  commit: (containerId, repo, tag, comment, author)->
    container = @_getContainer containerId

    if not repo
      commitData =
        repo: "AgilearningIO/"+Random.id(20)
        tag: "latest"

    if not tag
      commitData = parseRepoString repo
      if not commitData.tag
        commitData.tag = "latest"

    if not comment
      comment = "agilearning.io awesome!"

    if not author
      author = "agilearning.io"

    commitData = _.extend commitData,
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
    allFreePorts[0..n-1]

    # if allFreePorts.length >= n
    #   resData =
    #     error: null
    #     data: allFreePorts

    #   if @_callbacks.getFreePorts
    #     resData = @_callbacks.getFreePorts @, resData

    #   else
    #     resData.data = resData.data[0..n-1]

    # else
    #   resData =
    #     error: "port not enough"
    #     data: null

    # resData


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
    fports = @getFreePorts(servicePorts.length)

    # if not fports.error
    #   fports = fports.data
    # else
    #   fports = []

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


@Class.DockersManager = class DockersManager

  constructor: (@useIn="production")->

    @_servers = {}

    if @useIn is "production"
      @_serverQuery =
        useIn: "production"
    else
      @_serverQuery =
        useIn: "testing"


    db.dockerServers.find(@_serverQuery).map (serverData) =>
      docker = new Class.DockerServer serverData
      if not docker.ping().error
        @_servers[docker._data.name] = docker
        @_servers[docker._id] = docker

    managerApis =
      ls_servers:
        desc:
          get: ->
            Object.keys @_servers

    for api in Object.keys(managerApis)
      Object.defineProperty @, api, managerApis[api].desc


  _searchImageTag: (imageTag, activeOnly=true)->

    query =
      tag: imageTag
      serverId:
        $in: Object.keys(@_servers)

    if activeOnly
      query.active = true

    db.dockerImageTagsMonitor.find(query).map (imageTagData)-> imageTagData.serverId

