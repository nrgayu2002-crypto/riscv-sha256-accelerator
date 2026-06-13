
module top (
    input  wire clk,
    input  wire rst_n,
    
    // APB Ports (Driven by external testbench or RISC-V core)
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] paddr,
    input  wire [31:0] pwdata,
    output wire [31:0] prdata,
    output wire        done_pqc
);

    // Internal routing signals
    wire         start_hash;
    wire [511:0] message_block;
    wire [255:0] final_hash;
    wire         hash_valid;
    wire [7:0]   weight_out;
    wire         weight_valid;
    wire         silent_reset;

    // APB Slave Interface
    apb_slave u_apb (
        .clk(clk), .rst_n(rst_n),
        .psel(psel), .penable(penable), .pwrite(pwrite),
        .paddr(paddr), .pwdata(pwdata), .prdata(prdata),
        .start_hash(start_hash), .message_block(message_block),
        .hw_weight(weight_out), .done_pqc(done_pqc)
    );

    // SHA-256 Core
    sha256_core u_sha256 (
        .clk(clk), .rst_n(rst_n & ~silent_reset),
        .start_hash(start_hash), .message_block(message_block),
        .final_hash(final_hash), .hash_valid(hash_valid)
    );

    // Hamming Weight Pipeline
    hamming_pipeline u_hamming (
        .clk(clk), .rst_n(rst_n & ~silent_reset),
        .hash_in(final_hash), .valid_in(hash_valid),
        .weight_out(weight_out), .valid_out(weight_valid)
    );

    // FSM Decision Logic
    fsm_pqc u_fsm (
        .clk(clk), .rst_n(rst_n),
        .weight_in(weight_out), .weight_valid(weight_valid),
        .done_pqc(done_pqc), .silent_reset(silent_reset)
    );

    // Memory stubs (Unconnected in this top-level, used by RISC-V directly)
    // u_rom u_boot_rom (.clk(clk), .instr_addr(32'b0), .instr_rdata());
    // u_ram u_data_ram (.clk(clk), .we(1'b0), .data_addr(32'b0), .data_wdata(32'b0), .data_rdata());

endmodule