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

    handsOnApis =
      _MemoryLimit:
        desc:
          get:->
            @inspect().data.Config.Memory


    for api in Object.keys(handsOnApis)
      Object.defineProperty @, api, handsOnApis[api].desc



@Class.DockerServer = class DockerServer extends Class.DockerodeClass

  constructor: (@_data, @_callbacks=DockerServerCallbacks, @_streamingCallbacks=StreamingCallBacks) ->
    if typeof @_data is "string"
      @_data = db.dockerServers.findOne {$or:[{_id:@_data}, {name:@_data}]}

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


    handsOnApis =
      sum_cpus:
        desc:
          get: ->
            @summaryUsedCpusets()

      ls_cpus:
        desc:
          get: ->
            @listUsedCpusets()

      _cpus:
        desc:
          get: -> [0..@_serverSpec.NCPU-1].map String
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


      allImages:
        desc:
          get: ->
            @listImageTags(tagOnly=true)?.data.map (imageTag)=>
              @_getImage imageTag


      totalMemoryLimit:
        desc:
          get: ->
            @sumMemoryLimits({})


      remainderMemory:
        desc:
          get:->
            @_serverSpec.MemTotal - @totalMemoryLimit


      _serverSpec:
        desc:
          get: ->
            if not @_data.spec
              serverInfo = @info()

              if not serverInfo.error
                specData =
                  spec:
                    MemTotal: serverInfo.data.MemTotal
                    NCPU: serverInfo.data.NCPU
                db.dockerServers.update({_id:@_id},{$set:specData})

                @_data = db.dockerServers.findOne _id:@_id

            @_data.spec


      rmiAllNoneTags:
        desc:
          get: ->
            allImageTags = @listImageTags()

            if not allImageTags.error
              rmiData = []

              for imageTagData in allImageTags.data
                if imageTagData.tag is '<none>:<none>'
                  rmiData.push @rmi imageTagData.Id

              resData =
                data: rmiData
                error: null

            else
              resData =
                data: null
                error: allImageTags.error

            resData

      allUsedPorts:
        desc:
          get:->
            usedPorts = []
            @listContainers({all:1}).data.map (xx)->
              xx.Ports.map (yy)->
                usedPorts.push yy.PublicPort

            usedPorts.map String



    for api in Object.keys(handsOnApis)
      Object.defineProperty @, api, handsOnApis[api].desc


    if @_configs_errors.length is 0
      @_configs_ok = true
      @ping()


  ensureImage: (image)->
    if not @isImageTagInServer(image)
      @pull image


  summaryQuota: (c=1, memoryUsage=512*1024*1024)->
    total = @_serverSpec.MemTotal / memoryUsage
    remainder =  @remainderQuota(c, memoryUsage)

    resData =
      total: total
      remainder: remainder
      usage: 1 - remainder/total

  remainderQuota: (c=1, memoryUsage=512*1024*1024)->
    (@_serverSpec.MemTotal*c - @totalMemoryLimit) / memoryUsage


  sumMemoryLimits: (opts={all:1})->
    allMemory = @allContainers(opts).map (con)-> con._MemoryLimit

    if allMemory.length > 1
      res = allMemory.reduce (x,y)-> x+y
    else
      if allMemory.length is 1
        res = allMemory[0]
      else
        res = 0

    res


  allContainers: (opts={all:1})->
    @listContainerIds(opts).data.map (containerId)=>
      @_getContainer containerId


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
      repo = "AgilearningIO/"+Random.id(20)

      # commitData =
      #   repo: "AgilearningIO/"+Random.id(20)
      #   tag: "latest"

    if not tag
      tag = "latest"

      # commitData = parseRepoString repo
      # if not commitData.tag
      #   commitData.tag = "latest"

    if not comment
      comment = "agilearning.io awesome!"

    if not author
      author = "agilearning.io"

    commitData = #_.extend commitData,
      repo: repo
      tag: tag
      comment: comment
      author: author

    container.commit(commitData)

  getFreePorts: (n, start=8000, end=9000)->
    allPorts = [start..end].map String
    allUsedPorts = @allUsedPorts
    allFreePorts = allPorts.filter (port)=> port not in allUsedPorts

    #FIXME: checking allFreePorts is enough !

    freePorts = []

    for i in [0..n-1]
      oneFreePort = Random.choice allFreePorts
      freePorts.push oneFreePort
      allFreePorts = allFreePorts.filter (port) -> port isnt oneFreePort

    freePorts

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


  getUsedCpusets: ->
    usedCpusets = []
    @allContainers().map (con)=>
      cpuset = con.inspect().data.Config.Cpuset
      if cpuset is ""
        cpuset = @_cpus.join(",")
      usedCpusets.push cpuset

    usedCpusets

  summaryUsedCpusets: ()->
    summary = {}
    @_cpus.map (cpu)->
      summary[cpu] = 0

    allUsedCpusets = @getUsedCpusets()

    for oneSet in allUsedCpusets
      oneSet.split(",").map (cpu)->
        summary[cpu] = summary[cpu] + 1

    summary

  listUsedCpusets: ()->
    summary = @summaryUsedCpusets()
    listSummary = Object.keys(summary).map (cpu)->
      resData =
        cpuName: cpu
        usage: summary[cpu]


  getFreeCpus: (n)->
    if n >= @_cpus.length
      res = @_cpus
    else
      sorted_ls_cpus = _.sortBy(@ls_cpus, "usage").map (cpuData)-> cpuData.cpuName
      res = sorted_ls_cpus[0..n-1]

    res

  getFreeCpuset: (n)->
    @getFreeCpus(n).join(",")



  RUN:(imageTag, limitType, userId, name, links=[]) ->
    # dependents on db.dockerImageTags join db.envConfigTypes


    # con.commit({repo:"ClassDockerImage",tag:"firstCommit",comment:"agilearning awesome!",author:"agilearning.io"})
    # imageTag = "ClassDockerImage:firstCommit"

    if not imageTag
      imageTag = "c3h3/ipython:agilearning"

    containerConfig = new Class.DockerContainerConfigs(imageTag, @)
    containerConfig.setUsageLimit(limitType).setServicePorts()

    if userId
      containerConfig = new Class.DockerContainerConfigs(imageTag, @).setAll(limitType,userId)
      # containerConfig.setEnvs(userId)
    else
    containerConfig = new Class.DockerContainerConfigs(imageTag, @).setAll(limitType)
      # containerConfig.setEnvs()

    containerData = containerConfig._configs

    console.log "containerData = ",containerData

    if name
      containerData.name = name

    if links
      containerData.HostConfig.Links = links

    console.log "containerData = ",containerData

    containerResData = @createContainer containerData

    if not containerResData.error
      container = new Class.DockerContainer @_id, containerResData.data
      container.start()
      container
    else
      containerResData

