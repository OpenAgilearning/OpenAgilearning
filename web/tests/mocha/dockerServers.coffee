if Meteor.isServer
  MochaWeb?.testOnly ->

    mocha.timeout(10000)

    describe "Docker", ->

      describe "Servers", ->
        before ->
          db.dockerServersMonitor.remove {}
          db.dockerImageTagsMonitor.remove {}
          Fixture.DockerServers.reset()


        # db.dockerServers.remove({})
        dockerServersData = db.dockerServers.find({"useIn" : "testing"}).fetch()
        # console.log dockerServersData

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

            i=0
            if i < 1
              if dockerServer.name is "errorCaPathServer"
                it "DockerServerCallbacks has no info callback. So does docker._callbacks", ->
                  docker = new Class.DockerServer dockerServer, DockerServerCallbacks
                  chai.expect(docker._callbacks.info).to.be.undefined

                i = i+1

            # FIXED Above  Bug (DockerServerCallbacks has no info callback. So does docker._callbacks)!
            UsefulCallbacks = {}
            _.extend UsefulCallbacks, DockerServerCallbacks
            _.extend UsefulCallbacks, DockerMonitorCallbacks

            docker = new Class.DockerServer dockerServer, UsefulCallbacks

            do (docker) ->
              if dockerServer.name is "errorCaPathServer"
                it "ping " + dockerServer._id + " should be failed!", ->
                  resData = docker.ping()

                  # console.log "ping " + dockerServer._id + " should be failed!"
                  # console.log "resData = ",resData

                  chai.expect(docker._configs_ok).to.be.false
                  chai.expect(resData.data).to.be.null
                  chai.expect(resData.error).not.to.be.null


              else

                # it "ping " + dockerServer._id + " should be successful!", ->
                #   resData = docker.ping()

                #   chai.expect(docker._configs_ok).to.be.true
                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null

                # it "get info from " + dockerServer._id + " should be successful!", ->

                #   resData = docker.info()

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null

                # it "sync info from " + dockerServer._id + " should be successful!", ->

                #   query =
                #     serverId: docker._id

                #   db.dockerServersMonitor.remove query

                #   chai.expect(db.dockerServersMonitor.find(query).fetch()).to.be.empty
                #   resData = docker.info()

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null
                #   chai.expect(db.dockerServersMonitor.find(query).fetch()).not.to.be.empty

                # it "get listImages from " + dockerServer._id + " should be successful!", ->
                #   resData = docker.listImages()

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null

                # it "get listImageTags from " + dockerServer._id + " should be successful!", ->
                #   resData = docker.listImageTags()

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null

                # it "sync listImageTags from " + dockerServer._id + " should be successful!", ->

                #   query =
                #     serverId: docker._id

                #   db.dockerImageTagsMonitor.remove query

                #   chai.expect(db.dockerImageTagsMonitor.find(query).fetch()).to.be.empty
                #   resData = docker.listImageTags()

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null
                #   chai.expect(db.dockerImageTagsMonitor.find(query).fetch()).not.to.be.empty

                # it "no active < none > : < none > tag image in dockerImageTagsMonitor in " + dockerServer._id, ->

                #   query =
                #     serverId: docker._id
                #     tag: '<none>:<none>'

                #   chai.expect(db.dockerImageTagsMonitor.find(query).fetch()).to.be.empty

                # it "get listContainers from " + dockerServer._id + " should be successful!", ->
                #   resData = docker.listContainers({all:1})
                #   # resData = docker.listContainers()

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null

                # it "sync listContainers from " + dockerServer._id + " should be successful!", ->

                #   query =
                #     serverId: docker._id

                #   db.dockerContainersMonitor.remove query

                #   chai.expect(db.dockerContainersMonitor.find(query).fetch()).to.be.empty
                #   resData = docker.listContainers({all:1})

                #   chai.expect(resData.data).not.to.be.null
                #   chai.expect(resData.error).to.be.null
                #   chai.assert db.dockerContainersMonitor.find(query).count() is resData.data.length


                # describe "Class.DockerServer's IO", ->

                #   it "test Class.DockerServer::isImageTagInServer & listImageTags(tagOnly=true) with " + dockerServer._id, ->
                #     resData = docker.listImageTags(tagOnly=true)
                #     chai.expect(resData.data).not.to.be.null
                #     chai.expect(resData.error).to.be.null

                #     serverImageTags = resData.data
                #     chai.assert serverImageTags.length>1, dockerServer._id + " has at least one image!"

                #     testImage = serverImageTags[0]
                #     chai.expect(docker.isImageTagInServer(testImage)).to.be.true
                #     # chai.assert  is true, "test docker.isImageTagInServer on " + dockerServer._id + " with itself image: " + testImage

                #     randomImage = Random.id(30)
                #     chai.expect(randomImage in serverImageTags).to.be.false
                #     chai.expect(docker.isImageTagInServer(randomImage)).to.be.false
                #     # chai.assert randomImage not in serverImageTags, randomImage + " not in serverImageTags in " + dockerServer._id
                #     # chai.assert docker.isImageTagInServer randomImage is false, "docker.isImageTagInServer " + randomImage + " is false in " + dockerServer._id


                describe "tag & untag (image)", ->
                  it "ensure sync listImageTags consistent when untagging image in " + dockerServer._id, ->
                    console.log "TODO"


                describe "docker.pull & docker.rmi (image) / image.tag", ->
                  before ->
                    if not docker.isImageTagInServer("redis:2.8.18")
                      console.log "pulling redis:2.8.18 in " + dockerServer._id
                      docker.pull "redis:2.8.18"

                  it "ensure redis:2.8.18 image in " + dockerServer._id, ->
                    chai.expect(docker.isImageTagInServer("redis:2.8.18")).to.be.true

                  it "ensure no testingTag:testingTag image in " + dockerServer._id, ->
                    if docker.isImageTagInServer "testingTag:testingTag"
                      docker.rmi "testingTag:testingTag"

                    chai.expect(docker.isImageTagInServer("testingTag:testingTag")).to.be.false


                  it "tag redis:2.8.18 as testingTag:testingTag in " + dockerServer._id, ->

                    image = docker._getImage "redis:2.8.18"

                    tagOpts =
                      repo:"testingTag"
                      tag:"testingTag"

                    image.tag tagOpts

                    chai.expect(docker.isImageTagInServer("testingTag:testingTag")).to.be.true



                  # it "docker.rmi redis:2.8.18 image in " + dockerServer._id, ->
                  #   chai.expect(docker.isImageTagInServer("redis:2.8.18")).to.be.true
                  #   docker.rmi("redis:2.8.18")
                  #   chai.expect(docker.isImageTagInServer("redis:2.8.18")).to.be.false


                describe "run (image), stop & remove (contianer)", ->

                  before ->

                    if not docker.isImageTagInServer("debian:jessie")
                      console.log "pulling debian:jessie in " + dockerServer._id
                      docker.pull "debian:jessie"

                    if not docker.isImageTagInServer("c3h3/ipython:agilearning")
                      console.log "pulling c3h3/ipython:agilearning in " + dockerServer._id
                      docker.pull "c3h3/ipython:agilearning"

                    # if not docker.isImageTagInServer("c3h3/learning-shogun:agilearning")
                    #   console.log "pulling c3h3/learning-shogun:agilearning in " + dockerServer._id
                    #   docker.pull "c3h3/learning-shogun:agilearning"

                  it "ensure debian:jessie image in " + dockerServer._id, ->
                    chai.expect(docker.isImageTagInServer("debian:jessie")).to.be.true

                  it "ensure c3h3/ipython:agilearning image in " + dockerServer._id, ->
                    chai.expect(docker.isImageTagInServer("c3h3/ipython:agilearning")).to.be.true

                  it "run and check debian:jessie's container in " + dockerServer._id, ->
                    console.log "TODO"

                  it "stop and check debian:jessie's container in " + dockerServer._id, ->
                    console.log "TODO"

                  it "remove and check debian:jessie's container in " + dockerServer._id, ->
                    console.log "TODO"

                  it "sync run->stop with debian:jessie in " + dockerServer._id, ->
                    console.log "TODO"

                  it "sync run->stop->remove with debian:jessie in " + dockerServer._id, ->
                    console.log "TODO"


                # describe "pull & push from public docker hub", ->
                #   before ->
                #     if docker.isImageTagInServer("redis:2.8.18")
                #       console.log "redis:2.8.18 in " + dockerServer._id
                #       docker.rmi "redis:2.8.18"

                #   it "ensure redis:2.8.18 image not in " + dockerServer._id, ->
                #     chai.expect(docker.isImageTagInServer("redis:2.8.18")).to.be.false

                #   it "docker pull redis:2.8.18 image in " + dockerServer._id, ->
                #     console.log "TODO"

                describe "pull & push from private docker hub", ->

                  it "ensure redis:2.8.18 image not in private docker repo (test " + dockerServer._id + ")", ->
                    console.log "TODO"

                  it "docker push redis:2.8.18 image to private docker repo from " + dockerServer._id, ->
                    console.log "TODO"


      # describe "run, stop, remove", ->
      #   # "sync run->stop & run->stop->remove listContainers from " + dockerServer._id + " should be successful!", ->
      #   dockerServersData = db.dockerServers.find().fetch()

      #   for dockerServer in dockerServersData
      #     do (dockerServer) ->
      #       docker = new Class.DockerServer dockerServer, UsefulCallbacks

      #       do (docker) ->

      #         testImageTag = "debian:jessie"



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
