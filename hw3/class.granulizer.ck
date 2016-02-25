//-----------------------------------------------------------------------------
// name: granulizer.ck
// desc: a granular synthesis engine
//
// authors: Trijeet Mukhopadhyay (trijeetm@ccrma.stanford.edu)
// date: winter 2016
//       Stanford University
//-----------------------------------------------------------------------------

public class Granulizer {
    // overall volume
    1 => float MAIN_VOLUME;
    // grain duration base
    50::ms => dur GRAIN_LENGTH;
    // factor relating grain duration to ramp up/down time
    .5 => float GRAIN_RAMP_FACTOR;
    // playback rate
    1 => float GRAIN_PLAY_RATE;
    // grain position (0 start; 1 end)
    0 => float GRAIN_POSITION;
    // grain position randomization
    .001 => float GRAIN_POSITION_RANDOM;
    // grain jitter (0 == periodic fire rate)
    1 => float GRAIN_FIRE_RANDOM;

    false => int GRANULATE;

    // max lisa voices
    30 => int LISA_MAX_VOICES;

    LiSa @ lisa;

    PoleZero blocker;
    // pole location to block DC and ultra low frequencies
    0.98 => blocker.blockZero;

    fun void setup(string file, Channel channel) {
        channel.setMaster(0);
        load(file) @=> lisa;
        lisa.chan(0) => blocker => channel;
        channel.setup();
    }

    fun void granulize() {
        true => GRANULATE;
        // main loop
        while (GRANULATE)
        {
            // fire a grain
            fireGrain();
            // amount here naturally controls amount of overlap between grains
            GRAIN_LENGTH / 8 + Math.random2f(0, GRAIN_FIRE_RANDOM)::ms => now;
        }
    }

    fun void stopGranulizer() {
        false => GRANULATE;
    }

    fun void setPos(float pos) {
        pos => GRAIN_POSITION;
    }

    fun void setPos(float start, float end, dur duration) {
        start => GRAIN_POSITION;
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() => GRAIN_POSITION;
            interp.delta => now;
        }
        interp.getCurrent() => GRAIN_POSITION;
    }

    fun void setRate(float start, float end, dur duration) {
        start => GRAIN_PLAY_RATE;
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() => GRAIN_PLAY_RATE;
            interp.delta => now;
        }
        interp.getCurrent() => GRAIN_PLAY_RATE;
    }

    fun void setLength(float len) {
        len * second => GRAIN_LENGTH;
    }

    fun void setLength(float start, float end, dur duration) {
        start * second => GRAIN_LENGTH;
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() * second => GRAIN_LENGTH;
            interp.delta => now;
        }
        interp.getCurrent() * second => GRAIN_LENGTH;
    }

    fun void setRandomness(float rand) {
        rand => GRAIN_POSITION_RANDOM;
    }

    fun void setRandomness(float start, float end, dur duration) {
        start => GRAIN_POSITION_RANDOM;
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            interp.getCurrent() => GRAIN_POSITION_RANDOM;
            interp.delta => now;
        }
        interp.getCurrent() => GRAIN_POSITION_RANDOM;
    }

    // load file into a LiSa
    fun LiSa load(string _filename)
    {
        me.sourceDir() + "/samples/" => string path;
        path + _filename => string filename;

        // sound buffer
        SndBuf buffy;
        // load it
        filename => buffy.read;
        
        // new LiSa
        LiSa lisa;
        // set duration
        buffy.samples()::samp => lisa.duration;
        
        // transfer values from SndBuf to LiSa
        for( 0 => int i; i < buffy.samples(); i++ )
        {
            // args are sample value and sample index
            // (dur must be integral in samples)
            lisa.valueAt( buffy.valueAt(i), i::samp );        
        }
        
        // set LiSa parameters
        lisa.play( false );
        lisa.loop( false );
        lisa.maxVoices( LISA_MAX_VOICES );
        
        return lisa;
    }

    // fire!
    fun void fireGrain()
    {
        // grain length
        GRAIN_LENGTH => dur grainLen;
        // ramp time
        GRAIN_LENGTH * GRAIN_RAMP_FACTOR => dur rampTime;
        // play pos
        GRAIN_POSITION + Math.random2f(0,GRAIN_POSITION_RANDOM) => float pos;
        // a grain
        if( lisa != null && pos >= 0 )
            spork ~ grain( lisa, pos * lisa.duration(), grainLen, rampTime, rampTime, 
            GRAIN_PLAY_RATE );
    }

    // grain sporkee
    fun void grain( LiSa @ lisa, dur pos, dur grainLen, dur rampUp, dur rampDown, float rate )
    {
        // get a voice to use
        lisa.getVoice() => int voice;

        // if available
        if( voice > -1 )
        {
            // set rate
            lisa.rate( voice, rate );
            // set playhead
            lisa.playPos( voice, pos );
            // ramp up
            lisa.rampUp( voice, rampUp );
            // wait
            (grainLen - rampUp) => now;
            // ramp down
            lisa.rampDown( voice, rampDown );
            // wait
            rampDown => now;
        }
    }
}