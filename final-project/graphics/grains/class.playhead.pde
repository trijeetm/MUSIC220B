class Playhead {
  int head;
  Ani headAni;
  boolean running;

  Playhead() {
    running = false;
    head = 1;
    // headAni = new Ani();
  }

  void fire(int start, int end, float dur) {
    head = start;
    headAni = new Ani(this, dur, "head", end, Ani.LINEAR);
    headAni.setCallback("onEnd:headAniEnd");
    running = true;
    headAni.start();
  }

  void headAniEnd() {
    running = false;
  }

  int getPosition() {
    return head;
  }

  boolean isRunning() {
    return running;
  }
}