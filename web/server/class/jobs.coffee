
new Mongo.Collection "testJobs"

@defaultJobHandlers =
  "TODO": (jobObject)->
    console.log "[in defaultJobHandlers with Status TODO]"
    console.log "[in defaultJobHandlers jobObject._data]", jobObject._data

    finishedAtKey = ["finished", jobObject.status, "At"].join "_"

    updateData =
      status: "DOING"

    updateData[finishedAtKey] = new Date

    jobObject.collection.update {_id:jobObject.id}, {$set:updateData}


  "DOING": (jobObject)->
    console.log "[in defaultJobHandlers with Status DOING]"
    console.log "[in defaultJobHandlers jobObject._data]", jobObject._data

    finishedAtKey = ["finished", jobObject.status, "At"].join "_"

    updateData =
      status: "DONE"

    updateData[finishedAtKey] = new Date

    jobObject.collection.update {_id:jobObject.id}, {$set:updateData}


  "DONE": (jobObject)->
    console.log "[in defaultJobHandlers with Status DONE]"
    console.log "[in defaultJobHandlers jobObject._data]", jobObject._data

    finishedAtKey = ["finished", jobObject.status, "At"].join "_"

    updateData =
      status: "FINISHED"

    updateData[finishedAtKey] = new Date

    jobObject.collection.update {_id:jobObject.id}, {$set:updateData}


  "FINISHED": (jobObject)->
    console.log "[in defaultJobHandlers with Status FINISHED]"
    console.log "[in defaultJobHandlers jobObject._data]", jobObject._data


@Class.Job = class Job
  _jobHandlers: defaultJobHandlers
  collection: db.testJobs

  constructor: (@_data)->
    tmpData = @_data

    if typeof @_data is "string"

      @_data = @collection.findOne {$or:[{_id:@_data}, {name:@_data}]}

      if not @_data

        defaultJobData =
          name: tmpData
          status: "TODO"
          createdAt: new Date

        jobId = @collection.insert defaultJobData

        @_data = @collection.findOne _id:jobId



    handsOnApis =
      id:
        desc:
          get: ->
            @._data._id

      status:
        desc:
          get: ->
            @._data.status

      updateData:
        desc:
          get: ->
            if @id
              @_data = @collection.findOne _id:@id


      handle:
        desc:
          get: ->
            if @status in Object.keys(@_jobHandlers)
              @_jobHandlers[@status](@)
              @updateData



    for api in Object.keys(handsOnApis)
      Object.defineProperty @, api, handsOnApis[api].desc




  setJobHandlers: (jobHandlers) ->
    @_jobHandlers = _.extend @_jobHandlers, jobHandlers






