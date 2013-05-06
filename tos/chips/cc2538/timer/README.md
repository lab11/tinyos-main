CC2538 Timers
=============

The 32 kHz and millisecond timers are based on the hardware sleep timer so that
they can wake the microcontroller from sleep. The microsecond timers are based
on the general pupose timers and run off of the system clock

Component Wiring Diagram
------------------------

    --
    |                                                                     Counter32khz32C
    |   AlarmMilli16C()                                                     |
    |   AlarmMilli32C()                                                     |  Counter32khz16C
    |   Alarm32khz16C()                                                     |   |\
    |H        |\                                                            |   | Counter32khz16P
    |I        | TransformAlarmC()                                           |   |/
    |L        |/                                                            |   |  CounterMilli32C       CounterMicro32C
    |   Alarm32khz32C()            AlarmMicro32C()     AlarmMicro16C()      |   |  CounterMilli16C       CounterMicro16C
    |         |\                     |\                  |\                 |   |   |\                       |\
    --        | HalAlarmP()          | HalAlarmP()       | HalAlarmP()      |   |   | TransformCounterC()    | HalCounterMicroP()
    |H        |/                     |/                  |/                 |   |   |/                       |/
    |A     HalTimer32khz32C()      HalTimerMicro32C()  HalTimerMicro16C()  HalCounter32khz32C                |
    |L             |                       |                   |                  |                          |
    --             -------------------------------------------------------------------------------------------
    |                                |
    |H            -------------- HplTimerC --------------
    |P           /                                       \
    |L     HplSleepTimerP()              ------------HplGpTimerP() --------
    |           |                      /             |        |           \
    -------------------------------------------------------------------------------
    HW   ---------------         ----------  ----------  ------------  ------------
         | Sleep Timer |         | GPT 1A |  | GPT 2A |  | GPT 3A+B |  | GPT 4A+B |
         ---------------         ----------  ----------  ------------  ------------
