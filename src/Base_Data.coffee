

  
module.exports = {}
module.exports.i_love_u = (ilu) ->
    
   block_text_line_i = new Var 'Block_Text_Line_i', (name, env, line) ->
      block = line.block()
      if !block
        throw new Error("Block is not defined.")
      num = parseInt name.split('_').pop()
      val = block.text_line( num )
  block_text_line_i.regexp /^Block_Text_Line_[0-9]+$/ 
  ilu.vars().push block_text_line_i
  
  
  block_list_i = new Var "Block_List_i", (name, env, line) ->
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
          list.push env.get_if_data (mess) ->
            mess.name v.value()
            mess.line line
      list
  block_list_i.regexp /^Block_List_[0-9]+$/
  ilu.vars().push block_list_i
      
      
  list_noun =
    is_a_noun: () ->
      true
      
    target: () ->
      @_target_ ?= new humane_list()
      
    insert: (pos, val) ->
      @target().push( pos, val )

    values: () ->
      @target().values()
  
  ilu.vars().push (mess) ->
    mess.name "List"
    mess.value list_noun
    
    
    
    
