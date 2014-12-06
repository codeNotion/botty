if Meteor.isClient
  Meteor.startup ->
    Meteor.loginVisitor()

  Meteor.loginVisitor = ->
    if not Meteor.userId()
      Meteor.call 'createGuest', (err, user) ->
        Meteor.loginWithPassword user.username, user.password

if Meteor.isServer
  Accounts.removeOldGuests = (before) ->
    if typeof before == 'undefined'
      before = new Date()
      before.setHours (before.getHours() - 1)

    Meteor.users.remove
      createdAt: {$lte: before}
      'profile.guest': true


  Meteor.methods
    createGuest: ->
      count = Meteor.users.find().count() + 1
      guestname = "guest-#{count}"

      guest =
        username: guestname
        email: "#{guestname}@xgram.org"
        profile: {guest: true}
        password: Meteor.uuid()

      Accounts.createUser guest

      return guest