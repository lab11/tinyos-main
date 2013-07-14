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
    opo_bmsg_t *data = (opo_bmsg_t *) payload;
    int i;
    printf("Range:%lu\n", data->rec.range);
    printf("Seq:%lu\n", data->rec.sequence);
    printf("RX_ID:0x");
    for(i = 0; i < 6; i++) {
      printf("%x", data->m_id[i]);
    }
    printf("\n");
    printf("TX_ID:0x");
    for(i = 0; i < 6; i++) {
      printf("%x", data->rec.o_id[i]);
    }
    printf("\n");
    printf("RSSI:%i\n", data->rec.rssi);
    printf("Sec:%u\n", data->rec.seconds);
    printf("Min:%u\n", data->rec.minutes);
    printf("Hour:%u\n", data->rec.hours);
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