Accounts.onCreateUser (options, user) ->

  userMeetupId = String(user.services.meetup.id)
  userMeetupToken = user.services.meetup.accessToken

  userProfileUrl = "https://api.meetup.com/2/member/" + userMeetupId + "?&sign=true&photo-host=public&access_token=" + userMeetupToken

  res = Meteor.http.call "GET", userProfileUrl

  resData = JSON.parse res.content

  user.services.meetup.apiData = {}
  _.extend user.services.meetup.apiData, resData

  user.profile = {}

  user.profile.name = resData.name
  user.profile.hometown = resData.hometown
  user.profile.photo = resData.photo
  user.profile.link = resData.link
  user.profile.city = resData.city
  user.profile.country = resData.country
  user.profile.joined = resData.joined
  user.profile.topics = resData.topics
  user.profile.other_services = resData.other_services
  user.profile.email = null

  resume =
    name: resData.name
    hometown: resData.hometown
    link: resData.link
    photo_link : resData.photo?.photo_link
    highres_link : resData.photo?.highres_link
    thumb_link : resData.photo?.thumb_link
    photo_id : resData.photo?.photo_id



  _.map resume, (value, key)->
    db.publicResume.insert
      userId: user._id
      type: "profile"
      key: key
      value: value
      isPublic: true

  user
