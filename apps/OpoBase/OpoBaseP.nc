#include "printf.h"
#include "OpoBase.h"

module OpoBaseP {
  uses {
    interface AMSend as OpoAckSend;
    interface Receive as DataReceive;
    interface Receive as ProbeReceive;
    interface SplitControl as RfControl;
    interface AMPacket;
    interface Boot;
    interface Leds;
  }
}

implementation {
  message_t packet;
  bool sendLock = FALSE;

  event void Boot.booted() {
    call RfControl.start();
    printf("Booted\n");
    printfflush();
  }

  event message_t* DataReceive.receive(message_t *msg, void *payload, uint8_t len) {
    opo_rec_t *rec = (opo_rec_t *) payload;
    am_addr_t return_addr = call AMPacket.source(msg);
    printf("Range: %lu\n", rec->range);
    printf("Seq: %lu\n", rec->sequence);
    printf("RID: %u\n", return_addr);
    printf("ID: %u\n", rec->id);
    printf("RSSI: %i\n", rec->rssi);
    printf("Sec: %u\n", rec->seconds);
    printf("Min: %u\n", rec->minutes);
    printf("Hour: %u\n", rec->hours);
    printfflush();
    return msg;
  }

  event message_t* ProbeReceive.receive(message_t *msg, void *payload, uint8_t len) {
    am_addr_t return_addr = call AMPacket.source(msg);
    message_t p;
    atomic {
      if (sendLock == FALSE) {
        sendLock = TRUE;
        call OpoAckSend.send(return_addr, &packet, 0);
      }
    }
    
    return msg;
  }

  event void OpoAckSend.sendDone(message_t *msg, error_t error) {
    atomic sendLock = FALSE;
  }

  event void RfControl.startDone(error_t err) {}
  event void RfControl.stopDone(error_t err) {}

}