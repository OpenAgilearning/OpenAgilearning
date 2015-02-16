if Feedback.find().count() is 0 and Meteor.settings.public.environment isnt "production"
  feedbacks_fixture =[
    { "type" : "w", "title" : "I wish the platform serve cakes", "description" : "cake like giant castle", "createdBy" : "MjSZYPJm6YMevQAW9", "createdAt" : new Date() }
    { "type" : "b", "title" : "A bugggggg!!!!!", "description" : "burn it with fireee!!", "createdBy" : "MjSZYPJm6YMevQAW9", "createdAt" : new Date() }
    { "type" : "w", "title" : "Would you like to build a snow man?", "description" : "with 10 inch tall", "createdBy" : "MjSZYPJm6YMevQAW9", "createdAt" :new Date()}
    { "type" : "b", "title" : "I see aliens invade", "description" : "they looks like spiders", "createdBy" : "MjSZYPJm6YMevQAW9", "createdAt" : new Date() }

  ]
  Feedback.insert feedback for feedback in feedbacks_fixture