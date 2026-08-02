module tx_tb(

    );
    
    reg clk,rst,enb,wr_enb;
    reg[7:0] data;
    wire tx,busy;
     uart_tx dut(clk,rst,enb,wr_enb,data,tx,busy);
     initial
     begin
      {clk,rst,enb,wr_enb,data}=0;
      end
     always #5 clk=~clk;
     
     initial
     begin 
     rst=1;
     
     enb=1;
     data=8'h55;
     
     #10;
     rst=0;
     #10;
     wr_enb=1;
     #10;
     wr_enb=0;
     #150;
   
     $finish;
     
     end  
endmodule
