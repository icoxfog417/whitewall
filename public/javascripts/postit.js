// Generated by CoffeeScript 1.6.3
(function() {
  this.Position = (function() {
    function Position(id, top, left) {
      this.id = id;
      this.top = top;
      this.left = left;
    }

    return Position;

  })();

  this.Postit = (function() {
    function Postit() {
      this.id = new Date().getTime();
      this.position = new Position(this.id, 0, 0);
      this.contents = [];
      this.isDelete = false;
    }

    Postit.prototype.toSend = function(method, sender) {
      var p;
      p = new Postit(sender.id);
      switch (method) {
        case MethodType.Move:
          p.position = sender.position;
          break;
        case MethodType.Save:
          p.position = sender.position;
          p.contents = sender.contents;
          break;
        case MethodType.Delete:
          p.isDelete = true;
      }
      return p;
    };

    return Postit;

  })();

  this.MethodType = (function() {
    function MethodType(index) {
      this.index = index;
    }

    MethodType.Move = 0;

    MethodType.Save = 1;

    MethodType.Delete = 2;

    MethodType.prototype.valueOf = function() {
      return this.index;
    };

    return MethodType;

  })();

  this.ContentType = (function() {
    function ContentType(index) {
      this.index = index;
    }

    ContentType.Document = 0;

    ContentType.Link = 1;

    ContentType.Image = 2;

    ContentType.prototype.valueOf = function() {
      return this.index;
    };

    return ContentType;

  })();

  this.Content = (function() {
    function Content(type, value) {
      this.type = type;
      this.value = value;
    }

    return Content;

  })();

}).call(this);
