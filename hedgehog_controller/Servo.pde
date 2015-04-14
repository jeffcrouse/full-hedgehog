

int[] channel_map = new int[] {
  0, 1, 2, 3, 4, 5, 6, 7, 12
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
  private float seed;
  private String label;



  Servo(float angle, float radius, int id) {
    pos.x = cos(radians(angle)) * radius;
    pos.y = sin(radians(angle)) * radius;
    
    this.id = id;
    this.channel = channel_map[id];
    this.offset = offset_map[id];
    this.value = 0;
    this.lastValueSent = -1;
    //this.mappedValue = map(this.value, 0, 1, oscMin, oscMax);
    this.seed = random(0, PI);
    
    label = id + ":" + channel;
  }

  void update(float deltaTime) {
    // tmp start
    seed += deltaTime;
    value = 0.5 + cos(seed) * 0.5;
    // tmp end

    value += offset;
    value = map(value, 0, 1, oscMin, oscMax);

    if (abs(value-lastValueSent)>0.005) 
    {
      OscMessage msg = new OscMessage("/pwm");
      msg.add( channel );
      msg.add( value );
      //println("channel", channel, " value", value);
      oscP5.send(msg, pi);
      lastValueSent = value;
    }
  }

  void draw() {

    stroke(204, 102, 0);
    float c = map(value, 0, 1, 255, 0);
    if(c > 255 || c < 0) {
      // make it red -- warning! our of range!
    }
    fill(c);

    ellipse(pos.x, pos.y, diameter, diameter);

    noStroke();
    fill(255-c);
    textSize(24);
   
    text(label, pos.x-5, pos.y+10);
  }
}

