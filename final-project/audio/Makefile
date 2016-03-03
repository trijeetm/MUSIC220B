CLASSES = class.interpolator.ck class.sample.ck class.metronome.ck class.channel.ck class.ks.ck class.ks-chord.ck class.granulizer.ck
DEFAULTEXEC = client.ck
RECORD = rec-auto.ck

all: 
	chuck $(CLASSES) $(DEFAULTEXEC)

test_classes: 
	chuck $(CLASSES)

client: 
	chuck $(CLASSES) client.ck

milestone: 
	chuck $(CLASSES) milestone.ck

music: 
	chuck $(CLASSES) music.ck

record_music: 
	chuck $(CLASSES) music.ck $(RECORD)

quitely_record_music: 
	chuck --silent $(CLASSES) music.ck $(RECORD)