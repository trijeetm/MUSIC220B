//-----------------------------------------------------------------------------
// name: music.ck
// desc: 
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------
256 => int SEQUENCE_LEN;

Metronome metro;
metro.setup(120, 4, 4);

Metronome metro2;
metro2.setup(60, 4, 4);

Channel c_Perc, c_Perc2, c_Perc3;
c_Perc.setup();
c_Perc2.setup();
c_Perc3.setup();

Gain voicesGain;
FMVoices stk_voice1 => voicesGain;
FMVoices stk_voice2 => voicesGain;
voicesGain => JCRev voicesRev => Echo voicesEcho1 => Echo voicesEcho2 => Channel c_Voices;
c_Voices.setup();

Rhodey stk_bass => Channel c_Bass;
c_Bass.setup();

HevyMetl stk_metl0 => Echo echo_metl0 => Channel c_metl0;
c_metl0.setup();

Sample s_wilson;
s_wilson.getBuff() => Channel c_wilson;
c_wilson.setup();
s_wilson.init("wilson.wav");


Channel c_modal1, c_modal2;

// cMin pentatone
[0, 3, 5, 7, 10] @=> int scale[];

main();

fun void main() {
  -1 => metro.measure;
  metro.start();

  // spork ~ logger(metro2);

  spork ~ voicesLoop(metro, 0);
  spork ~ bassLoop(metro, 4);
  spork ~ percLoop(metro, 8, c_Perc);
  spork ~ metlRuns(metro, 20);

  c_modal1.setMaster(2);
  spork ~ metl2Runs(metro, 32, c_modal1);

  metro.waitTillMeasure(18);
  if (metro.getMeasure() == 18)
    spork ~ c_Voices.interpMaster(0.8, 0.1, metro.getMeasureDur(4));

  metro.waitTillMeasure(30);
  if (metro.getMeasure() == 30)
    spork ~ c_Voices.interpMaster(0.1, 0.65, metro.getMeasureDur(2));

  metro.waitTillMeasure(40);
  if (metro.getMeasure() == 40) {
    spork ~ c_Voices.interpMaster(0.65, 0.2, metro.getMeasureDur(16));
    spork ~ c_Perc.interpMaster(1, 0.5, metro.getMeasureDur(16));
    spork ~ c_metl0.interpMaster(0.7, 0.3, metro.getMeasureDur(16));
    spork ~ c_Bass.interpMaster(1, 0.7, metro.getMeasureDur(16));
  }
  else {
    c_Voices.setMaster(0.2);
    c_Perc.setMaster(0.5);
    c_metl0.setMaster(0.3);
  }

  metro.waitTillMeasure(56);
  metro2.start();
  c_modal2.setMaster(0.5);
  spork ~ metl2Runs(metro2, 0, c_modal2);
  spork ~ perc2Loop(metro2, 0, c_Perc2);

  spork ~ metro.interpBpm(120, 240, metro.getMeasureDur(32)); 
  spork ~ metro2.interpBpm(60, 120, metro.getMeasureDur(32));

  spork ~ c_Voices.interpMaster(0.2, 0, metro.getMeasureDur(32));
  spork ~ c_Perc.interpMaster(0.5, 0, metro.getMeasureDur(32));
  spork ~ c_metl0.interpMaster(0.3, 0, metro.getMeasureDur(32));
  spork ~ c_Bass.interpMaster(0.7, 0, metro.getMeasureDur(32));

  spork ~ c_modal1.interpMaster(2, 0, metro.getMeasureDur(36));

  spork ~ c_modal2.interpMaster(0.5, 2, metro.getMeasureDur(28));
  spork ~ c_Perc2.interpMaster(0.1, 0.5, metro.getMeasureDur(28));

  metro2.waitTillMeasure(28);

  spork ~ perc3Loop(metro2, 28, c_Perc3);

  spork ~ c_modal2.interpMaster(2, 0, metro.getMeasureDur(16));
  spork ~ c_Perc2.interpMaster(0.5, 0, metro.getMeasureDur(16));
  spork ~ c_Perc3.interpMaster(0, 0.18, metro.getMeasureDur(16));

  spork ~ c_modal2.interpPan(0, -1, metro.getMeasureDur(16));
  spork ~ c_Perc2.interpPan(0, -1, metro.getMeasureDur(16));
  spork ~ c_Perc3.interpPan(1, 0, metro.getMeasureDur(16));

  metro2.waitTillMeasure(32);
  s_wilson.play(2.2);
  c_wilson.setPan(0.35);

  // metro2.waitTillMeasure(44);
  spork ~ c_Perc3.interpLPFFreq(20000, 500, metro2.getMeasureDur(48));
  spork ~ c_Perc3.interpLPFQ(1, 5, metro2.getMeasureDur(4));

  metro2.waitTillMeasure(68);
  spork ~ c_Perc3.interpRev(0, 0.2, metro2.getMeasureDur(8));

  metro2.waitTillMeasure(72);
  spork ~ c_Perc3.interpMaster(0.18, 0, metro2.getMeasureDur(16));  

  metro2.waitTillMeasure(98);

  <<< "fini" >>>;
}

