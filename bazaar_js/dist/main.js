(() => {
  // output/bazaar_js/ffi.mjs
  function init(url) {
    return {
      ws: {
        contents: 0
      },
      url
    };
  }
  function connect(t) {
    t.ws.contents = new WebSocket(t.url);
  }
  function send(t, data) {
    t.ws.contents.send(data);
  }
  var $$WebSocket$2 = {
    init,
    connect,
    send
  };
  var LongPolling = {};
  var Trail = {
    $$WebSocket: $$WebSocket$2,
    LongPolling
  };
  function endpoint(path) {
    var $$location = window.location;
    var protocol = $$location.protocol;
    var protocol$1 = protocol.replace("http", "ws");
    var host = $$location.host;
    return protocol$1 + ("//" + (host + path));
  }
  function make(url, S) {
    var url$1 = endpoint(url);
    return (
      /* LS */
      {
        sock: S,
        state: S.init(url$1),
        url: url$1
      }
    );
  }
  function connect$1(param) {
    var state = param.state;
    var S = param.sock;
    var readyState = document.readyState;
    var do_connect = function(param2) {
      S.connect(state);
    };
    if ([
      "complete",
      "loaded",
      "interactive"
    ].indexOf(readyState) >= 0) {
      return S.connect(state);
    } else {
      document.addEventListener("DOMContentLoaded", do_connect);
      return;
    }
  }
  function send$1(param, data) {
    param.sock.send(param.state, data);
  }
  var LiveSocket = {
    endpoint,
    make,
    connect: connect$1,
    send: send$1
  };
  function bind(socket, root) {
    var elements = root.querySelectorAll("[data-sw-event]");
    elements.forEach(function(el) {
      var id = el.getAttribute("data-sw-el-id");
      var $$event = el.getAttribute("data-sw-event");
      var data = function(id2) {
        return JSON.stringify({ "Event": [id2, ""] });
      };
      var data$1 = data(id);
      el.addEventListener($$event, function(_ev) {
        send$1(socket, data$1);
      });
    });
  }
  function setup(socket) {
    var root = document.querySelector("[sw-root]");
    var observer = new MutationObserver(function(mut_list, _obs) {
      console.log(mut_list);
    });
    observer.observe(root, {
      attributes: true,
      childList: true,
      subtree: true
    });
    bind(socket, root);
  }
  var Sidewinder = {
    LiveSocket,
    bind,
    setup
  };

  // output/bazaar_js/main.mjs
  function main(param) {
    var socket = Sidewinder.LiveSocket.make("/live", Trail.$$WebSocket);
    Sidewinder.LiveSocket.connect(socket);
    Sidewinder.setup(socket);
  }
  main(void 0);
})();
