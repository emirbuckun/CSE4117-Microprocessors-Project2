module keyboard (
    input logic clk,
    input logic ps2d,
    input logic ps2c,
    input logic ack,
    output logic interrupt,
    output logic [15:0] dout
);

    localparam [1:0] IDLE = 2'b00,
                    READ = 2'b01,
                    END =  2'b10;
                    
    logic [7:0] filter;
    logic rx_done_tick;
    logic [3:0] count;
    logic [1:0] state;
    logic [1:0] c;
    logic fall_edge;
    logic [10:0] char;
    logic status;

    // Filter falling edge for ps2c
    always_ff @(posedge clk) begin
        filter <= {ps2c, filter[7:1]};
        if (filter == 8'b11111111)
            c <= {1'b1, c[1]}; // c[0] is past, c[1] is now.
        else if (filter == 8'b00000000)
            c <= {1'b0, c[1]};
    end

    assign fall_edge = c[0] & ~c[1]; // Detect falling edge

    // FSM
    always_ff @(posedge clk) begin
        rx_done_tick <= 1'b0;
        case (state)
            IDLE: begin
                if (fall_edge & ~status) begin
                    char <= {ps2d, char[10:1]};
                    count <= 4'd9;
                    state <= READ;
                end
            end
            READ: begin
                if (fall_edge) begin
                    char <= {ps2d, char[10:1]};
                    if (count == 0)
                        state <= END;
                    else
                        count <= count - 1;
                end
            end
            END: begin
                rx_done_tick <= 1'b1;
                state <= IDLE;
            end
        endcase
    end

    // Status and interrupt handling
    always_ff @(posedge clk) begin
        if (rx_done_tick) begin
            status <= 1'b1;
            interrupt <= 1'b1;
        end
        else if (status == 1'b1 && ack == 1'b1) begin
            status <= 1'b0;
            interrupt <= 1'b0;
        end
    end

    // Assign dout
    always_comb begin
        if (ack == 1'b1)
            dout = 16'(char[8:1]); // Assign scan code
        else
            dout = 16'(status);
    end

    // Initial conditions
    initial begin
        status = 0;
        state = IDLE;
        interrupt = 0;
    end

endmodule