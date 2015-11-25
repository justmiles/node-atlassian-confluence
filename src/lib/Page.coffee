#TODO: overwrite @constructor arguments, but don't drop unused values

class Page
  constructor: (p = {}) ->
    @space = p.space or {}
    @body = p.body or {}
    @body.storage = p.body?.storage or {}
    @version = p.version or {}
    @title = p.title or "New p"
    @type = p.type or 'p'
    @space = p.space or {}
    @space.key = p.space?.key if p.space?.key
    @body = p.body or {}
    @body.storage = p.body?.storage or {}
    @body.storage.value = p.body?.storage?.value or ''
    @body.storage.representation  = p.storage?.representation or 'storage'
    @version = p.version or {}
    @version.number = p.version?.number or 1


module.exports = Page