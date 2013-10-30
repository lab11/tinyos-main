configuration UartTestC {}
implementation {
	components MainC, LedsC, UartTestP;
    UartTestP.Boot -> MainC.Boot;
    UartTestP.Leds -> LedsC.Leds;

    components PlatformSerialC;
    UartTestP.UartStream -> PlatformSerialC.UartStream;
    UartTestP.UartControl -> PlatformSerialC;

    components new TimerMilliC() as SendTimer;
    UartTestP.SendTimer -> SendTimer;

}