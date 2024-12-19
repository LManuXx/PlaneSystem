ADA::
	gcc -c devices.c
	gnatmake -c control2.adb
	gnatbind control2.ali
	gnatlink control2.ali devices.o -lwiringPi -lm -lrt

clean::
	rm *.o control2

all:: C
