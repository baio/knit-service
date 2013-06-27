// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["ural/vm/itemVM", "app/vm/user/contribs", "app/dataProvider"], function(itemVM, Contribs, dataProvider) {
    var Data;

    return Data = (function(_super) {
      __extends(Data, _super);

      function Data() {
        this.ref = ko.observable();
        this.name = ko.observable();
        this.contribs = new Contribs(this);
      }

      Data.prototype.onLoad = function(filter, done) {
        return dataProvider.get("graphs", filter, done);
      };

      return Data;

    })(itemVM);
  });

}).call(this);

/*
//@ sourceMappingURL=data.map
*/
