https   = require  'https'
http    = require  'http'
async   = require  'async'
Page    = require './lib/Page'
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] or= '0'

class Confluence
  constructor: (options = {}) ->
    @useSSL   = options.useSSL or true

    @username = options.username or process.env.CONFLUENCE_USERNAME or process.env.ATLASSIAN_USERNAME
    @password = options.password or process.env.CONFLUENCE_PASSWORD or process.env.ATLASSIAN_PASSWORD
    @host     = options.host     or process.env.CONFLUENCE_HOST     or process.env.ATLASSIAN_HOST
    @port     = options.port     or process.env.CONFLUENCE_PORT     or process.env.ATLASSIAN_PORT or (if @useSSL then 443 else 80)
    @context  = options.context  or process.env.CONFLUENCE_CONTEXT  or ''

  page: (page = {}) ->
    return new Page(page)

  getContent:(params, callback) ->
    @XHR "GET", "/content", params, null, callback

  createContent:(params, payload, callback) ->
    @XHR "POST", "/content", params, payload, callback

  getContentById:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}", params, null, callback

  updateContent:(contentId, payload, callback) ->
    @XHR "PUT", "/content/#{contentId}", null, payload, callback

  upsertPage:(searchCQL, payload, callback) ->
    confluence = @
    page = new Page payload
    @advancedSearch searchCQL, {expand: 'version'}, (err, res) ->
      return callback err, res if err
      if res.results[0]?
        page.id = res.results[0].id
        page.version = res.results[0].version
        page.version.number = res.results[0].version.number + 1
        confluence.updateContent page.id, page, (err, res) ->
          return callback err, res
      else
        confluence.createContent null, payload, (err, res) ->
          return callback err, res

  deleteContent:(contentId, callback) ->
    @XHR "DELETE", "/content/#{contentId}", null, null, callback

  getContentHistory:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/history", params, null, callback

  getContentLabels:(contentId, params, callback) ->
    @XHR "GET", "/content/#{contentId}/label", params, null, callback
    
  setContentLabels:(contentId, payload, callback) ->
    @XHR "POST", "/content/#{contentId}/label", null, payload, callback

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
      params = toURL(params)

    payloadString = JSON.stringify(payload)

    options =
      host: @host
      port: @port
      path: "#{@context}/rest/api#{api}#{params}"
      method: method
      auth: "#{@username}:#{@password}"
      headers:
        'Content-Type': 'application/json'
        'Content-Length': payloadString.length

    http = (if @useSSL then https else http)
    req = http.request options, (res) ->
      res.setEncoding 'utf8'
      response = ''

      res.on 'data', (data) ->
        response += data

      res.on 'end', ->
        if res.statusCode != 200
          return callback "Request failed with status code #{res.statusCode}. --  #{options.method} #{options.host}#{options.path}", response
        else
          try
            jsonResponse = JSON.parse(response)
          catch e
            return callback "Could not parse as JSON response. #{e}. --  #{options.method} #{options.host}:#{options.port}#{options.path}"
          return callback null, jsonResponse

    req.on 'error', (e) ->
      return callback "HTTPS ERROR: #{e}"

    req.write payloadString
    req.end

toURL = (obj)->
  '?' + Object.keys(obj).map((k) ->
    encodeURIComponent(k) + '=' + encodeURIComponent(obj[k])
  ).join('&')

module.exports = new Confluence()
