import oscP5.*;
import de.looksgood.ani.*;

// osc
OscP5 oscP5;

// geometry
Sample sample;
Window grain;

void setup() {
  size(800, 800, P2D);
  smooth(8);
  noStroke();
  frameRate(25);

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
  sample = new Sample();
  grain = new Window(sample.getSlices());
}

void fireGrain(float dur) {
  // println("----");
  // println("pos: "+pos);
  // println("len: "+len);
  // println("dur: "+dur);
  grain.firePlayhead(dur);
}

void setupGrain(float amplitude) {
  sample.addSlice(amplitude);
}

void setWindowLength(float len) {
  grain.update(-1, len);
}

void setWindowPos(float pos) {
  grain.update(pos, -1);
}

void draw() {
  background(0);

  if (sample != null)
    sample.draw();

  if (grain != null)
    grain.draw();
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