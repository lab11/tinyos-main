/*
Basic interface for the opo mobile networking primitive
Author: William Huang
*/

interface Opo {
	command error_t transmit(message_t* packet, size_t psize);
	event void transmit_done();

	command error_t enable_receive();
	command error_t disable_receive();

	event void receive(uint32_t range, message_t* msg);
	event void receive_failed();

    command error_t setup_pins();
}