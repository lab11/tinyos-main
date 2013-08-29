configuration IdPrinterC {}

implementation {
    components MainC, SerialStartC, PrintfC, IdPrinterP;
    IdPrinterP.Boot -> MainC.Boot;

    components Ds2411C;
    IdPrinterP.IdReader -> Ds2411C;
}