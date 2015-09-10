_ = require 'lodash'
Promise = require 'when'

module.exports = (System) ->
  Characteristic = System.getModel 'Characteristic'

  preSave = (item) ->
    return item unless item.platform == 'twitter'
    return item if item.attributes?.characteristic?.length > 0
    return item unless item.data?.id_str

    item.attributes = {} unless item.attributes

    tweet = item.data

    chars = []
    chars.push "source: #{tweet.source}"
    if /http/.test tweet.text
      chars.push "has link"
      chars.push "link shared by by: @#{tweet.user.screen_name}"
    if /RT @/.test tweet.text
      chars.push "is retweet"
      chars.push "retweeted by: @#{tweet.user.screen_name}"
    if /(^|\s)@[-A-Za-z0-9_]+(\s|$)/gi.test tweet.text
      chars.push "is mention"

    Characteristic
    .getOrCreateArray chars
    .then (characteristics) ->
      item.attributes.characteristic = _.map characteristics, (c) ->
        c._id ? c
      item

  events:
    activityItem:
      save:
        pre: preSave
