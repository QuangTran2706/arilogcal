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

module arilogcal(
	input logic [3:0]optA, 
	input logic [3:0]optB, 
	input logic [2:0]doOpt, 
	input logic equalTo, ac, clk,
	output logic [7:0]seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7
);
	logic last_equal_to;
	logic [2:0] last_do_opt;
	logic [3:0] last_a;
	logic [3:0] last_b;
	
	logic [2:0] opt;
	logic [3:0] a;
	logic [3:0] b;
	
	logic [4:0] res2;
	logic [4:0] res1;
	logic [4:0] res0;

	always_ff@(posedge clk, negedge ac) begin
		if (!ac) begin
			res2 <= 17; // Turning the LEDS off
			res1 <= 17;
			res0 <= 17; 
			opt <= 0;
			a <= 0;
			b <= 0;
		end
		else if (!equalTo && last_equal_to == 1) begin
			case(opt)
			1: begin // Additional
				res2 <= ((a + b) / 100) % 10;
				res1 <= ((a + b) / 10) % 10;
				res0 <= (a + b) % 10;
			end
			2: begin // Multiplication
				res2 <= ((a * b) / 100) % 10;
				res1 <= ((a * b) / 10) % 10;
				res0 <= (a * b) % 10;
			end
			3: begin // Division
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
			4: begin // Logical And
				res2 <= 8'b1100_0000;
				res1 <= 8'b1100_0000;
				res0 <= (a & b) ? 1 : 0;
			end
			5: begin // Logical OR
				res2 <= 8'b1100_0000;
				res1 <= 8'b1100_0000;
				res0 <= (a | b) ? 1 : 0;
			end
			default: begin
				res2 <= 14; // E
				res1 <= 16; // r
				res0 <= 16; // r
			end
			endcase
			last_equal_to <= equalTo;
			last_do_opt <= doOpt;
			last_a <= optA;
			last_b <= optB;
		end
		else if (last_a != optA) begin
			a <= optA;
			last_equal_to <= equalTo;
			last_do_opt <= doOpt;
			last_a <= optA;
			last_b <= optB;
		end	
		else if (last_b != optB) begin
			b <= optB;
			last_equal_to <= equalTo;
			last_do_opt <= doOpt;
			last_a <= optA;
			last_b <= optB;
		end	
		else if (doOpt != last_do_opt) begin
			opt <= doOpt; 
			last_equal_to <= equalTo;
			last_do_opt <= doOpt;
			last_a <= optA;
			last_b <= optB;
		end
		else begin
			last_equal_to <= equalTo;
			last_do_opt <= doOpt;
			last_a <= optA;
			last_b <= optB;
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



	
