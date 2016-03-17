//-----------------------------------------------------------------------------
// name: music.ck
// desc: 
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------

// ----------------
// Graunlizer setup
// ----------------

4 => int N_GRANULIZERS;
Channel channels[N_GRANULIZERS];
Granulizer granulizers[N_GRANULIZERS];

// -----------------
// Continous Control
// -----------------
0 => int cc_id;

main();

fun void main() {
  // Metronome metro;
  // metro.setup(90, 4, 4);  

  // granulizers init
  granulizers[0].setup(0, "piston.wav", channels[0]);
  granulizers[1].setup(1, "glass.wav", channels[1]);
  granulizers[2].setup(2, "piston.wav", channels[2]);
  granulizers[3].setup(3, "glass.wav", channels[3]);
  
  // MIDI setup
  MidiIn MIDIInput;

  if (MIDIInput.open(0)) {
    <<< "device: ", MIDIInput.name(), "->", "open: SUCCESS" >>>;
    spork ~ handleMIDI(MIDIInput);
  }
  else {
    <<< "couldn't open any midi device, exiting..." >>>;
    me.exit();
  }

  // Trackpad setup
  /*
  HidIn trackpad;
  if (trackpad.openMouse(0)) {
    <<< "mouse '", trackpad.name(), "' ready" >>>;
    spork ~ handleTrackpad(trackpad);
  }
  else {
    <<< "couldn't open any trackpad, exiting..." >>>;
    me.exit();
  }
  */

  // infinite time loop
  while (true) 
    1::second => now;
}

fun void handleMIDI(MidiIn inputStream) {
  MidiMsg msg;

  while (true) {
    inputStream => now;

    while (inputStream.recv(msg))
      handleMIDIInput(msg.data1, msg.data2, msg.data3);
  }
}

fun void handleMIDIInput(int data1, int data2, int data3) {
  // <<< "msg: ", data1, data2, data3 >>>;
  // track selector
  if ((data2 >= 16) && (data2 <= 23)) {
    if (data1 == 176)
      0 => cc_id;
    if (data1 == 177)
      1 => cc_id;
    if (data1 == 178)
      2 => cc_id;
    if (data1 == 179)
      3 => cc_id;
  }

  // granulizer / pos
  if (data2 == 20)
    granulizers[cc_id].setPos((data3 / 127.0));
  // granulizer / length
  if (data2 == 21)
    granulizers[cc_id].setLength((data3 / 127.0));
  // granulizer / rate
  if (data2 == 23) {
    ((data3 / 127.0) * 2) => float r;
    granulizers[cc_id].setRate(r);
  }
  if (data2 == 19) {
    (((data3 / 127.0) * 6) + 2) => float r;
    if (granulizers[cc_id].GRAIN_PLAY_RATE == 2)
      granulizers[cc_id].setRate(r);
  }
  // granulizer / fire rate
  if ((data1 == 144) && (data2 == 101))
    granulizers[cc_id].decGrainFireRate();
  if ((data1 == 144) && (data2 == 100))
    granulizers[cc_id].incGrainFireRate();

  // gain / reverb
  if (data2 == 7) {
    if (data1 == 176)
      channels[0].setMaster((data3 / 127.0));
    if (data1 == 177)
      channels[0].setRev((data3 / 127.0));

    if (data1 == 178)
      channels[1].setMaster((data3 / 127.0));
    if (data1 == 179)
      channels[1].setRev((data3 / 127.0));

    if (data1 == 180)
      channels[2].setMaster((data3 / 127.0));
    if (data1 == 181)
      channels[2].setRev((data3 / 127.0));

    if (data1 == 182)
      channels[3].setMaster((data3 / 127.0));
    if (data1 == 183)
      channels[3].setRev((data3 / 127.0));
  }

  // state toggle
  if ((data1 == 144) && (data2 == 91))
    granulizers[cc_id].start();
  if ((data1 == 144) && (data2 == 92))
    granulizers[cc_id].stop();;
  if ((data1 == 144) && (data2 == 93))
    granulizers[cc_id].fireGrain();

  // pan
  if (data2 == 48)
    channels[0].setPan(((data3 - 64.0) / 64.0));
  if (data2 == 49)
    channels[1].setPan(((data3 - 64.0) / 64.0));
  if (data2 == 50)
    channels[2].setPan(((data3 - 64.0) / 64.0));
  if (data2 == 51)
    channels[3].setPan(((data3 - 64.0) / 64.0));
}

/*
fun void handleTrackpad(HidIn trackpad) {
  HidMsg msg;

  while (true) {
    trackpad => now;

    while (trackpad.recv(msg)) {
      if (msg.isMouseMotion()) {
        if (msg.deltaX) {
          (msg.deltaX * 0.0001) + channels[cc_id].pan.pan() => float _pan;
          <<< _pan >>>;
          channels[cc_id].setPan(_pan);
        }
      }
    }
  }
}
*/

fun void intro(Metronome metro, int startMeasure) {
  metro.waitTillMeasure(startMeasure);

  Channel c_piston;
  Granulizer g_piston;

  g_piston.setup(0, "piston.wav", c_piston);

  Channel c_glass;
  Granulizer g_glass;

  g_glass.setup(1, "glass.wav", c_glass);

  // --- 1 --- //
  spork ~ g_piston.granulize();
  g_piston.setLength(0.5);
  g_piston.setPos(0);
  g_piston.setRate(7.5);
  // spork ~ g_piston.setLength(0.8, 0.25, metro.getMeasureDur(16));
  // spork ~ g_piston.setPos(0, 0.75, metro.getMeasureDur(16));
  // spork ~ g_piston.setRate(1, 4, metro.getMeasureDur(16));
  spork ~ c_piston.interpMaster(0.5, 0.7, metro.getMeasureDur(16));
  c_piston.setRev(0.25);

  spork ~ g_glass.granulize();
  spork ~ c_glass.interpMaster(0.1, 0.3, metro.getMeasureDur(4));
  // spork ~ g_glass.setPos(0, 0.5, metro.getMeasureDur(16));
  // spork ~ g_glass.setLength(0.1, 0.5, metro.getMeasureDur(16));
  // spork ~ g_glass.setRate(1, 4, metro.getMeasureDur(16));
  g_glass.setLength(0.5);
  g_glass.setPos(0);
  g_glass.setRate(4);
  c_glass.setRev(0.25);

  while (true) {
    spork ~ g_piston.setLength(Math.randomf(), metro.getMeasureDur(2));
    spork ~ g_piston.setPos(Math.randomf(), metro.getMeasureDur(2));
    spork ~ g_piston.setRate(Math.random2f(0.1, 8), metro.getMeasureDur(2));
    spork ~ c_piston.interpPan(Math.random2f(-1, 1), metro.getMeasureDur(3));
    spork ~ c_piston.setMaster(Math.random2f(0.1, 0.9));

    spork ~ g_glass.setLength(Math.randomf(), metro.getMeasureDur(2));
    spork ~ g_glass.setPos(Math.randomf(), metro.getMeasureDur(2));
    spork ~ g_glass.setRate(Math.random2f(0.1, 8), metro.getMeasureDur(2));
    spork ~ c_glass.interpPan(Math.random2f(-1, 1), metro.getMeasureDur(3));
    spork ~ c_glass.setMaster(Math.random2f(0.05, 0.5));

    metro.waitForMeasures(4);
  }

  metro.waitTillMeasure(72);
}

fun void logger(Metronome met) {
  while (true) {
    <<< met.getMeasure(), met.getQuarterNoteCount() >>>;
    met.quarterNoteTick => now;
  }
}