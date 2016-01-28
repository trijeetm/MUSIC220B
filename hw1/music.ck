//-----------------------------------------------------------------------------
// name: music.ck
// desc: 
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------
8 => int PIECE_LENGTH;

Metronome metro;
metro.setup(120, 4, 4);

// -------------
// Setup samples
// -------------

Sample keyboard;
keyboard.getBuff() => Channel c1;
c1.setup();
keyboard.init("mechanical-keyboard-typing.wav");

Sample bassPound;
bassPound.getBuff() => KS ksBassPound => Channel c2;
c2.setup();
bassPound.init("desk-pound-stretch.wav");

Sample keyClick1;
keyClick1.getBuff() => Channel c3;
c3.setup();
keyClick1.init("vintage-keyboard-single.wav");
c3.setPan(-0.1);

Sample keyClick2;
keyClick2.getBuff() => Channel c4;
c4.setup();
keyClick2.init("vintage-keyboard-single.wav");
c4.setPan(0.75);

Sample ambientOffice;
ambientOffice.getBuff() => KSChord ksAmbient => LPF ambienceLPF => Channel c5;
c5.setup();
ambientOffice.init("office-ambience-mix.wav");

Sample keyClick3;
keyClick3.getBuff() => Channel c6;
c6.setup();
keyClick3.init("vintage-keyboard-single.wav");
c6.setPan(-0.9);

Sample keyClick2_1;
keyClick2_1.getBuff() => Channel cKC2_1;
cKC2_1.setup();
keyClick2_1.init("vintage-keyboard-single.wav");
cKC2_1.setPan(0.1);

Sample keyClick2_2;
keyClick2_2.getBuff() => Channel cKC2_2;
cKC2_2.setup();
keyClick2_2.init("vintage-keyboard-single.wav");
cKC2_2.setPan(-0.75);

Sample keyClick2_3;
keyClick2_3.getBuff() => Channel cKC2_3;
cKC2_3.setup();
keyClick2_3.init("vintage-keyboard-single.wav");
cKC2_3.setPan(0.9);

Channel c_steps;
Sample step1;
Sample step2;
Sample step3;
KS step1KS;
KS step2KS;
KS step3KS;

[0, 2, 4, 5, 7, 9, 11] @=> int scale[];
0 => int step1NoteOffset;
2 => int step2NoteOffset;
4 => int step3NoteOffset;
[0, 2, 4] @=> int stepNoteOffsets[];
48 => int step1Note;
step1Note + scale[step2NoteOffset] => int step2Note;
step1Note + scale[step3NoteOffset] => int step3Note;
[step1Note, step2Note, step3Note] @=> int stepNotes[];

2 => float spinRate;

//<<< "init: ", stepNotes[0], stepNotes[1], stepNotes[2] >>>;

main();

fun void main() {
  metro.measure;
  metro.start();

  spork ~ ambience(0);
  spork ~ intro(0);
  spork ~ phase1KeyboardTaps(8);
  spork ~ phase1KeyboardTapsBacking(28);
  spork ~ phase1TableTaps(24);

  spork ~ infiniteStaircase(78 - 4);

  metro.waitTillMeasure(114);

  <<< "fini" >>>;

//  while (true) {
    //<<< metro.getMeasure(), metro.getQuarterNoteCount() >>>;
    //<<< metro.getMeasure() >>>;
    //metro.quarterNoteTick => now;
//  }
}

// plain keyboard typing
// 0 - 8
fun void intro(int startMeasure) {
  if (metro.getMeasure() > startMeasure)
    return;
  keyboard.play();
  spork ~ c1.interpMaster(0, 1, metro.getMeasureDur(4));
  spork ~ c1.interpPan(-1, 1, metro.getMeasureDur(8));
  metro.waitTillMeasure(8);
}

// ambience office 
// 0 - 72
fun void ambience(int startMeasure) {
  if (metro.getMeasure() > startMeasure)
    return;
  ksAmbient.tune(60 - 24, 64 - 24, 67 - 24, 71 - 24);
  ambientOffice.play();
  spork ~ c5.interpMaster(0, 0.3, metro.getMeasureDur(16));
  spork ~ ambienceMod();
  // spork ~ ambienceTune();

  metro.waitTillMeasure(16);

  spork ~ ksAmbient.interpolateFeedback(0, 0.9999, metro.getMeasureDur(8));
  ksAmbient.tune(60 - 12, 64 - 12, 67 - 12, 71 - 12);

  metro.waitTillMeasure(60);
  //<<< "ramping ambience" >>>;
  spork ~ c5.interpMaster(0.3, 0.55, metro.getMeasureDur(4));

  metro.waitTillMeasure(67);
  //<<< "dropping feedback" >>>;
  spork ~ ksAmbient.interpolateFeedback(0.9999, 0.8, metro.getMeasureDur(5));

  metro.waitTillMeasure(72);
  //<<< "dropping ambience" >>>;
  spork ~ c5.interpMaster(0.55, 0, metro.getMeasureDur(4));

  metro.waitTillMeasure(76);
  c5.setMaster(0);
  ambientOffice.stop();
}

