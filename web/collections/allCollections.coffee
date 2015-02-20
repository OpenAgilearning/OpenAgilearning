
@Collections = {}

@db = {}
@db._AllCollections = new Mongo.Collection "allCollections"


@show = {}
@show

showCollectionsDes = 
  get: ->
    db._AllCollections.find().fetch().map (xx)-> xx.name

Object.defineProperty show, "collections", showCollectionsDes


@add = {}

addCollectionDes = 
  set: (name)->
    if db._AllCollections.find({name:name}).count() is 0
      collectionData = 
        _id: "Collection:"+name
        name: name

      db._AllCollections.insert collectionData

Object.defineProperty add, "collection", addCollectionDes


OldCollection = Mongo.Collection
NewCollection = class NewCollection extends OldCollection
  constructor: (name,options)->
    if db._AllCollections.find({name:name}).count() is 0
      collectionData = 
        _id: "Collection:"+name
        name: name

      db._AllCollections.insert collectionData

    if name not in Object.keys db
      super name, options
      db[name] = @
    else
      db[name]


@Mongo.Collection = NewCollection
@Meteor.Collection = NewCollection
