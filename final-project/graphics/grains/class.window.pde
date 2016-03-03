class Window {
  ArrayList<PShape> slices;
  float width;
  float pos;
  int startSlice;
  int endSlice;
  ArrayList<Integer> playheads;
  int head;

  static final int MAX_WIDTH = 600;

  Window(ArrayList<PShape> s) {
    slices = s;
    pos = 0;
    width = 0;
    startSlice = 0;
    endSlice = 0;
    playheads = new ArrayList<Integer>();
    head = -1;
  }

  void update(float p, float w) {
    if (p != -1) {
      pos = p;

      if (width + pos > 1)
        width = 1 - pos;
    }

    if (w != -1) {
      float _width = w;

      if (_width + pos > 1)
        width = 1 - pos;
      else 
        width = _width;
    }

    startSlice = (int)Math.ceil(pos * 200);
    endSlice = (int)Math.ceil((pos + width) * 200);
    // println("----");
    // println("pos: "+pos);
    // println("width: "+width);
    // println("startSlice: "+startSlice);
    // println("endSlice: "+endSlice);
  }

  void firePlayhead(float dur) {
    // playheads.add(startSlice);
    head = startSlice - 1;
    // Ani playheadAni = new Ani(this, dur, "playheads.get(playheads.size() - 1)", endSlice, Ani.LINEAR);
    Ani playheadAni = new Ani(this, dur, "head", endSlice - 1, Ani.LINEAR);
    playheadAni.start();
  }

  void draw() {
    // slice highlighting
    for (int i = startSlice; i < endSlice; i++) {
      PShape slice = slices.get(i);
      slice.setFill(color(255, 45, 85));
      slice.setStroke(0);
      shape(slice);
    }

    // rectangle window
    // fill(255, 45, 85, 30);
    // rect(100 + (pos * MAX_WIDTH), 400 - 25, (width * MAX_WIDTH), 50);

    // line window
    stroke(255, 45, 85);
    strokeWeight(1);
    line(100 + (pos * MAX_WIDTH), 400 - 50, 100 + (pos * MAX_WIDTH), 400 + 50);
    line(100 + (pos * MAX_WIDTH) + (width * MAX_WIDTH), 400 - 50, 100 + (pos * MAX_WIDTH) + (width * MAX_WIDTH), 400 + 50);
    noStroke();

    if (head != -1) {
      PShape headSlice = slices.get(head);
      headSlice.setFill(color(255, 255, 255));
      headSlice.setStroke(0);
      shape(headSlice);

      if (head < 199) {
        PShape leadSlice = slices.get(head + 1);
        leadSlice.setFill(color(255, 255, 255));
        leadSlice.setStroke(0);
        shape(leadSlice);
      }

      if (head > 2) {
        PShape trailSlice = slices.get(head - 1);
        trailSlice.setFill(color(255, 255, 255));
        trailSlice.setStroke(0);
        shape(trailSlice);
      }
    }

    // if (playheads.size() != 0)
    //   println("playheads.get(playheads.size() - 1): "+playheads.get(playheads.size() - 1));
  }
}