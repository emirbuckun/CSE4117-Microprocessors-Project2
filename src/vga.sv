module vga (
    input logic clk,
    input logic [15:0] x_spaceship,
    input logic [15:0] y_spaceship,
    input logic [15:0] x_planet,
    input logic [15:0] y_planet,
    input logic [15:0] spaceship_bitmap [0:15],
    input logic [15:0] planet_bitmap [0:15],
    output logic hsync,
    output logic vsync,
    output logic [2:0] rgb
);

    logic pixel_tick, video_on;
    logic [9:0] h_count;
    logic [9:0] v_count;

    localparam  HD       = 640, //horizontal display area
                HF       = 48,  //horizontal front porch
                HB       = 16,  //horizontal back porch
                HFB      = 96,  //horizontal flyback
                VD       = 480, //vertical display area
                VT       = 10,  //vertical top porch
                VB       = 33,  //vertical bottom porch
                VFB      = 2,   //vertical flyback
                LINE_END = HF+HD+HB+HFB-1,
                PAGE_END = VT+VD+VB+VFB-1;

    always_ff @(posedge clk)
        pixel_tick <= ~pixel_tick; // 25 MHz signal is generated.

    //=====Manages hcount and vcount======
    always_ff @(posedge clk)
        if (pixel_tick)
        begin
        if (h_count == LINE_END)
        begin
            h_count <= 0;
            if (v_count == PAGE_END)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
        else
            h_count <= h_count + 1;
        end

    //=====================color generation=================  
    //== origin of display area is at (h_count, v_count) = (0,0)===
    always_comb
    begin
        rgb = 3'b000;
        if ((h_count < HD) && (v_count < VD)) // if video on
        begin
            // Planet condition
            if ((h_count >= x_spaceship) && (h_count < x_spaceship + 16) &&
                (v_count >= y_spaceship) && (v_count < y_spaceship + 16))
            begin
                if (planet_bitmap[v_count - y_spaceship][h_count - x_spaceship] == 1)
                    rgb = 3'b110; // yellow spaceship
                else
                    rgb = 3'b010; // green background
            end
            // Spaceship condition
            else if ((h_count >= x_planet) && (h_count < x_planet + 16) &&
                    (v_count >= y_planet) && (v_count < y_planet + 16))
            begin
                if (spaceship_bitmap[v_count - y_planet][h_count - x_planet] == 1)
                    rgb = 3'b100; // red planet
                else
                    rgb = 3'b010; // green background
            end
            // Background condition
            else
                rgb = 3'b010; // paint background green
        end
    end

    //=======hsync and vsync will become 1 during flybacks.=======
    //== origin of display area is at (h_count, v_count) = (0,0)===
    assign hsync = (h_count >= (HD + HB) && h_count <= (HFB + HD + HB - 1));
    assign vsync = (v_count >= (VD + VB) && v_count <= (VD + VB + VFB - 1));

    initial
    begin
        h_count = 0;
        v_count = 0;
        pixel_tick = 0;
    end

endmodule