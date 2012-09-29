XRegExp   = require('xregexp' ).XRegExp
Env       = require "i_love_u/lib/Env"

LOOP_LIMIT   = 10123

if !RegExp.captures
  RegExp.captures= ( r, str ) ->
    r.lastIndex = 0
    match = null
    vals  = []
    pos   = 0
    while (match = XRegExp.exec( str, r, pos, 'sticky') )
      pos = match.index + match[0].length
      match.shift()
      ( vals.push(v) for v in match )
      
    return null if vals.length is 0 
    vals

if !RegExp.first_capture
  RegExp.first_capture= (r, str ) ->
    r.lastIndex = 0
    match = null
    vals  = null
    r.exec(str)

exports.i_love_u = Env



