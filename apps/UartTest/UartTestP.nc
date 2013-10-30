module UartTestP {
	uses {
		interface UartStream;
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as SendTimer;
		interface StdControl as UartControl;
	}
}
implementation {
	uint8_t msg[5];
	uint8_t *p;

	event void Boot.booted(){
		char msg[6];
		msg[0] = 'h';
		msg[1] = 'e';
		msg[2] = 'l';
		msg[3] = 'l';
		msg[4] = 'o';
		msg[5] = '\n';
		p = msg;
		call Leds.led0On();
		call UartControl.start();
		call UartStream.send(p, sizeof(msg));
	}

	async event void UartStream.receivedByte(uint8_t byte) {

	}

	async event void UartStream.receiveDone(uint8_t *buf, uint16_t len, error_t error) {

	}

	async event void UartStream.sendDone(uint8_t *buf, uint16_t len, error_t error) {
		call Leds.led0Toggle();
		call SendTimer.startOneShot(2000);
	}

	event void SendTimer.fired() {
		call UartStream.send(p, sizeof(msg));
	}

}