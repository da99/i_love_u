// Generated by CoffeeScript 1.3.3
(function() {
  var Procedure, a_new_noun, as_num, boolean_type_cast, catch_err, clone_list, cloneextend, compare, comparison_type_cast, derive_list, else_false, equals, i_love_u, if_true, insert_into_list, is_boolean_string, md_num, not_equals, procs, prop_of_noun, run_comparison_on_match, to_noun, top_bottom, update_word, while_loop, word_is_word, _, _do_,
    __slice = [].slice;

  Procedure = require('i_love_u/lib/Procedure');

  cloneextend = require("cloneextend");

  _ = require('underscore');

  i_love_u = null;

  to_noun = function(n) {
    n.is_a_noun = function() {
      return true;
    };
    n.add_user_method = function(name, meth) {
      return this["user_method_" + name] = meth;
    };
    n.is_user_method = function(name) {
      return !!this["user_method_" + name];
    };
    n.call_user_method = function() {
      var args, name;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this["user_method_" + name].apply(this, args);
    };
    return n;
  };

  md_num = new Procedure("!>NUM< !>CHAR< !>NUM<");

  md_num.position('top');

  md_num.procedure(function(match) {
    var m, n, op;
    m = match.args()[0];
    op = match.args()[1];
    n = match.args()[2];
    switch (op) {
      case '*':
        return parseFloat(m) * parseFloat(n);
      case '/':
        return parseFloat(m) / parseFloat(n);
      default:
        return match.is_a_match(false);
    }
  });

  as_num = new Procedure("!>NUM< !>CHAR< !>NUM<");

  as_num.procedure(function(match) {
    var m, n, op;
    m = match.args()[0];
    op = match.args()[1];
    n = match.args()[2];
    switch (op) {
      case '+':
        return parseFloat(m) + parseFloat(n);
      case '-':
        return parseFloat(m) - parseFloat(n);
      default:
        return match.is_a_match(false);
    }
  });

  word_is_word = new Procedure("!>WORD< is: !>ANY<.");

  word_is_word.procedure(function(match) {
    var name, val;
    name = _.first(match.args());
    val = _.last(match.args());
    match.line().calling_env().write().push(function(mess) {
      mess.name(name);
      return mess.value(val);
    });
    return val;
  });

  clone_list = new Procedure("a clone of !>List<");

  clone_list.position("top");

  clone_list.procedure(function(match) {
    var env, list;
    list = _.first(match.args());
    env = match.env();
    return $.extend(true, {}, clone);
  });

  derive_list = new Procedure("a derivative of !>List<");

  derive_list.position("top");

  derive_list.procedure(function(match) {
    var env, list;
    list = _.first(match.args());
    env = match.env();
    return new list();
  });

  update_word = new Procedure("Update !>WORD< to: !>ANY<.");

  update_word.procedure(function(match) {
    var name, val;
    name = _.first(match.args());
    val = _.last(match.args());
    match.env().update_name_and_value(name, val);
    return val;
  });

  if_true = new Procedure("If !>true_or_false<:");

  if_true.procedure(function(match) {
    var ans, luv, raw_val;
    raw_val = match.args()[0];
    if (!is_boolean_string(raw_val)) {
      return match.is_a_match(false);
    }
    ans = boolean_type_cast(raw_val);
    if (ans === true) {
      luv = new i_love_u(match.line().block(), match.env());
      luv.run();
    }
    match.env().push(Var.new_local("last-if-value", ans));
    return ans;
  });

  else_false = new Procedure("else:");

  else_false.procedure(function(match) {
    var luv;
    if (match.env().get_or_throw('last-if-value').value() === false) {
      luv = new i_love_u(match.line().block(), match.env());
      luv.run();
      return false;
    } else {
      return true;
    }
  });

  catch_err = function(msg, func) {
    var err;
    err = null;
    try {
      func();
    } catch (e) {
      err = e;
    }
    if (!err) {
      return true;
    }
    if (err.message.indexOf(msg) > -1) {
      return false;
    } else {
      throw err;
    }
  };

  run_comparison_on_match = function(op, r, l, match) {
    var known_type, val;
    val = null;
    known_type = catch_err("Can't convert value into type for comparison", function() {
      return val = compare(op, r, l);
    });
    if (known_type) {
      return val;
    } else {
      return match.is_a_match(false);
    }
  };

  is_boolean_string = function(v) {
    return v === 'true' || v === 'false';
  };

  boolean_type_cast = function(v) {
    if (!is_boolean_string(v)) {
      throw new Error("Can't be converted to boolean: " + v);
    }
    if (v === "true") {
      return true;
    } else {
      return false;
    }
  };

  comparison_type_cast = function(v) {
    return v = (function() {
      if (_.isString(v)) {
        if (v === is_boolean_string(v)) {
          return boolean_type_cast(v);
        } else if (!_.isNaN(v)) {
          return parseFloat(v);
        } else {
          return v;
        }
      } else if (_.isNumber(v)) {
        return v;
      } else if (_.isBoolean(v)) {
        return v;
      } else {
        throw new Error("Can't convert value into type for comparison: " + v);
      }
    })();
  };

  compare = function(op, raw_r, raw_l) {
    var ans, l, r;
    r = comparison_type_cast(raw_r);
    l = comparison_type_cast(raw_l);
    ans = (function() {
      switch (op) {
        case ">":
          return r > l;
        case "<":
          return r < l;
        case ">=":
          return r >= l;
        case "<=":
          return r <= l;
        case "===":
          return r === l;
        case "!==":
          return r !== l;
        default:
          throw new Error("Unknown comparison operation: " + op + " for " + r + ", " + l);
      }
    })();
    return ans;
  };

  not_equals = new Procedure("!>ANY< not equal to !>ANY<");

  not_equals.position('bottom');

  not_equals.procedure(function(match) {
    var l, r;
    r = match.args()[0];
    l = match.args()[1];
    return run_comparison_on_match("!==", r, l, match);
  });

  equals = new Procedure("!>ANY< equals !>ANY<");

  equals.position('bottom');

  equals.procedure(function(match) {
    var l, r;
    r = match.args()[0];
    l = match.args()[1];
    return run_comparison_on_match("===", r, l, match);
  });

  _do_ = new Procedure("Do:");

  _do_.procedure(function(match) {
    var b, block, env, luv, v;
    block = match.line().block();
    env = match.env();
    luv = new i_love_u(block, env);
    luv.run();
    v = new Var;
    b = match.env().push(Var.new_local("last-do-value", true));
    match.env().push(Var.new_local("last-do-block", block));
    return true;
  });

  while_loop = new Procedure("While !>true_or_false<.");

  while_loop.procedure(function(match) {
    var ans, block, env, prev;
    env = match.env();
    prev = _.last(env.scope());
    ans = match.args()[0];
    block = prev && prev.from_do ? prev.block : match.line().block();
    if (!block) {
      return match.is_a_match(false);
    }
    if (ans) {
      env.record_loop(match.line().origin_line_text());
      (new i_love_u(block, env)).run();
      env.run_line_tokens([match.line().origin_line(), block]);
    }
    env.update_or_push(Var.new_local("last-while-loop", ans));
    return ans;
  });

  a_new_noun = new Procedure("a new !>Noun<");

  a_new_noun.procedure(function(match) {
    var env, noun;
    env = match.env();
    noun = match.args()[0];
    return cloneextend.clone(noun);
  });

  prop_of_noun = new Procedure("the !>WORD< of !>WORD<");

  prop_of_noun.procedure(function(match) {
    var env, method, noun, noun_name;
    env = match.env();
    method = match.args()[0];
    noun_name = match.args()[1];
    if (!env.is_name_of_data(noun_name)) {
      return match.is_a_match(false);
    }
    noun = env.data(noun_name);
    if (!(typeof noun.is_a_noun === "function" ? noun.is_a_noun() : void 0)) {
      return match.is_a_match(false);
    }
    if (!noun.is_user_method(method)) {
      return match.is_a_match(false);
    }
    return noun.call_user_method(method);
  });

  insert_into_list = new Procedure("Insert at the !>WORD< of !>Noun<: !>ANY<.");

  insert_into_list.procedure(function(match) {
    var env, list, pos, val;
    env = match.env();
    pos = match.args()[0];
    list = match.args()[1];
    val = match.args()[2];
    if (!list.insert || !(pos === 'top' || pos === 'bottom')) {
      return match.is_a_match(false);
    } else {
      list.insert(pos, val);
      return val;
    }
  });

  top_bottom = new Procedure("!>Noun<, from top to bottom as !>WORD<:");

  top_bottom.procedure(function(match) {
    var block, env, noun, pos, pos_name;
    noun = match.args()[0];
    pos_name = match.args()[1];
    block = match.line().block();
    env = match.env();
    pos = noun.target().position();
    to_noun(pos);
    pos.add_user_method("value", function() {
      return this.value();
    });
    env.add_data(pos_name, pos);
    if (pos.is_at_bottom()) {
      return false;
    }
    while (true) {
      (new i_love_u(block, env)).run();
      if (pos.is_at_bottom()) {
        break;
      }
      pos.downward();
    }
    return true;
  });

  procs = {};

  procs.i_love_u = function(ilu) {
    ilu.vars().push_name_and_value('if_true', if_true);
    ilu.vars().push_name_and_value('else_false', else_false);
    ilu.vars().push_name_and_value('as_num', as_num);
    ilu.vars().push_name_and_value('md_num', md_num);
    ilu.vars().push_name_and_value('word_is_word', word_is_word);
    ilu.vars().push_name_and_value('update_word', update_word);
    ilu.vars().push_name_and_value('clone_list', clone_list);
    ilu.vars().push_name_and_value('derive_list', derive_list);
    ilu.vars().push_name_and_value('not_equals', not_equals);
    ilu.vars().push_name_and_value('equals', equals);
    ilu.vars().push_name_and_value('while_loop', while_loop);
    ilu.vars().push_name_and_value('_do_', _do_);
    ilu.vars().push_name_and_value('a_new_noun', a_new_noun);
    ilu.vars().push_name_and_value('prop_of_noun', prop_of_noun);
    ilu.vars().push_name_and_value('insert_into_list', insert_into_list);
    return ilu.vars().push_name_and_value('top_bottom', top_bottom);
  };

  module.exports = procs;

}).call(this);
