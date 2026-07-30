`timescale 1ns / 1ps

module i2c_master(
input clk,
input rst,
input start,
input rw_bit,
input [6:0] slave_add,
input [7:0] tx_data,

output reg [7:0] rx_data,
output reg error,
inout  sda,
output reg scl,
output reg done,
output reg busy
    );
    
  reg [3:0] state;
    reg [7:0] div;
    reg sda_oe;
    wire sda_in;
    reg [3:0] ct;
    reg [7:0] temp;
    reg scl_d;
    
wire rise;
wire fall;

assign rise = (~scl_d) & scl;
assign fall = scl_d & (~scl);
 assign sda =sda_oe ? 1'b0 :1'bz; //open drain logic
assign sda_in=sda;
  
localparam IDLE       = 4'b0000;
localparam START      = 4'b0001;
localparam ADDRESS    = 4'b0010;
localparam WAITACK    = 4'b0011;
localparam WRITE_DATA = 4'b0100;
localparam WAITACK2   = 4'b0101;
localparam STOP       = 4'b0110;
localparam READ_DATA  = 4'b0111;
localparam ERROR      = 4'b1000;


always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        div   <= 0;
        scl   <= 1;
        scl_d <= 1;
    end
    else
    begin
        // store previous SCL value
        scl_d <= scl;

        if(busy)
        begin
            if(div == 4)
            begin
                div <= 0;
                scl <= ~scl;
            end
            else
            begin
                div <= div + 1;
            end
        end
        else
        begin
            div <= 0;
            scl <= 1;
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst)
       begin
         state<=IDLE;
         done<=0;
         busy<=0;
         error<=0;
        rx_data<=0;
        sda_oe<=0;
        ct<=0;
        temp<=0;
        end
   else
     begin
         case(state)

IDLE:
begin
    busy <= 0;
    done <= 0;
    sda_oe <= 0;          // release SDA
    error<=0;
    if(start)
    begin
        busy  <= 1;
        
        state <= START;
    end
end

START:
begin
  
    sda_oe <= 1;          //  SDA goes low while SCL is high
    temp <= {slave_add, rw_bit};   // 7-bit address + R/W bit
    ct   <= 0;
    state <= ADDRESS;
end

ADDRESS:
begin
    if (fall)
    begin
    if(ct < 8)
    begin
        if(temp[7])
            sda_oe <= 0;      // Send '1' (release SDA)
        else
            sda_oe <= 1;      // Send '0' (pull SDA LOW)

        temp <= temp << 1;
        ct <= ct + 1;
    end
    else
    begin
        ct <= 0;
        state <= WAITACK;
    end
end
end

WAITACK:
begin

    sda_oe <= 0;          // Release SDA so slave can ACK
    if (rise)
    begin
    if(!sda_in)
    begin
        ct <= 0;
    
        if(rw_bit)
            state <= READ_DATA;
        else
        begin
             temp<=tx_data;
            state <= WRITE_DATA;
            
            end
    end
     else 
     state<=ERROR;
end
end

WRITE_DATA:
begin
    if(fall)
    begin
   
    if(ct < 8)
    begin
        if(temp[7])
            sda_oe <= 0;      // Send '1'
        else
            sda_oe <= 1;      // Send '0'

        temp <= temp << 1;
        ct   <= ct + 1;

    end

    else
    begin
        ct <= 0;
        state <= WAITACK2;
    end
end
end
                             
READ_DATA:
begin
    sda_oe <= 0; 
     if (rise)
     begin     
       $display("ct=%0d sda_in=%b temp=%b", ct, sda_in, temp);  // Release SDA \
    if(ct < 8)
    begin
        temp <= {temp[6:0], sda_in};   // Shift in received bit
        ct   <= ct + 1;
    end
    else
    begin
        rx_data <= temp;
        ct  <= 0;
        state<= WAITACK2;      
    end
end
end                     
    WAITACK2:
     begin
       if (rise)
       begin
       if (rw_bit == 0)
       begin
       
       sda_oe<=0;
       //9th pusle
        if (!sda_in)
        begin
        state<=STOP;
        end
        else
        state<=ERROR;             
       end    
       
       else
          begin
        // READ operation
        // Master sends NACK = 1
        sda_oe <= 0;          // Release SDA -> bus goes HIGH (NACK)
        // Hold this for the 9th SCL pulse
        state <= STOP;
       
    end
       end         
 end                   
 STOP:                   
      begin
         busy<=0;
         done<=1;
         sda_oe<=0;
         state<=IDLE;   
         end        
  
    ERROR:
begin
    error <= 1;
    busy <= 0;
    done <= 1; 
    state <= IDLE;
end         
  default: state<=IDLE;                          
 endcase
 end
end 
endmodule
