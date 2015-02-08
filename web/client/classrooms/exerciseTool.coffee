
#
#Template.addNewExercise.rendered = ->
#  AutoForm.hooks
#    createNewExecise:
#      before:
#        "createNewExercise":(doc, template)->
#          doc.classroomId = Router.current().params.classroomId
#          doc.createdBy = Meteor.userId()
#          return doc
#
#      onSubmit: (insertDoc, updateDoc, currentDoc) ->
#        @ExercisesSchema.clean currentDoc
#        console.log 'ExercisesSchema doc with auto values', currentDoc
#        @done()
#        false
  

Template.addNewExercise.helpers

    
  ExercisesSchema: ->
    schemaSettings =
      classroomId:
        type: String
        defaultValue: @classroomId
        autoform:
          type: "hidden"
          label:false
      title:
        type: String
        label: "Title"
        max: 200
      createdAt:
        type: Date
        defaultValue: new Date
        autoform:
          type: "hidden"
          label:false
      createdBy:
        type: String
        defaultValue: Meteor.userId()
        autoform:
          type: "hidden"
          label:false
      expectedTime:
        type: Number
        label: "Expected Finish Time"
        defaultValue: 10
        autoform:
          type: "select-radio-inline"
          options: ->
            [
              {label: " 5 mins", value: 5}
              {label: "10 mins", value: 10}
              {label: "20 mins", value: 20}
            ]
      isActive:
        type: Boolean
        defaultValue: true
        autoform:
          type: "hidden"
          label:false

    new SimpleSchema schemaSettings

#Template.addNewExercise.events
#  "onSubmit #createNewExecise":(e, t) ->
#    e.stopPropagation()
#    AutoForm.resetForm "#createNewExecise"
#    
Template.exercisePanelTeacher.helpers
  activeExercise:->
    Exercises.find({isActive:true}, {sort: {createdAt: -1}}).fetch()
  exerciseDone:->
    Exercises.find({isActive:false}, {sort: {createdAt: -1}}).fetch()

Template.exercisePanelTeacher.events
  "click .closeExercise": (e, t) ->
    e.stopPropagation()
    exerciseId = $(e.target).attr "id"
    
    Meteor.call "closeExercise", exerciseId, Router.current().params.classroomId

Template.exercisePanelStudent.helpers
  activeExercise:->
    Exercises.find({isActive:true}, {sort: {createdAt: -1}}).fetch()
  exerciseDone:->
    Exercises.find({isActive:false}, {sort: {createdAt: -1}}).fetch()
    

Template.exercisePanelStudent.events
  "click .doneExercise": (e, t) ->
    e.stopPropagation()
    exerciseId = $(e.target).attr "id"
    Meteor.call "completeExercise", exerciseId, Router.current().params.classroomId
    
  "click .helpExercise": (e, t) ->
    e.stopPropagation()
    exerciseId = $(e.target).attr "id"
    
    Meteor.call "helpExercise", exerciseId, Router.current().params.classroomId
    

Template.exerciseActiveTeacher.helpers
  remaining_time:->
    moment(@createdAt).add(@expectedTime,"minutes")
    
Template.exerciseActiveStudent.helpers
  remaining_time:->
    moment(@createdAt).add(@expectedTime,"minutes")
  I_am_in:(listOfStudents)->
    listOfStudents.some (student)-> student.id is Meteor.userId()
    
  completed_time:(listOfStudents)->
    listOfStudents.filter((student)->student.id is Meteor.userId())[0].completedTime

    
Template.miniThumbRow.helpers
  profile:(arr)->
    Meteor.users.find _id:
      $in: arr.map (user)->user.id