fun void ambienceTune() {
  metro.waitTillMeasure(24);
  ksAmbient.interpolateTune(60, 64, 67, 71, 12, metro.getMeasureDur(4));
  metro.waitTillMeasure(48);
  ksAmbient.interpolateTune(60, 64, 67, 71, -12, metro.getMeasureDur(8));
}

fun void ambienceMod() {
  ambienceLPF.set(12000, 2);
  while (metro.getMeasure() < 40) {
    Interpolator iAmbienceLPF;
    iAmbienceLPF.setup(10000, 500, metro.getMeasureDur(8));
    iAmbienceLPF.interpolate();
    while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
      iAmbienceLPF.getCurrent() => ambienceLPF.freq;
      iAmbienceLPF.delta => now;
    }
    iAmbienceLPF.setup(500, 10000, metro.getMeasureDur(8));
    iAmbienceLPF.interpolate();
    while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
      iAmbienceLPF.getCurrent() => ambienceLPF.freq;
      iAmbienceLPF.delta => now;
    }
  }
  while (metro.getMeasure() < 64) {
    Interpolator iAmbienceLPF;
    iAmbienceLPF.setup(5000, 400, metro.getMeasureDur(4));
    iAmbienceLPF.interpolate();
    while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
      iAmbienceLPF.getCurrent() => ambienceLPF.freq;
      iAmbienceLPF.delta => now;
    }
    iAmbienceLPF.setup(400, 5000, metro.getMeasureDur(4));
    iAmbienceLPF.interpolate();
    while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
      iAmbienceLPF.getCurrent() => ambienceLPF.freq;
      iAmbienceLPF.delta => now;
    }
  }
  /*
  while (metro.getMeasure() < 64) {
    Interpolator iAmbienceLPF;
    iAmbienceLPF.setup(5000, 400, metro.getMeasureDur(2));
    iAmbienceLPF.interpolate();
    while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
      iAmbienceLPF.getCurrent() => ambienceLPF.freq;
      iAmbienceLPF.delta => now;
    }
    iAmbienceLPF.setup(400, 5000, metro.getMeasureDur(2));
    iAmbienceLPF.interpolate();
    while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
      iAmbienceLPF.getCurrent() => ambienceLPF.freq;
      iAmbienceLPF.delta => now;
    }
  }
  */

  ////<<< "removing LPF" >>>;
  Interpolator iAmbienceLPF;
  iAmbienceLPF.setup(5000, 22000, metro.getMeasureDur(8));
  iAmbienceLPF.interpolate();
  while (iAmbienceLPF.getCurrent() != iAmbienceLPF.end) {
    iAmbienceLPF.getCurrent() => ambienceLPF.freq;
    iAmbienceLPF.delta => now;
  }
  ambienceLPF.set(22000, 1);
}

