@Fixture.Community =
  data: ->
    # [
    #   {
    #     _id: "Community:TW.R"
    #     name : "Taiwan R user group"
    #     pic_url : "http://photos4.meetupstatic.com/photos/event/5/4/0/8/global_260721512.jpeg"
    #     description : "R 是目前最紅的 Open Source 統計語言，而且，不只是對於傳統的統計檢定來說，或是，對於新世代的 Machine Learning 和 Data Mining 的許多技術而言，R 都有很完整的套件支援。因此，可以很快速的在R上面運用各種 Machine Learning 的技術來分析資料。"
    #     createdAt : new Date()
    #   }
    #   {
    #     _id: "Taishin"
    #     name : "台新國際商業銀行"
    #     pic_url : "http://upload.wikimedia.org/wikipedia/zh/thumb/b/b2/Taishin.svg/225px-Taishin.svg.png"
    #     description : "台新國際商業銀行，金融機構代號：812，是台灣的商業銀行之一，現為台新金融控股公司旗下之子公司。共計有總行營業部、信託部、國外部、OBU等四個營業部門。"
    #     createdAt : new Date()
    #   }
    # ]
    [
      [
        {communityId: "Community:TW.R", key: "name", value: "Taiwan R user group" , isPublic: true}
        {communityId: "Community:TW.R", key: "pic_url", value: "http://photos4.meetupstatic.com/photos/event/5/4/0/8/global_260721512.jpeg" , isPublic: true}
        {communityId: "Community:TW.R", key: "description", value: "R 是目前最紅的 Open Source 統計語言，而且，不只是對於傳統的統計檢定來說，或是，對於新世代的 Machine Learning 和 Data Mining 的許多技術而言，R 都有很完整的套件支援。因此，可以很快速的在R上面運用各種 Machine Learning 的技術來分析資料。" , isPublic: true}
        {communityId: "Community:TW.R", key: "createdAt", value: new Date() , isPublic: true}

        {communityId: "Taishin", key: "name", value: "台新國際商業銀行", isPublic: true}
        {communityId: "Taishin", key: "pic_url", value: "http://upload.wikimedia.org/wikipedia/zh/thumb/b/b2/Taishin.svg/225px-Taishin.svg.png", isPublic: true}
        {communityId: "Taishin", key: "description", value: "台新國際商業銀行，金融機構代號：812，是台灣的商業銀行之一，現為台新金融控股公司旗下之子公司。共計有總行營業部、信託部、國外部、OBU等四個營業部門。", isPublic: true}
        {communityId: "Taishin", key: "createdAt", value: new Date(), isPublic: true}
     ],[
        {_id:"Community:TW.R"}
        {_id:"Taishin"}
     ]
    ]

  set: ->
    if db.communities.find().count() is 0 and
    db.communityIds.find().count() is 0 and
    Meteor.settings.public.environment isnt "production"

      db.communities.insert community for community in @data()[0]

      db.communityIds.insert id for id in @data()[1]

  clear: ->
    db.communities.remove community for community in @data()[0]
    db.communityIds.remove id for id in @data()[1]

  reset: ->
    @clear()
    @set()

Fixture.Community.set()
