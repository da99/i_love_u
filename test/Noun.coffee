_ = require "underscore"
    
Find_Message_Handler = (noun, k) ->
  ans = []
  if _.has noun, k
    ans = [ noun, noun[k] ]
  else
    return [] unless _.isArray noun["Message Handlers"]
    for v in noun["Message Handlers"]
      target = v[0]
      obj    = v[1]
      if _.has target, k
        ans = [target, target]
      else if _.has obj, k
        ans = [target, obj[k]]
        break
      else
        ans = Find_Message_Handler obj, k
        break if ans.length isnt 0
          

  ans

Find_Key = (noun, k) ->
  ans = []
  if _.has noun, k
    ans.push noun
  else
    return [] unless _.isArray noun["Message Handlers"]
    for v in ans["Message Handlers"]
      target = v[0]
      obj    = v[1]

  ans

Noun_To_Hash = (noun, keys) ->
  ans = 
    keys:      {}
    undefined: []

  for k in keys
    pair = Find_Message_Handler noun, k
    if pair.length is 0
      ans["undefined"].push k
    else
      ans["keys"][k] = { target: pair[0], func: pair[1] }
      
  ans
      
Send_Message = (mess_or_yield_to) ->
  m = if _.isFunction(mess_or_yield_to)
    mess = Core.Noun.New()
    mess_or_yield_to mess
    mess
  else
    mess_or_yield_to
  m
  h = m
  noun = h.original_target
  handler_pair = Find_Message_Handler noun, h.content
  
  m.target = handler_pair[0]
  m.response = handler_pair[1](m)
  m.is_done = true
  m.response

  



# Core = {
  # "Message Handlers": []  
# }

Noun = 
  "New": (mess) ->
    target = (mess and mess.original_target) or Noun
    n = { 
      "Message Handlers": [ [ {}, target ]  ]
    }
    n

# Core.Message = 
  # "response is": (n) ->
    # this._response_ = n
    # this._is_response_ = true
    # n

  # "_is_response_": false
  
  # "is response?": () ->
    # not not this._is_response_

  # "New": (mess) ->
    # n = Core.Noun.New()
    # n["Message Handlers"].unshift Core.Message
    # n["status"] = "last value"
    # n


# Environment = Core.Noun.New()
# Environment["is an env?"] = true

Vehicle = Noun.New()
Vehicle["is a vehicle?"] = true
Car = Send_Message({content: "New", original_target: Vehicle})
Car["Message Handlers"][0][0].this_is_vehicle_target = true
Car["is a car?"] = true


console.log "-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - "
console.log Car
console.log "-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - "
console.log Noun_To_Hash(Car, ['is a vehicle?', "is a car?", "this_is_vehicle_target"])
















