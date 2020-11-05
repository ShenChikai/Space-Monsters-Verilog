`timescale 1ns / 1ps

module block_controller(
	input clk,
	input bright,
	input rst,
	input left, input right, input up,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
   
	// -------------------------------------------------------------------------------------Object_Variables(reg, wire)-----------------------------------------------------------------------------------
	// display for all objects
	wire tank_body, tank_head;
	wire monster_0, monster_1, monster_2, monster_3, monster_4;
	wire monster_0_bullet_0, monster_0_bullet_1, monster_0_bullet_2,
			monster_1_bullet_0, monster_1_bullet_1, monster_1_bullet_2,
			monster_2_bullet_0, monster_2_bullet_1, monster_2_bullet_2,
			monster_3_bullet_0, monster_3_bullet_1, monster_3_bullet_2,
			monster_4_bullet_0, monster_4_bullet_1, monster_4_bullet_2;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos_tank, ypos_tank;
	// debounce up
	// reg [1:0] upState;
	// wire debounced_up;
	// 3 tank bullets positions
	reg [9:0] xpos_tank_bullet_0, ypos_tank_bullet_0;
	reg [9:0] xpos_tank_bullet_1, ypos_tank_bullet_1;
	reg [9:0] xpos_tank_bullet_2, ypos_tank_bullet_2;
	// 5 monsters positions
	reg [9:0] xpos_mons_0, ypos_mons_0;
	reg [9:0] xpos_mons_1, ypos_mons_1;
	reg [9:0] xpos_mons_2, ypos_mons_2;
	reg [9:0] xpos_mons_3, ypos_mons_3;
	reg [9:0] xpos_mons_4, ypos_mons_4;
	// 15 monsters bullets positions
	reg [9:0] xpos_mons_0_bullet_0, ypos_mons_0_bullet_0;
	reg [9:0] xpos_mons_0_bullet_1, ypos_mons_0_bullet_1;
	reg [9:0] xpos_mons_0_bullet_2, ypos_mons_0_bullet_2;
	reg [9:0] xpos_mons_1_bullet_0, ypos_mons_1_bullet_0;
	reg [9:0] xpos_mons_1_bullet_1, ypos_mons_1_bullet_1;
	reg [9:0] xpos_mons_1_bullet_2, ypos_mons_1_bullet_2;
	reg [9:0] xpos_mons_2_bullet_0, ypos_mons_2_bullet_0;
	reg [9:0] xpos_mons_2_bullet_1, ypos_mons_2_bullet_1;
	reg [9:0] xpos_mons_2_bullet_2, ypos_mons_2_bullet_2;
	reg [9:0] xpos_mons_3_bullet_0, ypos_mons_3_bullet_0;
	reg [9:0] xpos_mons_3_bullet_1, ypos_mons_3_bullet_1;
	reg [9:0] xpos_mons_3_bullet_2, ypos_mons_3_bullet_2;
	reg [9:0] xpos_mons_4_bullet_0, ypos_mons_4_bullet_0;
	reg [9:0] xpos_mons_4_bullet_1, ypos_mons_4_bullet_1;
	reg [9:0] xpos_mons_4_bullet_2, ypos_mons_4_bullet_2;
	
	// object flag destroyed
	reg tank_destroyed;
	reg [4:0] monster_destroyed;
	
	// bullets flag alive
	reg [2:0] tank_bullet_alive;
	
	// bullets flag alive
	reg [2:0] mons_0_bullet_alive;
	reg [2:0] mons_1_bullet_alive;
	reg [2:0] mons_2_bullet_alive;
	reg [2:0] mons_3_bullet_alive;
	reg [2:0] mons_4_bullet_alive;
	
	// -------------------------------------------------------------------------------------Color_Display_4_Objects-----------------------------------------------------------------------------------
	parameter BLACK = 12'b0000_0000_0000;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter BLUE 	= 12'b0000_0000_1111;
	parameter PURPLE= 12'b1111_0000_1111;
	parameter CYAN  = 12'b0000_1111_1111;
	parameter PINK  = 12'b1111_1100_1100;
	
	always@ (*) begin
    	if(~bright)	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (tank_bullet_0)
			rgb = BLUE;
		else if (tank_bullet_1)
			rgb = BLUE;
		else if (tank_bullet_2)
			rgb = BLUE;
		else if (tank_head)
			rgb = GREEN;
		else if (tank_body)
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
		else if (monster_0_bullet_0)
			rgb = RED;
		else if (monster_0_bullet_1)
			rgb = RED;
		else if (monster_0_bullet_2)
			rgb = RED;
		else if (monster_1_bullet_0)
			rgb = RED;
		else if (monster_1_bullet_1)
			rgb = RED;
		else if (monster_1_bullet_2)
			rgb = RED;
		else if (monster_2_bullet_0)
			rgb = RED;
		else if (monster_2_bullet_1)
			rgb = RED;
		else if (monster_2_bullet_2)
			rgb = RED;
		else if (monster_3_bullet_0)
			rgb = RED;
		else if (monster_3_bullet_1)
			rgb = RED;
		else if (monster_3_bullet_2)
			rgb = RED;
		else if (monster_4_bullet_0)
			rgb = RED;
		else if (monster_4_bullet_1)
			rgb = RED;
		else if (monster_4_bullet_2)
			rgb = RED;
		else
			rgb = background;
	end
	
	// -------------------------------------------------------------------------------------Draw_Shape_in_Pixel--------------------------------------------------------------------------------------
	// draw tank
	assign tank_head =vCount>=(ypos_tank-5) && vCount< (ypos_tank) && hCount>=(xpos_tank-2) && hCount<=(xpos_tank+2);
	assign tank_body =vCount>=(ypos_tank) && vCount<=(ypos_tank+10) && hCount>=(xpos_tank-10) && hCount<=(xpos_tank+10);
	// draw tank bullets
	assign tank_bullet_0 =vCount>=(ypos_tank_bullet_0 -1) && vCount<=(ypos_tank_bullet_0 +1) && hCount>=(xpos_tank_bullet_0 -1) && hCount<=(xpos_tank_bullet_0 +1);
	assign tank_bullet_1 =vCount>=(ypos_tank_bullet_1 -1) && vCount<=(ypos_tank_bullet_1 +1) && hCount>=(xpos_tank_bullet_1 -1) && hCount<=(xpos_tank_bullet_1 +1);
	assign tank_bullet_2 =vCount>=(ypos_tank_bullet_2 -1) && vCount<=(ypos_tank_bullet_2 +1) && hCount>=(xpos_tank_bullet_2 -1) && hCount<=(xpos_tank_bullet_2 +1);
	// draw monsters
	assign monster_0 =vCount>=(ypos_mons_0 -5) && vCount<=(ypos_mons_0 +5) && hCount>=(xpos_mons_0 -10) && hCount<=(xpos_mons_0 +10);
	assign monster_1 =vCount>=(ypos_mons_1 -5) && vCount<=(ypos_mons_1 +5) && hCount>=(xpos_mons_1 -10) && hCount<=(xpos_mons_1 +10);
	assign monster_2 =vCount>=(ypos_mons_2 -5) && vCount<=(ypos_mons_2 +5) && hCount>=(xpos_mons_2 -10) && hCount<=(xpos_mons_2 +10);
	assign monster_3 =vCount>=(ypos_mons_3 -5) && vCount<=(ypos_mons_3 +5) && hCount>=(xpos_mons_3 -10) && hCount<=(xpos_mons_3 +10);
	assign monster_4 =vCount>=(ypos_mons_4 -5) && vCount<=(ypos_mons_4 +5) && hCount>=(xpos_mons_4 -10) && hCount<=(xpos_mons_4 +10);
	// draw monster bullets
	assign monster_0_bullet_0 =vCount>=(ypos_mons_0_bullet_0 -1) && vCount<=(ypos_mons_0_bullet_0 +1) && hCount>=(xpos_mons_0_bullet_0 -1) && hCount<=(xpos_mons_0_bullet_0 +1);
	assign monster_0_bullet_1 =vCount>=(ypos_mons_0_bullet_1 -1) && vCount<=(ypos_mons_0_bullet_1 +1) && hCount>=(xpos_mons_0_bullet_1 -1) && hCount<=(xpos_mons_0_bullet_1 +1);
	assign monster_0_bullet_2 =vCount>=(ypos_mons_0_bullet_2 -1) && vCount<=(ypos_mons_0_bullet_2 +1) && hCount>=(xpos_mons_0_bullet_2 -1) && hCount<=(xpos_mons_0_bullet_2 +1);
	
	assign monster_1_bullet_0 =vCount>=(ypos_mons_1_bullet_0 -1) && vCount<=(ypos_mons_1_bullet_0 +1) && hCount>=(xpos_mons_1_bullet_0 -1) && hCount<=(xpos_mons_1_bullet_0 +1);
	assign monster_1_bullet_1 =vCount>=(ypos_mons_1_bullet_1 -1) && vCount<=(ypos_mons_1_bullet_1 +1) && hCount>=(xpos_mons_1_bullet_1 -1) && hCount<=(xpos_mons_1_bullet_1 +1);
	assign monster_1_bullet_2 =vCount>=(ypos_mons_1_bullet_2 -1) && vCount<=(ypos_mons_1_bullet_2 +1) && hCount>=(xpos_mons_1_bullet_2 -1) && hCount<=(xpos_mons_1_bullet_2 +1);
	
	assign monster_2_bullet_0 =vCount>=(ypos_mons_2_bullet_0 -1) && vCount<=(ypos_mons_2_bullet_0 +1) && hCount>=(xpos_mons_2_bullet_0 -1) && hCount<=(xpos_mons_2_bullet_0 +1);
	assign monster_2_bullet_1 =vCount>=(ypos_mons_2_bullet_1 -1) && vCount<=(ypos_mons_2_bullet_1 +1) && hCount>=(xpos_mons_2_bullet_1 -1) && hCount<=(xpos_mons_2_bullet_1 +1);
	assign monster_2_bullet_2 =vCount>=(ypos_mons_2_bullet_2 -1) && vCount<=(ypos_mons_2_bullet_2 +1) && hCount>=(xpos_mons_2_bullet_2 -1) && hCount<=(xpos_mons_2_bullet_2 +1);
	
	assign monster_3_bullet_0 =vCount>=(ypos_mons_3_bullet_0 -1) && vCount<=(ypos_mons_3_bullet_0 +1) && hCount>=(xpos_mons_3_bullet_0 -1) && hCount<=(xpos_mons_3_bullet_0 +1);
	assign monster_3_bullet_1 =vCount>=(ypos_mons_3_bullet_1 -1) && vCount<=(ypos_mons_3_bullet_1 +1) && hCount>=(xpos_mons_3_bullet_1 -1) && hCount<=(xpos_mons_3_bullet_1 +1);
	assign monster_3_bullet_2 =vCount>=(ypos_mons_3_bullet_2 -1) && vCount<=(ypos_mons_3_bullet_2 +1) && hCount>=(xpos_mons_3_bullet_2 -1) && hCount<=(xpos_mons_3_bullet_2 +1);
	
	assign monster_4_bullet_0 =vCount>=(ypos_mons_4_bullet_0 -1) && vCount<=(ypos_mons_4_bullet_0 +1) && hCount>=(xpos_mons_4_bullet_0 -1) && hCount<=(xpos_mons_4_bullet_0 +1);
	assign monster_4_bullet_1 =vCount>=(ypos_mons_4_bullet_1 -1) && vCount<=(ypos_mons_4_bullet_1 +1) && hCount>=(xpos_mons_4_bullet_1 -1) && hCount<=(xpos_mons_4_bullet_1 +1);
	assign monster_4_bullet_2 =vCount>=(ypos_mons_4_bullet_2 -1) && vCount<=(ypos_mons_4_bullet_2 +1) && hCount>=(xpos_mons_4_bullet_2 -1) && hCount<=(xpos_mons_4_bullet_2 +1);
	
	//Debounce all btn press here
	debounce DUP(rst, clk, up, clean_up);
	pulse PULSE_UP(rst, clk, clean_up, pulse_up);
	
	// initialize bg, flags 
	always@(posedge rst)  begin
		if (rst)
			background <= BLACK;
			tank_destroyed = 0;					// TODO: check tank collision	还没�?�的 先放这
			monster_destroyed = 5'b00000;		// TODO: check mons collision
			
	end
	
	// ---------------------------------------------------------------------------------------Tank-------------------------------------------------------------------------------------------------
	// button up Debounce
	// Update register to the btn state now and 1 cycle ago (compare now & before)
	/* always@(posedge clk, posedge rst) 
	begin
		if (rst) begin
			upState <= 2'b00;
		end
		else if (clk) begin
			if (up) begin
				upState <= {upState[0], 1'b1};
			end
		end
	end
	// If we see a edge now, but didnt 1 cycle ago, pulse
	assign debounced_up = ~upState[1] & upState[0]; */
	
	// tank state block: left, right, shoot
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			// rough values for center of screen
			xpos_tank<=450;
			ypos_tank<=450;
			// tank_bullet_alive & xpos of bullet can be assigned in tank blcok
			// and only ypos of bullet can only be assigned in corresponding bullet block
			tank_bullet_alive <= 3'b000;
			xpos_tank_bullet_0<=450;
			xpos_tank_bullet_1<=444;
			xpos_tank_bullet_2<=456;
		end
		
		else if (clk) 
		begin
			// shoot when debounced up
			if (pulse_up) begin					// TODO: 这里应该�?debounce_up，但是我上�?�写的debounced_up�?�能触�?�一次，�?知�?�错哪了
				if (tank_bullet_alive[0] == 1'b0) begin			// set bullet0 alive (=1)
					tank_bullet_alive[0] <= 1'b1;
				end
				else if (tank_bullet_alive[1] == 1'b0) begin	// set bullet1 alive (=1)
					tank_bullet_alive[1] <= 1'b1;
				end 
				else if (tank_bullet_alive[2] == 1'b0) begin	// set bullet2 alive (=1)
					tank_bullet_alive[2] <= 1'b1;
				end
				// else = 3'b111, no bullet available
			end
			
			
			// move tank left/right 
			else if(right) begin
				xpos_tank<=xpos_tank+2; 
				// (Also updating bullets position with tank IF not alive)
				if(tank_bullet_alive[0] == 1'b0)
					xpos_tank_bullet_0<=xpos_tank+2;
				if(tank_bullet_alive[1] == 1'b0)
					xpos_tank_bullet_1<=xpos_tank+2;
				if(tank_bullet_alive[2] == 1'b0)
					xpos_tank_bullet_2<=xpos_tank+2;
					
				// wrap around
				if(xpos_tank==800) begin
					xpos_tank<=150;
				end
			end
			else if(left) begin
				xpos_tank<=xpos_tank-2;
				// (Also updating bullets position with tank IF not alive)
				if(tank_bullet_alive[0] == 1'b0)
					xpos_tank_bullet_0<=xpos_tank-2;
				if(tank_bullet_alive[1] == 1'b0)
					xpos_tank_bullet_1<=xpos_tank-2;
				if(tank_bullet_alive[2] == 1'b0)
					xpos_tank_bullet_2<=xpos_tank-2;
					
				if(xpos_tank==150) begin
					xpos_tank<=800;
					if(tank_bullet_alive[0] == 1'b0)
						xpos_tank_bullet_0<=800;
					if(tank_bullet_alive[1] == 1'b0)
						xpos_tank_bullet_1<=800;
					if(tank_bullet_alive[2] == 1'b0)
						xpos_tank_bullet_2<=800;
				end
			end
			
			// IF tank bullets reached top of screen (range from 32-33), reset bullet to available (=0)
			if((32<=ypos_tank_bullet_0) && (ypos_tank_bullet_0<=33)) begin
				tank_bullet_alive[0] <= 1'b0;
				xpos_tank_bullet_0<=xpos_tank;
			end
		
			if((32<=ypos_tank_bullet_1) && (ypos_tank_bullet_1<=33)) begin
				tank_bullet_alive[1] <= 1'b0;
				xpos_tank_bullet_1<=xpos_tank;
			end
			
			if((32<=ypos_tank_bullet_2) && (ypos_tank_bullet_2<=33)) begin
				tank_bullet_alive[2] <= 1'b0;
				xpos_tank_bullet_2<=xpos_tank;
			end
		end
	end
	
	// ----------------------------------------------------------------------------------------Tank_Bullets-----------------------------------------------------------------------------------------
	// tank_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			ypos_tank_bullet_0<=450;
		end
		
		else if (clk) begin
			if (tank_bullet_alive[0] == 1'b1) begin
				// move up
				ypos_tank_bullet_0<=ypos_tank_bullet_0 - 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_tank_bullet_0<=ypos_tank;
			end
		end
	end
	
	// tank_bullet_1 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			ypos_tank_bullet_1<=450;
		end
		
		else if (clk) begin
			if (tank_bullet_alive[1] == 1'b1) begin
				// move up
				ypos_tank_bullet_1<=ypos_tank_bullet_1 - 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_tank_bullet_1<=ypos_tank;
			end
		end
	end
	
	// tank_bullet_2 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			ypos_tank_bullet_2<=450;
		end
		
		else if (clk) begin
			if (tank_bullet_alive[2] == 1'b1) begin
				// move up
				ypos_tank_bullet_2<=ypos_tank_bullet_2 - 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_tank_bullet_2<=ypos_tank;
			end
		end
	end
	
	// ------------------------------------------------------------------------------------------Monsters---------------------------------------------------------------------------------------------
	// monster_0 state block
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_0<=250;
			ypos_mons_0<=100;
			mons_0_bullet_alive<=3'b000;
		end
		
		else if (clk) 
		begin
			// shoot
			if (mons_0_bullet_alive[0] == 1'b0) begin											// set bullet0 alive (=1)
				mons_0_bullet_alive[0] <= 1'b1;
			end
			else if ((mons_0_bullet_alive[1] == 1'b0) && (250==ypos_mons_0_bullet_0))begin		// set bullet1 alive (=1)
				mons_0_bullet_alive[1] <= 1'b1;
			end 
			else if ((mons_0_bullet_alive[2] == 1'b0) && (450==ypos_mons_0_bullet_0))begin		// set bullet2 alive (=1)
				mons_0_bullet_alive[2] <= 1'b1;
			end

			// IF tank bullets reached top of screen (range from 32-34), reset bullet to available (=0)
			if((514<=ypos_mons_0_bullet_0) && (ypos_mons_0_bullet_0<=515)) begin
				mons_0_bullet_alive[0] <= 1'b0;
			end
			if((514<=ypos_mons_0_bullet_1) && (ypos_mons_0_bullet_1<=515)) begin
				mons_0_bullet_alive[1] <= 1'b0;
			end
			if((514<=ypos_mons_0_bullet_2) && (ypos_mons_0_bullet_2<=515)) begin
				mons_0_bullet_alive[2] <= 1'b0;
			end
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
			mons_1_bullet_alive<=3'b000;
		end
		
		else if (clk) 
		begin
			// shoot
			if (mons_1_bullet_alive[0] == 1'b0) begin											// set bullet0 alive (=1)
				mons_1_bullet_alive[0] <= 1'b1;
			end
			else if ((mons_1_bullet_alive[1] == 1'b0) && (180==ypos_mons_1_bullet_0))begin		// set bullet1 alive (=1)
				mons_1_bullet_alive[1] <= 1'b1;
			end 
			else if ((mons_1_bullet_alive[2] == 1'b0) && (380==ypos_mons_1_bullet_0))begin		// set bullet2 alive (=1)
				mons_1_bullet_alive[2] <= 1'b1;
			end

			// IF tank bullets reached top of screen (range from 32-34), reset bullet to available (=0)
			if((514<=ypos_mons_1_bullet_0) && (ypos_mons_1_bullet_0<=515)) begin
				mons_1_bullet_alive[0] <= 1'b0;
			end
			if((514<=ypos_mons_1_bullet_1) && (ypos_mons_1_bullet_1<=515)) begin
				mons_1_bullet_alive[1] <= 1'b0;
			end
			if((514<=ypos_mons_1_bullet_2) && (ypos_mons_1_bullet_2<=515)) begin
				mons_1_bullet_alive[2] <= 1'b0;
			end
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
			mons_2_bullet_alive<=3'b000;
		end
		
		else if (clk) 
		begin
			// shoot
			if (mons_2_bullet_alive[0] == 1'b0) begin											// set bullet0 alive (=1)
				mons_2_bullet_alive[0] <= 1'b1;
			end
			else if ((mons_2_bullet_alive[1] == 1'b0) && (250==ypos_mons_2_bullet_0))begin		// set bullet1 alive (=1)
				mons_2_bullet_alive[1] <= 1'b1;
			end 
			else if ((mons_2_bullet_alive[2] == 1'b0) && (450==ypos_mons_2_bullet_0))begin		// set bullet2 alive (=1)
				mons_2_bullet_alive[2] <= 1'b1;
			end

			// IF tank bullets reached top of screen (range from 32-34), reset bullet to available (=0)
			if((514<=ypos_mons_2_bullet_0) && (ypos_mons_2_bullet_0<=515)) begin
				mons_2_bullet_alive[0] <= 1'b0;
			end
			if((514<=ypos_mons_2_bullet_1) && (ypos_mons_2_bullet_1<=515)) begin
				mons_2_bullet_alive[1] <= 1'b0;
			end
			if((514<=ypos_mons_2_bullet_2) && (ypos_mons_2_bullet_2<=515)) begin
				mons_2_bullet_alive[2] <= 1'b0;
			end
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
			mons_3_bullet_alive<=3'b000;
		end
		
		else if (clk) 
		begin
			// shoot
			if (mons_3_bullet_alive[0] == 1'b0) begin											// set bullet0 alive (=1)
				mons_3_bullet_alive[0] <= 1'b1;
			end
			else if ((mons_3_bullet_alive[1] == 1'b0) && (200==ypos_mons_3_bullet_0))begin		// set bullet1 alive (=1)
				mons_3_bullet_alive[1] <= 1'b1;
			end 
			else if ((mons_3_bullet_alive[2] == 1'b0) && (400==ypos_mons_3_bullet_0))begin		// set bullet2 alive (=1)
				mons_3_bullet_alive[2] <= 1'b1;
			end

			// IF tank bullets reached top of screen (range from 32-34), reset bullet to available (=0)
			if((514<=ypos_mons_3_bullet_0) && (ypos_mons_3_bullet_0<=515)) begin
				mons_3_bullet_alive[0] <= 1'b0;
			end
			if((514<=ypos_mons_3_bullet_1) && (ypos_mons_3_bullet_1<=515)) begin
				mons_3_bullet_alive[1] <= 1'b0;
			end
			if((514<=ypos_mons_3_bullet_2) && (ypos_mons_3_bullet_2<=515)) begin
				mons_3_bullet_alive[2] <= 1'b0;
			end
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
			mons_4_bullet_alive<=3'b000;
		end
		
		else if (clk) 
		begin
			// shoot
			if (mons_4_bullet_alive[0] == 1'b0) begin											// set bullet0 alive (=1)
				mons_4_bullet_alive[0] <= 1'b1;
			end
			else if ((mons_4_bullet_alive[1] == 1'b0) && (260==ypos_mons_4_bullet_0))begin		// set bullet1 alive (=1)
				mons_4_bullet_alive[1] <= 1'b1;
			end 
			else if ((mons_4_bullet_alive[2] == 1'b0) && (460==ypos_mons_4_bullet_0))begin		// set bullet2 alive (=1)
				mons_4_bullet_alive[2] <= 1'b1;
			end

			// IF tank bullets reached top of screen (range from 32-34), reset bullet to available (=0)
			if((514<=ypos_mons_4_bullet_0) && (ypos_mons_4_bullet_0<=515)) begin
				mons_4_bullet_alive[0] <= 1'b0;
			end
			if((514<=ypos_mons_4_bullet_1) && (ypos_mons_4_bullet_1<=515)) begin
				mons_4_bullet_alive[1] <= 1'b0;
			end
			if((514<=ypos_mons_4_bullet_2) && (ypos_mons_4_bullet_2<=515)) begin
				mons_4_bullet_alive[2] <= 1'b0;
			end
		end
	end
	// -------------------------------------------------------------------------------------Monster_Bullets-------------------------------------------------------------------------------------------
	// The frequency of the bullets is determined by the positions of previous bullets
	// monster_0_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_0_bullet_0<=250;
			ypos_mons_0_bullet_0<=100;
		end
		
		else if (clk) begin
			if (mons_0_bullet_alive[0] == 1'b1) begin
				// move down
				ypos_mons_0_bullet_0<=ypos_mons_0_bullet_0 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_0_bullet_0<=ypos_mons_0;
			end
		end
	end
	
	// monster_0_bullet_1 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_0_bullet_1<=250;
			ypos_mons_0_bullet_1<=100;
		end
		
		else if (clk) begin
			if (mons_0_bullet_alive[1] == 1'b1) begin
				// move down
				ypos_mons_0_bullet_1<=ypos_mons_0_bullet_1 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_0_bullet_1<=ypos_mons_0;
			end
		end
	end
	
	// monster_0_bullet_2 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_0_bullet_2<=250;
			ypos_mons_0_bullet_2<=100;
		end
		
		else if (clk) begin
			if (mons_0_bullet_alive[2] == 1'b1) begin
				// move down
				ypos_mons_0_bullet_2<=ypos_mons_0_bullet_2 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_0_bullet_2<=ypos_mons_0;
			end
		end
	end
	
	// monster_1_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_1_bullet_0<=350;
			ypos_mons_1_bullet_0<=100;
		end
		
		else if (clk) begin
			if (mons_1_bullet_alive[0] == 1'b1) begin
				// move down
				ypos_mons_1_bullet_0<=ypos_mons_1_bullet_0 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_1_bullet_0<=ypos_mons_1;
			end
		end
	end
	
	// monster_1_bullet_1 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_1_bullet_1<=350;
			ypos_mons_1_bullet_1<=100;
		end
		
		else if (clk) begin
			if (mons_1_bullet_alive[1] == 1'b1) begin
				// move down
				ypos_mons_1_bullet_1<=ypos_mons_1_bullet_1 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_1_bullet_1<=ypos_mons_1;
			end
		end
	end
	
	// monster_1_bullet_2 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_1_bullet_2<=350;
			ypos_mons_1_bullet_2<=100;
		end
		
		else if (clk) begin
			if (mons_1_bullet_alive[2] == 1'b1) begin
				// move down
				ypos_mons_1_bullet_2<=ypos_mons_1_bullet_2 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_1_bullet_2<=ypos_mons_1;
			end
		end
	end
	
	// monster_2_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_2_bullet_0<=450;
			ypos_mons_2_bullet_0<=100;
		end
		
		else if (clk) begin
			if (mons_2_bullet_alive[0] == 1'b1) begin
				// move down
				ypos_mons_2_bullet_0<=ypos_mons_2_bullet_0 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_2_bullet_0<=ypos_mons_2;
			end
		end
	end
	
	// monster_2_bullet_1 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_2_bullet_1<=450;
			ypos_mons_2_bullet_1<=100;
		end
		
		else if (clk) begin
			if (mons_2_bullet_alive[1] == 1'b1) begin
				// move down
				ypos_mons_2_bullet_1<=ypos_mons_2_bullet_1 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_2_bullet_1<=ypos_mons_2;
			end
		end
	end
	
	// monster_2_bullet_2 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_2_bullet_2<=450;
			ypos_mons_2_bullet_2<=100;
		end
		
		else if (clk) begin
			if (mons_2_bullet_alive[2] == 1'b1) begin
				// move down
				ypos_mons_2_bullet_2<=ypos_mons_2_bullet_2 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_2_bullet_2<=ypos_mons_2;
			end
		end
	end
	
	// monster_3_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_3_bullet_0<=550;
			ypos_mons_3_bullet_0<=100;
		end
		
		else if (clk) begin
			if (mons_3_bullet_alive[0] == 1'b1) begin
				// move down
				ypos_mons_3_bullet_0<=ypos_mons_3_bullet_0 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_3_bullet_0<=ypos_mons_3;
			end
		end
	end
	
	// monster_3_bullet_1 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_3_bullet_1<=550;
			ypos_mons_3_bullet_1<=100;
		end
		
		else if (clk) begin
			if (mons_3_bullet_alive[1] == 1'b1) begin
				// move down
				ypos_mons_3_bullet_1<=ypos_mons_3_bullet_1 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_3_bullet_1<=ypos_mons_3;
			end
		end
	end
	
	// monster_3_bullet_2 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_3_bullet_2<=550;
			ypos_mons_3_bullet_2<=100;
		end
		
		else if (clk) begin
			if (mons_3_bullet_alive[2] == 1'b1) begin
				// move down
				ypos_mons_3_bullet_2<=ypos_mons_3_bullet_2 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_3_bullet_2<=ypos_mons_3;
			end
		end
	end
	
	// monster_4_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_4_bullet_0<=650;
			ypos_mons_4_bullet_0<=100;
		end
		
		else if (clk) begin
			if (mons_4_bullet_alive[0] == 1'b1) begin
				// move down
				ypos_mons_4_bullet_0<=ypos_mons_4_bullet_0 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_4_bullet_0<=ypos_mons_4;
			end
		end
	end
	
	// monster_4_bullet_1 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_4_bullet_1<=650;
			ypos_mons_4_bullet_1<=100;
		end
		
		else if (clk) begin
			if (mons_4_bullet_alive[1] == 1'b1) begin
				// move down
				ypos_mons_4_bullet_1<=ypos_mons_4_bullet_1 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_4_bullet_1<=ypos_mons_4;
			end
		end
	end
	
	// monster_4_bullet_2 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			//rough values for center of screen
			xpos_mons_4_bullet_2<=650;
			ypos_mons_4_bullet_2<=100;
		end
		
		else if (clk) begin
			if (mons_4_bullet_alive[2] == 1'b1) begin
				// move down
				ypos_mons_4_bullet_2<=ypos_mons_4_bullet_2 + 1;
			end
			else begin
				// not alive, set ypos to be same as tank
				ypos_mons_4_bullet_2<=ypos_mons_4;
			end
		end
	end
endmodule