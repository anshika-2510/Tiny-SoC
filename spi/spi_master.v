
module spi_master(
input clk,
input rst,
input start,
input [7:0] tx_data,
input miso,

output reg sclk,
output reg mosi,
output reg cs,
output reg [7:0]  rx_data,
output reg busy,
output reg  done
    );
    
reg [7:0] tx_shift;
reg [7:0] rx_shift;
reg [2:0] ct;
reg [1:0] state;

    
  localparam  IDLE=2'b00;
  localparam  LOAD=2'b01;
  localparam  TRANSFER=2'b10;
  
  reg[3:0] div_ct;
 
 always @(posedge clk or posedge rst) 
 begin
  if (rst)
   begin 
 state <= IDLE;
cs <= 1;
sclk <= 0;
mosi <= 0;
busy <= 0;
done <= 0;
ct <= 0;
div_ct<=0;

tx_shift <= 0;
rx_shift <= 0;
rx_data <= 0;
   end
   
   else
      begin
       case (state)
      
         IDLE:
         begin   
         cs<=1;
         busy<=0;
         done<=0;
         sclk<=0; // if sclk remains high frm transfer , if sclk=0 then becomes 1 at end of clock edge , comes here needs to reset to 0 ( MODE 0)
         if (start)
         begin
         state<=LOAD;
         end
         
         end 
         LOAD:
         begin
         sclk<=0;
         div_ct <= 0;         // we want every transder to start from fresh 
       //  mosi <= tx_data[7]; // not mandatory // timing issue , transfer ralr has
         tx_shift <= tx_data;
         ct <= 0;
         cs <= 0;
         busy <= 1;
         rx_shift <= 0;
         state<=TRANSFER;
         end
      
      
      TRANSFER:
      begin
      div_ct<=div_ct+1;
      if(div_ct==4)
      begin
      div_ct<=0;
       if(sclk==0)
       begin
       mosi <= tx_shift[7];
      tx_shift <= tx_shift << 1;
  //  tx_shift <= tx_shift << 1;
//mosi <= tx_shift[6];
      rx_shift <= {rx_shift[6:0], miso};
     
         if(ct==7)
         begin
           rx_data<= {rx_shift[6:0], miso};  //non blocking so to get last bit 
        done<=1;
      state<=IDLE;
      cs <= 1;
     busy <= 0;
         end
        else
         ct<=ct+1;
        end
      sclk<=~sclk;
      end
      end
      default: state<=IDLE;
     endcase
      end
       end        
 endmodule   

