//
// Kevin Vennitti (@kevinvennitti)
// Projet "Gare aux vélos !"
// de l'événement Gare Remix 2015
// http://garemixsaintpaul.grandlyon.com/index.php/les-aboyeurs/
// 
// Code Arduino à téléverser sur la carte Arduino
// Testé avec une Arduino Uno
// 
// Schéma technique disponible sur GitHub

// Les pin input sont définis ici,
// il est possible de les modifier
// en adaptant le circuit électronique

const int veloLeft  = A2;
const int veloRight = A4;

// On initialise les variables qui seront
// mises à jour à chaque loop()

int veloLeftValue = 0;
int veloRightValue = 0;

void setup() {
  Serial.begin(9600); 
}

void loop() {
  // On lit les valeurs de chaque light sensor
  
  veloLeftValue = analogRead(veloLeft);        
  veloRightValue = analogRead(veloRight);   

  // On écrit les valeurs captées
  // en les formattant pour Processing,
  // les chaines reçues seront sous la forme :
  // xxx,xxx
  // xxx,xxx
  // xxx,xxx

  Serial.print(veloLeftValue);
  Serial.print(",");
  Serial.println(veloRightValue);
  
  // Le delay() peut etre étalonné
  // selon les valeurs captées
  // (pour en capter + régulièrement ou non)
  
  delay(80);                     
}

