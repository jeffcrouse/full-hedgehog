

int[] channel_map = new int[] {
  0, 1, 2, 3, 4, 5, 6, 7, 12,
};
float[] offset_map = new float[] {
  0, 0, 0, 0, 0, .28, 0, -0.1, 0
};

class Servo {

  public float diameter = 130;
  public float theta;
  public float r;
  public PVector center = new PVector();
  public int id;
  private float offset;
  public int channel;
  public float value;
  private float lastValueSent;
  private String label;

  private float seed;
  
  
  // -------------------------------------------
  Servo(float theta, float r, int id) {
    this.r = r;
    this.theta = theta;
    this.id = id;

    this.center.x = cos(theta) * r;
    this.center.y = sin(theta) * r;

    this.channel = (id<channel_map.length) ? channel_map[id] : id;
    this.offset = (id<offset_map.length) ? offset_map[id] : 0;
    this.value = 0;
    this.lastValueSent = -1;

    this.seed = random(TWO_PI);

    label = id + ":" + channel;
  }

  // -------------------------------------------
  void update(float deltaTime) {
    
    this.seed += deltaTime;
    if(autoServo) {
      value = 0.5 * cos(seed) + 0.5;
    }
    
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
    ellipse(center.x, center.y, diameter, diameter);

    noStroke();
    fill(255-c);
    textSize(18);

    text(label, center.x-20, center.y+10);
  }
}

