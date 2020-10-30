`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input slow_clk,
	input bright,
	input rst,
	input left, input right, input up,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire tank_body, tank_head;
	wire tank_bullet_0, tank_bullet_1, tank_bullet_2;
	wire monster_0, monster_1, monster_2, monster_3, monster_4;
	
	// tank position
	reg [9:0] xpos_tank, ypos_tank;
	// 3 tank bullets positions
	reg [9:0] xpos_tank_bullet_0, ypos_tank_bullet_0;
	reg [9:0] xpos_tank_bullet_1, ypos_tank_bullet_1;
	reg [9:0] xpos_tank_bullet_2, ypos_tank_bullet_2;
	// 10 monsters positions
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
	
	// Object Flag destroyed
	reg tank_destroyed;
	reg [4:0] monster_destroyed;
	
	// Bullets Flag alive
	reg [2:0] tank_bullet_alive;
	
	parameter BLACK = 12'b0000_0000_0000;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter BLUE 	= 12'b0000_0000_1111;
	parameter PURPLE= 12'b1111_0000_1111;
	parameter CYAN  = 12'b0000_1111_1111;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright)	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (tank_head)
			rgb = GREEN;
		else if (tank_body)
			rgb = GREEN;
		else if (tank_bullet_0)
			rgb = RED;
		else if (tank_bullet_1)
			rgb = RED;
		else if (tank_bullet_2)
			rgb = RED;	
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
	assign tank_head =vCount>=(ypos_tank-7) && vCount< (ypos_tank) && hCount>=(xpos_tank-2) && hCount<=(xpos_tank+2);
	assign tank_body =vCount>=(ypos_tank) && vCount<=(ypos_tank+10) && hCount>=(xpos_tank-10) && hCount<=(xpos_tank+10);
	// draw tank bullets
	assign tank_bullet_0 =vCount>=(ypos_tank_bullet_0 -3) && vCount<=(ypos_mons_0 +3) && hCount>=(xpos_mons_0 -1) && hCount<=(xpos_mons_0 +1);
	assign tank_bullet_1 =vCount>=(ypos_tank_bullet_1 -3) && vCount<=(ypos_mons_1 +3) && hCount>=(xpos_mons_1 -1) && hCount<=(xpos_mons_1 +1);
	assign tank_bullet_2 =vCount>=(ypos_tank_bullet_2 -3) && vCount<=(ypos_mons_2 +3) && hCount>=(xpos_mons_2 -1) && hCount<=(xpos_mons_2 +1);
	// draw monsters
	assign monster_0 =vCount>=(ypos_mons_0 -5) && vCount<=(ypos_mons_0 +5) && hCount>=(xpos_mons_0 -10) && hCount<=(xpos_mons_0 +10);
	assign monster_1 =vCount>=(ypos_mons_1 -5) && vCount<=(ypos_mons_1 +5) && hCount>=(xpos_mons_1 -10) && hCount<=(xpos_mons_1 +10);
	assign monster_2 =vCount>=(ypos_mons_2 -5) && vCount<=(ypos_mons_2 +5) && hCount>=(xpos_mons_2 -10) && hCount<=(xpos_mons_2 +10);
	assign monster_3 =vCount>=(ypos_mons_3 -5) && vCount<=(ypos_mons_3 +5) && hCount>=(xpos_mons_3 -10) && hCount<=(xpos_mons_3 +10);
	assign monster_4 =vCount>=(ypos_mons_4 -5) && vCount<=(ypos_mons_4 +5) && hCount>=(xpos_mons_4 -10) && hCount<=(xpos_mons_4 +10);
	
	// initialize bg, flags
	always@(posedge clk, posedge rst)  begin
		if (rst)
			background = BLACK;
			tank_destroyed = 0;
			monster_destroyed = 5'b00000;
			tank_bullet_alive = 3'b000;
	end
	
	// tank state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_tank<=450;
			ypos_tank<=450;
		end
		else if (clk) begin
			// shoot?
			if (up) begin
				if (tank_bullet_alive[0] == 1'b0) begin	// set bullet0 alive
					xpos_tank<=xpos_tank+2; 
				end
				else if (tank_bullet_alive[1] == 1'b0) begin	// set bullet1 alive
					tank_bullet_alive[1] = 1'b1;
				end 
				else if (tank_bullet_alive[2] == 1'b0) begin	// set bullet2 alive
					tank_bullet_alive[2] = 1'b1;
				end
				// else if 3'b111, no bullet available
			end
			
			// move tank left/right 
			else if(right) begin
				xpos_tank<=xpos_tank+2; 
				// (Also updating bullets position with tank IF not alive)
				if(tank_bullet_alive[0] == 1'b0)
					xpos_tank_bullet_0<=xpos_tank_bullet_0+2;
				if(tank_bullet_alive[1] == 1'b0)
					xpos_tank_bullet_1<=xpos_tank_bullet_1+2;
				if(tank_bullet_alive[2] == 1'b0)
					xpos_tank_bullet_2<=xpos_tank_bullet_2+2;
					
				// wrap around
				if(xpos_tank==800) begin
					xpos_tank<=150;
					if(tank_bullet_alive[0] == 1'b0)
						xpos_tank_bullet_0<=150;
					if(tank_bullet_alive[1] == 1'b0)
						xpos_tank_bullet_1<=150;
					if(tank_bullet_alive[2] == 1'b0)
						xpos_tank_bullet_2<=150;
				end
			end
			else if(left) begin
				xpos_tank<=xpos_tank-2;
				// (Also updating bullets position with tank IF not alive)
				if(tank_bullet_alive[0] == 1'b0)
					xpos_tank_bullet_0<=xpos_tank_bullet_0-2;
				if(tank_bullet_alive[1] == 1'b0)
					xpos_tank_bullet_1<=xpos_tank_bullet_1-2;
				if(tank_bullet_alive[2] == 1'b0)
					xpos_tank_bullet_2<=xpos_tank_bullet_2-2;
					
				if(xpos_tank==150) begin
					xpos_tank<=800;
					if(tank_bullet_alive[0] == 1'b0)
						xpos_tank_bullet_0<=150;
					if(tank_bullet_alive[1] == 1'b0)
						xpos_tank_bullet_1<=150;
					if(tank_bullet_alive[2] == 1'b0)
						xpos_tank_bullet_2<=150;
				end
			end
		end
	end
	
	// tank_bullet_0 movement
	always@(posedge slow_clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_tank_bullet_0<=450;
			ypos_tank_bullet_0<=450;
		end
		
		else if (slow_clk) begin
			if (tank_bullet_alive[0] == 1'b1) begin
				// move up
				ypos_tank_bullet_0<=ypos_tank_bullet_0 - 2;
				// IF reach top, reset bullet to available
				if(ypos_tank_bullet_0==34)
					tank_bullet_alive[0] = 1'b0;
					xpos_tank_bullet_0<=xpos_tank;
					ypos_tank_bullet_0<=ypos_tank;
			end
		end
	end
	
	// tank_bullet_1 movement
	always@(posedge slow_clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_tank_bullet_1<=450;
			ypos_tank_bullet_1<=450;
		end
		
		else if (slow_clk) begin
			if (tank_bullet_alive[1] == 1'b1) begin
				// move up
				ypos_tank_bullet_1<=ypos_tank_bullet_1 - 2;
				// IF reach top, reset bullet to available
				if(ypos_tank_bullet_1==34)
					tank_bullet_alive[1] = 1'b0;
					xpos_tank_bullet_1<=xpos_tank;
					ypos_tank_bullet_1<=ypos_tank;
			end
		end
	end
	
	// tank_bullet_2 movement
	always@(posedge slow_clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_tank_bullet_2<=450;
			ypos_tank_bullet_2<=450;
		end
		
		else if (slow_clk) begin
			if (tank_bullet_alive[2] == 1'b1) begin
				// move up
				ypos_tank_bullet_2<=ypos_tank_bullet_2 - 2;
				// IF reach top, reset bullet to available
				if(ypos_tank_bullet_2==34)
					tank_bullet_alive[2] = 1'b0;
					xpos_tank_bullet_2<=xpos_tank;
					ypos_tank_bullet_2<=ypos_tank;
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

	
	
endmodule
