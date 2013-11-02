#include "printf.h"

module IdPrinterP {
    uses {
        interface Boot;
        interface ReadId48 as IdReader;
    }
}

implementation {
    uint8_t id[6];
    uint8_t i;

    event void Boot.booted() {
        call IdReader.read(&id[0]);
        printf("Id: 0x");
        for(i=0; i < 6; i++) {
            printf("%x", id[i]);
        }
        printf("\n");
        printfflush();
    }
}