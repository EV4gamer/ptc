
int[][] grid;
ArrayList<inflictor> inflictors;
ArrayList<vehicle> vehicles;
ArrayList<button> buttons;
ArrayList<sign> signs;

boolean continuePhysics = true;
vehicle player_one;
vehicle player_two;

int currentPlayerIndex = 0;
int buttonHeight;
int physPerFrame = 5;

void setup() {
  size(1600, 900);
  buttonHeight = height / 5;  
  initiateGround(100, 75);  
  initiateButtons(); 

  inflictors = new ArrayList<inflictor>();
  vehicles = new ArrayList<vehicle>();
  buttons = new ArrayList<button>();
  signs = new ArrayList<sign>();

  vehicle player_one = new vehicle(new PVector(width / 5, 0), 10, color(0, 0, 200));
  vehicle player_two = new vehicle(new PVector(4 * width / 5, 0), 10, color(200, 0, 0));
  vehicles.add(player_one);
  vehicles.add(player_two);
  player_one.active = true;  

  buttons.add(new button(width / 2, height - buttonHeight / 2, 250, 125, color(255, 140, 20), color(20), "Fire", 50, 20));
  buttons.add(new button(6 * width / 8, height - buttonHeight / 2 + 30, 50, 50, color(255), color(20), "+", 50, 13));
  buttons.add(new button(6 * width / 8 + 60, height - buttonHeight / 2 + 30, 50, 50, color(255), color(20), "-", 50, 13));

  buttons.add(new button(7 * width / 8, height - buttonHeight / 2 + 30, 50, 50, color(255), color(20), "+", 50, 13));
  buttons.add(new button(7 * width / 8 + 60, height - buttonHeight / 2 + 30, 50, 50, color(255), color(20), "-", 50, 13));

  signs.add(new sign(100, 40, 200, 50, color(20), "Player 1", 50, 15, player_one.col));
  signs.add(new sign(width - 100, 40, 200, 50, color(20), "Player 2", 50, 15, player_two.col));

  signs.add(new sign(50, 100, 200, 50, color(20), "100", 50, 15, player_one.col));
  signs.add(new sign(width - 50, 100, 200, 50, color(20), "100", 50, 15, player_two.col));

  signs.add(new sign(width / 8, height - buttonHeight / 2, 50, 50, color(20), "Moves\n5", 30, -37, color(255)));
  signs.add(new sign(6 * width / 8 + 30, height - buttonHeight / 2 - 40, 0, 0, color(50), "Angle", 30, 0, color(255)));
  signs.add(new sign(7 * width / 8 + 30, height - buttonHeight / 2 - 40, 0, 0, color(50), "Power", 30, 0, color(255)));
  signs.add(new sign(6 * width / 8 + 30, height - buttonHeight / 2 - 17, 114, 30, color(20), "0", 30, 11, color(255)));
  signs.add(new sign(7 * width / 8 + 30, height - buttonHeight / 2 - 17, 114, 30, color(20), "0", 30, 11, color(255)));

  signs.add(new sign(0, 35, 20, 20, color(255), " ", 1, 0, color(0)));

  for (int i = 0; i < vehicles.size(); i++) { //check player index
    if (vehicles.get(i).active == true) {
      currentPlayerIndex = i;
      break;
    }
  }
}

