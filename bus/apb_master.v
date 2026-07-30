`timescale 1ns / 1ps

module apb_master( input pclk,
input prst,
input pready,
input [7:0] prdata ,

input slverr,
input start,
input wr,
input [7:0] addr,
input [7:0] tx_data,
output reg [7:0] paddr,
output reg [7:0] pwdata ,
output reg pselx,
output reg penb,
output reg busy,
output reg done ,
output reg pwrite,
output reg [7:0] rx_data, 
output reg error
    );
    
    localparam [1:0] IDLE=2'b00;
    localparam [1:0] SETUP=2'b01;
    localparam [1:0] ACCESS=2'b10;
    
    reg [1:0] state ;
    
 always@(posedge pclk or posedge prst )  
 begin
  if(prst)
  begin
  state<=IDLE;
  done<=0;
  busy<=0; 
 pselx<=0;
 penb<=0;
 pwrite<=0;
 paddr  <= 0;
pwdata <= 0;
error<=0;
rx_data<= 0;
  end
  
 else
 begin
   case (state)
   IDLE:
   begin
   pselx<=0;
   done<=0;
   busy<=0;
   penb<=0;
   if(start)
   begin
   busy<=1;
   state<=SETUP;
   end
   end
   
   SETUP:
   begin
   busy<=1;
   error<=0; //new transaction
   pselx<=1;
   penb<=0;
   paddr<=addr;
   pwrite<=wr;
   if(wr)
   pwdata<=tx_data;
   
   state<=ACCESS;
   end
   
   ACCESS:
   begin
   pselx<=1;
   penb<=1;
   
    if ( pready) 
    begin
     if(slverr)
        error <= 1;
    else
        error <= 0;
     if (! pwrite)
     rx_data<=prdata;
     
     done <= 1;
    busy <= 0;
     state<=IDLE;
    end
   end
   
 default: state<=IDLE;
 endcase
 end
 end    
endmodule
