
@Collections = {}

@db = {}
@db._AllCollections = new Mongo.Collection "allCollections"


@show = {}
@show

showCollectionsDes =
  get: ->
    db._AllCollections.find().fetch().map (xx)-> xx.name

Object.defineProperty show, "collections", showCollectionsDes


if Meteor.isClient
  @add =
    Role: (userId, group, role)->
      do (userId, group, role)->
        Meteor.call "addRole", userId, group, role, (err, res)->
          if not err
            console.log "[in addRole] res = ", res
          else
            console.log "[in addRole] err = ", err

else
  @add = {}

addCollectionDes =
  set: (input)->

    if typeof input is "string"
      name = input
    else if input instanceof Array
      #FIXME: input.length is 0
      name = input[0]

      if input.length > 1
        opts = input[1]

    else if input instanceof Object
      {name, opts} = input


    if db._AllCollections.find({name:name}).count() is 0
      collectionData =
        _id: "Collection:"+name
        name: name

      if opts
        collectionData.opts = opts

      db._AllCollections.insert collectionData


Object.defineProperty add, "collection", addCollectionDes


OldCollection = Mongo.Collection
NewCollection = class NewCollection extends OldCollection
  constructor: (name, options)->

    if name not in Object.keys db
      super name, options

      if options?.maskName
        db[options.maskName] = @
      else
        db[name] = @

    # if Meteor.isServer
    #   Meteor.defer ->
    #     if db._AllCollections.find({name:name}).count() is 0
    #       collectionData =
    #         _id: "Collection:"+name
    #         name: name

    #       if options
    #         collectionData.options = options

    #       if options?.where
    #         collectionData.where = options.where

    #       else
    #         collectionData.where = "both"

    #       db._AllCollections.insert collectionData

        # else
        #   query =
        #     _id: "Collection:"+name
        #     name: name

        #   collectionData = {}

        #   if options
        #     collectionData.options = options

        #   if options?.where
        #     collectionData.where = options.where

        #   else
        #     collectionData.where = "both"

        #   db._AllCollections.update query, {$set:collectionData}




@Mongo.Collection = NewCollection
@Meteor.Collection = NewCollection
