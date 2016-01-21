//-----------------------------------------------------------------------------
// name: milestone.ck
// desc: a simple milestone created using Brewery and some dope
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------
KSChord ks1; 
KSChord ks2; 
KSChord ks3; 
Pan2 p;
// -1 => p.pan;
SndBuf buffy1 => ks1 => Channel c1; // => blackhole; 
c1.L() => dac.left; c1.R() => dac.right;
SndBuf buffy2 => ks2 => Channel c2; // => blackhole;
c2.L() => dac.left; c2.R() => dac.right;
SndBuf buffy3 => ks3 => Channel c3; // => blackhole;
c3.L() => dac.left; c3.R() => dac.right;
"special:dope" => buffy1.read;
"special:dope" => buffy2.read;
"special:dope" => buffy3.read;
0 => buffy1.gain;
0 => buffy2.gain;
0 => buffy3.gain;

<<< c1.L(), c1.R() >>>;

Metronome metro;
metro.setup(120, 4, 4);
metro.start();

spork ~ phase1();
spork ~ phase2();
spork ~ phase3();
spork ~ ksMod();
spork ~ channelMod();
spork ~ channelModMed();
spork ~ channelModFast();
spork ~ c3RevMod();

metro.waitTillMeasure(16);

fun void c3RevMod() {
    metro.waitForMeasures(1);
    c3.interpRev(0, 0.2, metro.getMeasureDur() * 2);
    c3.interpRev(0.2, 0.1, metro.getMeasureDur() * 1);

    metro.waitForMeasures(1);
    c3.interpRev(0.1, 0.2, metro.getMeasureDur() * 2);
    c3.interpRev(0.2, 0, metro.getMeasureDur() * 1);
}

fun void channelMod() {
    c1.interpPan(1, -1, metro.getMeasureDur() * 4);
    c1.interpPan(-1, 1, metro.getMeasureDur() * 4);

    c1.interpPan(1, -1, metro.getMeasureDur() * 4);
    c1.interpPan(-1, 1, metro.getMeasureDur() * 4);
}

fun void channelModMed() {
    c2.interpPan(1, -1, metro.getMeasureDur() * 2);
    c2.interpPan(-1, 1, metro.getMeasureDur() * 2);

    c2.interpPan(1, -1, metro.getMeasureDur() * 2);
    c2.interpPan(-1, 1, metro.getMeasureDur() * 2);

    c2.interpPan(1, -1, metro.getMeasureDur() * 2);
    c2.interpPan(-1, 1, metro.getMeasureDur() * 2);

    c2.interpPan(1, -1, metro.getMeasureDur() * 2);
    c2.interpPan(-1, 1, metro.getMeasureDur() * 2);
}

fun void channelModFast() {
    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);

    c3.interpPan(1, -1, metro.getMeasureDur() * 1);
    c3.interpPan(-1, 1, metro.getMeasureDur() * 1);
}

fun void ksMod() {
    Interpolator ksInterp;

    // 1
    60 => int offset;
    0.7 => float startFb;
    0.85 => float midFb;
    0.9999 => float endFb;
    ks1.tune( 0 + offset, 4 + offset, 7 + offset, 10 + offset );
    ks2.tune( 0 + offset, 4 + offset, 7 + offset, 10 + offset );
    ks3.tune( 0 + offset, 4 + offset, 7 + offset, 10 + offset );
    ksInterp.setup(startFb, endFb, metro.getMeasureDur() * 4);
    ksInterp.interpolate();
    ksInterp.getCurrent() => float fb;
    while (fb != endFb) {
        ksInterp.getCurrent() => fb;
        ks1.feedback(fb);
        ks2.feedback(fb);
        ks3.feedback(fb);
        10::samp => now;
    }
    // 2
    metro.waitForMeasures(2);
    ksInterp.setup(endFb, midFb, metro.getMeasureDur() * 2);
    ksInterp.interpolate();
    ksInterp.getCurrent() => fb;
    while (fb != midFb) {
        ksInterp.getCurrent() => fb;
        ks1.feedback(fb);
        ks2.feedback(fb);
        ks3.feedback(fb);
        10::samp => now;
    }
    // 3
    60 => offset;
    ks1.tune( 2 + offset, 5 + offset, 9 + offset, 14 + offset );
    ks2.tune( 2 + offset, 5 + offset, 9 + offset, 14 + offset );
    ks3.tune( 2 + offset, 5 + offset, 9 + offset, 14 + offset );
    ksInterp.setup(midFb, endFb, metro.getMeasureDur() * 4);
    ksInterp.interpolate();
    ksInterp.getCurrent() => fb;
    while (fb != endFb) {
        ksInterp.getCurrent() => fb;
        ks1.feedback(fb);
        ks2.feedback(fb);
        ks3.feedback(fb);
        10::samp => now;
    }
    // 4
    metro.waitForMeasures(2);
    <<< "!" >>>;
    ksInterp.setup(endFb, startFb, metro.getMeasureDur() * 2);
    ksInterp.interpolate();
    ksInterp.getCurrent() => fb;
    while (fb != startFb) {
        ksInterp.getCurrent() => fb;
        ks1.feedback(fb);
        ks2.feedback(fb);
        ks3.feedback(fb);
        10::samp => now;
    }
}

fun void phase1() {
    metro.waitTillMeasure(4);

    while (metro.getMeasure() < 8) {
        if (metro.getQuarterNoteCount() == 0)
            playBuff(buffy1, 0.5, 0.5);
        metro.quarterNoteTick => now;
    }

    while (metro.getMeasure() < 16) {
        if ((metro.getQuarterNoteCount() == 0) ||
            (metro.getQuarterNoteCount() == 1))
            playBuff(buffy1, 0.4, 0.6);
        metro.quarterNoteTick => now;
    }
}

fun void phase2() {
    metro.waitTillMeasure(2);

    while (metro.getMeasure() < 16) {
        if ((metro.getQuarterNoteCount() == 2) || (metro.getQuarterNoteCount() == 3))
            playBuff(buffy2, 0.3, 1);
        metro.quarterNoteTick => now;
    }
}

fun void phase3() {
    metro.waitTillMeasure(4);

    while (metro.getMeasure() < 10) {
        if ((metro.getEighthNoteCount() == 2) || 
            (metro.getEighthNoteCount() == 3) ||
            (metro.getEighthNoteCount() == 5) ||
            (metro.getEighthNoteCount() == 6) ||
            (metro.getEighthNoteCount() == 7))
            playBuff(buffy3, 0.2, 8);
        metro.eighthNoteTick => now;
    }

    while (metro.getMeasure() < 16) {
        if ((metro.getSixteenthNoteCount() == 0) || 
            (metro.getSixteenthNoteCount() == 1) ||
            (metro.getSixteenthNoteCount() == 2) ||
            (metro.getSixteenthNoteCount() == 3) ||
            (metro.getSixteenthNoteCount() == 5) ||
            (metro.getSixteenthNoteCount() == 7) ||
            (metro.getSixteenthNoteCount() == 8) ||
            (metro.getSixteenthNoteCount() == 9) ||
            (metro.getSixteenthNoteCount() == 10) ||
            (metro.getSixteenthNoteCount() == 11))
            playBuff(buffy3, 0.1, 8);
        metro.sixteenthNoteTick => now;
    }
}

fun void playBuff(SndBuf buff, float gain, float rate) {
    0 => buff.pos;
    gain => buff.gain;
    rate => buff.rate;
}