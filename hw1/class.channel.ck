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

    0 => rev.mix;
    0 => pan.pan;

    inlet => rev => master => pan => outlet;

    fun UGen L() { return pan.left; }
    fun UGen R() { return pan.right; }

    // range (0, ?)
    fun void setMaster(float g) {
        g => master.gain;
    }

    // range (-1, 1)
    fun void setPan(float p) {
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
            interpPan.getCurrent() => pan.pan;
            interpPan.delta => now;
        }
        interpPan.getCurrent() => pan.pan;

    }

    fun void interpMaster(float start, float end, dur duration) {
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
}