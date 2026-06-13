
`timescale 1ns / 1ps

module tb_sha256_top();

    reg clk;
    reg rst_n;
    reg psel;
    reg penable;
    reg pwrite;
    reg [31:0] paddr;
    reg [31:0] pwdata;
    
    wire [31:0] prdata;
    wire done_pqc;

    top uut (
        .clk(clk), .rst_n(rst_n),
        .psel(psel), .penable(penable), .pwrite(pwrite),
        .paddr(paddr), .pwdata(pwdata),
        .prdata(prdata), .done_pqc(done_pqc)
    );

    always #10 clk = ~clk;

    initial begin
        // System Init
        clk = 0; rst_n = 0;
        psel = 0; penable = 0; pwrite = 0; paddr = 0; pwdata = 0;

        #25 rst_n = 1;

        // APB Message Offload
        @(posedge clk);
        psel = 1; pwrite = 1; paddr = 32'h0000_0000; pwdata = 32'hDEADBEEF;
        @(posedge clk) penable = 1;
        @(posedge clk) penable = 0; paddr = 32'h0000_003C; pwdata = 32'hA1B2C3D4; 
        @(posedge clk) penable = 1; // Start trigger
        @(posedge clk);
        psel = 0; penable = 0; pwrite = 0;

        // Wait for FSM autonomous loop
        wait(done_pqc == 1'b1);
        
        // APB Read Weight
        @(posedge clk);
        psel = 1; pwrite = 0; paddr = 32'h0000_0100;
        @(posedge clk) penable = 1;
        
        $display("Valid PQC Sparse Vector Found!");
        $display("Calculated Weight: %d", prdata);
        
        #50 $stop;
    end
endmodule