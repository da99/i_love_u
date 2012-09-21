

  
module.exports = {}
module.exports.i_love_u = (ilu) ->
    
  ilu.add_data /^Block_Text_Line_[0-9]+$/, (name, env, line) ->
      block = line.block()
      if !block
        throw new Error("Block is not defined.")
      num = parseInt name.split('_').pop()
      val = block.text_line( num )

  ilu.add_data /^Block_List_[0-9]+$/, (name, env, line) ->
      block = line.block()
      if !block
        throw new Error("Block is not defined.")
      num = parseInt name.split('_').pop()
      str = block.text_line( num ).strip()
      tokens = _.flatten( new englishy.Englishy(str + '.').to_tokens() )
      list = []
      for v in tokens
        if v.is_quoted()
          list.push v.value()
        else
          list.push env.get_if_data(v.value(), line)
      list
      
      
  ilu.add_data "List", {
    is_a_noun: () ->
      true
      
    target: () ->
      @_target_ ?= new humane_list()
      
    insert: (pos, val) ->
      @target().push( pos, val )

    values: () ->
      @target().values()
  }
