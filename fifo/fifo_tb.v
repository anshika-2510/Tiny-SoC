module fifo_tb;

    reg clk;
    reg reset;
    reg rd;
    reg wr;
    reg [7:0] w_data;

    wire empty;
    wire full;
    wire [7:0] r_data;

    fifo uut (
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .wr(wr),
        .w_data(w_data),
        .empty(empty),
        .full(full),
        .r_data(r_data)
    );
    initial 
      begin
    clk = 0;
    reset = 0;
    wr = 0;
    rd = 0;
    w_data = 0;
     end
 always #5 clk=~clk; 
initial begin

    reset = 1;
    #20;

reset = 0;

@(negedge clk);
wr = 1;
w_data = 8'd10;

@(posedge clk);

@(negedge clk);
w_data = 8'd20;

@(posedge clk);

@(negedge clk);
w_data = 8'd30;

@(posedge clk);

@(negedge clk);
wr = 0;
rd = 1;
 @(posedge clk); //perform 3 reads
 @(posedge clk);
 @(posedge clk);
    rd=0;
    #10;
    $finish;

end
always @(posedge clk)
begin
    $display("T=%0t wr=%b wptr=%d wdata=%h arr0=%h arr1=%h arr2=%h",
              $time,
              wr,
              uut.w_ptr_reg,
              w_data,
              uut.array_reg[0],
              uut.array_reg[1],
              uut.array_reg[2]);
end
endmodule
