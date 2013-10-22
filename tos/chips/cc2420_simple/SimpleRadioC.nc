
configuration SimpleRadioC {
	provides {
		interface SimpleRadio;
	}
}
implementation {

	components SimpleRadioP;

	components new Msp430Spi0C() as SpiC;
	SimpleRadioP.SpiByte -> SpiC.SpiByte;

	components new Alarm32khz16C() as CC2420StartUpAlarm;
	SimpleRadioP.CC2420StartUpAlarm -> CC2420StartUpAlarm;

	components HplMsp430GeneralIOC as GpIO;

	SimpleRadioP.VREG -> GpIO.Port45;
	SimpleRadioP.CSN -> GpIO.Port42;
	SimpleRadioP.SFD -> GpIO.Port41;
	SimpleRadioP.RESET -> GpIO.Port46;
	SimpleRadioP.FIFOP -> GpIO.Port10;
	SimpleRadioP.FIFO -> GpIO.Port13;
	SimpleRadioP.CCA -> GpIO.Port14;


}