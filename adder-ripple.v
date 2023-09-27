/* ACM Class System (I) Fall Assignment 1 
 *
 *
 * Implement your naive adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */

module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));

endmodule

module adder_32(
    input cin,
	input   [31:0]  a,
    input   [31:0]  b,
    output  [31:0]  sum,
    output cout
);

    wire [32:0] tmpcarry;
    assign tmpcarry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            full_adder fa(
                .a      (a[i]),
                .b      (b[i]),
                .cin    (tmpcarry[i]),
                .sum    (sum[i]),
                .cout   (tmpcarry[i+1])
            );
        end
    endgenerate
	
    assign cout = tmpcarry[32];
endmodule

module Add(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
);
    wire unused;
    wire [31:0] tmpsum;
    adder_32 adder(1'b0, a, b, tmpsum, unused);
    always @* begin
		sum <= tmpsum;
	end
endmodule
