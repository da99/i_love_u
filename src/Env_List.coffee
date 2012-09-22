rw = require 'rw_ize'

class Env_List
  
  this['Local-Env'] = () ->
    'Local-Env'
    
  this['Outside-Env'] = ()->
    'Outside-Env'

  rw.ize this
  @read_able 'read', 'write', 'outside', 'local'

  constructor: (local, outside) ->
    @rw 'local', local
    @rw 'outside', outside
    @rw 'read' , (outside || local)
    @rw 'write', local
    
  has_outside: () ->
    @outside() and @outside() isnt "none"

  is_local_only: () ->
    (not @has_outside()) or (@read() is @local() and @write() is @local())

  is_read_local: () ->
    @local() is @read()

  is_write_local: () ->
    @local() is @write()

  read: (name) ->
    return @rw('read') if arguments.length is 0
    change_env 'read', name

  write: (name) ->
    return @rw('write') if arguments.length is 0
    change_env 'write', name

  change_env: (r_or_w, name) ->
    if Env_List[name]
      @rw r_or_w, Env_List[name]()
    else
      throw new Error "Unknown env called: #{name}"
      
module.exports = Env_List
