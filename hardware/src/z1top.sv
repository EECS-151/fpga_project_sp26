module z1top #(
    parameter int BAUD_RATE = 115_200,
    // Warning: CPU_CLOCK_FREQ must match the PLL parameters!
    parameter int CPU_CLOCK_FREQ = 100_000_000,
    // PLL Parameters: sets the CPU clock = 100Mhz * 36 / 4 / 9 = 100 MHz
    parameter int CPU_CLK_CLKFBOUT_MULT = 40,
    parameter int CPU_CLK_DIVCLK_DIVIDE = 4,
    parameter int CPU_CLK_CLKOUT_DIVIDE  = 10,
    
    /* verilator lint_off REALCVT */
    // Sample the button signal every 500us
    parameter int B_SAMPLE_CNT_MAX = int'(0.0005 * CPU_CLOCK_FREQ),
    // The button is considered 'pressed' after 100ms of continuous pressing
    parameter int B_PULSE_CNT_MAX = int'(0.100 / 0.0005),
    /* lint_on */
    // The PC the RISC-V CPU should start at after reset
    parameter logic [31:0] RESET_PC = 32'h4000_0000
) (
    input  logic        CLK_100_P,
    input  logic        CLK_100_N,
    input  logic [3:0]  BUTTONS,
    input  logic [7:0]  SWITCHES,
    output logic [7:0]  LEDS,
    input  logic        FPGA_SERIAL_RX,
    output logic        FPGA_SERIAL_TX
);

    logic CLK_100MHZ;
    `ifdef SYNTHESIS
    IBUFDS ibufds_clk (
        .I(CLK_100_P),
        .IB(CLK_100_N),
        .O(CLK_100MHZ)
    );
    `endif
    `ifndef SYNTHESIS
    assign CLK_100MHZ = CLK_100_P;
    `endif

    // Clocks and PLL lock status
    logic cpu_clk, cpu_clk_locked;

    // Buttons after the button_parser
    logic [3:0] buttons_pressed;

    // Switches after the synchronizer
    logic [7:0] switches_sync;

    // Reset the CPU and all components on the cpu_clk if the reset button is
    // pushed or whenever the CPU clock PLL isn't locked
    logic cpu_reset;
    assign cpu_reset = buttons_pressed[0] || !cpu_clk_locked;

    // Use IOBs to drive/sense the UART serial lines
    logic cpu_tx, cpu_rx;
    (* IOB = "true" *) logic fpga_serial_tx_iob;
    (* IOB = "true" *) logic fpga_serial_rx_iob;
    assign FPGA_SERIAL_TX = fpga_serial_tx_iob;
    assign cpu_rx = fpga_serial_rx_iob;

    always_ff @(posedge CLK_100MHZ) begin
        fpga_serial_tx_iob <= cpu_tx;
        fpga_serial_rx_iob <= FPGA_SERIAL_RX;
    end

    clocks #(
        .CPU_CLK_CLKFBOUT_MULT(CPU_CLK_CLKFBOUT_MULT),
        .CPU_CLK_DIVCLK_DIVIDE(CPU_CLK_DIVCLK_DIVIDE),
        .CPU_CLK_CLKOUT_DIVIDE(CPU_CLK_CLKOUT_DIVIDE)
    ) clk_gen (
        .clk_100mhz(CLK_100MHZ),
        .cpu_clk(cpu_clk),
        .cpu_clk_locked(cpu_clk_locked)
    );

    button_parser #(
        .WIDTH(4),
        .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
    ) bp (
        .clk(cpu_clk),
        .in(BUTTONS),
        .out(buttons_pressed)
    );

    synchronizer #(
        .WIDTH(8)
    ) switch_synchronizer (
        .clk(cpu_clk),
        .async_signal(SWITCHES),
        .sync_signal(switches_sync)
    );

    cpu #(
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ),
        .SYSTEM_CLOCK_FREQ(100_000_000),
        .RESET_PC(RESET_PC),
        .BAUD_RATE(BAUD_RATE)
    ) cpu_inst (
        .clk(cpu_clk),
        .rst(cpu_reset),
        .system_clk(CLK_100MHZ),
        .bp_enable(switches_sync[0]),
        .serial_out(cpu_tx),
        .serial_in(cpu_rx)
    );

    assign LEDS = 8'd0;
endmodule
