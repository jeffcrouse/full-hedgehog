

import controlP5.*;
import oscP5.*;
import netP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

OscP5 oscP5;
NetAddress pi;
ControlP5 cp5;
Minim minim;
AudioInput mic;
PitchDetector pitchdetect;

float oscMin = 0;
float oscMax = 1;
float level = 0;
float levelSmoothed = 0;
float smoothing = 10.0;
float amplify = 2;

// ------------------------------------------------------------
void setup() {
  size(500, 500);
  frameRate(25);
  registerPre(this);


  int y = 50;
  cp5 = new ControlP5(this);
  cp5.addRange("OSC value range")
    .setPosition(20, y)
      .setSize(400, 40)
        .setHandleSize(20)
          .setRange(0, 1)
            .setRangeValues(0, 1)
              ;
  y += 50;
  cp5.addSlider("smoothing")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(2, 20.0)
          ;

  y += 50;
  cp5.addSlider("amplify")
    .setPosition(20, y)
      .setSize(400, 40)
        .setRange(0, 5.0)
          ;

  cp5.loadProperties("controler02.properties");

  // Setup OSC stuff
  oscP5 = new OscP5(this, 7000);
  pi = new NetAddress("hedgehog.local", 7000);

  // Setup Audio stuff
  minim = new Minim(this);
  mic = minim.getLineIn(Minim.MONO, 512, 44100);
  pitchdetect = new PitchDetector(); 
  mic.addEffect(pitchdetect);
}

// ------------------------------------------------------------
void pre() {
  level = pitchdetect.getAmplitude() * amplify;

  levelSmoothed += (level-levelSmoothed) / smoothing;


  OscMessage msg = new OscMessage("/level");
  msg.add( levelSmoothed );
  oscP5.send(msg, pi);
}

// ------------------------------------------------------------
void draw() {
  float b = map(levelSmoothed, 0, 1, 0, 255);
  background(b);
}


// ------------------------------------------------------------
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("OSC value range")) {

    oscMin = theControlEvent.getController().getArrayValue(0);
    oscMax = theControlEvent.getController().getArrayValue(1);
  } else if (theControlEvent.isFrom("smoothing")) {

    smoothing = theControlEvent.getController().getValue();
  } else if (theControlEvent.isFrom("amplify")) {

    amplify = theControlEvent.getController().getValue();
  }
}

// ------------------------------------------------------------
void keyPressed() {
  // default properties load/save key combinations are 
  // alt+shift+l to load properties
  // alt+shift+s to save properties
  if (key=='s') {
    cp5.saveProperties("controler02.properties");
  } else if (key=='l') {
    cp5.loadProperties("controler02.properties");
  }
}