fun void logger(Metronome met) {
  while (met.getMeasure() < SEQUENCE_LEN) {
    <<< met.getMeasure(), met.getQuarterNoteCount() >>>;
    met.quarterNoteTick => now;
  }
}

fun void voicesLoop(Metronome met, int startMeasure) {
  met.waitTillMeasure(startMeasure);

  spork ~ voicesMod();

  while (met.getMeasure() < SEQUENCE_LEN) {
    48 => int offset;
    met.getMeasure() % 4 => int m;

    if ((m == 0) || (m == 1)) {
      if (Math.randomf() > 0.2) {
        Std.mtof(offset + scale[0]) => stk_voice1.freq;
        0.9 => stk_voice1.noteOn;
        met.getQuarterBeatDur() => now;
        0.5 => stk_voice1.noteOff;
      }
      if (Math.randomf() > 0.25) {
        Std.mtof(offset + scale[3]) => stk_voice2.freq;
        0.7 => stk_voice2.noteOn;
        met.getQuarterBeatDur() => now;
        0.4 => stk_voice2.noteOff;
      }
    }

    if ((m == 2)) {
      if (Math.randomf() > 0.05) {
        Std.mtof(offset - 12 + scale[4]) => stk_voice1.freq;
        0.9 => stk_voice1.noteOn;
        met.getQuarterBeatDur() => now;
        0.5 => stk_voice1.noteOff;
      }
      if (Math.randomf() > 0.1) {
        Std.mtof(offset + scale[2]) => stk_voice2.freq;
        0.7 => stk_voice2.noteOn;
        met.getQuarterBeatDur() => now;
        0.4 => stk_voice2.noteOff;
      }
    }

    if ((m == 3)) {
      if (Math.randomf() > 0.05) {
        Std.mtof(offset - 12 + scale[2]) => stk_voice1.freq;
        0.9 => stk_voice1.noteOn;
        met.getQuarterBeatDur() => now;
        0.5 => stk_voice1.noteOff;
      }
      if (Math.randomf() > 0.1) {
        Std.mtof(offset + scale[0]) => stk_voice2.freq;
        0.7 => stk_voice2.noteOn;
        met.getQuarterBeatDur() => now;
        0.4 => stk_voice2.noteOff;
      }
    }

    met.quarterNoteTick => now;
  }
}

fun void voicesMod() {
  0.2 => voicesRev.mix;
  c_Voices.setMaster(0.8);
}

fun void percLoop(Metronome met, int startMeasure, Channel chan) {
  Sample s_bass;
  s_bass.getBuff() => chan;
  chan.setup();
  s_bass.init("99sounds/kick-plain.wav");

  Sample s_hiHat;
  s_hiHat.getBuff() => chan;
  chan.setup();
  s_hiHat.init("99sounds/hihat-acoustic02.wav");

  met.waitTillMeasure(startMeasure);

  while (met.getMeasure() < 16) {
    if (met.getQuarterNoteCount() == 1)
      s_bass.play(0.5, 1);
      
    // s_hiHat.playWithJitter(0.5, 1);

    met.quarterNoteTick => now;
  }

  while (met.getMeasure() < 24) {
    if (met.getQuarterNoteCount() == 1)
      s_bass.play(0.5, 1);
      
    s_hiHat.playWithJitter(0.3, 1);

    chan.setPan(Math.random2f(-0.5, 0.5));
    met.quarterNoteTick => now;
  }

  while (met.getMeasure() < SEQUENCE_LEN) {
    if ((met.getSixteenthNoteCount() == 1) || (met.getSixteenthNoteCount() == 3))
      s_bass.play(0.5, 1);

    if (met.getSixteenthNoteCount() % 2 == 1)
      s_hiHat.playWithJitter(0.3, 1);

    if (met.getSixteenthNoteCount() % 2 == 0)
      if (Math.randomf() > 0.7)
        s_hiHat.playWithJitter(0.2, 1);

    chan.setPan(Math.random2f(-0.5, 0.5));

    met.sixteenthNoteTick => now;
  }
}

