`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input left, input right, input up,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire tank_body, tank_head;
	wire monster_0, monster_1, monster_2, monster_3, monster_4;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos_tank, ypos_tank;
	// 10 monsters
	reg [9:0] xpos_mons_0, ypos_mons_0;
	reg [9:0] xpos_mons_1, ypos_mons_1;
	reg [9:0] xpos_mons_2, ypos_mons_2;
	reg [9:0] xpos_mons_3, ypos_mons_3;
	reg [9:0] xpos_mons_4, ypos_mons_4;
	//reg [9:0] xpos_mons_5, ypos_mons_5;
	//reg [9:0] xpos_mons_6, ypos_mons_6;
	//reg [9:0] xpos_mons_7, ypos_mons_7;
	//reg [9:0] xpos_mons_8, ypos_mons_8;
	//reg [9:0] xpos_mons_9, ypos_mons_9;
	
	parameter BLACK = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter BLUE 	= 12'b0000_0000_1111;
	parameter PURPLE= 12'b1111_0000_1111;
	parameter CYAN  = 12'b0000_1111_1111;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright)	//force black if not inside the display area
			rgb = 12'b0000_1111_1111;
		else if (tank_body)
			rgb = GREEN;
		else if (tank_head)
			rgb = GREEN;
		else if (monster_0)
			rgb = RED;
		else if (monster_1)
			rgb = RED;
		else if (monster_2)
			rgb = RED;
		else if (monster_3)
			rgb = RED;
		else if (monster_4)
			rgb = RED;
		else
			rgb = background;
	end
	
	// draw tank
	assign tank_body =vCount>=(ypos_tank) && vCount<=(ypos_tank+5) && hCount>=(xpos_tank-7) && hCount<=(xpos_tank+7);
	assign tank_head =vCount>=(ypos_tank+5) && vCount<=(ypos_tank+8) && hCount>=(xpos_tank-2) && hCount<=(xpos_tank+2);
	// draw monsters
	assign monster_0 =vCount>=(ypos_mons_0 -3) && vCount<=(ypos_mons_0 +3) && hCount>=(xpos_mons_0 -5) && hCount<=(xpos_mons_0 +5);
	assign monster_1 =vCount>=(ypos_mons_1 -3) && vCount<=(ypos_mons_1 +3) && hCount>=(xpos_mons_1 -5) && hCount<=(xpos_mons_1 +5);
	assign monster_2 =vCount>=(ypos_mons_2 -3) && vCount<=(ypos_mons_2 +3) && hCount>=(xpos_mons_2 -5) && hCount<=(xpos_mons_2 +5);
	assign monster_3 =vCount>=(ypos_mons_3 -3) && vCount<=(ypos_mons_3 +3) && hCount>=(xpos_mons_3 -5) && hCount<=(xpos_mons_3 +5);
	assign monster_4 =vCount>=(ypos_mons_4 -3) && vCount<=(ypos_mons_4 +3) && hCount>=(xpos_mons_4 -5) && hCount<=(xpos_mons_4 +5);
	
	// tank state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_tank<=450;
			ypos_tank<=550;
		end
		else if (clk) begin
			// shoot
			if (up) begin
				
			end
			// move left/right
			if(right) begin
				xpos_tank<=xpos_tank+2; //change the amount you increment to make the speed faster 
				if(xpos_tank==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					xpos_tank<=150;
			end
			else if(left) begin
				xpos_tank<=xpos_tank-2;
				if(xpos_tank==150)
					xpos_tank<=800;
			end
		end
	end
	
	// monster_0 state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_0<=250;
			ypos_mons_0<=100;
		end
		
		else if (clk) begin
			// shoot
		end
	end
	
	// monster_1 state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_1<=350;
			ypos_mons_1<=100;
		end
		
		else if (clk) begin
			// shoot
		end
	end
	
	// monster_2 state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_2<=450;
			ypos_mons_2<=100;
		end
		
		else if (clk) begin
			// shoot
		end
	end
	
	// monster_3 state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_3<=550;
			ypos_mons_3<=100;
		end
		
		else if (clk) begin
			// shoot
		end
	end
	
	// monster_4 state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_4<=650;
			ypos_mons_4<=100;
		end
		
		else if (clk) begin
			// shoot
		end
	end

		//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b1111_1111_1111;

	end
	
endmodule
