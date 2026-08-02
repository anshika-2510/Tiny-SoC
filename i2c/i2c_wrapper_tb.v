`timescale 1ns / 1ps

module apb_wrapper_i2c_tb( );
 // APB bus signals
wire [7:0] paddr;
wire [7:0] pwdata;
wire pwrite;
wire pselx;
wire penb;

wire [7:0] prdata;
wire pready;
wire pslverr;

// APB master interface
reg start;
reg wr;
reg [7:0] addr;
reg [7:0] tx_data;

// APB master status outputs
wire busy;
wire done;
wire [7:0] rx_data;
wire error;

// I2C bus
wire sda;
wire scl;

reg sda_drive;
reg sda_slave;
reg clk,rst;
assign sda = (sda_drive) ? sda_slave : 1'bz;

apb_wrapper_i2c wrapper(

    .clk(clk),
    .rst(rst),

    .paddr(paddr),
    .pwdata(pwdata),
    .pwrite(pwrite),
    .pselx(pselx),
    .penb(penb),

    .sda(sda),
    .scl(scl),

    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr)

);
apb_master master(

    .pclk(clk),
    .prst(rst),

    .pready(pready),
    .prdata(prdata),
    .slverr(pslverr),

    .start(start),
    .wr(wr),
    .addr(addr),
    .tx_data(tx_data),

    .paddr(paddr),
    .pwdata(pwdata),
    .pselx(pselx),
    .penb(penb),

    .busy(busy),
    .done(done),

    .pwrite(pwrite),

    .rx_data(rx_data),
    .error(error)

); 
always #5 clk=~clk;

initial
begin

    clk = 0;
    rst = 1;

    start = 0;
    wr = 0;
    addr = 0;
    tx_data = 0;

    sda_drive = 0;
    sda_slave = 1;

    #20;
    rst = 0;
    //1st write
    addr = 8'h04;
    tx_data = 8'h68;
    wr = 1;

    start = 1;
    #10;
    start = 0;

    wait(done);
    #20;
    //2nd write
     addr = 8'h08;
    tx_data = 8'hA5;
    wr = 1;

    start = 1;
    #10;
    start = 0;

    wait(done);
    #20;
    //3rd write
     addr = 8'h00;
tx_data = 8'b00000001;   // START=1, RW=0
wr = 1;

start = 1;
#10;
start = 0;

wait(done);
#20;


    // Wait for address ACK
    wait(wrapper.i2c.state ==4'd3);        // WAITACK

    // Slave ACKs address
    sda_drive = 1;
    sda_slave = 0;

    // Hold ACK until master enters WRITE_DATA
    wait(wrapper.i2c.state == 4'd4);        // WRITE_DATA

    // Release SDA so master can drive data
    sda_drive = 0;

    // Wait until master finishes transmitting
    wait(wrapper.i2c.state == 4'd5);        // WAITACK2

    // Slave ACKs data byte
    sda_drive = 1;
    sda_slave = 0;

    // Hold ACK until STOP
    wait(wrapper.i2c.state == 4'd6);        // STOP

    sda_drive = 0;
    #100;
   
    wait(wrapper.i2c.done);
$display("WRITE TRANSACTION COMPLETED");
#100;
$finish;
end                                          
endmodule