fun void perc2Loop(Metronome met, int startMeasure, Channel chan) {
  Sample s_bass;
  s_bass.getBuff() => chan;
  chan.setup();
  s_bass.init("99sounds/kick-plain.wav");

  Sample s_hiHat;
  s_hiHat.getBuff() => chan;
  chan.setup();
  s_hiHat.init("99sounds/hihat-acoustic02.wav");

  met.waitTillMeasure(startMeasure);

  while (met.getMeasure() < SEQUENCE_LEN) {
    if ((met.getSixteenthNoteCount() == 1) || (met.getSixteenthNoteCount() == 3))
      s_bass.play(0.5, 1);

    if (met.getSixteenthNoteCount() % 2 == 1)
      s_hiHat.playWithJitter(0.3, 1);

    if (met.getSixteenthNoteCount() % 2 == 0)
      if (Math.randomf() > 0.7)
        s_hiHat.playWithJitter(0.2, 1);

    chan.setPan(Math.random2f(-0.5, 0.5));

    met.sixteenthNoteTick => now;
  }
}

fun void perc3Loop(Metronome met, int startMeasure, Channel chan) {
  Sample s_bass;
  s_bass.getBuff() => chan;
  chan.setup();
  s_bass.init("99sounds/kick-slapback.wav");

  Sample s_bass2;
  s_bass2.getBuff() => chan;
  chan.setup();
  s_bass2.init("99sounds/kick-plain.wav");

  Sample s_hiHat;
  s_hiHat.getBuff() => chan;
  chan.setup();
  s_hiHat.init("99sounds/hihat-acoustic02.wav");

  Sample s_hiHat2;
  s_hiHat2.getBuff() => chan;
  chan.setup();
  s_hiHat2.init("99sounds/hihat-dist01.wav");

  Sample s_clap;
  s_clap.getBuff() => chan;
  chan.setup();
  s_clap.init("99sounds/clap-808.wav");

  Sample s_ride;
  s_ride.getBuff() => chan;
  chan.setup();
  s_ride.init("99sounds/ride-acoustic02.wav");

  Sample s_crash;
  s_crash.getBuff() => chan;
  chan.setup();
  s_crash.init("99sounds/crash-acoustic.wav");

  Sample s_tom1;
  s_tom1.getBuff() => chan;
  chan.setup();
  s_tom1.init("99sounds/tom-acoustic01.wav");

  Sample s_tom2;
  s_tom2.getBuff() => chan;
  chan.setup();
  s_tom2.init("99sounds/tom-acoustic02.wav");

  Sample s_snare1;
  s_snare1.getBuff() => chan;
  chan.setup();
  s_snare1.init("99sounds/snare-smasher.wav");

  Sample s_snare2;
  s_snare2.getBuff() => chan;
  chan.setup();
  s_snare2.init("99sounds/snare-acoustic02.wav");

  chan.addLPF();

  met.waitTillMeasure(startMeasure);

  <<< "GO!" >>>;

  while (met.getMeasure() < SEQUENCE_LEN) {
    // kicks 
    if (
        (met.getSixteenthNoteCount() == 1) || 
        (met.getSixteenthNoteCount() == 5) || 
        (met.getSixteenthNoteCount() == 9) || 
        (met.getSixteenthNoteCount() == 13)
      ) {
      if (Math.randomf() > 0.6)
        s_bass.play(0.5, 1);
      if (Math.randomf() > 0.6)
        s_bass2.play(0.5, 1);
    }

    if (met.getSixteenthNoteCount() % 2 == 0) {
      if (Math.randomf() > 0.85)
        s_bass.play(0.2, 1);
      if (Math.randomf() > 0.85)
        s_bass2.play(0.2, 1);
    }

    // ride
    if (met.getSixteenthNoteCount() % 4 == 0) {
      if (Math.randomf() > 0.85)
        s_ride.play(0.15, 1);
    }

    // crash
    if (met.getSixteenthNoteCount() % 8 == 0) {
      if (Math.randomf() > 0.9)
        s_crash.play(0.1, 1);
    }

    // snare
    if (Math.randomf() > 0.85)
      s_snare1.play(0.45, 1);
    if (Math.randomf() > 0.85)
      s_snare2.play(0.45, 1);

    if (
        (met.getSixteenthNoteCount() > 4) &&
        (met.getSixteenthNoteCount() < 9)
      ) {
      if (Math.randomf() > 0.65)
        s_clap.play(Math.random2f(0.2, 0.5), Math.random2f(0.8, 1.2));
      if (Math.randomf() > 0.85)
        s_tom1.play(Math.random2f(0.2, 0.4), Math.random2f(0.95, 1.05));
      if (Math.randomf() > 0.85)
        s_tom2.play(Math.random2f(0.2, 0.4), Math.random2f(0.95, 1.05));
    }

    if (
        (met.getSixteenthNoteCount() > 12) &&
        (met.getSixteenthNoteCount() < 17)
      ) {
      if (Math.randomf() > 0.65)
        s_clap.play(Math.random2f(0.2, 0.5), Math.random2f(0.8, 1.2));
      if (Math.randomf() > 0.85)
        s_tom1.play(Math.random2f(0.2, 0.4), Math.random2f(0.95, 1.05));
      if (Math.randomf() > 0.85)
        s_tom2.play(Math.random2f(0.2, 0.4), Math.random2f(0.95, 1.05));
    }

    // hi hats
    if (Math.randomf() > 0.5)
      s_hiHat.playWithJitter(0.2, 1);
    if (Math.randomf() > 0.5)
      s_hiHat2.playWithJitter(0.2, 1);
    
    chan.setPan(Math.random2f(-0.5, 0.5));

    met.sixteenthNoteTick => now;
  }
}

