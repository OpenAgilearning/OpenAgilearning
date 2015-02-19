
DockerServerCallbacks = 
  default: (self, resData)->
    if resData.error
      resData.error["errorInfo"] = 
        errorAt: new Date
        fn: "_futureCallDockerode"
        args:
          apiName: apiName
          opts: opts

      self._docker_errors.push resData.error

    resData

  ping: (self, resData)->
    if not resData.error
      self._docker_ping = true
    else
      self._docker_ping = false
    
    resData




@Class.DockerServer = class DockerServer

  constructor: (@_data, @_callbacks=DockerServerCallbacks) ->
    
    @_configs = _.extend {}, @_data.connect
    @_configs_ok = false
    @_configs_errors = []
    @_docker_errors = []

    if not @_configs.socketPath
      if @_data.connect.protocol is "https"
        fs = Meteor.npmRequire 'fs'

        try

          #TODO: need a error path testing case
          ["ca","cert","key"].map (xx) =>
            @_configs[xx] = fs.readFileSync(@_data.security[xx+"Path"])

        catch err

          @_configs_errors.push err
    
    if @_configs_errors.length is 0
      @_configs_ok = true

      Docker = Meteor.npmRequire "dockerode"

      @_docker = new Docker @_configs
      @ping()
    

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
      resData = @_futureCallDockerode apiName
      
      if callback
        resData = callback @, resData
      else
        if @_callbacks.ping
          resData = @_callbacks.ping @, resData
        else
          resData
    

  info: (callback) ->
    apiName = "info"

    if @_docker and @_docker_ping
      resData = @_futureCallDockerode apiName
      
      if callback
        resData = callback @, resData
      else
        resData
      

  listImages: (opts, callback)->
    apiName = "listImages"

    if @_docker and @_docker_ping
      resData = @_futureCallDockerode apiName, opts
      
      if callback
        resData = callback @, resData
      else
        resData
      








        
