var hyper = ['ctrl', 'cmd'];
var keys = [];

Phoenix.set({
  'openAtLogin': true
});

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
    x: frame.x,
    y: frame.y
  };

  // recompute size and position for next screen
  var curr_pos = window.topLeft();
  if (curr_pos.x == pos.x && curr_pos.y == pos.y) {
    var prev_screen = screen.previous();
    var frame = prev_screen.visibleFrameInRectangle();
    size = {
      width: Math.round(frame.width/2), 
      height: frame.heigt
    };
    pos = {
      x: frame.x + Math.round(frame.width/2),
      y: frame.y
    };
  }

  window.setTopLeft(pos);
  window.setSize(size);
}));

// move window right
keys.push(Phoenix.bind('l', hyper, function() {
  var window = Window.focusedWindow();
  if (!window) return;

  // compute size and position
  var screen = window.screen();
  var frame = screen.visibleFrameInRectangle();
  var size = {
    width: Math.round(frame.width/2), 
    height: frame.heigt
  };
  var pos = {
    x: frame.x + Math.round(frame.width/2),
    y: frame.y
  };

  // recompute size and position for next screen
  var curr_pos = window.topLeft();
  if (curr_pos.x == pos.x && curr_pos.y == pos.y) {
    var next_screen = screen.next();
    var frame = next_screen.visibleFrameInRectangle();
    size = {
      width: frame.width/2, 
      height: frame.heigt
    };
    pos = {
      x: frame.x,
      y: frame.y
    };
  }


  window.setTopLeft(pos);
  window.setSize(size);
}));

// maximize window
keys.push(Phoenix.bind('k', hyper, function() {
  var window = Window.focusedWindow();
  if (!window) return;
  window.maximize();
}));

