interface SimpleRadio {

	async command error_t turnOn();
	async command error_t turnOff();

	event void turnedOn();
	event void turnedOff();

	event void received();

}