fun void phase1KeyboardTaps(int startMeasure) {
  metro.waitTillMeasure(startMeasure);

  spork ~ keyTapsMod();

  //<<< "1!" >>>;

  while (metro.getMeasure() < 4) {
    if (metro.getQuarterNoteCount() == 1) 
      keyClick1.playWithJitter(1, 0.75);
    metro.quarterNoteTick => now;
  }

  while (metro.getMeasure() < 8) {
    if (metro.getQuarterNoteCount() == 1)
      keyClick1.playWithJitter(1, 0.75);
    if (metro.getQuarterNoteCount() == 4)
      keyClick2.playWithJitter(0.9, 0.6);
    metro.quarterNoteTick => now;
  }

  while (metro.getMeasure() < 12) {
    if (metro.getEighthNoteCount() == 1)
      keyClick1.playWithJitter(1, 0.5);
    if (metro.getEighthNoteCount() == 7)
      keyClick2.playWithJitter(0.9, 0.6);
    if ((metro.getEighthNoteCount() == 2) ||
        (metro.getEighthNoteCount() == 8)
      )
      keyClick3.playWithJitter(0.75, 1);

    metro.eighthNoteTick => now;
  }

  while (metro.getMeasure() < 16) {
    if ((metro.getEighthNoteCount() == 1) ||
        (metro.getEighthNoteCount() == 3)
      )
      keyClick1.playWithJitter(1, 0.4);
    if (metro.getEighthNoteCount() == 7)
      keyClick2.playWithJitter(0.9, 0.6);
    if ((metro.getEighthNoteCount() == 2) ||
        (metro.getEighthNoteCount() == 8)
      )
      keyClick3.playWithJitter(0.9, 1);

    metro.eighthNoteTick => now;
  }

  while (metro.getMeasure() < 20) {
    if ((metro.getEighthNoteCount() == 1) ||
        (metro.getEighthNoteCount() == 3)
      )
      keyClick1.playWithJitter(1, 0.4);
    if ((metro.getEighthNoteCount() == 7) || 
        (metro.getEighthNoteCount() == 3)
      )
      keyClick2.playWithJitter(0.9, 0.6);
    if ((metro.getEighthNoteCount() == 2) ||
        (metro.getEighthNoteCount() == 8)
      )
      keyClick3.playWithJitter(0.9, 1);

    metro.eighthNoteTick => now;
  }

  //<<< "2!" >>>;

  while (metro.getMeasure() < 28) {
    if ((metro.getEighthNoteCount() == 1) ||
        (metro.getEighthNoteCount() == 3)
      )
      keyClick1.playWithJitter(1, 0.4);
    if ((metro.getEighthNoteCount() == 7) || 
        (metro.getEighthNoteCount() == 3)
      )
      keyClick2.playWithJitter(0.9, 0.6);
    if (metro.getEighthNoteCount() == 5)
      keyClick2.playWithJitter(0.7, 0.8);
    if ((metro.getEighthNoteCount() == 2) ||
        (metro.getEighthNoteCount() == 8)
      )
      keyClick3.playWithJitter(0.8, 1);
    if ((metro.getEighthNoteCount() == 4) ||
        (metro.getEighthNoteCount() == 6)
      )
      keyClick3.playWithJitter(0.6, 1.1);

    metro.eighthNoteTick => now;
  }

  //<<< "3!" >>>;

  while (metro.getMeasure() < 40) {
    if ((metro.getSixteenthNoteCount() == 1) ||
        (metro.getSixteenthNoteCount() == 3) ||
        (metro.getSixteenthNoteCount() == 5)
      )
      keyClick1.playWithJitter(1.0, 0.3);
    if ((metro.getSixteenthNoteCount() == 9) || 
        (metro.getSixteenthNoteCount() == 5)
      )
      keyClick2.playWithJitter(0.9, 0.7);
    if (metro.getSixteenthNoteCount() == 9)
      keyClick2.playWithJitter(0.7, 0.9);
    if ((metro.getSixteenthNoteCount() == 3) ||
        (metro.getSixteenthNoteCount() == 15)
      )
      keyClick3.playWithJitter(0.8, 1);
    if ((metro.getSixteenthNoteCount() == 7) ||
        (metro.getSixteenthNoteCount() == 11)
      )
      keyClick3.playWithJitter(0.6, 1.2);

    metro.sixteenthNoteTick => now;
  }

  //<<< "4!" >>>;

  while (metro.getMeasure() < 48) {
    if ((metro.getSixteenthNoteCount() == 1) ||
        (metro.getSixteenthNoteCount() == 2) ||
        (metro.getSixteenthNoteCount() == 4) ||
        (metro.getSixteenthNoteCount() == 5)
      )
      keyClick1.playWithJitter(1.1, 0.3);
    if ((metro.getSixteenthNoteCount() == 9) || 
        (metro.getSixteenthNoteCount() == 10)
      )
      keyClick2.playWithJitter(0.9, 1.2);
    if (metro.getSixteenthNoteCount() == 11)
      keyClick3.playWithJitter(1, 0.9);
    if ((metro.getSixteenthNoteCount() == 13) ||
        (metro.getSixteenthNoteCount() == 14)
      )
      keyClick2.playWithJitter(0.8, 0.7);
    if (metro.getSixteenthNoteCount() == 15)
      keyClick3.playWithJitter(0.9, 0.5);

    metro.sixteenthNoteTick => now;
  }

  //<<< "5!" >>>;

  while (metro.getMeasure() < 56) {
    if ((metro.getSixteenthNoteCount() == 1) ||
        (metro.getSixteenthNoteCount() == 2) ||
        (metro.getSixteenthNoteCount() == 4) ||
        (metro.getSixteenthNoteCount() == 5)
      )
      keyClick1.playWithJitter(1.1, 0.3);
    if ((metro.getSixteenthNoteCount() == 3) || 
        (metro.getSixteenthNoteCount() == 5)
      )
      keyClick2.playWithJitter(1.4, 1.5);
    if (metro.getSixteenthNoteCount() == 4) 
      keyClick2.playWithJitter(1.2, 0.9);
    if ((metro.getSixteenthNoteCount() == 9) || 
        (metro.getSixteenthNoteCount() == 10)
      )
      keyClick2.playWithJitter(0.9, 1.2);
    if (metro.getSixteenthNoteCount() == 11)
      keyClick3.playWithJitter(1, 0.9);
    if ((metro.getSixteenthNoteCount() == 13) ||
        (metro.getSixteenthNoteCount() == 14)
      )
      keyClick2.playWithJitter(0.8, 0.7);
    if (metro.getSixteenthNoteCount() == 15)
      keyClick3.playWithJitter(0.9, 0.5);

    metro.sixteenthNoteTick => now;
  }

  //<<< "6!" >>>;

  while (metro.getMeasure() < 74) {
    if ((metro.getSixteenthNoteCount() == 1) ||
        (metro.getSixteenthNoteCount() == 5) ||
        (metro.getSixteenthNoteCount() == 6) ||
        (metro.getSixteenthNoteCount() == 8) ||
        (metro.getSixteenthNoteCount() == 9)
      )
      keyClick1.playWithJitter(1.1, 0.25);
    if ((metro.getSixteenthNoteCount() == 1) || 
        (metro.getSixteenthNoteCount() == 2) || 
        (metro.getSixteenthNoteCount() == 5) || 
        (metro.getSixteenthNoteCount() == 6) ||
        (metro.getSixteenthNoteCount() == 13) ||
        (metro.getSixteenthNoteCount() == 14)
      )
      keyClick3.playWithJitter(0.9, 1.3);
    if ((metro.getSixteenthNoteCount() == 3) ||
        (metro.getSixteenthNoteCount() == 7) ||
        (metro.getSixteenthNoteCount() == 15)
      )
      keyClick2.playWithJitter(0.8, 0.9);

    metro.sixteenthNoteTick => now;
  }
}

