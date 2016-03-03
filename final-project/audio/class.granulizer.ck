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
    // grain duration
    0::ms => dur SAMPLE_LENGTH;
    // 0::ms => dur GRAIN_LENGTH;
    0 => float GRAIN_LENGTH;
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

    0 => int id;

    // ----
    // lisa
    // ----
    
    200 => int LISA_MAX_VOICES;

    LiSa @ lisa;

    PoleZero blocker;
    // pole location to block DC and ultra low frequencies
    0.98 => blocker.blockZero;

    // ----

    // ---
    // osc
    // ---

    // name
    "localhost" => string hostname;
    4242 => int port;

    // send object
    OscSend xmit;

    // aim the transmitter
    xmit.setHost( hostname, port );

    // ---

    fun void setup(int _id, string file, Channel channel) {
        _id => id;

        // init graphics
        xmit.startMsg( "/granulizer/init", "i" );
        id => xmit.addInt;

        channel.setMaster(0);
        load(file) @=> lisa;
        lisa.chan(0) => blocker => channel;
        channel.setup();

        setPos(0);
        setLength(0);
    }

    fun void granulize() {
        true => GRANULATE;
        // main loop
        while (GRANULATE)
        {
            // fire a grain
            fireGrain();
            // amount here naturally controls amount of overlap between grains
            // SAMPLE_LENGTH / 32 + Math.random2f(0, GRAIN_FIRE_RANDOM)::ms => now;
            5000::ms => now;
        }
    }

    fun void stopGranulizer() {
        false => GRANULATE;
    }

    fun void setPos(float pos) {
        pos => GRAIN_POSITION;

        xmit.startMsg( "/granulizer/prop/pos", "f" );
        pos => xmit.addFloat;
    }

    fun void setPos(float start, float end, dur duration) {
        setPos(start);
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setPos(interp.getCurrent());
            interp.delta => now;
        }
        setPos(interp.getCurrent());
    }

    fun void setRate(float rate) {
        rate => GRAIN_PLAY_RATE;
    }

    fun void setRate(float start, float end, dur duration) {
        setRate(start);
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setRate(interp.getCurrent());
            interp.delta => now;
        }
        setRate(interp.getCurrent());
    }

    fun void setLength(float len) {
        len => GRAIN_LENGTH;

        xmit.startMsg( "/granulizer/prop/len", "f" );
        len => xmit.addFloat;
    }

    fun void setLength(float start, float end, dur duration) {
        setLength(start);
        Interpolator interp;
        interp.setup(start, end, duration);
        interp.interpolate();
        while (interp.getCurrent() != interp.end) {
            setLength(interp.getCurrent());
            interp.delta => now;
        }
        setLength(interp.getCurrent());
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

        // get length
        buffy.length() => SAMPLE_LENGTH;
        0 => GRAIN_LENGTH;
        
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

        // send sample data to processing
        0 => int s;
        for (int i; i < 200; i++) {
            xmit.startMsg("/granulizer/setup", "f");
            buffy.valueAt(s) => float _samp;
            0.01 => float min;
            if (_samp < 0)
                -1 *=> _samp;
            if (_samp < min)
                min => _samp;
            _samp => xmit.addFloat;
            (buffy.samples() / 200) +=> s;
        }
        xmit.startMsg( "/granulizer/setup", "f" );
        -1 => xmit.addFloat;
        
        return lisa;
    }

    // fire!
    fun void fireGrain()
    {
        // grain length
        GRAIN_LENGTH * SAMPLE_LENGTH => dur grainLen;
        // ramp time
        grainLen * GRAIN_RAMP_FACTOR => dur rampTime;
        // play pos
        GRAIN_POSITION + Math.random2f(0,GRAIN_POSITION_RANDOM) => float pos;

        // xmit.startMsg( "/granulizer/fire", "f f f" );
        // GRAIN_POSITION => xmit.addFloat;
        // GRAIN_LENGTH => xmit.addFloat;
        xmit.startMsg( "/granulizer/fire", "f" );
        (grainLen / 1::second) / GRAIN_PLAY_RATE => xmit.addFloat;

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