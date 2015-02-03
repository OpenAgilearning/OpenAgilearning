if Meteor.isClient
  MochaWeb?.testOnly ->
    describe "Demo tests", ->
      describe "Simple Arithmetics", ->
        it "should be 2 when adding 1 to 1", ->
          chai.assert.equal 2, (1 + 1)
#        it "should fail when you dishonored 5566!", ->
#          chai.assert.equal 426, 5566


if Meteor.isServer
  MochaWeb?.testOnly ->
    describe "Demo tests", ->
      describe "Server can do simple arithmetics, too.", ->
        it "should be 2 when adding 1 to 1", ->
          chai.assert.equal 2, (1 + 1)