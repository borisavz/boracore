module boracore_tb;
	wire [7:0] a;
	wire [7:0] b;
	wire [7:0] c;
	wire [7:0] ip;
	
	reg clk;

	task pulse_clk;
		begin
			#5; clk = 1;
			#5; clk = 0;
		end
	endtask


    cpu cpu0 (
	    .clk(clk),
		.a(a),
		.b(b),
		.c(c),
		.ip(ip)
	);

    initial begin
		$monitor("clk=%d ip=%d a=%d b=%d c=%d", clk, ip, a, b, c);
	    clk = 0;
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		pulse_clk();
		
        $finish;
    end
endmodule