module uart_rx(

    input clk,
    input rst,
    input rdy_clr,
    input clk_enb,
    input rx,

    output reg rdy,
    output reg [7:0] dataout

);

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;

reg [3:0] sample;
reg [2:0] index;

reg [7:0] temp;

always @(posedge clk)
begin

    if(rst)
    begin
        state   <= IDLE;
        sample  <= 0;
        index   <= 0;
        temp    <= 0;
        dataout <= 0;
        rdy     <= 0;
    end

    else
    begin

        if(rdy_clr)
            rdy <= 0;

        if(clk_enb)
        begin

            case(state)

            IDLE:
            begin
                sample <= 0;
                index  <= 0;
                  temp<=0;
                if(rx == 0)
                    state <= START;
            end
              
            START:
            begin

                sample <= sample + 1;

                if(sample == 7)
                begin

                    if(rx == 0)
                    begin
                        sample <= 0;
                        index  <= 0;
                        state  <= DATA;
                    end

                    else
                    begin
                        sample <= 0;
                        state <= IDLE;
                    end

                end

            end

            DATA:
            begin

                sample <= sample + 1;

                if(sample == 15)
                begin
                    sample <= 0;

                    temp[index] <= rx;

                    if(index == 7)
                        state <= STOP;
                    else
                        index <= index + 1;

                end

            end

            STOP:
            begin

                sample <= sample + 1;

                if(sample == 15)
                begin

                    sample <= 0;

                    if(rx == 1)
                    begin
                        dataout <= temp;
                        rdy <= 1'b1;
                    end

                    state <= IDLE;

                end

            end

            default:
                state <= IDLE;

            endcase

        end

    end

end

endmodule
           
