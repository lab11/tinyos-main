#include "printf.h"

module TimerTestP {
    uses {
        interface Boot;
        interface Timer<TMilli> as Timer1;
        interface Timer<TMilli> as Timer2;
    }
}

implementation {
    uint32_t t0;
    uint32_t tn;
    uint32_t dt;
    event void Boot.booted() {
        call Timer1.startOneShot(1320);
        call Timer2.startOneShot(2000);
    }

    event void Timer1.fired() {
        call Timer2.stop();
        tn = call Timer2.getNow();
        t0 = call Timer2.gett0();
        dt = call Timer2.getdt();
        printf("T0: %lu\n", t0);
        printf("TN: %lu\n", tn);
        printf("Dt: %lu\n", dt);
        printfflush();

    }

    event void Timer2.fired() {

    }
}