fun void keyTapsMod() {
  while (metro.getMeasure() < 74) {
    0.2 => float jitter;
    spork ~ c3.interpPan(c3.pan.pan(), Math.random2f(-1, 1), metro.getMeasureDur(1) / 4);
    spork ~ c4.interpPan(c4.pan.pan(), Math.random2f(-1, 1), metro.getMeasureDur(1) / 4);
    spork ~ c6.interpPan(c6.pan.pan(), Math.random2f(-1, 1), metro.getMeasureDur(1) / 4);

    spork ~ cKC2_1.interpPan(cKC2_1.pan.pan(), Math.random2f(-1, 1), metro.getMeasureDur(1) / 4);
    spork ~ cKC2_2.interpPan(cKC2_2.pan.pan(), Math.random2f(-1, 1), metro.getMeasureDur(1) / 4);
    spork ~ cKC2_3.interpPan(cKC2_3.pan.pan(), Math.random2f(-1, 1), metro.getMeasureDur(1) / 4);
    metro.quarterNoteTick => now;
  }
}

fun void phase1KeyboardTapsBacking(int startMeasure) {
  metro.waitTillMeasure(startMeasure);
  spork ~ cKC2_1.interpMaster(0.3, 0.7, metro.getMeasureDur(8));
  spork ~ cKC2_2.interpMaster(0.3, 0.7, metro.getMeasureDur(8));
  spork ~ cKC2_3.interpMaster(0.3, 0.7, metro.getMeasureDur(8));

  //<<< "backing!" >>>;

  while (metro.getMeasure() < 70) {
    if ((metro.getEighthNoteCount() == 1) ||
        (metro.getEighthNoteCount() == 3)
      )
      keyClick2_1.playWithJitter(1, 0.4);
    if ((metro.getEighthNoteCount() == 7) || 
        (metro.getEighthNoteCount() == 3)
      )
      keyClick2_2.playWithJitter(0.9, 0.6);
    if (metro.getEighthNoteCount() == 5)
      keyClick2.playWithJitter(0.7, 0.8);
    if ((metro.getEighthNoteCount() == 2) ||
        (metro.getEighthNoteCount() == 8)
      )
      keyClick2_2.playWithJitter(0.8, 1);
    if ((metro.getEighthNoteCount() == 4) ||
        (metro.getEighthNoteCount() == 6)
      )
      keyClick2_3.playWithJitter(0.6, 1.1);

    metro.eighthNoteTick => now;
  }
}

