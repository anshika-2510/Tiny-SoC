module apb_decoder(input [7:0] paddr,
                   input pselx,
                   output reg pselx_i2c,
                   output reg pselx_spi,
                   output reg pselx_uart

    );
    always @(*)
    begin
    pselx_i2c  = 0;
    pselx_uart = 0;
    pselx_spi  = 0;
  if (paddr <= 8'h0F)
    pselx_i2c = 1;

else if (paddr <= 8'h1F)
    pselx_uart = 1;

else if (paddr <= 8'h2F)
    pselx_spi = 1;
    end
    
    
endmodule
