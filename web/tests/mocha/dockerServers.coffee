if Meteor.isServer
  MochaWeb?.testOnly ->
    
    mocha.timeout(10000)

    describe "Docker", ->
      
      describe "Servers", ->
        # db.dockerServers.remove({})
        dockerServersData = db.dockerServers.find().fetch()

        it "db.dockerServers have data", ->
          chai.assert dockerServersData.length > 0, "db.dockerServers have data"

        for dockerServer in dockerServersData
          # do (dockerServer) ->
          #   it "ping " + dockerServer._id + " should be successful!", ->                
          #     console.log "dockerServer._id = "
          #     console.log dockerServer._id


          #     docker = new Class.DockerServer dockerServer
             
          #     resData = docker.ping()

          #     chai.expect(docker._configs_ok).to.be.true
          #     chai.expect(resData.data).not.to.be.null
          #     chai.expect(resData.error).to.be.null

          do (dockerServer) ->
            docker = new Class.DockerServer dockerServer

            do (docker) ->
              if dockerServer.name is "errorCaPathServer"                
                it "ping " + dockerServer._id + " should be failed!", ->
                  resData = docker.ping()

                  chai.expect(docker._configs_ok).to.be.false
                  chai.expect(resData).to.be.undefined                

              else
                it "ping " + dockerServer._id + " should be successful!", ->                
                  resData = docker.ping()

                  chai.expect(docker._configs_ok).to.be.true
                  chai.expect(resData.data).not.to.be.null
                  chai.expect(resData.error).to.be.null


                it "get and sync info from " + dockerServer._id + " should be successful!", ->                
                  query = 
                    serverId: docker._id
                  
                  db.dockerServersMonitor.remove query

                  chai.expect(db.dockerServersMonitor.find(query).fetch()).to.be.empty
                  resData = docker.info()
                  
                  chai.expect(resData.data).not.to.be.null
                  chai.expect(resData.error).to.be.null
                  chai.expect(db.dockerServersMonitor.find(query).fetch()).not.to.be.empty

                it "listImages from " + dockerServer._id + " should be successful!", ->                
                  resData = docker.listImages()
                  
                  chai.expect(resData.data).not.to.be.null
                  chai.expect(resData.error).to.be.null

                it "listContainers from " + dockerServer._id + " should be successful!", ->                
                  resData = docker.listContainers({all:1})
                  # resData = docker.listContainers()
                  
                  chai.expect(resData.data).not.to.be.null
                  chai.expect(resData.error).to.be.null



      # describe "localhost", ->

      #   it "db.dockerServers should have localhost", ->
      #     chai.assert db.dockerServers.find({_id:"localhost"}).count() > 0, "db.dockerServers have a data with _id is localhost"


      #   it "ping localhost OK!", ->
      #     localhostServer = db.dockerServers.findOne _id:"localhost"
      #     localDocker = new Class.DockerServer localhostServer
      #     chai.expect(localDocker.ping().data).to.equal("OK")


      #   it "can get localhost info!", ->
      #     localhostServer = db.dockerServers.findOne _id:"localhost"
      #     localDocker = new Class.DockerServer localhostServer
      #     resInfo = localDocker.info()
          
      #     chai.expect(resInfo.data).not.to.be.null
      #     chai.expect(resInfo.error).to.be.null


      #   it "can listImages in localhost!", ->
      #     localhostServer = db.dockerServers.findOne _id:"localhost"
      #     localDocker = new Class.DockerServer localhostServer
      #     reslistImages = localDocker.listImages()
          
      #     chai.expect(reslistImages.data).not.to.be.null
      #     chai.expect(reslistImages.error).to.be.null
