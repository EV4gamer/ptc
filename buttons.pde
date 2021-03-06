
class button {
  int x, y, w, h;
  boolean pressed;
  boolean show = true;
  int buttoncol;
  int textcol;
  String text;
  int textSize;
  int textpos;
  boolean stroke = true;
  boolean isSwitch = false;

  button(int x1, int y1, int w1, int h1, int tc, int bc, String t, int ts, int ty) {
    x = x1;
    y = y1;
    w = w1;
    h = h1;
    buttoncol = bc;
    textcol = tc;
    text = t;
    textSize = ts;
    textpos = ty;
    pressed = false;
  }

  void render() {
    rectMode(CENTER);
    if (stroke == true) {
      stroke(black);
    }
    fill(pressed ? buttoncol - darkgrey : buttoncol);
    rect(x, y, w, h);
    fill(textcol);
    textSize(textSize);
    textAlign(CENTER);
    text(text, x, y + textpos);
  }
}

class sign {
  String text;
  int x, y, w, h;
  color col;
  int textSize;
  int textpos;
  color textcol;

  sign(int x1, int y1, int w1, int h1, color c, String t, int ts, int ty, color tc) {
    x = x1;
    y = y1;
    w = w1;
    h = h1;
    col = c;
    text = t;
    textSize = ts;
    textpos = ty;
    textcol = tc;
  }

  void render() {
    noStroke();
    rectMode(CENTER);
    textAlign(CENTER);
    textSize(textSize);
    fill(col);
    rect(x, y, w, h);
    fill(textcol);
    text(text, x, y + textpos);
  }
}