void draw() {
  display();

  //update shells
  for (int j = 0; j < physPerFrame; j++) {
    for (int i = 0; i < inflictors.size(); i++) {
      inflictors.get(i).applyForce(new PVector(0, 1));
      inflictors.get(i).update(1.0 / physPerFrame);
      inflictors.get(i).render();
    }
  }

  //update ground
  if (continuePhysics) {
    for (int s = 0; s < 2; s++) {
      iterativeDown();
    }
  }

  //update players
  for (int i = 0; i < vehicles.size(); i++) {
    vehicles.get(i).update(1);
    vehicles.get(i).render();
  }

  //update buttons
  for (int i = 0; i < buttons.size(); i++) {
    buttons.get(i).render();
  }

  //update signs
  for (int i = 0; i < signs.size(); i++) {
    signs.get(i).render();
  }
  signs.get(2).text = str(vehicles.get(0).score); //move these lines to when health is updated instead of here
  signs.get(3).text = str(vehicles.get(1).score);
  signs.get(4).text = "Moves\n"+str(vehicles.get(currentPlayerIndex).movesLeft);
  signs.get(7).text = str((int)(vehicles.get(currentPlayerIndex).angle / TWO_PI * 360));
  signs.get(8).text = str(vehicles.get(currentPlayerIndex).power);

  signs.get(9).x = (currentPlayerIndex == 0 ? 250 : width - 250);

  //set next player in the list to be the active one if currentindexed isnt active
  if (vehicles.get(currentPlayerIndex).active != true) {
    for (int i = 0; i < vehicles.size(); i++) {
      if (i == currentPlayerIndex) {
        vehicles.get(i).active = true;
      } else {
        vehicles.get(i).active = false;
      }
    }
  }

  //purge inflictors when flagged or outside of screen
  if (inflictors.size() > 0) {
    for (int i = inflictors.size() - 1; i >= 0; i--) {
      inflictor infl = inflictors.get(i);
      if ((int)infl.pos.x < 0 || (int)infl.pos.x > width - 1 || (int)infl.pos.y > height - 1) {
        infl.purge = true;
      }
      if((int)infl.pos.y < 0){
        infl.offscreen = true;
      } else {
        infl.offscreen = false;
      }
    }
    for (int i = inflictors.size() - 1; i >= 0; i--) {
      if (inflictors.get(i).purge == true) {
        inflictors.remove(i);
      }
    }
  }

  //check inflictor collision
  if (inflictors.size() > 0) {
    for (int i = inflictors.size() - 1; i >= 0; i--) {
      inflictor infl = inflictors.get(i);
      if (infl.offscreen == false) {
        //ground collision test
        if (grid[(int)infl.pos.x][(int)infl.pos.y] != 0) {
          infl.purge = true;
          sphere((int)infl.pos.x, (int)infl.pos.y, (int)infl.aoe, 0);
          continuePhysics = true;
        }
        
        //vehicle collision test
        for(int j = 0; j < vehicles.size(); j ++){          
          if(j != currentPlayerIndex){
            vehicle v = vehicles.get(j);
            if((int)infl.pos.x > (int)v.pos.x - 40 && (int)infl.pos.x < (int)v.pos.x + 40){ //within width of the player
              if((int)infl.pos.y < (int)v.pos.y && (int)infl.pos.y > (int)v.pos.y - 70){ //within height of the player
                infl.purge = true;
                sphere((int)infl.pos.x, (int)infl.pos.y, (int)infl.aoe, 0);
                continuePhysics = true;
                vehicles.get(currentPlayerIndex).score += 10;
                //v.applyForce(new PVector(infl.vel.x, -abs(infl.vel.y)).mult(10)); //fix the impact force, doesnt work
              }
            }
          }
        }
        
        
      }
    }
  }
}

void mousePressed() {
  for (int i = 0; i < buttons.size(); i++) {
    button b = buttons.get(i);
    if (mouseX > b.x - b.w / 2 && mouseX < b.x + b.w / 2 && mouseY > b.y - b.h / 2 && mouseY < b.y + b.h / 2) { //if mouse in button hitbox
      if (b.pressed == true) {
        b.longPress = true;
      } else {
        b.pressed = true;
      }
    }
  }
}

void mouseReleased() {
  float x = vehicles.get(currentPlayerIndex).pos.x;
  float y = vehicles.get(currentPlayerIndex).pos.y;
  float a = vehicles.get(currentPlayerIndex).angle;
  float p = vehicles.get(currentPlayerIndex).power;

  for (int i = 0; i < buttons.size(); i++) {
    if (buttons.get(i).pressed == true) {

      //do the action the button is related to
      switch(i) {
      case 0: //Fire button       
        inflictor shell = new inflictor(new PVector(x + 100 * cos(a), y - 55 - 100 * sin(a)), new PVector(cos(a), sin(-a)).mult(p).div(10), 10, 10, 10, color(255), 100);
        inflictors.add(shell);
        //currentPlayerIndex = (currentPlayerIndex + 1) % vehicles.size();
        break;
      case 1:
        vehicles.get(currentPlayerIndex).angle += TWO_PI / 36;
        break;
      case 2:
        vehicles.get(currentPlayerIndex).angle -= TWO_PI / 36;
        break;
      case 3:
        vehicles.get(currentPlayerIndex).power++;
        break;
      case 4:
        vehicles.get(currentPlayerIndex).power--;
        break;
      }
    }
  }
  vehicles.get(currentPlayerIndex).power = limit(vehicles.get(currentPlayerIndex).power, 0, 200);

  //reset all buttons to false;
  for (int i = 0; i < buttons.size(); i++) {
    buttons.get(i).pressed = false;
    buttons.get(i).longPress = false;
  }
}

void keyPressed() {

  switch(key) {
  case 'w':
    break;
  case 'a':
    if (vehicles.get(currentPlayerIndex).movesLeft > 0) {
      vehicles.get(currentPlayerIndex).movesToTarget -= width / 20;
      vehicles.get(currentPlayerIndex).movesLeft--;
    }
    break;
  case 's':
    break;
  case 'd':
    if (vehicles.get(currentPlayerIndex).movesLeft > 0) {
      vehicles.get(currentPlayerIndex).movesToTarget += width / 20;
      vehicles.get(currentPlayerIndex).movesLeft--;
    }
    break;
  }
}
