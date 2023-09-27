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

// PG generator
module PG (
    input a,
    input b,
    output p,
    output g
);
    assign p = a ^ b;
    assign g = a & b;
endmodule

// PGM generator
module PGM (
    input [3:0] p,
    input [3:0] g,
    output pm,
    output gm
);
    assign pm = p[0] & p[1] & p[2] & p[3];
    assign gm = g[3] | g[2] & p[3] | g[1] & p[3] & p[2] | g[0] & p[3] & p[2] & p[1];
endmodule

// Carry Lookahead Unit
module CLU (
    input [3:0] p,
    input [3:0] g,
    input cin,
    output [3:0] cout
);
    assign cout[0] = g[0] | cin & p[0];
    assign cout[1] = g[1] | g[0] & p[1] | cin & p[0] & p[1];
    assign cout[2] = g[2] | g[1] & p[2] | g[0] & p[1] & p[2] | cin & p[0] & p[1] & p[2];
    assign cout[3] = g[3] | g[2] & p[3] | g[1] & p[2] & p[3] | g[0] & p[1] & p[2] & p[3] | cin & p[0] & p[1] & p[2] & p[3];
endmodule

// 4-bit Carry Lookahead Adder without cout
module CLA_4 (
    input cin,
    input [3:0] p,
    input [3:0] g,
    output [3:0] s
);
    wire [3:0] c;
    CLU clu(p, g, cin, c);

    assign s[0] = p[0] ^ cin;
    assign s[1] = p[1] ^ c[0];
    assign s[2] = p[2] ^ c[1];
    assign s[3] = p[3] ^ c[2];
endmodule

// 16-bit CLA with cout
module CLA_16(
    input cin,
	input [15:0] a,
    input [15:0] b,
    output [15:0] s,
    output cout
);
    wire [15:0] p;
    wire [15:0] g;
    wire [3:0] pm;
    wire [3:0] gm;
    wire [3:0] c;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            PG pg(a[i], b[i], p[i], g[i]);
        end
    endgenerate

    PGM pgm0(p[3:0], g[3:0], pm[0], gm[0]),
        pgm1(p[7:4], g[7:4], pm[1], gm[1]),
        pgm2(p[11:8], g[11:8], pm[2], gm[2]),
        pgm3(p[15:12], g[15:12], pm[3], gm[3]);

    CLU clu(pm, gm, cin, c);

    CLA_4 cla0(cin, p[3:0], g[3:0], s[3:0]),
          cla1(c[0], p[7:4], g[7:4], s[7:4]),
          cla2(c[1], p[11:8], g[11:8], s[11:8]),
          cla3(c[2], p[15:12], g[15:12], s[15:12]);

    assign cout = c[3];
endmodule

module adder_32(
    input cin,
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum,
    output cout  
);
    wire c15;
    CLA_16 cla0(cin, a[15:0], b[15:0], sum[15:0], c15);
    CLA_16 cla1(c15, a[31:16], b[31:16], sum[31:16], cout);
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
