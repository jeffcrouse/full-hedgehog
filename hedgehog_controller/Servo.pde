

class Servo {

  public float diameter = 130;
  public float angle;
  public float radius;
  public PVector pos = new PVector();
  public int id;
  public float value;
  private float lastValueSent;
  private float seed;

  Servo(float angle, float radius, int id) {
    pos.x = cos(radians(angle)) * radius;
    pos.y = sin(radians(angle)) * radius;
    this.id = id;
    this.value = 0;
    this.lastValueSent = -1;
    this.seed = random(0, PI);
  }

  void update(float deltaTime) {
    value = 0.5 + cos(seed) * 0.5;
    seed += deltaTime;
    
    if (abs(value-lastValueSent)>0.01) {
      OscMessage msg = new OscMessage("/pwm");
      msg.add( id );
      msg.add( value );
      
      oscP5.send(msg, pi);

      lastValueSent = value;
    }
  }

  void draw() {

    stroke(204, 102, 0);
    float c = map(value, 0, 1, 255, 0);
    fill(c);

    ellipse(pos.x, pos.y, diameter, diameter);

    noStroke();
    fill(255-c);
    textSize(24);
    text(id, pos.x-5, pos.y+10);
  }
}

