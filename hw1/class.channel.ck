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

    inlet => rev => pan => master => outlet;

    // range (0, ?)
    fun void setGain(float g) {
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
        while (start != end) {
            interpPan.getCurrent() => pan.pan;
            1::samp => now;
        }
    }

    fun void interpMaster(float start, float end, dur duration) {
        Interpolator iGain;
        iGain.setup(start, end, duration);
        while (start != end) {
            iGain.getCurrent() => master.gain;
            1::samp => now;
        }
    }

    fun void interpRev(float start, float end, dur duration) {
        Interpolator iRev;
        iRev.setup(start, end, duration);
        while (start != end) {
            iRev.getCurrent() => rev.mix;
            1::samp => now;
        }
    }
}