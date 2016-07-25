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
keys.push(new Key('h', hyper, function() {
  var window = Window.focused();
  if (!window) return;
  var screen = window.screen();
  var frame = screen.visibleFrameInRectangle();
  var size = {
    width: Math.floor(frame.width/2), 
    height: frame.height
  };
  var pos = {
    x: frame.x,
    y: frame.y
  };

  // recompute size and position for next screen
  var curr_pos = window.topLeft();
  var diff = Math.abs((window.size().width) - size.width);
  var delta = 5;
  if (curr_pos.x == pos.x && curr_pos.y == pos.y && diff < delta ) {
    var prev_screen = screen.previous();
    var frame = prev_screen.visibleFrameInRectangle();
    size = {
      width: Math.round(frame.width/2), 
      height: frame.height
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
keys.push(new Key('l', hyper, function() {
  var window = Window.focused();
  if (!window) return;

  // compute size and position
  var screen = window.screen();
  var frame = screen.visibleFrameInRectangle();
  var size = {
    width: Math.round(frame.width/2), 
    height: frame.height
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
      height: frame.height
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
keys.push(new Key('k', hyper, function() {
  var window = Window.focused();
  if (!window) return;
  var width = window.frame().width;
  var height = window.frame().height;
  window.maximize();
  var delta = 10;
  var diff_width = Math.abs(window.size().width - width)
  var diff_height = Math.abs(window.size().height - height);
  if (diff_width < delta && diff_height < delta) {
    var screen = window.screen().next();
    window.setTopLeft(screen.visibleFrameInRectangle());
    window.maximize();
  };
}));

