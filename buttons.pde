
class button{
  int x, y, w, h;
  boolean pressed;
  boolean longPress;
  color col;
  String text;
  int textSize;
  
  button(int x1, int y1, int w1, int h1, color c, String t, int ts){
    x = x1;
    y = y1;
    w = w1;
    h = h1;
    col = c;
    text = t;
    textSize = ts;
    pressed = false;
    longPress = false;  
  }
  
  void render(){
    rectMode(CENTER);
    stroke(0);
    fill(pressed ? limit(col + 20, 0, 255) : col);
    rect(x, y, w, h);
    fill(255);
    textSize(textSize);
    textAlign(CENTER);
    text(text, x, y + h / 6);
  }
  
  
}
