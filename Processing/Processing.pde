//
// Kevin Vennitti (@kevinvennitti)
// Projet "Gare aux vélos !"
// de l'événement Gare Remix 2015
// http://garemixsaintpaul.grandlyon.com/index.php/les-aboyeurs/
// 
// Code Processing qui fait tourner le jeu
// et qui écoute les données Arduino (via Serial)
// Testé avec Processing 2.2.1

import processing.net.*;
import processing.video.*;
import processing.serial.*;   
import java.io.IOException;
import java.util.Date;
import java.util.*; 

// On va faire appel à Arduino
// et à la librairie Serial

Serial port;

// Il est possible d'afficher des données
// dans la console pour vérifier certaines valeurs
// en activant [DEBUG = true];

Boolean DEBUG = false;

// Si vous n'avez pas d'Arduino à disposition,
// vous pouvez désactiver son initialisation
// (vous ne pourrez jouer qu'avec la souris)

// Note : le jeu a été conçu pour récupérer
// deux valeurs (vélo gauche & droit) via Arduino,
// il n'y a aucune garantie que le jeu à la souris
// soit fonctionnel, fun ou même jouable

Boolean useArduino = false;

// Le jeu s'affiche en portrait dans le dispositif,
// et occupe donc l'écran horizontal de votre écran,
// d'où l'inversion des valeurs

int WIDTH = 1280;
int HEIGHT = 720;

// Le PADDING représente les marges affichées
// à gauche et à droite.

// Note : par manque de temps le jour J,
// le PADDING n'affecte que l'affichage des limites
// latérales et non pas les collisions latérales
// déclarées en brut dans le display() de Player

int PADDING = 70;

// Le port Arduino

int ARDUINO_PORT = 5;

// La variable inclinaison est importante
// car elle modifie la direction du player
// en ajoutant sa valeur à l'angle [P.a] du player
// (voir la class Player)

float inclinaison = 0;

// La variable veloSpeed définit
// la vitesse du player dans le jeu

float veloSpeed = 0;

// Ce tableau contient tous les "obstacles"
// qui seront générés dans le jeu

ArrayList<Item> items = new ArrayList();

// Ces deux tableaux contiendront
// les 20 dernières valeurs récupérées
// du Serial Arduino, donc un historique
// sur lequel on détectera la vitesse
// des roues gauches et droites

int[] veloLeftArray = new int[20];
int[] veloRightArray = new int[20];

// Notre player va être défini
// par la classe Player

Player P;

// On utilise une font particulière
// pour le (peu de) HUD du jeu

PFont font;





void setup() {
  size(WIDTH, HEIGHT);

  font = loadFont("OfficinaSanITC-ExtraBold-48.vlw");

  P = new Player();

  if (useArduino) {
    println(Serial.list());

    port = new Serial(this, Serial.list()[ARDUINO_PORT], 9600); 

    port.clear();
    port.bufferUntil('\n');
  } 
  
  else {
    // Si vous n'utilisez pas Arduino,
    // alors on fait avancer le player
    // pour pouvoir tester avec la souris
    
    veloSpeed = 8;
  }

  frameRate(30);
  smooth();
}





