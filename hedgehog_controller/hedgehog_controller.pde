import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pi;

void setup() {
  size(400, 400);
  frameRate(25);
  oscP5 = new OscP5(this, 7000);
  pi = new NetAddress("hedgehog.local", 7000);
}


void draw() {
  background(0);
}

void mousePressed() {

  OscMessage msg = new OscMessage("/pwm");
  msg.add( int(random(9)));
  msg.add( int(random(300, 2000)));
  oscP5.send(msg, pi); 

}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