fun void bassLoop(Metronome met, int startMeasure) {
  met.waitTillMeasure(startMeasure);
  24 => int offset;

  c_Bass.setRev(0.2);

  while (met.getMeasure() < startMeasure + 8) {
    met.getMeasure() % 4 => int m;

    if ((m == 0) || (m == 1)) {
      if (met.getEighthNoteCount() == 1) {
        Std.mtof(offset + scale[0]) => stk_bass.freq;
        1 => stk_bass.noteOn;
        met.getHalfBeatDur() => now;
        0 => stk_bass.noteOff;
      }
    }

    if ((m == 2)) {
      if (met.getEighthNoteCount() == 1) {
        Std.mtof(offset - 12 + scale[4]) => stk_bass.freq;
        1 => stk_bass.noteOn;
        met.getHalfBeatDur() => now;
        0 => stk_bass.noteOff;
      }
    }

    if ((m == 3)) {
      if (met.getEighthNoteCount() == 1) {
        Std.mtof(offset + scale[2]) => stk_bass.freq;
        1 => stk_bass.noteOn;
        met.getHalfBeatDur() => now;
        0 => stk_bass.noteOff;
      }
    }

    met.eighthNoteTick => now;
  }

  while (met.getMeasure() < SEQUENCE_LEN) {
    met.getMeasure() % 4 => int m;

    if ((m == 0) || (m == 1)) {
      if (met.getEighthNoteCount() == 1) {
        Std.mtof(offset + scale[0]) => stk_bass.freq;
        1.5 => stk_bass.noteOn;
        met.getHalfBeatDur() => now;
        0 => stk_bass.noteOff;
      }
      if ((met.getEighthNoteCount() == 7) || (met.getEighthNoteCount() == 8)) {
        Std.mtof(offset + scale[0]) => stk_bass.freq;
        1 => stk_bass.noteOn;
        met.getSixteenthBeatDur() => now;
        0 => stk_bass.noteOff;
      }
    }

    if ((m == 2)) {
      if (met.getEighthNoteCount() == 1) {
        Std.mtof(offset - 12 + scale[4]) => stk_bass.freq;
        1.5 => stk_bass.noteOn;
        met.getHalfBeatDur() => now;
        0 => stk_bass.noteOff;
      }
      if ((met.getEighthNoteCount() == 7) || (met.getEighthNoteCount() == 8)) {
        Std.mtof(offset - 12 + scale[4]) => stk_bass.freq;
        1 => stk_bass.noteOn;
        met.getSixteenthBeatDur() => now;
        0 => stk_bass.noteOff;
      }
    }

    if ((m == 3)) {
      if (met.getEighthNoteCount() == 1) {
        Std.mtof(offset + scale[2]) => stk_bass.freq;
        1.5 => stk_bass.noteOn;
        met.getHalfBeatDur() => now;
        0 => stk_bass.noteOff;
      }
      if ((met.getEighthNoteCount() == 7) || (met.getEighthNoteCount() == 8)) {
        Std.mtof(offset + scale[2]) => stk_bass.freq;
        1 => stk_bass.noteOn;
        met.getSixteenthBeatDur() => now;
        0 => stk_bass.noteOff;
      }
    }

    met.eighthNoteTick => now;
  }
}


