module main (
	input logic clk,
	input logic ps2d,
	input logic ps2c,
	output logic hsync,
	output logic vsync,
	output logic [2:0] rgb
);

	//====memory map is defined here====
	localparam	BEGINMEM = 12'h000,
				ENDMEM = 12'h1ff,
				KEYBOARD_DATA = 12'h902,
				PLANET_X = 12'h903,
				PLANET_Y = 12'h904,
				SPACESHIP_X = 12'h905,
				SPACESHIP_Y = 12'h906,
				TIMER = 12'h907,
				BEGIN_PLANET_BITMAP = 12'h910,
				END_PLANET_BITMAP = 12'h91f,
				BEGIN_SPACESHIP_BITMAP = 12'h920,
				END_SPACESHIP_BITMAP = 12'h92f;

	//====memory chip==============
	logic [15:0] memory [0:511];

	//=====cpu's input-output pins===== 
	logic [15:0] data_out;
	logic [15:0] data_in;
	logic [11:0] address;
	logic memwt;
	logic INT;
	logic intack;

	// Data and Status
	logic [15:0] kb_dout, x_spaceship, y_spaceship, x_planet, y_planet;
	logic [15:0] spaceship_bitmap [0:15];
	logic [15:0] planet_bitmap [0:15];
	logic kb_interrupt, ack, timer_interrupt, timer_ack;

	//====== pic ===============
	logic irq0, irq1, irq2, irq3, irq4, irq5, irq6, irq7;

	keyboard kb (.clk(clk), .ps2d(ps2d), .ps2c(ps2c), .ack(ack), .interrupt(kb_interrupt), .dout(kb_dout));
	vga vga_module(.clk(clk), .hsync(hsync), .vsync(vsync), .rgb(rgb), .x_spaceship(x_spaceship), .y_spaceship(y_spaceship), .x_planet(x_planet), .y_planet(y_planet), .spaceship_bitmap(spaceship_bitmap), .planet_bitmap(planet_bitmap));
	mammal m1(.clk(clk), .data_in(data_in), .data_out(data_out), .address(address), .memwt(memwt), .INT(INT), .intack(intack));
	timer t1 (.clk(clk), .ack(timer_ack), .interrupt(timer_interrupt));

	//===============IRQ's==============
	always_comb begin
		irq0 = 1'b0;
		irq1 = 1'b0;
		irq2 = kb_interrupt;
		irq3 = timer_interrupt;
		irq4 = 1'b0;
		irq5 = 1'b0;
		irq6 = 1'b0;
		irq7 = 1'b0;
	end

	//we assume that the devices hold their irq until being serviced by cpu
	assign INT = irq0 | irq1 | irq2 | irq3 | irq4 | irq5 | irq6 | irq7;

	//====multiplexer for cpu input======
	always_comb begin
		ack = 0;
		timer_ack = 1;
		if (intack == 0) begin
			ack = 0;
			timer_ack = 0;
			if ((BEGINMEM <= address) && (address <= ENDMEM)) begin
				data_in = memory[address];
			end else if (address == KEYBOARD_DATA) begin
				ack = 1;
				data_in = kb_dout;
			end else if (address == SPACESHIP_X) begin
				data_in = x_planet;
			end else if (address == SPACESHIP_Y) begin
				data_in = y_planet;
			end else if (address == PLANET_X) begin
				data_in = x_spaceship;
			end else if (address == PLANET_Y) begin
				data_in = y_spaceship;
			end else if (address == TIMER) begin
				timer_ack = 1;
				data_in = 16'h1;
			end else begin
				data_in = 16'h0000;
			end
		end else begin
			if (irq0)
				data_in = 16'h0;
			else if (irq1)
				data_in = 16'h1;
			else if (irq2)
				data_in = 16'h2;
			else if (irq3)
				data_in = 16'h3;
			else if (irq4)
				data_in = 16'h4;
			else if (irq5)
				data_in = 16'h5;
			else if (irq6)
				data_in = 16'h6;
			else
				data_in = 16'h7;
		end
	end

	//=====multiplexer for cpu output=========== 
	always_ff @(posedge clk) begin
		if (memwt) begin
			if ((BEGINMEM <= address) && (address <= ENDMEM)) begin
				memory[address] <= data_out;
			end else if (SPACESHIP_X == address) begin
				x_spaceship <= data_out;
			end else if (SPACESHIP_Y == address) begin
				y_spaceship <= data_out;
			end else if (PLANET_X == address) begin
				x_planet <= data_out;
			end else if (PLANET_Y == address) begin
				y_planet <= data_out;
			end else if ((BEGIN_PLANET_BITMAP <= address) && (address <= END_PLANET_BITMAP)) begin
				planet_bitmap[address - BEGIN_PLANET_BITMAP] <= data_out;
			end else if ((BEGIN_SPACESHIP_BITMAP <= address) && (address <= END_SPACESHIP_BITMAP)) begin
				spaceship_bitmap[address - BEGIN_SPACESHIP_BITMAP] <= data_out;
			end
		end
	end

	initial begin
		kb_interrupt = 0;
		timer_ack = 0;
		$readmemh("ram.dat", memory);
	end

endmodule