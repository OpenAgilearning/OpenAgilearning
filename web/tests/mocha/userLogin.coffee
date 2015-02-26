if Meteor.isClient
  MochaWeb?.testOnly ->
    describe "Meetup Login (Client)", ->
      before ->
        meetupServiceData = Package['service-configuration'].ServiceConfiguration.configurations.findOne({service:"meetup"})

        if not meetupServiceData
          configuration = { "service" : "meetup", "clientId" : "YOUR_OWN_ID", "secret" : "YOUR_SECRET", "loginStyle" : "redirect" }
          serviceName = "meetup"
          loginButtonsSession = Accounts._loginButtonsSession

          Accounts.connection.call "configureLoginService", configuration, (error, result)->
            if error
              Meteor._debug "Error configuring login service " + serviceName, error
            else
              loginButtonsSession.set 'configureLoginServiceDialogVisible', false



      it "service-configuration has meetup data", ->
        meetupServiceData = Package['service-configuration'].ServiceConfiguration.configurations.findOne({service:"meetup"})
        chai.expect(meetupServiceData).not.to.be.null



if Meteor.isServer
  MochaWeb?.testOnly ->
    describe "init Users and Courses", ->
      before ->
        Meteor.users.remove {}

        fs = Meteor.npmRequire 'fs'

        wholeJsonText = fs.readFileSync(process.env.PWD + "/private/users.json", 'utf8')
        for jsonText in wholeJsonText.split("\n")
          try
            data = JSON.parse(jsonText.replace("$date","date"))
            # data.createdAt = new Date data.createdAt["$date"]
            if Meteor.users.find({_id:data._id}).count() is 0
              Meteor.users.insert data
            # console.log data
          catch e
            console.log "[MochaTest][init Users and Courses]"
            console.log "error = ", e



        Fixture.Courses.forceClear()
        Fixture.Courses.set()


      it "check Meteor.users has data", ->
        chai.assert Meteor.users.find().count()>0, "Meteor.users has data"

      it "check db.courses has data", ->
        chai.assert db.courses.find().count()>0, "db.courses has data"



#     Package['service-configuration'].ServiceConfiguration.configurations.remove({service:"meetup"})
