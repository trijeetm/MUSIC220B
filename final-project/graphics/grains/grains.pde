import oscP5.*;
import de.looksgood.ani.*;

// osc
OscP5 oscP5;

// geometry
static int N_GRAINS = 8;
Sample[] samples = new Sample[N_GRAINS];
Window[] grains = new Window[N_GRAINS];

void setup() {
  size(1920, 1080, P2D);
  smooth(8);
  noStroke();
  noCursor();
  frameRate(24);

  Ani.init(this);
  
  oscP5 = new OscP5(this, 4242);
  
  /* osc plug service
   * osc messages with a specific address pattern can be automatically
   * forwarded to a specific method of an object. in this example 
   * a message with address pattern /test will be forwarded to a method
   * test(). below the method test takes 2 arguments - 2 ints. therefore each
   * message with address pattern /test and typetag ii will be forwarded to
   * the method test(int theA, int theB)
   */
  oscP5.plug(this, "initGrain", "/granulizer/init");
  oscP5.plug(this, "setupGrain", "/granulizer/setup");
  oscP5.plug(this, "fireGrain", "/granulizer/fire");
  oscP5.plug(this, "setWindowLength", "/granulizer/prop/len");
  oscP5.plug(this, "setWindowPos", "/granulizer/prop/pos");
}

void initGrain(int id) {
  if (id == 0) {
    samples[id] = new Sample(1, 450, 100, 150, 255, 880);
    grains[id] = new Window(samples[id].getSlices(), 450, 100, 150, 255, 880);
  }
  if (id == 1) {
    samples[id] = new Sample(1, 450, 100, 150, 1215, 880);
    grains[id] = new Window(samples[id].getSlices(), 450, 100, 150, 1215, 880);
  }
}

void fireGrain(int id, float dur) {
  // println("----");
  // println("pos: "+pos);
  // println("len: "+len);
  // println("dur: "+dur);
  grains[id].firePlayhead(dur);
}

void setupGrain(int id, float amplitude) {
  samples[id].addSlice(amplitude);
}

void setWindowLength(int id, float len) {
  grains[id].update(-1, len);
}

void setWindowPos(int id, float pos) {
  grains[id].update(pos, -1);
}

void draw() {
  background(0);

  for (int i = 0; i < N_GRAINS; i++) {
    Sample sample = samples[i];
    if (sample != null)
      sample.draw();

    Window grain = grains[i];
    if (grain != null)
      grain.draw();
  }
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage oscMsg) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
   * be used for double posting but is not required.
  */  
  if (oscMsg.isPlugged() == false) {
    /* print the address pattern and the typetag of the received OscMessage */
    println("### received an osc message.");
    println("### addrpattern\t" + oscMsg.addrPattern());
    println("### typetag\t"+ oscMsg.typetag());
  }
}