void draw() {
  pushMatrix();

  ///////////////////////////////////
  //
  // On fait pivoter l'affichage du jeu
  // à 90°, ce qui entrainera une gymnastique
  // de l'esprit pour positionner tous les éléments

  rotate(radians(-90));
  translate(-HEIGHT, 0);

  ///////////////////////////////////
  //
  // On applique des décors en fond

  background(0);
  fill(#e13f29, 150);
  rect(0, 0, HEIGHT, WIDTH);


  ///////////////////////////////////
  //
  // Puis on redessine la zone de jeu jouable

  fill(0);
  noStroke();
  rect(PADDING-P.location.x, 0, HEIGHT-2*PADDING, WIDTH);


  ///////////////////////////////////
  //
  // Ensuite, on trace deux lignes
  // aux extrémités latérales de la zone jouable

  noFill();
  stroke(#e13f29);
  strokeWeight(3);
  line(PADDING-P.location.x, 0, PADDING-P.location.x, WIDTH);
  line(HEIGHT-PADDING-P.location.x, 0, HEIGHT-PADDING-P.location.x, WIDTH);

  ///////////////////////////////////
  //
  // Pour chaque obstacle, on l'affiche
  // et s'il est en dehors du jeu,
  // on le supprime pour ne pas saturer Processing

  for (int i = items.size () - 1; i >= 0; i--) {
    Item item = items.get(i);
    item.display();
    if (item.isOut()) {
      items.remove(i);
    }
  }

  ///////////////////////////////////
  //
  // On affiche notre player

  P.display();

  ///////////////////////////////////
  //
  // On affiche à la fin
  // les différents éléments du HUD

  fill(255);
  noStroke();
  textFont(font);
  textAlign(CENTER);
  text(P.distance+" mètres franchis !", HEIGHT/2, 280);
  text(""+P.distance/3+" calories brûlées !", HEIGHT/2, 350);

  popMatrix();
}



void mouseMoved() {
  // Pour tester l'inclinaison et l'inertie
  // de l'angle du player, vous pouvez
  // décommenter la ligne suivante
  // et déplacer la souris dans la partie supérieur ou inférieure :

  inclinaison = map(mouseY, 0, HEIGHT, 2, -2);
}





String C;
int veloLeftValue;
int veloRightValue;

void serialEvent(Serial port) {
  if ( port.available() > 0) {
    C = port.readStringUntil('\n');

    // Si Arduino nous renvoie une valeur :

    if (C != null) {

      // On découpe la valeur reçue
      // (rappel : sous la forme ‘xxx,xxx‘)
      // en séparant le texte à gauche de la virgule
      // du texte à droite de la virgule

      String[] values = split(C, ',');

      // Si on a bien récupéré deux valeurs,
      // on va traiter ces données
      // Note : Arduino peut renvoyer
      // une seule valeur au lancement du Processing
      // sous la forme ‘xxx,‘ (ou ‘,xxx‘),
      // d'où la vérification suivante :

      if (values.length == 2) {


        ///////////////////////////////////
        //
        // On stocke nos nouvelles valeurs
        // respectivement dans nos variables
        // en les convertissant en nombres entiers

        veloLeftValue = int(trim(values[0]));
        veloRightValue = int(trim(values[1]));


        ///////////////////////////////////
        //
        // Maintenant, on crée un nouveau tableau temporaire
        // semblable au tableau qui contient
        // les 20 dernières valeurs,
        // pour supprimer la plus ancienne valeur captée
        // (en position [0]),
        // et ajouter celle que l'on vient de capter
        // (en position [19])

        int[] _veloLeftArray = new int[20];

        // Pour cela, on décale les entrées du vrai tableau
        // d'un cran dans le tableau temporaire, sous la forme :

        // _tableauTemp[0] = vraiTableau[1]
        // _tableauTemp[1] = vraiTableau[2]
        // _tableauTemp[2] = vraiTableau[3]
        // ...
        // _tableauTemp[18] = vraiTableau[19]

          // Ainsi, la valeur vraiTableau[0] est exclue par le haut
        // (la plus ancienne valeur donc) en remontant toutes les valeurs…

        for (int i = 0; i < 19; i++) {
          _veloLeftArray[i] = veloLeftArray[i+1];
        }

        // …et en ajoutant la dernière valeur captée
        // à la fin du tableau en position [19]

          _veloLeftArray[19] = veloLeftValue;

        // Enfin, on écrase le vrai tableau
        // par le tableau temporaire
        // pour mettre à jour notre historique
        // des valeurs captées

        veloLeftArray = _veloLeftArray;


        ///////////////////////////////////
        //
        // On réitère avec l'autre valeur

        int[] _veloRightArray = new int[20];

        for (int i = 0; i < 19; i++) {
          _veloRightArray[i] = veloRightArray[i+1];
        }

        _veloRightArray[19] = veloRightValue;
        veloRightArray = _veloRightArray;


        ///////////////////////////////////
        // Enfin, on va se servir de notre nouvel historique
        // des données captées pour intervenir sur le player du jeu

        checkSpeed();
      }
    }
  }
}


int speedLeft, speedRight;


void checkSpeed() {

  // Maintenant que l'on dispose
  // des 20 dernières valeurs captées,
  // on va analyser chaque roue
  // pour définir la vitesse du player
  // ainsi que sa direction


  ///////////////////////////////////
  // 
  // Pour définir la direction du player,
  // on va "convertir" les 20 valeurs en binaire,
  // selon si le light sensor détecte la lumière
  // ou le noir : en calculant le nombre de va-et-vient
  // entre la lumière et le noir pendant 20 valeurs,
  // ou peut quantifier de manière superficielle
  // la vitesse de la roue ; par exemple :

  // La roue n'a pas bougé,
  // le joueur ne pédale pas (à l'arrêt) :
  // ex. 00000000000000000000
  // ex. 11111111111111111111

  // La roue n'a même pas fait un tour complet,
  // le joueur pédale lentement :
  // ex. 00000000001111111111
  // ex. 11111111000000000000

  // La roue a fait plus d'un tour complet,
  // le joueur pédale plus vite :
  // ex. 00001111111110000000
  // ex. 11111111000000000011

  // La roue a fait au moins deux tours complets,
  // le joueur pédale de plus en plus vite :
  // ex. 00001111000011110000
  // ex. 11000111000111000111

  // Plus il y a de passages de 0 à 1 et de 1 à 0,
  // plus le joueur pédale vite :
  // ex. 00110011001100110011
  // ex. 10101010101010101010  (hyperspeed)

  // Cas spéciaux :
  // — si vous avez placé les capteurs
  //   trop près du centre de la roue
  // — si vous avez défini un delay()
  //   trop long dans le code Arduino
  // — si le joueur pédale
  //   à la vitesse de la lumière
  //
  // Vous pouvez récupérer des valeurs extrêmes
  // sous la forme 11111111111111111111
  // car la roue (tournant trop vite)
  // n'a pas le temps de cacher la lumière
  // et le light sensor est toujours éclairé
  // (principe du gris optique)

  // On initialise la variable changesLeft
  // qui contiendra le nombre de va-et-vient 1/0 0/1

  int changesLeft = 0;

  // Aussi, à chaque donnée de l'historique,
  // on va stocker son prédécesseur chronologique
  // pour le comparer ; par défaut,
  // la première valeur à comparer
  // sera la seconde du tableau par rapport
  // à la première, directement définie ici :

  int binOld = veloLeftArray[0];



  ///////////////////////////////////
  //
  // On va checker chacune des 19 valeurs :

  for (int i = 1; i < 19; i++) {

    ///////////////////////////////////
    //
    // Pour bien comprendre la suite :
    // le light sensor nous envoie une valeur
    // de luminosité (entre 0 et 1023),
    // qui est donc propre
    // à l'environnement lumineux,
    // à la position du capteur,
    // à l'intensité de la lumière, etc.
    //
    // Pour notre dispositif, les valeurs
    // évoluaient de 0 (caché) à plus de 50 (éclairé),
    // j'ai donc appliqué un seuil à + ou - 10
    // pour définir notre valeur binaire 0 ou 1
    // Vous aurez donc à étalonner votre seuil

    // Par défaut, notre binaire sera à 0 (caché)

    int bin = 0;

    // Si la valeur Arduino est supérieure
    // au seuil de tolérance que vous définissez,
    // alors notre binaire sera à 1 (éclairé)

    //                   seuil
    //                   VVVV
    if (veloLeftArray[i] > 10) {
      bin = 1;
    }

    // Si le binaire précédent est différent
    // du binaire actuel, alors on incrémente
    // notre variable va-et-vient

    if (bin != binOld) {
      changesLeft++;
    }

    // Surtout, on oublie pas de définir notre binaire
    // comme la nouvelle valeur précédente du prochain binaire :
    //
    // Si notre binaire actuel est 0,
    // alors on comparera 0 à la prochaine valeur
    //
    // Si notre binaire actuel est 1,
    // alors on comparera 1 à la prochaine valeur

    binOld = bin;
  }



  ///////////////////////////////////
  //
  // On applique le même principe
  // pour l'autre roue

  int changesRight = 0;
  int binOldR = veloRightArray[0];

  for (int i = 1; i < 19; i++) {
    int bin = 0;
    if (veloRightArray[i] > 10) {
      bin = 1;
    }

    if (bin != binOldR) {
      changesRight++;
    }

    binOldR = bin;
  }




  ///////////////////////////////////
  //
  // On dispose désormais de deux valeurs
  // qui représentent le nombre de va-et-vient
  // pour chaque roue ; par exemple en reprenant
  // les chaînes précédemment listées :

  // La roue n'a pas bougé,
  // le joueur ne pédale pas (à l'arrêt) :
  // ex. 00000000000000000000  [ 0 changement ]
  // ex. 11111111111111111111  [ 0 changement ]


  // La roue n'a même pas fait un tour complet,
  // le joueur pédale lentement :
  // ex. 00000000001111111111  [ 1 changement ]
  //              /\          
  // ex. 11111111000000000000  [ 1 changement ]
  //            /\            


  // La roue a fait plus d'un tour complet,
  // le joueur pédale plus vite :
  // ex. 00001111111110000000  [ 2 changements ]
  //        /\       /\       
  // ex. 11111111000000000011  [ 2 changements ]
  //            /\        /\  


  // La roue a fait au moins deux tours complets,
  // le joueur pédale de plus en plus vite :
  // ex. 00001111000011110000  [ 4 changements ]
  //        /\  /\  /\  /\
  // ex. 11000111000111000111  [ 6 changements ]
  //      /\ /\ /\ /\ /\ /\


  // Plus il y a de passages de 0 à 1 et de 1 à 0,
  // plus le joueur pédale vite :
  // ex. 00110011001100110011  [ 9 changements ]
  //      /\/\/\/\/\/\/\/\/\
  // ex. 10101010101010101010  [ 19 changements ]
  //      |||||||||||||||||||

  // Par conséquent,
  // plus le joueur va pédaler vite,
  // plus il y aura de changements ;
  // et en comparant les changements
  // du joueur de gauche et de droite,
  // on peut (enfin) faire varier
  // la direction du player dans le jeu


  ///////////////////////////////////
  //
  // Si les deux joueurs
  // pédalent à la même vitesse :
  // 0 == 0
  // 1 == 1
  // 2 == 2
  // 3 == 3
  // 4 == 4
  // ...
  //
  // Alors le player va continuer
  // tout droit dans sa direction actuelle
  //
  // * Techniquement, on va ajouter 0
  //    à son angle, donc il va conserver son angle

  if (changesLeft == changesRight) {
    inclinaison = 0;
  }


  ///////////////////////////////////
  //
  // Si le joueur gauche
  // pédale plus vite que le joueur droit :
  // 1 > 0
  // 2 > 0
  // 2 > 1
  // 3 > 0
  // 3 > 1
  // 3 > 2
  // ...
  //
  // Alors le player va se diriger
  // sur la gauche
  //
  // * Techniquement, on va soustraire
  //   .05 à son angle, donc il va tourner un peu à gauche

  if (changesLeft > changesRight) {
    inclinaison -= .05;
  }


  ///////////////////////////////////
  //
  // Si le joueur droit
  // pédale plus vite que le joueur gauche :
  // 0 < 1
  // 0 < 2
  // 1 < 2
  // 0 < 3
  // 1 < 3
  // 2 < 3
  // ...
  //
  // Alors le player va se diriger
  // sur la droite
  //
  // * Techniquement, on va ajouter
  //   .05 à son angle, donc il va tourner un peu à droite

  if (changesLeft < changesRight) {
    inclinaison += .05;
  }


  ///////////////////////////////////
  //
  // Enfin, on va faire varier la vitesse
  // du player en récupérant la moyenne
  // des changements (donc des vitesses)
  // des deux joueurs

  veloSpeed = (changesLeft+changesRight)/2;
}

