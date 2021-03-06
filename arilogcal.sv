module arilogcalfsm(
	input logic [3:0]optA, 
	input logic [3:0]optB, 
	input logic [2:0]doOpt, 
	input logic equalTo, ac, clk,
	output logic [7:0]seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7
);

	logic [2:0] last_do_opt;
	logic [3:0] last_a;
	logic [3:0] last_b;

	logic [2:0] opt;
	logic [3:0] a;
	logic [3:0] b;

	logic [4:0] res2;
	logic [4:0] res1;
	logic [4:0] res0;

	typedef enum logic[1:0] { Reset, Acuumulate, Calculation } State;

	State current_state;

	always_ff@(posedge clk, negedge ac) begin
			if (!ac) begin
				res2 <= 17; // Turning the LEDS off
				res1 <= 17;
				res0 <= 17; 
				opt <= 0;
				a <= 0;
				b <= 0;
				current_state <= Reset;
			end
			else begin
				case(current_state)
					Reset: begin
						res2 <= 17; // Turning the LEDS off
						res1 <= 17;
						res0 <= 17; 
						opt <= 0;
						a <= 0;
						b <= 0;
						if (last_a != optA || last_b != optB || last_do_opt != doOpt) begin
							current_state <= Acuumulate;
						end
					   else if (!equalTo) current_state <= Calculation;
						else if (!ac) current_state <= Reset;
					end
					Acuumulate: begin
						a <= optA;
						last_a <= optA;
						b <= optB;
						last_b <= optB;
						opt <= doOpt; 
						last_do_opt <= doOpt;
						if (!equalTo) current_state <= Calculation;
						else if (!ac) current_state <= Reset;
					end
					Calculation: begin
						case(opt)
							1: begin
								res2 <= ((a + b) / 100) % 10;
								res1 <= ((a + b) / 10) % 10;
								res0 <= (a + b) % 10;
							end
							2: begin 
								res2 <= ((a * b) / 100) % 10;
								res1 <= ((a * b) / 10) % 10;
								res0 <= (a * b) % 10;
							end
							3: begin 
								if (b == 0) begin
									res2 <= 14; // E
									res1 <= 16; // r
									res0 <= 16; // r
								end
								else begin
									res2 <= ((a / b) / 100) % 10;
									res1 <= ((a / b) / 10) % 10;
									res0 <= (a / b) % 10;
								end
							end
							4: begin 
								res2 <= (a && b) ? 1 : 0;
								res1 <= (a && b) ? 1 : 0;
								res0 <= (a && b) ? 1 : 0;
							end
							5: begin 
								res2 <= (a || b) ? 1 : 0;
								res1 <= (a || b) ? 1 : 0;
								res0 <= (a || b) ? 1 : 0;
							end
							default: begin
								res2 <= 14; // E
								res1 <= 16; // r
								res0 <= 16; // r
							end
						endcase
						if (last_a != optA || last_a != optB || last_do_opt != doOpt) begin
							current_state <= Acuumulate;
						end
						else if (!ac) current_state <= Reset;
					end
					default: current_state <= Reset;
				endcase
			end
	end 

	DisplaySeg s7(.number((a / 10) % 10), .seg_display(seg7));
	DisplaySeg s6(.number(a % 10), .seg_display(seg6));

	DisplaySeg s5(.number((b / 10) % 10), .seg_display(seg5));
	DisplaySeg s4(.number(b % 10), .seg_display(seg4));
	
	DisplaySeg o(.number(opt), .seg_display(seg3));
	
	DisplaySeg s2(.number(res2), .seg_display(seg2));
	DisplaySeg s1(.number(res1), .seg_display(seg1));
	DisplaySeg s0(.number(res0), .seg_display(seg0));
endmodule


module DisplaySeg(
	input logic [4:0] number, 
	output logic [7:0] seg_display);
	always_comb begin
		case(number)
			0: seg_display = 8'b1100_0000;
			1: seg_display = 8'b1111_1001;
			2: seg_display = 8'b1010_0100;
			3: seg_display = 8'b1011_0000;
			4: seg_display = 8'b1001_1001;
			5: seg_display = 8'b1001_0010;
			6: seg_display = 8'b1000_0010;
			7: seg_display = 8'b1111_1000;
			8: seg_display = 8'b1000_0000;
			9: seg_display = 8'b1001_0000;
			10: seg_display = 8'b1000_1000;
			11: seg_display = 8'b1000_0011;
			12: seg_display = 8'b1010_0111;
			13: seg_display = 8'b1010_0001;
			14: seg_display = 8'b1000_0110;
			15: seg_display = 8'b1000_1110;
			16: seg_display = 8'b1010_1111; // r
			default: seg_display = 8'b1111_1111;
		endcase
	end
endmodule
