if Meteor.isServer
  MochaWeb?.testOnly ->
    describe "Docker", ->
      describe "localhost Docker Server", ->

        it "db.dockerServers should have localhost", ->
          chai.assert db.dockerServers.find({_id:"localhost"}).count() > 0, "db.dockerServers have a data with _id is localhost"
