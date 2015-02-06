if Meteor.isClient
  MochaWeb?.testOnly ->
    describe "Demo tests", ->
      describe "Simple Arithmetics", ->
        it "should be 2 when adding 1 to 1", ->
          chai.assert.equal 2, (1 + 1)
        it "should fail when you dishonored 5566!", ->
          chai.assert.equal 5566, 5566

    describe "classroom", ->
      
      describe "student list for admin", ->
        it "should exist in the admin tab of classroom."
        it "should show a list of students."
        it "should let admin to add/remove teachers and admins."
        it "should not interrupt other user, other user should still access the classroom without loading forever."
        it "should not show users who are not enrolled in the classroom."
        

if Meteor.isServer
  MochaWeb?.testOnly ->
    describe "Demo tests", ->
      describe "Server can do simple arithmetics, too.", ->
        it "should be 2 when adding 1 to 1", ->
          chai.assert.equal 2, (1 + 1)