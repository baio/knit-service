// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["ural/vm/itemVM", "app/dataProvider", "ural/modules/pubSub"], function(itemVM, dataProvider, pubSub) {
    var Push;

    return Push = (function(_super) {
      __extends(Push, _super);

      function Push(resource, _index, _graph) {
        var _this = this;

        this._graph = _graph;
        this.dest_user = ko.observable();
        this.dest_graph = ko.observable();
        this.status = ko.observable();
        Push.__super__.constructor.call(this, "push", _index);
        this.displayText = ko.computed(function() {
          return _this.dest_user() + "-" + _this.status();
        });
      }

      Push.prototype.onCreateItem = function() {
        return new Graph(this.resource, this._graph);
      };

      Push.prototype.onCreate = function(done) {
        var data;

        data = this.toData();
        return dataProvider.ajax("pushes", "post", data, done);
      };

      Push.prototype.onRemove = function(done) {
        var data;

        data = this.toData();
        return dataProvider.ajax("pushes", "delete", data, done);
      };

      Push.prototype.onUpdate = function(done) {
        var data;

        data = {
          id: this.ref(),
          name: this.name(),
          contribs: this._contribs.list().filter(function(f) {
            return f.isSelected();
          }).map(function(m) {
            return m.ref();
          })
        };
        return dataProvider.ajax("pushes", "put", data, done);
      };

      return Push;

    })(itemVM);
  });

}).call(this);

/*
//@ sourceMappingURL=push.map
*/
