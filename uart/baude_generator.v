`timescale 1ns / 1ps

    input clk,
    input rst,
    output tx_enb,
    output rx_enb
);

reg [12:0] tx_ct;
reg [9:0]  rx_ct;

// TX baud (9600)
always @(posedge clk)
begin
    if(rst)
        tx_ct <= 0;
    else if(tx_ct == 5208)
        tx_ct <= 0;
    else
        tx_ct <= tx_ct + 1;
end

// RX 16x baud
always @(posedge clk)
begin
    if(rst)
        rx_ct <= 0;
    else if(rx_ct == 325)
        rx_ct <= 0;
    else
        rx_ct <= rx_ct + 1;
end

assign tx_enb = (tx_ct == 5208);
assign rx_enb = (rx_ct == 0);

endmodule