fun void metlRuns(Metronome met, int startMeasure) {
  met.waitTillMeasure(startMeasure);
  48 => int base;

  met.getSixteenthBeatDur() => echo_metl0.delay;
  met.getQuarterBeatDur() => echo_metl0.max;
  c_metl0.setMaster(0.7);

  while (met.getMeasure() < SEQUENCE_LEN) {
    //if (Math.randomf() > 0.1) {
      scale[Math.random2(0, scale.cap() - 1)] => int note;
      base + (Math.random2(0, 2) * 12) => int offset;
      Std.mtof(offset + note) => stk_metl0.freq;
      c_metl0.setPan(Math.random2f(-1, 1));
      Math.random2f(0, 0.5) => echo_metl0.mix;
      1 => stk_metl0.noteOn;
      met.getEighthBeatDur() => now;
      0 => stk_metl0.noteOff;
    //}

    met.eighthNoteTick => now;
  }
}

fun void metl2Runs(Metronome met, int startMeasure, Channel chan) {
  ModalBar stk_metl => Echo echo_metl => chan;
  chan.setup();

  met.waitTillMeasure(startMeasure);

  48 => int base;

  while (met.getMeasure() < SEQUENCE_LEN) {
    48 => int base;
    2 => int step;
    base => int note;
    0 => int noteIndex;
    1 => int isBaseNote;

    0 => int echoType;

    if (echoType == 0) {
      met.getQuarterBeatDur() => echo_metl.delay;
      met.getQuarterBeatDur() => echo_metl.max;
    }

    if (echoType == 1) {
      met.getSixteenthBeatDur() => echo_metl.delay;
      met.getQuarterBeatDur() => echo_metl.max;
    }

    if (echoType == 2) {
      met.getEighthBeatDur() => echo_metl.delay;
      met.getQuarterBeatDur() => echo_metl.max;
    }

    (echoType + 1) % 3 => echoType;


    for (0 => int i; i < 32; i++) {
      if (isBaseNote == 1) {
        Std.mtof(note) => stk_metl.freq;
        (noteIndex + 1) % scale.cap() => noteIndex;
        if (noteIndex == 0)
          base + 12 => base;
        base + scale[noteIndex] => note;
        0 => isBaseNote;
      }
      else {
        Std.mtof(note + step) => stk_metl.freq;
        1 => isBaseNote;
      }

      chan.setPan(Math.random2f(-1, 1));
      Math.random2f(0.4, 0.5) => echo_metl.mix;
      1 => stk_metl.noteOn;
      met.getSixteenthBeatDur() => now;
      0 => stk_metl.noteOff;
    }


    for (0 => int i; i < 32; i++) {
      if (isBaseNote == 1) {
        Std.mtof(note) => stk_metl.freq;
        (noteIndex + 1) % scale.cap() => noteIndex;
        if (noteIndex == 0)
          base - 12 => base;
        base - scale[noteIndex] => note;
        0 => isBaseNote;
      }
      else {
        Std.mtof(note - step) => stk_metl.freq;
        1 => isBaseNote;
      }

      chan.setPan(Math.random2f(-1, 1));
      Math.random2f(0.4, 0.5) => echo_metl.mix;
      1 => stk_metl.noteOn;
      met.getSixteenthBeatDur() => now;
      0 => stk_metl.noteOff;
    }


    // met.getMeasureDur(1) => now;
  }
}