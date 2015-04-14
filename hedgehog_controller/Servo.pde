

int[] channel_map = new int[] {
  0, 1, 2, 3, 4, 5, 6, 7, 12,
};
float[] offset_map = new float[] {
  0, 0, 0, 0, 0, .28, 0, -0.1, 0
};

class Servo {

  public float diameter = 130;
  public float angle;
  public float radius;
  public PVector pos = new PVector();
  public int id;
  private float offset;
  public int channel;
  public float value;
  private float lastValueSent;
  private String label;


  // -------------------------------------------
  Servo(float angle, float radius, int id) {
    this.radius = radius;
    this.angle = angle;
    this.id = id;

    this.pos.x = cos(angle) * radius;
    this.pos.y = sin(angle) * radius;

    this.channel = (id<channel_map.length) ? channel_map[id] : -1;
    this.offset = (id<offset_map.length) ? offset_map[id] : -1;
    this.value = 0;
    this.lastValueSent = -1;

    label = id + ":" + channel;
  }

  // -------------------------------------------
  void update(float deltaTime) {
    value = constrain(value, 0, 1);
    if (value>0) {
      value -= deltaTime;
    }

    float valueAdjusted = value + offset;
    valueAdjusted = constrain(valueAdjusted, 0, 1);
    valueAdjusted = map(valueAdjusted, 0, 1, oscMin, oscMax);

    // TO DO: Also limit how frequently a single servo is sent.
    if (abs(valueAdjusted-lastValueSent)>0.005 && channel != -1) 
    {
      OscMessage msg = new OscMessage("/pwm");
      msg.add( channel );
      msg.add( valueAdjusted );
      //println("channel", channel, " value", value);
      oscP5.send(msg, pi);
      lastValueSent = valueAdjusted;
    }
  }

  // -------------------------------------------
  void draw() {

    float c = map(value, 0, 1, 0, 255);
    if (c > 255 || c < 0) {
      // make it red -- warning! our of range!
    }
    fill(c);
    stroke(204, 102, 0);
    strokeWeight(4);
    ellipse(pos.x, pos.y, diameter, diameter);

    noStroke();
    fill(255-c);
    textSize(18);

    text(label, pos.x-20, pos.y+10);
  }
}

