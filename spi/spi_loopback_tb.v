module spi_master_slave_tb(

    );
wire sclk; // these are the actual bus wires connecting master and slave
wire mosi;
wire miso;
wire cs;

reg clk;   // master side signals
reg rst;
reg start;
reg [7:0] master_tx_data;
wire [7:0] master_rx_data;
wire busy;
wire done;

reg [7:0] slave_tx_data; // slave side signals
wire [7:0] slave_rx_data;

spi_master master (
    .clk(clk),
    .rst(rst),
    .start(start),
    .tx_data(master_tx_data),
    .miso(miso),

    .sclk(sclk),
    .mosi(mosi),
    .cs(cs),

    .rx_data(master_rx_data),
    .busy(busy),
    .done(done)
);
spi_slave slave (
    .sclk(sclk),
    .cs(cs),
    .mosi(mosi),
    .rst(rst),

    .miso(miso),

    .tx_data(slave_tx_data),
    .rx_data(slave_rx_data)
);

initial
begin
{clk,rst,start}=0;
master_tx_data=0;
slave_tx_data=0;
end 
always #5 clk=~clk;

initial
begin 
rst=1;
#10;
rst=0;
master_tx_data = 8'hA5;
slave_tx_data  = 8'h3C;
start=1;
#20;
start=0;
#1500;
$finish;
end
endmodule
