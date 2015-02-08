@Exercises = new Mongo.Collection "exercises"

#@ExercisesSchema= new SimpleSchema
#  classroomId:
#    type: String
#    autoform:
#      type: "hidden"
#      label:false
#  title:
#    type: String
#    label: "Title"
#    max: 200
#  createdAt:
#    type: Date
#    defaultValue: new Date
#    autoform:
#      type: "hidden"
#      label:false
#  createdBy:
#    type: String
#    autoform:
#      type: "hidden"
#      label:false
#  expectedTime:
#    type: Number
#    label: "Expected Finish Time"
#    defaultValue: 10
#    autoform:
#      type: "select-radio-inline"
#      options: ->
#        [
#          {label: " 5 mins", value: 5}
#          {label: "10 mins", value: 10}
#          {label: "20 mins", value: 20}
#        ]
#  isActive:
#    type: Boolean
#    defaultValue: true
#    autoform:
#      type: "hidden"
#      label:false
#  
#  
#Exercises.attachSchema ExercisesSchema
#    
Meteor.methods
  "createNewExercise": (data) ->
    classroomAndId = "classroom_" + data.classroomId
    loggedInUserId = Meteor.userId()
    
    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Roles.userIsInRole loggedInUserId, "teacher", classroomAndId
      data.createdBy = loggedInUserId
      data.createdAt = new Date()
      
      # FIXME: I have to manually add default value here, since the default value of 10 mins disappeared in quickForm after submitting the form the second time.
      data.expectedTime = 10 unless data.expectedTime in [5,10,20]
      Exercises.insert data
    else
      throw new Meteor.Error(1301, "[Classroom Teacher Error] permision deny, " + loggedInUserId + " is not an Teacher of " + classroomAndId)
      
  "closeExercise": (exerciseId, classroomId) ->
    classroomAndId = "classroom_" + classroomId
    loggedInUserId = Meteor.userId()
    
    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Exercises.find({_id: exerciseId}).count()>0
      if Roles.userIsInRole loggedInUserId, "teacher", classroomAndId
        Exercises.update  {_id: exerciseId},
          $set:
            closedAt: new Date()
            isActive: false
      else
        throw new Meteor.Error(1301, "[Classroom Teacher Error] permision deny, " + loggedInUserId + " is not an Teacher of " + classroomAndId)
    else
      throw new Meteor.Error(1301, "[Delete exercise Error] No record of " + exerciseId " found.")
    
  "completeExercise": (exerciseId, classroomId) ->
    classroomAndId = "classroom_" + classroomId
    loggedInUserId = Meteor.userId()
    
    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Exercises.find({_id: exerciseId}).count()>0
      if Roles.userIsInRole loggedInUserId, "student", classroomAndId
            
        Exercises.update {
          _id: exerciseId
          'completedStudents.id':
            $ne: loggedInUserId},
          $push:
            completedStudents:
              id:loggedInUserId
              # FIXME: Y U No just query user profile at frontend?
              profile: Meteor.user().profile
              completedTime: new Date()
      else
        throw new Meteor.Error(1301, "[Classroom Student Error] permision deny, " + loggedInUserId + " is not an student of " + classroomAndId)
    else
      throw new Meteor.Error(1301, "[Complete exercise Error] No record of " + exerciseId " found.")
      
      
  "helpExercise": (exerciseId, classroomId) ->
    classroomAndId = "classroom_" + classroomId
    loggedInUserId = Meteor.userId()
    
    if not loggedInUserId
      throw new Meteor.Error(401, "You need to login")
    
    if Exercises.find({_id: exerciseId}).count()>0
      if Roles.userIsInRole loggedInUserId, "student", classroomAndId
        Exercises.update {
          _id: exerciseId
          'needHelpStudents.id':
            $ne: loggedInUserId},
          $push:
            needHelpStudents:
              id:loggedInUserId
              # FIXME: Y U No just query user profile at frontend?
              profile: Meteor.user().profile
              askedTime: new Date()
      else
        throw new Meteor.Error(1301, "[Classroom Student Error] permision deny, " + loggedInUserId + " is not an student of " + classroomAndId)
    else
      throw new Meteor.Error(1301, "[Exercise Help Error] No record of " + exerciseId " found.")