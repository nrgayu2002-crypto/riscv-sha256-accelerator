
module fsm_pqc (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] weight_in,
    input  wire       weight_valid,
    output reg        done_pqc,
    output reg        silent_reset
);

    parameter TARGET_WEIGHT = 8'd66; // HQC-128 requirement

    localparam IDLE  = 2'b00;
    localparam CHECK = 2'b01;
    localparam DONE  = 2'b10;

    reg [1:0] current_state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else        current_state <= next_state;
    end

    always @(*) begin
        // Default Outputs
        done_pqc     = 1'b0;
        silent_reset = 1'b0;
        next_state   = current_state;

        case (current_state)
            IDLE: begin
                if (weight_valid) next_state = CHECK;
            end
            CHECK: begin
                if (weight_in == TARGET_WEIGHT) begin
                    next_state = DONE;
                end else begin
                    silent_reset = 1'b1; // Trigger autonomous rejection
                    next_state = IDLE;
                end
            end
            DONE: begin
                done_pqc = 1'b1;
                // Wait for processor to read, then software resets system
            end
            default: next_state = IDLE;
        endcase
    end
endmodule