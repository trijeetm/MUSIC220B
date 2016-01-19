//-----------------------------------------------------------------------------
// name: milestone.ck
// desc: a simple milestone created using Brewery and some dope
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------
KSChord ks;
SndBuf buffy1 => ks => dac;
SndBuf buffy2 => ks => dac;
SndBuf buffy3 => ks => dac;
"special:dope" => buffy1.read;
"special:dope" => buffy2.read;
"special:dope" => buffy3.read;
0 => buffy1.gain;
0 => buffy2.gain;
0 => buffy3.gain;

Metronome metro;
metro.setup(120, 4, 4);
metro.start();

spork ~ phase1();
spork ~ phase2();
spork ~ phase3();
spork ~ ksMod();

metro.waitTillMeasure(16);

fun void ksMod() {
    Interpolator ksInterp;

    // 1
    60 => int offset;
    0.7 => float startFb;
    0.85 => float midFb;
    0.9999 => float endFb;
    ks.tune( 0 + offset, 4 + offset, 7 + offset, 10 + offset );
    ksInterp.setup(startFb, endFb, metro.getMeasureDur() * 4);
    ksInterp.interpolate();
    ksInterp.getCurrent() => float fb;
    while (fb != endFb) {
        ksInterp.getCurrent() => fb;
        ks.feedback(fb);
        10::samp => now;
    }
    // 2
    metro.waitForMeasures(2);
    ksInterp.setup(endFb, midFb, metro.getMeasureDur() * 2);
    ksInterp.interpolate();
    ksInterp.getCurrent() => fb;
    while (fb != midFb) {
        ksInterp.getCurrent() => fb;
        ks.feedback(fb);
        10::samp => now;
    }
    // 3
    60 => offset;
    ks.tune( 2 + offset, 5 + offset, 9 + offset, 14 + offset );
    ksInterp.setup(midFb, endFb, metro.getMeasureDur() * 4);
    ksInterp.interpolate();
    ksInterp.getCurrent() => fb;
    while (fb != endFb) {
        ksInterp.getCurrent() => fb;
        ks.feedback(fb);
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
        ks.feedback(fb);
        10::samp => now;
    }
}

fun void phase1() {
    // metro.waitTillMeasure(4);

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
            playBuff(buffy3, 0.1, 8);
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