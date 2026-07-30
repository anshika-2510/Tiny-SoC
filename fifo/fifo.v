`timescale 1ns / 1ps

module fifo
#(
    parameter B = 8,   // number of bits in a word
    parameter W = 4    // number of address bits
)
(
    input wire clk,
    input wire reset,

    input wire rd,
    input wire wr,

    input wire [B-1:0] w_data,

    output wire empty,
    output wire full,

    output wire [B-1:0] r_data
);

    // signal declarations
    reg [B-1:0] array_reg [0:(2**W)-1];

    reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;

    reg full_reg, full_next;
    reg empty_reg, empty_next;

    wire wr_en; //combinational logic so wire


integer i;

always @(posedge reset)
begin
    for(i=0;i<16;i=i+1)
        array_reg[i] <= 0;
end
    // register file write operation
    always @(posedge clk)
        if (wr_en)
            array_reg[w_ptr_reg] <= w_data;  //storing

    // register file read operation
    assign r_data = array_reg[r_ptr_reg];

    // write enabled only when FIFO is not full
    assign wr_en = wr & ~full_reg;

    // registers for read and write pointers
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg  <= 1'b0;
            empty_reg <= 1'b1;
        end
        else
        begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end

    
    always @*
    begin

        w_ptr_succ = w_ptr_reg + 1;
        r_ptr_succ = r_ptr_reg + 1;

        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;

        full_next  = full_reg;
        empty_next = empty_reg;

        case ({wr, rd})

            2'b00:
            begin
                // no operation
            end

            2'b01: // read
            begin
                if (~empty_reg)
                begin
                    r_ptr_next = r_ptr_succ;
                    full_next  = 1'b0;    // removed data item so theres space

                    if (r_ptr_succ == w_ptr_reg)
                        empty_next = 1'b1;
                end
            end

            2'b10: // write
            begin
                if (~full_reg)
                begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;

                    if (w_ptr_succ == r_ptr_reg)
                        full_next = 1'b1;
                end
            end

            2'b11: // read and write
            begin
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;
            end

        endcase
    end

    // outputs
    assign full  = full_reg;
    assign empty = empty_reg;

endmodule
