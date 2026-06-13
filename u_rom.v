
module u_rom (
    input  wire        clk,
    input  wire [31:0] instr_addr,
    output reg  [31:0] instr_rdata
);
    
    reg [31:0] rom_memory [0:255];
    
    initial begin
        // Initialize with NOPs or compiled firmware hex
        $readmemh("firmware.hex", rom_memory);
    end

    always @(posedge clk) begin
        instr_rdata <= rom_memory[instr_addr >> 2];
    end
endmodule