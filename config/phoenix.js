var hyper = ['alt', 'cmd'];
var keys = [];

const DEBUG = true;
function debug(message) {
  if (!DEBUG) return;
  if (typeof message == 'string') Phoenix.log(message);
  else Phoenix.log(JSON.stringify(message));
};


keys.push(Phoenix.bind('j', hyper, function() {
  var window = Window.focusedWindow();
  if (!window) return;
  window.setSize(
      {width: 50.0, height: 50.0}
      );
}));
