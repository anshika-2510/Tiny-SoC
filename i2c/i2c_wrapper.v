`timescale 1ns / 1ps

module apb_wrapper_i2c(
input clk,
input rst,
input [7:0] paddr,
input [7:0] pwdata,
input pwrite,
input pselx,
input penb,
inout sda,
output scl, // eeprom needs it so 
output reg [7:0] prdata,
output  pready,
output  pslverr);

assign pready = 1'b1;
assign pslverr =1'b0;
reg [7:0] control_reg;
reg [6:0] slave_addr_reg;
reg [7:0] tx_data_reg;
reg rw_reg;
reg start_pulse;

wire busy;
wire done;
wire error;
wire [7:0] rx_data;        // come from i2c core, not apb outputs

i2c_master i2c(
    .clk(clk),
    .rst(rst),
    .start(start_pulse),
    .rw_bit(rw_reg),
    .slave_add(slave_addr_reg),
    .tx_data(tx_data_reg),
    .rx_data(rx_data),
    .error(error),
    .sda(sda),
    .scl(scl),
    .done(done),
    .busy(busy)
);

always @(posedge clk or posedge rst)
begin
   if(rst)
    begin
 control_reg <=0;
 slave_addr_reg<=0;
 tx_data_reg <=0;
rw_reg<=0;
start_pulse<=0;
prdata<=0;
    end
    else
    begin
      start_pulse<=0;
        if(pselx && penb && pwrite)
        begin
            case(paddr)
            8'h00:
             begin
            control_reg <= pwdata;
            rw_reg <= pwdata[1];
             if(pwdata[0])
              start_pulse<= 1;
                end
            8'h04:   //slave addr
            begin
            slave_addr_reg<=pwdata[6:0];
            end
            8'h08:
            begin
            tx_data_reg<=pwdata;
            end
            default: ;
             endcase

        end
        else if ( pselx && penb && !pwrite)
        begin
          case(paddr)   
            8'h0C:
            begin
            prdata<= {5'b00000, error, done, busy};
            end
            8'h10:
            begin
            prdata<=rx_data;
            end
            default: prdata<=8'h00;
           
            endcase

        end

    end

end


endmodule