@Class.DockerContainerConfigs = class DockerContainerConfigs
  constructor: (@imageTag, @_docker)->
    @_configs = {}
    @_configs.Image = @imageTag


    @_configs.HostConfig = {}
    @_configs.HostConfig.PortBindings = {}

    @_imageTagData = db.dockerImageTags.findOne({tag:@imageTag})
    @_envConfigType = db.envConfigTypes.findOne({name:@_imageTagData.envConfigTypeName})

    @_Envs = {}
    @_portDataArray = []

  setUsageLimit: (limitType)->
    if limitType
      dockerLimit = db.dockerUsageLimits.findOne({name:limitType})

      usageLimitData =
        Cpuset: @_docker.getFreeCpuset(dockerLimit.NCPU)
        Memory: dockerLimit.Memory

      _.extend @_configs, usageLimitData
    @

  setServicePorts: ->
    servicePorts = @_imageTagData.servicePorts
    fports = @_docker.getFreePorts(servicePorts.length)

    portDataArray = [0..fports.length-1].map (i)->
      portData =
        guestPort: servicePorts[i].port
        hostPort: fports[i]
        type: servicePorts[i].type

    for portData in portDataArray
      servicePort = portData.guestPort + "/tcp"
      @_configs.HostConfig.PortBindings[servicePort] = [{"HostPort": portData.hostPort}]

    @_portDataArray = portDataArray
    @

  getUserEnvConfigData: (userId)->
    query =
      userId: userId
      envConfigTypeName: @_imageTagData.envConfigTypeName
    db.envUserConfigs.findOne(query)


  setEnvs: (userId)->
    mustSetEnvFields = []

    Envs = {}
    @_envConfigType.envs.map (fieldData)->
      if fieldData.mustHave
        mustSetEnvFields.push fieldData.name

        if fieldData.autoGen
          Envs[fieldData.name] = Random.id(40)

      else
        if fieldData.defaultValue
          Envs[fieldData.name] = fieldData.defaultValue

    if userId
      @getUserEnvConfigData(userId)?.envs.map (fieldData)->
        Envs[fieldData.key] = fieldData.value


    # FIXME: check all mustSetEnvFields are set
    EnvsArray = Object.keys(Envs).map (key)-> key + "=" + Envs[key]
    @_configs.Env = EnvsArray

    _.extend @_Envs, Envs

    @

  saveEnvUserConfigs: (userId)->
    console.log "TODO: db.envUserConfigs.upsert ? suggest use update and insert "
    console.log "@_Envs = ", @_Envs
    console.log "@_portDataArray = ", @_portDataArray


  setAll: (limitType, userId)->
    @setUsageLimit(limitType).setServicePorts().setEnvs(userId)
    @saveEnvUserConfigs(userId)
    @



