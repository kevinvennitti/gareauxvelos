///////////////////////////////////
//
// class Item
//
// Cette classe permet de générer
// des obstacles dans la zone de jeu
//
// Note : je n'ai pas eu le temps
// d'activer les collisions avec les obstacles,
// une simple fonction dist()
// avec les rayons du player/item
// est simple à mettre en place

class Item {
  // Position x et y de l'item
  
  float x;
  float y;
  
  // Rayon de l'item + largeur du contour (décor)
  
  float r, rW;
  
  // Type de l'item
  // (initialisé créé pour générer des items bonus,
  //  des obstacles particuliers, etc)
  
  int type;

  Item(int _type) {
    r = random(50, 150);
    rW = random(30, 70);
    x = random(HEIGHT-2*PADDING)+PADDING;
    y = -r*2;
  }

  boolean isOut() {
    // Puisque le player peut revenir en arrière,
    // on supprime les obstacles une fois
    // qu'ils sont assez loin
    
    if (y + r*2 > 2*WIDTH) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    // On déplace l'item
    // selon la vitesse du player
    
    y -= P.velocity.y;
    
    // On anime le contour (décor)
    
    rW -= 1;
    
    if (rW <= 0) { 
      rW = 50;
    }

    pushMatrix();
    
    ellipseMode(CENTER);
    translate(x-P.location.x, y);

    fill(#e13f29);
    stroke(#e13f29, 80);
    strokeWeight(rW);
    
    ellipse(0, 0, r, r);

    popMatrix();
  }
}

