configuration TimerTestC {

}

implementation {
    components MainC, SerialStartC, PrintfC, TimerTestP;
    TimerTestP.Boot -> MainC.Boot;

    components new TimerMilliC() as Timer1;
    components new TimerMilliC() as Timer2;
    TimerTestP.Timer1 -> Timer1;
    TimerTestP.Timer2 -> Timer2;
}