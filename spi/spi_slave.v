
module spi_slave(input sclk,
input cs,
input mosi,
input rst,
output reg miso,
input [7:0] tx_data,
output reg [7:0] rx_data  );

reg [7:0] tx_shift;
reg [7:0] rx_shift;
reg [2:0] ct;


always @(negedge cs)
begin
tx_shift<=tx_data;
//miso <= tx_data[7];
ct<=0;
rx_shift<=0;
rx_data<=0;
end
always @ (posedge sclk or posedge rst)
begin
 if(rst)
    begin
        ct <= 0;
        tx_shift <= 0;
        rx_shift <= 0;
        rx_data <= 0;
        miso <= 0;
    end
 else
 begin
 
 
if (cs==0)
begin
miso <= tx_shift[7];
tx_shift <= tx_shift << 1;
 rx_shift <= {rx_shift[6:0], mosi};
if(ct == 6)
begin
   rx_data <= {rx_shift[6:0], mosi};
    ct <= ct + 1;
end
else
    ct <= ct + 1;
  end 
end
end    
endmodule
