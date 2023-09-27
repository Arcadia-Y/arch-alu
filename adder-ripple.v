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

module adder(
	input   [15:0]  a,
    input   [15:0]  b,
    output  [15:0]  sum,
    output  wire    carry
);

    wire [16:0] tmpcarry;
    assign tmpcarry[0] = 0;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            full_adder fa(
                .a      (a[i]),
                .b      (b[i]),
                .cin    (tmpcarry[i]),
                .sum    (sum[i]),
                .cout   (tmpcarry[i+1])
            );
        end
    endgenerate

    assign carry = tmpcarry[16];
	
endmodule
