//--------------------------------------------------------------------------------
// Company: N/A
// Engineer: Martin G.
// 
// Create Date: 29.08.2023 18:30:56
// Design Name: 
// Module Name: AD9648_Sniffer - Behavioral
// Project Name: Eclypse Z7 SPI AD9648 sniffer
// Target Devices: Eclypse Z7
// Tool Versions: 2021.2
// Description: Top level entity for Eclypse Z7 SPI AD9648 sniffer
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//--------------------------------------------------------------------------------

`timescale 1ps/1ps

module AD9648_Sniffer 
(
    // 125MHz input clock
    input wire          sys_clock,

    // User buttons
    input wire          btn0,
    input wire          btn1,

    // User RGB LEDs
    output wire [2:0]   led0,
    output wire [2:0]   led1,

    // Zmod Digitizer module's I/Os
    input wire [13:0]   diZmodADC_Data,
    input wire          DcoClkIn,
    //output wire         CG_InputClk_n, // Unused for this
    //output wire         CG_InputClk_p, // IP customization
    input wire          aCG_PLL_Lock,
    output wire         aREFSEL,
    output wire         aHW_SW_CTRL,
    output wire         aZmodSync,
    output wire         sPDNout_n,
    inout wire          sZmodADC_SDIO,
    output wire         sZmodADC_CS,
    output wire         sZmodADC_Sclk,
    inout wire          CDCE_SDA,
    inout wire          CDCE_SCL,

    // Zmod Digitizer SPI bus for configuration sniffing
    output wire         ADC_SDIO_spy,
    output wire         ADC_CS_spy,
    output wire         ADC_Sclk_spy
);

// Clocks and resets signals
wire        SampleClk;
wire        SysClk100;
wire        SysResetn;

// Zmod Digitizer SPI CS and Sclk signals
wire        sZmodADC_CS_s;
wire        sZmodADC_Sclk_s;
wire        ADC_SDIO_spy_s;

reg         ADCEn;

// Zmod Digitizer I2C signals
wire        s_scl_i;
wire        s_scl_o;
wire        s_scl_t;
wire        s_sda_i;
wire        s_sda_o;
wire        s_sda_t;

// Zmod Digitizer data stream
(* MARK_DEBUG = "TRUE" *)
wire [31:0] ADCdata_d;
wire        ADCdata_v;
wire        ADCdata_r;

//-----------------------------------------------------
// Clocks and resets generation
Clocks_Resets Clocks_Resets_inst
(
    .sys_clk             (sys_clock         ),
    .SampleClk           (SampleClk         ),
    .ext_reset_in        (btn1              ),
    .locked              (                  ),
    .SysClk100           (SysClk100         ),
    .SampleClk_shift     (                  ),
    .SysResetn           (SysResetn         ),
    .SampleResetn        (                  )
);

//-----------------------------------------------------
// Digitizer IP and control
ZmodDigitizerCtrl ZmodDigitizerCtrl_inst
(
    .SysClk100           (SysClk100         ),
    .ClockGenPriRefClk   (1'b0              ),
    .sInitDoneClockGen   (                  ),
    .sPLL_LockClockGen   (                  ),
    .ZmodDcoClkOut       (SampleClk         ),
    .sZmodDcoPLL_Lock    (                  ),
    .aRst_n              (SysResetn         ),
    .sInitDoneADC        (                  ),
    .sConfigError        (                  ),
    .sEnableAcquisition  (ADCEn             ),
    .doDataAxisTvalid    (ADCdata_v         ),
    .doDataAxisTready    (ADCdata_r         ),
    .doDataAxisTdata     (ADCdata_d         ),
    .sTestMode           (1'b0              ), // TODO : instantiate a VIO to toggle testmode
    .aZmodSync           (aZmodSync         ),
    .DcoClkIn            (DcoClkIn          ),
    .diZmodADC_Data      (diZmodADC_Data    ),
    .sZmodADC_SDIO       (sZmodADC_SDIO     ),
    .sZmodADC_CS         (sZmodADC_CS_s     ),
    .sZmodADC_Sclk       (sZmodADC_Sclk_s   ),
    .CG_InputClk_p       (                  ),
    .CG_InputClk_n       (                  ),
    .aCG_PLL_Lock        (aCG_PLL_Lock      ),
    .aREFSEL             (aREFSEL           ),
    .aHW_SW_CTRL         (aHW_SW_CTRL       ),
    .sPDNout_n           (sPDNout_n         ),
    .s_scl_i             (s_scl_i           ),
    .s_scl_o             (s_scl_o           ),
    .s_scl_t             (s_scl_t           ),
    .s_sda_i             (s_sda_i           ),
    .s_sda_o             (s_sda_o           ),
    .s_sda_t             (s_sda_t           )
);

// Whenever the sink is ready, enable the ADC
    // The IP's reference manual states this signal
    // should never be de-asserted after so hold it
always @(posedge SysClk100) begin
    if(ADCdata_r)
        ADCEn <= 1'b1;
    else
        ADCEn <= ADCEn;
end

// Instantiate OBUFTs for CDCE IIC interface
IOBUF # (
    .DRIVE      (12         ),
    .IOSTANDARD ("LVCMOS18" ),
    .SLEW       ("SLOW"     )
) sda_IOBUF_inst (
    .O          (s_sda_i    ),
    .IO         (CDCE_SDA   ),
    .I          (s_sda_o    ),
    .T          (s_sda_t    )
);

IOBUF # (
    .DRIVE      (12         ),
    .IOSTANDARD ("LVCMOS18" ),
    .SLEW       ("SLOW"     )
)scl_IOBUF_inst (
    .O          (s_scl_i    ),
    .IO         (CDCE_SCL   ),
    .I          (s_scl_o    ),
    .T          (s_scl_t    )
);

// ADC always ready
assign ADCdata_r = 1'b1;

// Digitizer's SPI bus
assign sZmodADC_CS     = sZmodADC_CS_s;
assign sZmodADC_Sclk   = sZmodADC_Sclk_s;
//-----------------------------------------------------


//-----------------------------------------------------
// Assign ADC calibration spy outputs
assign ADC_SDIO_spy_s = 1'b0;
OBUF OBUF_SDIO_inst(
    .O          (ADC_SDIO_spy),
    .I          (ADC_SDIO_spy_s)
);
assign ADC_CS_spy   = sZmodADC_CS_s;
assign ADC_Sclk_spy = sZmodADC_Sclk_s;
//-----------------------------------------------------

endmodule
