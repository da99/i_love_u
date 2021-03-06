// Generated by CoffeeScript 1.3.3
(function() {
  var Arguments_Match, funcy_perm, rw, surgeon, _,
    __slice = [].slice;

  rw = require("rw_ize");

  funcy_perm = require("funcy_perm");

  surgeon = require("array_surgeon");

  _ = require("underscore");

  Arguments_Match = (function() {

    rw.ize(Arguments_Match);

    Arguments_Match.read_able("list", "line", "new_line", "slice_desc", "args", "origin_args");

    Arguments_Match.read_write_able_bool("is_a_match", "is_full_match", "is_for_entire_line");

    Arguments_Match.extract_args = function(match, list) {
      var a, args, end, i, slice, start, _i, _len;
      start = match.slice_desc().start_index;
      end = match.slice_desc().end_index;
      slice = match.slice_desc().slice;
      args = [];
      if (slice.length !== list.length) {
        throw new Error("Slice does not match list length: " + slice.length + " != " + list.length + ". Check start and end positions.");
      }
      for (i = _i = 0, _len = list.length; _i < _len; i = ++_i) {
        a = list[i];
        if (!a.is_plain_text()) {
          args.push(slice[i]);
        }
      }
      return args;
    };

    function Arguments_Match(line, proc) {
      var a, a_i, args, desc_slice, f, finders, i, l, limit, list, origin_args, print_it, result, _i, _len, _ref;
      if (arguments.length === 1) {
        this.rw("line", arguments[0]);
        return this;
      }
      this.rw("list", proc.args_list().list());
      this.rw("line", line);
      this.rw("args", []);
      this.rw("origin_args", []);
      if (proc.args_list().is_block_required()) {
        if (!this.line().block()) {
          return null;
        }
      }
      f = _.first(this.list());
      l = _.last(this.list());
      if (f.is_start()) {
        if (l.is_end() || (l.is_splat && l.is_splat())) {
          this.is_for_entire_line(true);
        }
      }
      list = this.list();
      finders = [];
      print_it = false;
      args = [];
      origin_args = [];
      desc_slice = null;
      _ref = this.list();
      for (a_i = _i = 0, _len = _ref.length; _i < _len; a_i = ++_i) {
        a = _ref[a_i];
        finders.push(function(v, i, fi) {
          var arg, extracted, last_i;
          arg = list[fi];
          if (!arg) {
            return false;
          }
          if (!(arg.is_splat && arg.is_splat())) {
            if (arg.is_start()) {
              if (i !== 0) {
                return false;
              }
            }
            if (arg.is_end()) {
              last_i = line.line().length - 1;
              if (i !== last_i) {
                return false;
              }
            }
          }
          extracted = arg.extract_args(v, line);
          if (!extracted) {
            args = [];
            origin_args = [];
            return false;
          }
          if (extracted.length) {
            args.splice.apply(args, [args.length, 0].concat(__slice.call(extracted[0])));
            origin_args.splice.apply(origin_args, [origin_args.length, 0].concat(__slice.call(extracted[1])));
          }
          return true;
        });
        if (a.is_splat && a.is_splat()) {
          _.last(finders).is_splat = true;
        }
      }
      i = 0;
      limit = line.line().length - finders.length;
      while (true) {
        desc_slice = surgeon(line.line()).describe_slice(finders, i);
        if (desc_slice) {
          this.is_a_match(true);
          this.rw("new_line", line.line());
          this.rw("slice_desc", desc_slice);
          this.rw("args", args);
          this.rw("origin_args", origin_args);
          result = proc.procedure()(this);
          if (this.is_a_match()) {
            this.replace(result);
          }
        }
        i += 1;
        if (i > limit || this.is_a_match()) {
          break;
        }
      }
    }

    Arguments_Match.prototype.replace = function(val) {
      var i, l;
      i = this.slice_desc().start_index;
      l = this.slice_desc().length;
      this.new_line().splice(i, l, val);
      this.line().line(this.new_line());
      if (this.is_for_entire_line()) {
        this.is_full_match(true);
      }
      return this.line();
    };

    return Arguments_Match;

  })();

  module.exports = Arguments_Match;

}).call(this);
