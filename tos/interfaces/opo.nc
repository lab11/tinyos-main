/*
Basic interface for the opo mobile networking primitive
Author: William Huang
*/

interface Opo {
	command error_t transmit(message_t packet, size_t psize);
	/*
	Transmits an opo synchronization
	*/

	async void receive(uint32_t range, message_t msg);
	/*
	Triggers upon a successful opo synchronization/ranging
	*/
}