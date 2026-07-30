module uart_tx(

    input clk,
    input rst,
    input enb,
    input wr_enb,
    input [7:0] datain,

    output reg tx,
    output busy

);

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;
reg [7:0] temp;
reg [2:0] index;

always @(posedge clk)
begin

    if(rst)
    begin
        state <= IDLE;
        tx <= 1'b1;
        temp <= 0;
        index <= 0;
    end

    else
    begin

        case(state)

        IDLE:
        begin
            tx <= 1'b1;

            if(wr_enb)
            begin
                temp <= datain;
                index <= 0;
                state <= START;
            end
        end

        START:
        begin
            tx <= 1'b0;

            if(enb)
            begin
                tx <= temp[0];
                index <= 1;
                state <= DATA;
            end
        end

        DATA:
        begin

            if(enb)
            begin
                tx <= temp[index];

                if(index == 7)
                    state <= STOP;
                else
                    index <= index + 1;

            end

        end

        STOP:
        begin

            if(enb)
            begin
                tx <= 1'b1;
                state <= IDLE;
            end

        end

        endcase

    end

end

assign busy = (state != IDLE);
endmodule
