module timer (
    input logic clk,
    input logic ack,
    output logic interrupt
);

    parameter CLOCK_FREQ = 50000000;
    parameter TIMER_LIMIT = CLOCK_FREQ;

    logic [31:0] timer_counter;
    logic status_reg;

    always_ff @(posedge clk) begin
        if (ack) begin
            timer_counter <= 32'b0;
            status_reg <= 1'b0;
            interrupt <= 1'b0;
        end else if (timer_counter == TIMER_LIMIT - 1) begin
            status_reg <= 1'b1;
            interrupt <= 1'b1;
            // Keep the timer_counter value unchanged
        end else if (!status_reg) begin
            timer_counter <= timer_counter + 1;
        end
    end

    initial begin
        timer_counter = 32'b0;
        interrupt = 1'b0;
        status_reg = 1'b0;
    end

endmodule