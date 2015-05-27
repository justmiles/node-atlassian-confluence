http = require('https')
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

class Confluence
  constructor: () ->
    @username = ''
    @password = ''
    @host = ''
    @context = ''

  getContent:(params, callback) ->
    @XHR "GET", "/content", params, null, callback

  createContent:(params, payload, callback) ->
    @XHR "POST", "/content", params, payload, callback

  getContentById:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}", params, null, callback

  updateContent:(contentId, payload, callback) ->
    @XHR "PUT", "/content/#{contentId}", null, payload, callback

  deleteContent:(contentId, callback) ->
    @XHR "DELETE", "/content/#{contentId}", null, null, callback

  getContentHistory:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/history", params, null, callback

  getContentLabels:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/label", params, null, callback

  getContentChildren:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/child", params, null, callback

  getContentChildByType:(contentId, type, params, callback) ->
    @XHR "GET", "/content/#{contentId}/child/#{type}", params, null, callback

  getContentComments:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/child/comment", params, null, callback

  getContentAttachment:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/child/attachment", params, null, callback

  updateContentAttachment:(contentId, attachmentId, params, callback) ->
    @XHR "PUT", "/content/#{contentId}/child/attachment/#{attachmentId}", params, null, callback

  getSpaces:(params, callback) ->
    @XHR "GET", "/space", params, null, callback

  getSpace:(spaceKey, params, callback) ->
    @XHR "GET", "/space/#{spaceKey}", params, null, callback

  getSpaceContentType:(spaceKey, type, params, callback) ->
    @XHR "GET", "/space/#{spaceKey}/content/#{type}", params, null, callback

  createSpace:(key, name, description, params, callback) ->
    if (!params)
      params = {}
    params.spaceKey = key
    params.name = name
    params.description =
      plain:
        value: description
        representation: 'plain'
    @XHR "POST", "/space", params, null, callback

  simpleSearch: (query, params, callback) ->
    if (!params)
      params = {}
    params.cql = "type=page and title~'#{query}'"
    @XHR "GET", "/content/search", params, null, callback

  advancedSearch:(cql, params, callback) ->
    if (!params)
      params = {}
    params.cql = cql
    @XHR "GET", "/content/search", params, null, callback

  #  utils
  XHR:(method, api, params, payload, callback) ->

    if params == null
      params = ''
    else
      params = params.toURL()

    payloadString = JSON.stringify(payload)

    options =
      host: @host
      path: "#{@context}/rest/api#{api}#{params}"
      method: method
      auth: "#{@username}:#{@password}"
      headers:
        'Content-Type': 'application/json'
        'Content-Length': payloadString.length

    req = http.request options, (res) ->
      res.setEncoding 'utf8'
      response = ''

      res.on 'data', (data) ->
        response += data

      res.on 'end', ->
        if res.statusCode != 200
          console.log "Request failed with status code #{res.statusCode}"
          return callback false
        else
          try
            jsonResponse = JSON.parse(response)
            return callback jsonResponse
          catch e
            console.log "Could not parse as JSON response. #{e}"
            return callback false

    req.on 'error', (e) ->
      console.log "HTTPS ERROR: #{e}"

    req.write payloadString
    req.end

Object::toURL = ->
  obj = this
  '?' + Object.keys(obj).map((k) ->
    encodeURIComponent(k) + '=' + encodeURIComponent(obj[k])
  ).join('&')

module.exports = new Confluence()