fun void phase1TableTaps(int startMeasure) {
  metro.waitTillMeasure(startMeasure);
  c2.setRev(0.2);
  spork ~ c2.interpMaster(0.1, 0.5, metro.getMeasureDur(16));
  ksBassPound.tune(36);
  ksBassPound.feedback(0.85);

  spork ~ tableTapMod();

  while (metro.getMeasure() < 78) {
    bassPound.playWithJitter(1, 0.5);
    metro.wholeNoteTick => now;
  }
}

fun void tableTapMod() {
  metro.waitTillMeasure(70);
  spork ~ c2.interpRev(0, 0.75, metro.getMeasureDur(8));
  //metro.waitTillMeasure(74);
  //spork ~ ksBassPound.interpolateTune(36, 24, metro.getMeasureDur(3));
  metro.waitTillMeasure(78);
}

// phase2
fun void infiniteStaircase(int startMeasure) {
  metro.waitTillMeasure(startMeasure);

  initInfiniteStaircase(startMeasure);

  spork ~ ascendStaircase();

  while (metro.getMeasure() < 86) {
    step1.play(1, 0.25);
    step2.play(1, 0.25);
    step3.play(1, 0.25);

    metro.waitForMeasures(4);
  }

  //// <<< "escalating!" >>>;
  spork ~ c_steps.interpRev(0.3, 0.5, metro.getMeasureDur(24));
  spork ~ c_steps.interpMaster(0.8, 0.1, metro.getMeasureDur(24));
  spork ~ spinStaircase();

  while (metro.getMeasure() < 108) {
    ////<<< "la!" >>>;
    ////<<< "gain:", c_steps.master.gain() >>>;
    step1.play(1, 0.5);
    step2.play(1, 0.5);
    step3.play(1, 0.5);

    metro.waitForMeasures(2);
  }
}

fun void spinStaircase() {
  metro.waitTillMeasure(86);
  c_steps.setPan(0);
  0::samp => dur t;

  spork ~ spinFaster();

  while (metro.getMeasure() < 110) {
    ////<<< Math.sin(now / 1::second) >>>;
    5::samp => dur duration;

    //c_steps.interpPan(c_steps.pan.pan(), Math.sin(now / 1::second), duration);
    c_steps.setPan(Math.sin(t / spinRate::second));

    duration + t => t;

    duration => now;
  }
}

fun void spinFaster() {
  Interpolator interp;
  interp.setup(spinRate, 0.5, metro.getMeasureDur(21));
  interp.interpolate();
  while (interp.getCurrent() != interp.end) {
      interp.getCurrent() => spinRate;
      interp.delta => now;
  }
  interp.getCurrent() => spinRate;
}

fun void ascendStaircase() {
  metro.waitTillMeasure(86 - 2);
  2 => int nStep;

  ////<<< "begin: ", stepNotes[0], stepNotes[1], stepNotes[2] >>>;

  while (metro.getMeasure() < 108) {
    stepNotes[nStep] => int currNote;
    stepNoteOffsets[nStep] => int currOffset;

    currNote - scale[currOffset] + scale[(currOffset + 1) % 7] => int newNote;

    newNote => stepNotes[nStep];

    if (nStep == 0)
      step1KS.interpolateTune(currNote, newNote, metro.getMeasureDur(1) / 2);

    if (nStep == 1)
      step2KS.interpolateTune(currNote, newNote, metro.getMeasureDur(1) / 2);

    if (nStep == 2)
      step3KS.interpolateTune(currNote, newNote, metro.getMeasureDur(1) / 2);

    // (nStep + 1) % 3 => nStep;
    nStep - 1 => nStep;
    if (nStep == -1)
      2 => nStep;

    ////<<< "end: ", stepNotes[0], stepNotes[1], stepNotes[2] >>>;

    //metro.quarterNoteTick => now;
    metro.halfNoteTick => now;
  }
}

fun void initInfiniteStaircase(int startMeasure) {
  step1.getBuff() => step1KS => c_steps;
  step1.init("desk-chair-piston-single.wav");

  step2.getBuff() => step2KS => c_steps;
  step2.init("desk-chair-piston-single.wav");

  step3.getBuff() => step3KS => c_steps;
  step3.init("desk-chair-piston-single.wav");

  step1KS.tune(step1Note);
  step1KS.feedback(0.99);
  step2KS.tune(step2Note);
  step2KS.feedback(0.99);
  step3KS.tune(step3Note);
  step3KS.feedback(0.99);

  c_steps.setup();
  c_steps.setRev(0.3);
  c_steps.setMaster(0.8);
  spork ~ c_steps.interpMaster(0.3, 1, metro.getMeasureDur(4));
}