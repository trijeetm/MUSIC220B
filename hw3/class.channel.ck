//-----------------------------------------------------------------------------
// name: channel.ck
// desc: a multichannel system for brewery
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------

public class Channel extends Chubgraph {
    Pan2 pan;
    Gain master;
    NRev rev;
    LPF lpf;

    0 => rev.mix;
    0 => pan.pan;
    20000 => lpf.freq;

    inlet => rev => master => pan => outlet;

    // outlet is not stereo, so instead on connection outlet to dac, connect 
    // Channel.L and Channel.R as shown below
    // Channel.L() => dac.left; Channel.R() => dac.right;
    fun UGen L() { return pan.left; }
    fun UGen R() { return pan.right; }

    fun void addLPF() {
        inlet =< rev;
        inlet => lpf => rev;
    }

    fun void setup() {
        L() => dac.left;
        R() => dac.right;
    }

    // range (0, ?)
    fun void setMaster(float g) {
        g => master.gain;
    }

    // range (-1, 1)
    fun void setPan(float p) {
        if (p > 1)
            1 => p;
        if (p < -1)
            -1 => p;
        p => pan.pan;
    }

    fun void setRev(float mix) {
        mix => rev.mix;
    }

    fun void interpPan(float start, float end, dur duration) {
        Interpolator interpPan;
        interpPan.setup(start, end, duration);
        interpPan.interpolate();
        while (interpPan.getCurrent() != interpPan.end) {
            setPan(interpPan.getCurrent());
            interpPan.delta => now;
        }
        setPan(interpPan.getCurrent());

    }

    fun void interpMaster(float start, float end, dur duration) {
        start => master.gain;
        Interpolator iGain;
        iGain.setup(start, end, duration);
        iGain.interpolate();
        while (iGain.getCurrent() != iGain.end) {
            iGain.getCurrent() => master.gain;
            iGain.delta => now;
        }
        iGain.getCurrent() => master.gain;
    }

    fun void interpRev(float start, float end, dur duration) {
        Interpolator iRev;
        iRev.setup(start, end, duration);
        iRev.interpolate();
        while (iRev.getCurrent() != iRev.end) {
            iRev.getCurrent() => rev.mix;
            iRev.delta => now;
        }
        iRev.getCurrent() => rev.mix;
    }

    fun void setLPF(float freq, float Q) {
        freq => lpf.freq;
        Q => lpf.Q;
    }

    fun void interpLPFFreq(float start, float end, dur duration) {
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() => lpf.freq;
            interp.delta => now;
        }
        interp.getCurrent() => lpf.freq;
    }

    fun void interpLPFQ(float start, float end, dur duration) {
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() => lpf.Q;
            interp.delta => now;
        }
        interp.getCurrent() => lpf.Q;
    }
}