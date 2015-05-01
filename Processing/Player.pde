///////////////////////////////////
//
// class Player
//
// Cette classe permet de générer
// le joueur et (plus tard) d'envisager
// potentiellement du multijoueur,
// un mode "fantôme" des anciens joueurs, etc.

class Player {
  float x;
  float y;
  float w;
  float h;
  float a;
  int maxScore, distance;
  PShape svg;
  PVector location, velocity;

  Player() {
    w = 60;
    h = 60;
    a = 270;

    location = new PVector(0, 0);
    velocity = new PVector(cos(radians(a))*veloSpeed, sin(radians(a))*veloSpeed);

    svg = loadShape("player.svg");
  }

  void display() {
    a += inclinaison;

    if (a >= 360) {
      a = 0+360-a;
    }
    if (a < 0) {
      a = 360+a;
    }

    velocity = new PVector(cos(radians(a))*veloSpeed, sin(radians(a))*veloSpeed);
    location.add(velocity);    
    location.x = constrain(location.x, -(HEIGHT-PADDING*2)/4, (HEIGHT-PADDING*2)/4);
  
    // Si le player bat son record
    // en avancant dans le bon sens,
    // on met à jour le record :
     
    if (int(abs(location.y)) > maxScore) {
      maxScore = int(abs(location.y));
      distance = maxScore/30;
      
      // On génère des obstacles
      // tous les 20
      // (à largement améliorer)
      
      if (distance % 20 == 0) {
        if (random(1) > .85) {
          items.add(new Item(1));
        }
      }
    }

    pushMatrix();
    
    ellipseMode(CENTER);
    shapeMode(CENTER);    
    translate(location.x+HEIGHT/2, WIDTH-100);
    noStroke();
    fill(255);
    rotate(radians(a+90));
    
    shape(svg);
    
    popMatrix();
  }
}

