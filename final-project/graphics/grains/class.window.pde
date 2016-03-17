class Window {
  ArrayList<PShape> slices;
  float width;
  float height;
  float pos;
  int startSlice;
  int endSlice;
  int nSlices;
  int MAX_WIDTH;
  int xOffset;
  int yOffset;
  int id;
  float alpha = 120;
  float sliceAlpha = 0;
  Colors colors = new Colors();

  ArrayList<Playhead> heads;
  int currHead;
  static final int MAX_HEADS = 200;

  Window(int _id, ArrayList<PShape> s, int _w, int _h, int _nSlices, int _x, int _y) {
    id = _id;
    slices = s;
    nSlices = _nSlices;
    MAX_WIDTH = _w;
    pos = 0;
    width = 0;
    height = _h;
    startSlice = 0;
    endSlice = 0;
    heads = new ArrayList<Playhead>(MAX_HEADS);
    for (int i = 0; i < MAX_HEADS; ++i) {
      heads.add(new Playhead());
    }
    currHead = 0;
    xOffset = _x;
    yOffset = _y;
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

    startSlice = (int)Math.floor(pos * nSlices);
    endSlice = (int)Math.ceil((pos + width) * nSlices);
  }

  void firePlayhead(float dur) {
    Playhead head = heads.get(currHead);
    head.fire(startSlice, endSlice - 1, dur);
    currHead = (currHead + 1) % MAX_HEADS;
  }

  void hide() {
    Ani.to(this, 2, "alpha", 120);
  }

  void show() {
    Ani.to(this, 2, "alpha", 255);
  }

  void setGain(float g) {
    sliceAlpha = ((float)Math.pow(g, 0.15));
  }

  void draw() {
    // slice highlighting
    for (int i = startSlice; i < endSlice; i++) {
      PShape slice = slices.get(i);
      color _c = colors.getById(id);
      color c = (_c & 0xffffff) | ((int)alpha << 24); 
      slice.setFill(c);
      slice.setStroke(0);
      shape(slice);
    }

    // rectangle window
    // fill(255, 45, 85, 30);
    // rect(100 + (pos * MAX_WIDTH), 400 - 25, (width * MAX_WIDTH), 50);

    // line window
    stroke(colors.getById(id), alpha);
    strokeWeight(3);
    line(xOffset + (pos * MAX_WIDTH) - 2, yOffset - (height / 2), xOffset + (pos * MAX_WIDTH) - 2, yOffset + (height / 2));
    line(xOffset + (pos * MAX_WIDTH) - 2 + (width * MAX_WIDTH), yOffset - (height / 2), xOffset + (pos * MAX_WIDTH) - 2 + (width * MAX_WIDTH), yOffset + (height / 2));
    noStroke();

    if (slices.size() > 0) {
      for (Playhead h : heads) {
        if (
          (h.getPosition() != -1) && (h.isRunning()) &&
          (h.getPosition() < endSlice)
        ) {
          PShape headSlice = slices.get(h.getPosition());
          headSlice.setFill(color(255, 255, 255, (230 * sliceAlpha)));
          headSlice.setStroke(0);
          shape(headSlice);

          if (h.getPosition() < nSlices - 1) {
            PShape leadSlice = slices.get(h.getPosition() + 1);
            leadSlice.setFill(color(255, 255, 255, (120 * sliceAlpha)));
            leadSlice.setStroke(0);
            shape(leadSlice);
          }

          if (
            (h.getPosition() > 2) &&
            (h.getPosition() > startSlice)
          ) {
            PShape trailSlice = slices.get(h.getPosition() - 1);
            trailSlice.setFill(color(255, 255, 255, (120 * sliceAlpha)));
            trailSlice.setStroke(0);
            shape(trailSlice);
          }
        }
      }
    }
  }
}