@Class.DockersManager = class DockersManager

  constructor: (@useIn="production")->

    if typeof @useIn is "string"
      if @useIn is "production"
        @_serverQuery =
          useIn: "production"
      else
        @_serverQuery =
          useIn: "testing"

    else
      @_serverQuery = @useIn


    managerApis =
      ls_cpus:
        desc:
          get: ->
            lsCpusData = {}
            dockerServers = @_servers
            Object.keys(dockerServers).map (name)->
              lsCpusData[name] = dockerServers[name].ls_cpus

            lsCpusData


      rmAll:
        desc:
          get: ->
            rmAllData = {}
            dockerServers = @_servers
            Object.keys(dockerServers).map (name)->
              rmAllData[name] = dockerServers[name].rmAll

            rmAllData


      rmiAllNoneTags:
        desc:
          get: ->
            rmiData = {}
            dockerServers = @_servers
            Object.keys(dockerServers).map (name)->
              rmiData[name] = dockerServers[name].rmiAllNoneTags

            rmiData

      _serverIds:
        desc:
          get: ->
            db.dockerServers.find(@_serverQuery).map (serverData)-> serverData._id

      _serverNames:
        desc:
          get: ->
            db.dockerServers.find(@_serverQuery).map (serverData)-> serverData.name

      ls_servers:
        desc:
          get: ->
            # Object.keys @_servers
            @_serverNames

      _servers:
        desc:
          get: ->
            @_DockerServers()

      ps:
        desc:
          get: ->
            dockersPs = {}
            dockerServers = @_servers
            Object.keys(dockerServers).map (name)->
              dockersPs[name] = dockerServers[name].ps

            dockersPs

      ps_a:
        desc:
          get: ->
            dockersPs = {}
            dockerServers = @_servers
            Object.keys(dockerServers).map (name)->
              dockersPs[name] = dockerServers[name].ps_a

            dockersPs

      allUsedPorts:
        desc:
          get: ->
            dockersAllUsedPorts = {}
            dockerServers = @_servers
            Object.keys(dockerServers).map (name)->
              dockersAllUsedPorts[name] = dockerServers[name].allUsedPorts

            dockersAllUsedPorts





    for api in Object.keys(managerApis)
      Object.defineProperty @, api, managerApis[api].desc


  ensureImages: (images=["c3h3/ml-for-hackers", "c3h3/dsc2014tutorial", "c3h3/learning-shogun:u1404-ocv", "c3h3/rladies-hello-kaggle"])->
    for image in images
      @ensureImage image


  ensureImage: (image)->
    dockerServers = @_servers
    Object.keys(dockerServers).map (name)->
      dockerServers[name].ensureImage image


  summaryQuota: (c=1, memoryUsage=512*1024*1024)->
    serverQuota = {}
    dockerServers = @_servers
    Object.keys(dockerServers).map (name)->
      serverQuota[name] = dockerServers[name].summaryQuota(c, memoryUsage)

    serverQuota


  ls_summaryQuota: (c=1, memoryUsage=512*1024*1024)->
    dockerServers = @_servers
    Object.keys(dockerServers).map (name)->
      summary = dockerServers[name].summaryQuota(c, memoryUsage)
      resData =
        serverName: name
        total: summary.total
        remainder: summary.remainder
        usage: summary.usage


  getFreeServerName: (c=1, memoryUsage=512*1024*1024, forcely=false)->
    sumQuota = @ls_summaryQuota(c,memoryUsage)

    if forcely
      filteredSumQuota = sumQuota
    else
      filteredSumQuota = sumQuota.filter (quotaData)-> quotaData.remainder >= 1

    if filteredSumQuota.length > 0
      _.sortBy(filteredSumQuota,"usage")[0].serverName

    #FIXME: if no free servers ! OR no server

  getFreeServer: (c=1, memoryUsage=512*1024*1024)->
    @_servers[@getFreeServerName(c,memoryUsage,false)]


  getFreeServerForcely: (c=1, memoryUsage=512*1024*1024)->
    @_servers[@getFreeServerName(c,memoryUsage,true)]


  remainderQuota: (c=1, memoryUsage=512*1024*1024)->
    serverQuota = {}
    dockerServers = @_servers
    Object.keys(dockerServers).map (name)->
      serverQuota[name] = dockerServers[name].remainderQuota(c, memoryUsage)

    serverQuota


  ls_remainderQuota: (c=1, memoryUsage=512*1024*1024)->
    dockerServers = @_servers
    Object.keys(dockerServers).map (name)->
      resData =
        serverName: name
        quota: dockerServers[name].remainderQuota(c, memoryUsage)


  _DockerServers: (index="names")->
    dockerServers = {}

    db.dockerServers.find(@_serverQuery).map (serverData) =>

      docker = new Class.DockerServer serverData
      if not docker.ping().error
        if index is "names"
          dockerServers[docker._data.name] = docker
        else
          dockerServers[docker._data._id] = docker

    dockerServers


  _searchImageTag: (imageTag, activeOnly=true)->

    query =
      tag: imageTag
      serverId:
        $in: Object.keys(@_servers)

    if activeOnly
      query.active = true

    db.dockerImageTagsMonitor.find(query).map (imageTagData)-> imageTagData.serverId

