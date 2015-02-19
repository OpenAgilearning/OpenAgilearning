
@Class.DockerServer = class DockerServer

  constructor: (@_data) ->
    
    @_configs = _.extend {}, @_data.connect
    @_configs_ok = false
    @_configs_errors = []
    @_docker_errors = []

    if not @_configs.socketPath
      if @_data.connect.protocol is "https"
        fs = Meteor.npmRequire 'fs'

        try

          #TODO: need a error path testing case
          ["ca","cert","key"].map (xx) ->
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
      callback resData.error, resData.data
    else
      if resData.error
        resData.error["errorInfo"] = 
          errorAt: new Date
          fn: "_futureCallDockerode"
          args:
            apiName: apiName
            opts: opts

        @_docker_errors.push resData.error

      resData


  ping: ->
    if @_docker
      pingRes = @_futureCallDockerode "ping" 

      if not pingRes.error
        @_docker_ping = true
      else
        @_docker_ping = false
      
      pingRes      


  info: ->
    if @_docker and @_docker_ping
      infoRes = @_futureCallDockerode "info" 
      infoRes

    
  listImages: (opts)->
    if @_docker and @_docker_ping
      listImagesRes = @_futureCallDockerode "listImages", opts
      listImagesRes








        
