if Meteor.isServer
  MochaWeb?.testOnly ->
    describe "Docker", ->
      describe "localhost Docker Server", ->

        it "db.dockerServers should have localhost", ->
          chai.assert db.dockerServers.find({_id:"localhost"}).count() > 0, "db.dockerServers have a data with _id is localhost"

        it "ping localhost OK!", ->
          localhostServer = db.dockerServers.findOne _id:"localhost"
          localDocker = new Class.DockerServer localhostServer
          chai.expect(localDocker.ping().data).to.equal("OK")
