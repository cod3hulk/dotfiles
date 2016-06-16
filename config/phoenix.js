var hyper = ['alt', 'cmd'];
var keys = [];

const DEBUG = true;
function debug(message) {
  if (!DEBUG) return;
  if (typeof message == 'string') Phoenix.log(message);
  else Phoenix.log(JSON.stringify(message));
};


// move window left
keys.push(Phoenix.bind('h', hyper, function() {
  var window = Window.focusedWindow();
  if (!window) return;
  var screen = window.screen();
  var frame = screen.visibleFrameInRectangle();
  var size = {
    width: frame.width/2, 
    height: frame.heigt
  };
  var pos = {
    x: 0,
    y: 0
  };
  window.setSize(size);
  window.setTopLeft(pos);
}));

// move window right
keys.push(Phoenix.bind('l', hyper, function() {
  var window = Window.focusedWindow();
  if (!window) return;
  var screen = window.screen();
  var frame = screen.visibleFrameInRectangle();
  var size = {
    width: Math.round(frame.width/2), 
    height: frame.heigt
  };
  var pos = {
    x: Math.round(frame.width/2),
    y: 0
  };
  window.setSize(size);
  window.setTopLeft(pos);
}));

// maximize window
keys.push(Phoenix.bind('k', hyper, function() {
  var window = Window.focusedWindow();
  if (!window) return;
  window.maximize();
}));
