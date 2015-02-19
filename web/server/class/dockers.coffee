
@Class.DockerServer = class DockerServer

  constructor: (@_data) ->
    
    @_configs = _.extend {}, @_data.connect
    @_configs_ok = false
    @_configs_errors = []
    @_docker_errors = []

    if not @_configs.socketPath
      if @_configs.connect.protocol is "https"
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
    

  ping: ->
    Future = Meteor.npmRequire 'fibers/future'
    pingFuture = new Future

    @_docker.ping (err,data)->
      if not err
        console.log data
        pingFuture.return data
      else
        console.log err
        pingFuture.return err

    ping = pingFuture.wait()

    if ping is "OK"
      @_docker_ping = true
    else
      @_docker_ping = false
      @_docker_errors.push ping 


    








        
