`timescale 1ns / 1ps

module block_controller(
	input clk,
	input bright,
	input rst,
	input left, input right, input up,
	input [9:0] hCount, vCount,
	input [1:0] level_in,
	output reg [11:0] rgb,
	output reg [11:0] background,
	output reg [4:0] monster_destroyed,
	output reg tank_destroyed,
	output reg [3:0] score
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
	parameter EMERLD= 12'b0101_1101_0110; //(80, 220, 100)
	parameter BLUE 	= 12'b0000_0000_1111;
	parameter PURPLE= 12'b1111_0000_1111;
	parameter CYAN  = 12'b0000_1111_1111;
	parameter PINK  = 12'b1111_1001_1010;
	parameter GREY  = 12'b1000_1000_1000;
	parameter YELLOW= 12'b1111_1111_0000;
	parameter GOLD 	= 12'b1111_1010_0000;
	
	always@ (*) begin
		if(~bright)	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (monster_destroyed == 5'b11111 && win_W)
			rgb = CYAN;
		else if (tank_destroyed && lose_L)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && tank_bullet_0)
			rgb = BLUE;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && tank_bullet_1)
			rgb = BLUE;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && tank_bullet_2)
			rgb = BLUE;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && tank_outter)
			rgb = GREY;	
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && tank_body)
			rgb = GREEN;	
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && mons_0_eye)
			rgb = YELLOW;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && mons_1_eye)
			rgb = PINK;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && mons_2_eye)
			rgb = BLUE;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && mons_3_eye)
			rgb = GOLD;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && mons_4_eye)
			rgb = CYAN;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_0)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_1)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_2)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_3)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_4)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_0_bullet_0)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_0_bullet_1)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_0_bullet_2)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_1_bullet_0)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_1_bullet_1)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_1_bullet_2)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_2_bullet_0)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_2_bullet_1)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_2_bullet_2)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_3_bullet_0)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_3_bullet_1)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_3_bullet_2)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_4_bullet_0)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_4_bullet_1)
			rgb = RED;
		else if (~tank_destroyed && monster_destroyed != 5'b11111 && monster_4_bullet_2)
			rgb = RED;
		else
			rgb = background;
	end
	
	// -------------------------------------------------------------------------------------Draw_Shape_in_Pixel--------------------------------------------------------------------------------------
	// win \ lose
	assign lose_L = vCount>=(35+60) && vCount<=(35+420) && hCount>=(144+230) && hCount<=(144+300) ||
					vCount>=(35+350) && vCount<=(35+420) && hCount>=(144+230) && hCount<=(144+470);
	assign win_W = vCount>=(35+390) && vCount<=(35+450) && hCount>=(94+175) && hCount<=(94+500) ||
					vCount>=(35+90) && vCount<=(35+390) && hCount>=(94+175) && hCount<=(94+240) ||
					vCount>=(35+90) && vCount<=(35+390) && hCount>=(94+305) && hCount<=(94+370) ||
					vCount>=(35+90) && vCount<=(35+390) && hCount>=(94+435) && hCount<=(94+500);
	
	// draw tank
	assign tank_body = vCount>=(ypos_tank-6) && vCount<=(ypos_tank+6) && hCount>=(xpos_tank-6) && hCount<=(xpos_tank+6);
	assign tank_outter = vCount>=(ypos_tank-10) && vCount<=(ypos_tank+10) && hCount>=(xpos_tank-9) && hCount<=(xpos_tank-6) ||
						vCount>=(ypos_tank-10) && vCount<=(ypos_tank+10) && hCount>=(xpos_tank+6) && hCount<=(xpos_tank+9) ||
						vCount>=(ypos_tank-18) && vCount<=(ypos_tank) && hCount>=(xpos_tank-1) && hCount<=(xpos_tank+1);
						
	// draw tank bullets
	assign tank_bullet_0 =vCount>=(ypos_tank_bullet_0 -1) && vCount<=(ypos_tank_bullet_0 +1) && hCount>=(xpos_tank_bullet_0 -1) && hCount<=(xpos_tank_bullet_0 +1);
	assign tank_bullet_1 =vCount>=(ypos_tank_bullet_1 -1) && vCount<=(ypos_tank_bullet_1 +1) && hCount>=(xpos_tank_bullet_1 -1) && hCount<=(xpos_tank_bullet_1 +1);
	assign tank_bullet_2 =vCount>=(ypos_tank_bullet_2 -1) && vCount<=(ypos_tank_bullet_2 +1) && hCount>=(xpos_tank_bullet_2 -1) && hCount<=(xpos_tank_bullet_2 +1);
	
	// draw monsters_0
	assign mons_0_eye = (vCount>=(ypos_mons_0-2) && vCount<=(ypos_mons_0) && hCount>=(xpos_mons_0-5) && hCount<=(xpos_mons_0-3)) || 
	(vCount>=(ypos_mons_0-2) && vCount<=(ypos_mons_0) && hCount>=(xpos_mons_0+3) && hCount<=(xpos_mons_0+5));
	assign monster_0 = (vCount>=(ypos_mons_0-2) && vCount<=(ypos_mons_0+3) && hCount>=(xpos_mons_0-7) && hCount<=(xpos_mons_0+7)) || (vCount>=(ypos_mons_0-3) && vCount<=(ypos_mons_0-2) && hCount>=(xpos_mons_0+4) && hCount<=(xpos_mons_0+7)) ||
	(vCount>=(ypos_mons_0-4) && vCount<=(ypos_mons_0-3) && hCount>=(xpos_mons_0+2) && hCount<=(xpos_mons_0+4)) ||
	(vCount>=(ypos_mons_0-2) && vCount<=(ypos_mons_0) && hCount>=(xpos_mons_0+7) && hCount<=(xpos_mons_0+10)) ||
	(vCount>=(ypos_mons_0-5) && vCount<=(ypos_mons_0-2) && hCount>=(xpos_mons_0+8) && hCount<=(xpos_mons_0+10)) ||
	(vCount>=(ypos_mons_0+3) && vCount<=(ypos_mons_0+4) && hCount>=(xpos_mons_0+7) && hCount<=(xpos_mons_0+8)) ||
	(vCount>=(ypos_mons_0+4) && vCount<=(ypos_mons_0+5) && hCount>=(xpos_mons_0+8) && hCount<=(xpos_mons_0+10)) || 
	(vCount>=(ypos_mons_0-3) && vCount<=(ypos_mons_0-2) && hCount>=(xpos_mons_0-7) && hCount<=(xpos_mons_0-4)) ||
	(vCount>=(ypos_mons_0-4) && vCount<=(ypos_mons_0-3) && hCount>=(xpos_mons_0-4) && hCount<=(xpos_mons_0-2)) ||
	(vCount>=(ypos_mons_0-2) && vCount<=(ypos_mons_0) && hCount>=(xpos_mons_0-10) && hCount<=(xpos_mons_0-7)) ||
	(vCount>=(ypos_mons_0-5) && vCount<=(ypos_mons_0-2) && hCount>=(xpos_mons_0-10) && hCount<=(xpos_mons_0-8)) ||
	(vCount>=(ypos_mons_0+3) && vCount<=(ypos_mons_0+4) && hCount>=(xpos_mons_0-8) && hCount<=(xpos_mons_0-7)) ||
	(vCount>=(ypos_mons_0+4) && vCount<=(ypos_mons_0+5) && hCount>=(xpos_mons_0-10) && hCount<=(xpos_mons_0-8));
	
	// draw monsters_1
	assign mons_1_eye = (vCount>=(ypos_mons_1-2) && vCount<=(ypos_mons_1) && hCount>=(xpos_mons_1-5) && hCount<=(xpos_mons_1-3)) || 
	(vCount>=(ypos_mons_1-2) && vCount<=(ypos_mons_1) && hCount>=(xpos_mons_1+3) && hCount<=(xpos_mons_1+5));
	assign monster_1 = (vCount>=(ypos_mons_1-2) && vCount<=(ypos_mons_1+3) && hCount>=(xpos_mons_1-7) && hCount<=(xpos_mons_1+7)) || (vCount>=(ypos_mons_1-3) && vCount<=(ypos_mons_1-2) && hCount>=(xpos_mons_1+4) && hCount<=(xpos_mons_1+7)) ||
	(vCount>=(ypos_mons_1-4) && vCount<=(ypos_mons_1-3) && hCount>=(xpos_mons_1+2) && hCount<=(xpos_mons_1+4)) ||
	(vCount>=(ypos_mons_1-2) && vCount<=(ypos_mons_1) && hCount>=(xpos_mons_1+7) && hCount<=(xpos_mons_1+10)) ||
	(vCount>=(ypos_mons_1-5) && vCount<=(ypos_mons_1-2) && hCount>=(xpos_mons_1+8) && hCount<=(xpos_mons_1+10)) ||
	(vCount>=(ypos_mons_1+3) && vCount<=(ypos_mons_1+4) && hCount>=(xpos_mons_1+7) && hCount<=(xpos_mons_1+8)) ||
	(vCount>=(ypos_mons_1+4) && vCount<=(ypos_mons_1+5) && hCount>=(xpos_mons_1+8) && hCount<=(xpos_mons_1+10)) || 
	(vCount>=(ypos_mons_1-3) && vCount<=(ypos_mons_1-2) && hCount>=(xpos_mons_1-7) && hCount<=(xpos_mons_1-4)) ||
	(vCount>=(ypos_mons_1-4) && vCount<=(ypos_mons_1-3) && hCount>=(xpos_mons_1-4) && hCount<=(xpos_mons_1-2)) ||
	(vCount>=(ypos_mons_1-2) && vCount<=(ypos_mons_1) && hCount>=(xpos_mons_1-10) && hCount<=(xpos_mons_1-7)) ||
	(vCount>=(ypos_mons_1-5) && vCount<=(ypos_mons_1-2) && hCount>=(xpos_mons_1-10) && hCount<=(xpos_mons_1-8)) ||
	(vCount>=(ypos_mons_1+3) && vCount<=(ypos_mons_1+4) && hCount>=(xpos_mons_1-8) && hCount<=(xpos_mons_1-7)) ||
	(vCount>=(ypos_mons_1+4) && vCount<=(ypos_mons_1+5) && hCount>=(xpos_mons_1-10) && hCount<=(xpos_mons_1-8));
	
	// draw monsters_2
	assign mons_2_eye = (vCount>=(ypos_mons_2-2) && vCount<=(ypos_mons_2) && hCount>=(xpos_mons_2-5) && hCount<=(xpos_mons_2-3)) || 
	(vCount>=(ypos_mons_2-2) && vCount<=(ypos_mons_2) && hCount>=(xpos_mons_2+3) && hCount<=(xpos_mons_2+5));
	assign monster_2 = (vCount>=(ypos_mons_2-2) && vCount<=(ypos_mons_2+3) && hCount>=(xpos_mons_2-7) && hCount<=(xpos_mons_2+7)) || (vCount>=(ypos_mons_2-3) && vCount<=(ypos_mons_2-2) && hCount>=(xpos_mons_2+4) && hCount<=(xpos_mons_2+7)) ||
	(vCount>=(ypos_mons_2-4) && vCount<=(ypos_mons_2-3) && hCount>=(xpos_mons_2+2) && hCount<=(xpos_mons_2+4)) ||
	(vCount>=(ypos_mons_2-2) && vCount<=(ypos_mons_2) && hCount>=(xpos_mons_2+7) && hCount<=(xpos_mons_2+10)) ||
	(vCount>=(ypos_mons_2-5) && vCount<=(ypos_mons_2-2) && hCount>=(xpos_mons_2+8) && hCount<=(xpos_mons_2+10)) ||
	(vCount>=(ypos_mons_2+3) && vCount<=(ypos_mons_2+4) && hCount>=(xpos_mons_2+7) && hCount<=(xpos_mons_2+8)) ||
	(vCount>=(ypos_mons_2+4) && vCount<=(ypos_mons_2+5) && hCount>=(xpos_mons_2+8) && hCount<=(xpos_mons_2+10)) || 
	(vCount>=(ypos_mons_2-3) && vCount<=(ypos_mons_2-2) && hCount>=(xpos_mons_2-7) && hCount<=(xpos_mons_2-4)) ||
	(vCount>=(ypos_mons_2-4) && vCount<=(ypos_mons_2-3) && hCount>=(xpos_mons_2-4) && hCount<=(xpos_mons_2-2)) ||
	(vCount>=(ypos_mons_2-2) && vCount<=(ypos_mons_2) && hCount>=(xpos_mons_2-10) && hCount<=(xpos_mons_2-7)) ||
	(vCount>=(ypos_mons_2-5) && vCount<=(ypos_mons_2-2) && hCount>=(xpos_mons_2-10) && hCount<=(xpos_mons_2-8)) ||
	(vCount>=(ypos_mons_2+3) && vCount<=(ypos_mons_2+4) && hCount>=(xpos_mons_2-8) && hCount<=(xpos_mons_2-7)) ||
	(vCount>=(ypos_mons_2+4) && vCount<=(ypos_mons_2+5) && hCount>=(xpos_mons_2-10) && hCount<=(xpos_mons_2-8));
	
	// draw monsters_3
	assign mons_3_eye = (vCount>=(ypos_mons_3-2) && vCount<=(ypos_mons_3) && hCount>=(xpos_mons_3-5) && hCount<=(xpos_mons_3-3)) || 
	(vCount>=(ypos_mons_3-2) && vCount<=(ypos_mons_3) && hCount>=(xpos_mons_3+3) && hCount<=(xpos_mons_3+5));
	assign monster_3 = (vCount>=(ypos_mons_3-2) && vCount<=(ypos_mons_3+3) && hCount>=(xpos_mons_3-7) && hCount<=(xpos_mons_3+7)) || (vCount>=(ypos_mons_3-3) && vCount<=(ypos_mons_3-2) && hCount>=(xpos_mons_3+4) && hCount<=(xpos_mons_3+7)) ||
	(vCount>=(ypos_mons_3-4) && vCount<=(ypos_mons_3-3) && hCount>=(xpos_mons_3+2) && hCount<=(xpos_mons_3+4)) ||
	(vCount>=(ypos_mons_3-2) && vCount<=(ypos_mons_3) && hCount>=(xpos_mons_3+7) && hCount<=(xpos_mons_3+10)) ||
	(vCount>=(ypos_mons_3-5) && vCount<=(ypos_mons_3-2) && hCount>=(xpos_mons_3+8) && hCount<=(xpos_mons_3+10)) ||
	(vCount>=(ypos_mons_3+3) && vCount<=(ypos_mons_3+4) && hCount>=(xpos_mons_3+7) && hCount<=(xpos_mons_3+8)) ||
	(vCount>=(ypos_mons_3+4) && vCount<=(ypos_mons_3+5) && hCount>=(xpos_mons_3+8) && hCount<=(xpos_mons_3+10)) || 
	(vCount>=(ypos_mons_3-3) && vCount<=(ypos_mons_3-2) && hCount>=(xpos_mons_3-7) && hCount<=(xpos_mons_3-4)) ||
	(vCount>=(ypos_mons_3-4) && vCount<=(ypos_mons_3-3) && hCount>=(xpos_mons_3-4) && hCount<=(xpos_mons_3-2)) ||
	(vCount>=(ypos_mons_3-2) && vCount<=(ypos_mons_3) && hCount>=(xpos_mons_3-10) && hCount<=(xpos_mons_3-7)) ||
	(vCount>=(ypos_mons_3-5) && vCount<=(ypos_mons_3-2) && hCount>=(xpos_mons_3-10) && hCount<=(xpos_mons_3-8)) ||
	(vCount>=(ypos_mons_3+3) && vCount<=(ypos_mons_3+4) && hCount>=(xpos_mons_3-8) && hCount<=(xpos_mons_3-7)) ||
	(vCount>=(ypos_mons_3+4) && vCount<=(ypos_mons_3+5) && hCount>=(xpos_mons_3-10) && hCount<=(xpos_mons_3-8));
	
	// draw monsters_4
	assign mons_4_eye = (vCount>=(ypos_mons_4-2) && vCount<=(ypos_mons_4) && hCount>=(xpos_mons_4-5) && hCount<=(xpos_mons_4-3)) || 
	(vCount>=(ypos_mons_4-2) && vCount<=(ypos_mons_4) && hCount>=(xpos_mons_4+3) && hCount<=(xpos_mons_4+5));
	assign monster_4 = (vCount>=(ypos_mons_4-2) && vCount<=(ypos_mons_4+3) && hCount>=(xpos_mons_4-7) && hCount<=(xpos_mons_4+7)) || (vCount>=(ypos_mons_4-3) && vCount<=(ypos_mons_4-2) && hCount>=(xpos_mons_4+4) && hCount<=(xpos_mons_4+7)) ||
	(vCount>=(ypos_mons_4-4) && vCount<=(ypos_mons_4-3) && hCount>=(xpos_mons_4+2) && hCount<=(xpos_mons_4+4)) ||
	(vCount>=(ypos_mons_4-2) && vCount<=(ypos_mons_4) && hCount>=(xpos_mons_4+7) && hCount<=(xpos_mons_4+10)) ||
	(vCount>=(ypos_mons_4-5) && vCount<=(ypos_mons_4-2) && hCount>=(xpos_mons_4+8) && hCount<=(xpos_mons_4+10)) ||
	(vCount>=(ypos_mons_4+3) && vCount<=(ypos_mons_4+4) && hCount>=(xpos_mons_4+7) && hCount<=(xpos_mons_4+8)) ||
	(vCount>=(ypos_mons_4+4) && vCount<=(ypos_mons_4+5) && hCount>=(xpos_mons_4+8) && hCount<=(xpos_mons_4+10)) || 
	(vCount>=(ypos_mons_4-3) && vCount<=(ypos_mons_4-2) && hCount>=(xpos_mons_4-7) && hCount<=(xpos_mons_4-4)) ||
	(vCount>=(ypos_mons_4-4) && vCount<=(ypos_mons_4-3) && hCount>=(xpos_mons_4-4) && hCount<=(xpos_mons_4-2)) ||
	(vCount>=(ypos_mons_4-2) && vCount<=(ypos_mons_4) && hCount>=(xpos_mons_4-10) && hCount<=(xpos_mons_4-7)) ||
	(vCount>=(ypos_mons_4-5) && vCount<=(ypos_mons_4-2) && hCount>=(xpos_mons_4-10) && hCount<=(xpos_mons_4-8)) ||
	(vCount>=(ypos_mons_4+3) && vCount<=(ypos_mons_4+4) && hCount>=(xpos_mons_4-8) && hCount<=(xpos_mons_4-7)) ||
	(vCount>=(ypos_mons_4+4) && vCount<=(ypos_mons_4+5) && hCount>=(xpos_mons_4-10) && hCount<=(xpos_mons_4-8));
	
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
	
	// Debounce all btn press here
	// ee201_debouncer(clk, rst, up, DPB, SCEN, MCEN, CCEN);
	debounce(rst, clk, up, DPB, SCEN);
	
	// ---------------------------------------------------------------------------------------Tank-------------------------------------------------------------------------------------------------
	
	// tank state block: left, right, shoot
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin
			// bg color
			background <= BLACK;
			// rough values for center of screen
			xpos_tank<=450;
			ypos_tank<=450;
			// tank_bullet_alive & xpos of bullet can be assigned in tank blcok
			// and only ypos of bullet can only be assigned in corresponding bullet block
			tank_bullet_alive <= 3'b000;
			xpos_tank_bullet_0<=1000;
			xpos_tank_bullet_1<=1000;
			xpos_tank_bullet_2<=1000;
			// reset destory flag
			tank_destroyed <= 0;
			monster_destroyed <= 5'b01010;
			score <= 0;
		end
		else if (level_in == 1)		// next level
		begin
			// bg color
			background <= BLACK;
			// rough values for center of screen
			xpos_tank<=450;
			ypos_tank<=450;
			// tank_bullet_alive & xpos of bullet can be assigned in tank blcok
			// and only ypos of bullet can only be assigned in corresponding bullet block
			tank_bullet_alive <= 3'b000;
			xpos_tank_bullet_0<=1000;
			xpos_tank_bullet_1<=1000;
			xpos_tank_bullet_2<=1000;
			// reset destory flag
			tank_destroyed <= 0;
			monster_destroyed <= 5'b00000;
		end
		
		else if (clk) 
		begin
			// shoot when debounced up, activate bullet
			if (SCEN) begin
				if (tank_bullet_alive[0] == 1'b0) begin			// set bullet0 alive (=1)
					tank_bullet_alive[0] <= 1'b1;
					xpos_tank_bullet_0 <= xpos_tank;
				end
				else if (tank_bullet_alive[1] == 1'b0) begin	// set bullet1 alive (=1)
					tank_bullet_alive[1] <= 1'b1;
					xpos_tank_bullet_1 <= xpos_tank;
				end 
				else if (tank_bullet_alive[2] == 1'b0) begin	// set bullet2 alive (=1)
					tank_bullet_alive[2] <= 1'b1;
					xpos_tank_bullet_2 <= xpos_tank;
				end
				// else = 3'b111, no bullet available
			end
			
			// move tank left/right 
			else if(right) begin
				xpos_tank<=xpos_tank+2; 
				// wrap around
				if(xpos_tank==800) begin
					xpos_tank<=150;
				end
			end
			else if(left) begin
				xpos_tank<=xpos_tank-2;
				// wrap around
				if(xpos_tank==150) begin
					xpos_tank<=800;
				end
			end

			//----------------------------------------------------------------------------Check_Hit_Monsters--------------------------------------------------------------------------------------------
			if(tank_bullet_alive[0])
			begin
				//hit mons0
				if( (xpos_tank_bullet_0 <= xpos_mons_0+10) && (xpos_tank_bullet_0 >= xpos_mons_0-10) && (ypos_tank_bullet_0 == ypos_mons_0))
				begin
					monster_destroyed[0] = 1;
					tank_bullet_alive[0] <= 1'b0;
					xpos_tank_bullet_0<=1000;
					score <= score+1;
				end
				//hit mons1
				if( (xpos_tank_bullet_0 <= xpos_mons_1+10) && (xpos_tank_bullet_0 >= xpos_mons_1-10)  && (ypos_tank_bullet_0 == ypos_mons_1))
				begin
					monster_destroyed[1] = 1;
					tank_bullet_alive[0] <= 1'b0;
					xpos_tank_bullet_0<=1000;
					score <= score+1;
				end
				//hit mons2
				if( (xpos_tank_bullet_0 <= xpos_mons_2+10) && (xpos_tank_bullet_0 >= xpos_mons_2-10)  && (ypos_tank_bullet_0 == ypos_mons_2))
				begin
					monster_destroyed[2] = 1;
					tank_bullet_alive[0] <= 1'b0;
					xpos_tank_bullet_0<=1000;
					score <= score+1;
				end
				//hit mons3
				if( (xpos_tank_bullet_0 <= xpos_mons_3+10) && (xpos_tank_bullet_0 >= xpos_mons_3-10)  && (ypos_tank_bullet_0 == ypos_mons_3))
				begin
					monster_destroyed[3] = 1;
					tank_bullet_alive[0] <= 1'b0;
					xpos_tank_bullet_0<=1000;
					score <= score+1;
				end
				//hit mons4
				if( (xpos_tank_bullet_0 <= xpos_mons_4+10) && (xpos_tank_bullet_0 >= xpos_mons_4-10)  && (ypos_tank_bullet_0 == ypos_mons_4))
				begin
					monster_destroyed[4] = 1;
					tank_bullet_alive[0] <= 1'b0;
					xpos_tank_bullet_0<=1000;
					score <= score+1;
				end
			end

			//check if bullet 1 hits monster
			if(tank_bullet_alive[1])
			begin
				//hit mons0
				if( (xpos_tank_bullet_1 <= xpos_mons_0+10) && (xpos_tank_bullet_1 >= xpos_mons_0-10) && (ypos_tank_bullet_1 == ypos_mons_0))
				begin
					monster_destroyed[0] = 1;
					tank_bullet_alive[1] <= 1'b0;
					xpos_tank_bullet_1<=1000;
					score <= score+1;
				end
				//hit mons1
				if( (xpos_tank_bullet_1 <= xpos_mons_1+10) && (xpos_tank_bullet_1 >= xpos_mons_1-10)  && (ypos_tank_bullet_1 == ypos_mons_1))
				begin
					monster_destroyed[1] = 1;
					tank_bullet_alive[1] <= 1'b0;
					xpos_tank_bullet_1<=1000;
					score <= score+1;
				end
				//hit mons2
				if( (xpos_tank_bullet_1 <= xpos_mons_2+10) && (xpos_tank_bullet_1 >= xpos_mons_2-10)  && (ypos_tank_bullet_1 == ypos_mons_2))
				begin
					monster_destroyed[2] = 1;
					tank_bullet_alive[1] <= 1'b0;
					xpos_tank_bullet_1<=1000;
					score <= score+1;
				end
				//hit mons3
				if( (xpos_tank_bullet_1 <= xpos_mons_3+10) && (xpos_tank_bullet_1 >= xpos_mons_3-10)  && (ypos_tank_bullet_1 == ypos_mons_3))
				begin
					monster_destroyed[3] = 1;
					tank_bullet_alive[1] <= 1'b0;
					xpos_tank_bullet_1<=1000;
					score <= score+1;
				end
				//hit mons4
				if( (xpos_tank_bullet_1 <= xpos_mons_4+10) && (xpos_tank_bullet_1 >= xpos_mons_4-10)  && (ypos_tank_bullet_1 == ypos_mons_4))
				begin
					monster_destroyed[4] = 1;
					tank_bullet_alive[1] <= 1'b0;
					xpos_tank_bullet_1<=1000;
					score <= score+1;
				end
			end

			//check if bullet 2 hits monster
			if(tank_bullet_alive[2])
			begin
				//hit mons0
				if( (xpos_tank_bullet_2 <= xpos_mons_0+10) && (xpos_tank_bullet_2 >= xpos_mons_0-10) && (ypos_tank_bullet_2 == ypos_mons_0))
				begin
					monster_destroyed[0] = 1;
					tank_bullet_alive[2] <= 1'b0;
					xpos_tank_bullet_2<=1000;
					score <= score+1;
				end
				//hit mons1
				if( (xpos_tank_bullet_2 <= xpos_mons_1+10) && (xpos_tank_bullet_2 >= xpos_mons_1-10)  && (ypos_tank_bullet_2 == ypos_mons_1))
				begin
					monster_destroyed[1] = 1;
					tank_bullet_alive[2] <= 1'b0;
					xpos_tank_bullet_2<=1000;
					score <= score+1;
				end
				//hit mons2
				if( (xpos_tank_bullet_2 <= xpos_mons_2+10) && (xpos_tank_bullet_2 >= xpos_mons_2-10)  && (ypos_tank_bullet_2 == ypos_mons_2))
				begin
					monster_destroyed[2] = 1;
					tank_bullet_alive[2] <= 1'b0;
					xpos_tank_bullet_2<=1000;
					score <= score+1;
				end
				//hit mons3
				if( (xpos_tank_bullet_2 <= xpos_mons_3+10) && (xpos_tank_bullet_2 >= xpos_mons_3-10)  && (ypos_tank_bullet_2 == ypos_mons_3))
				begin
					monster_destroyed[3] = 1;
					tank_bullet_alive[2] <= 1'b0;
					xpos_tank_bullet_2<=1000;
					score <= score+1;
				end
				//hit mons4
				if( (xpos_tank_bullet_2 <= xpos_mons_4+10) && (xpos_tank_bullet_2 >= xpos_mons_4-10)  && (ypos_tank_bullet_2 == ypos_mons_4))
				begin
					monster_destroyed[4] = 1;
					tank_bullet_alive[2] <= 1'b0;
					xpos_tank_bullet_2<=1000;
					score <= score+1;
				end
			end
			
			//----------------------------------------------------------------------------Check_Hit_Tank--------------------------------------------------------------------------------------------
			//check if bullets from monster_0 hits tank
			if(mons_0_bullet_alive[0])
			begin
				//hit tank
				if( (xpos_mons_0_bullet_0 <= xpos_tank+10) && (xpos_mons_0_bullet_0 >= xpos_tank-10) && (ypos_mons_0_bullet_0 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_0_bullet_alive[1])
			begin
				//hit tank
				if( (xpos_mons_0_bullet_1 <= xpos_tank+10) && (xpos_mons_0_bullet_1 >= xpos_tank-10) && (ypos_mons_0_bullet_1 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_0_bullet_alive[2])
			begin
				//hit tank
				if( (xpos_mons_0_bullet_2 <= xpos_tank+10) && (xpos_mons_0_bullet_2 >= xpos_tank-10) && (ypos_mons_0_bullet_2 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			
			//check if bullets from monster_1 hits tank
			if(mons_1_bullet_alive[0])
			begin
				//hit tank
				if( (xpos_mons_1_bullet_0 <= xpos_tank+10) && (xpos_mons_1_bullet_0 >= xpos_tank-10) && (ypos_mons_1_bullet_0 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_1_bullet_alive[1])
			begin
				//hit tank
				if( (xpos_mons_1_bullet_1 <= xpos_tank+10) && (xpos_mons_1_bullet_1 >= xpos_tank-10) && (ypos_mons_1_bullet_1 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_1_bullet_alive[2])
			begin
				//hit tank
				if( (xpos_mons_1_bullet_2 <= xpos_tank+10) && (xpos_mons_1_bullet_2 >= xpos_tank-10) && (ypos_mons_1_bullet_2 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			
			//check if bullets from monster_2 hits tank
			if(mons_2_bullet_alive[0])
			begin
				//hit tank
				if( (xpos_mons_2_bullet_0 <= xpos_tank+10) && (xpos_mons_2_bullet_0 >= xpos_tank-10) && (ypos_mons_2_bullet_0 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_2_bullet_alive[1])
			begin
				//hit tank
				if( (xpos_mons_2_bullet_1 <= xpos_tank+10) && (xpos_mons_2_bullet_1 >= xpos_tank-10) && (ypos_mons_2_bullet_1 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_2_bullet_alive[2])
			begin
				//hit tank
				if( (xpos_mons_2_bullet_2 <= xpos_tank+10) && (xpos_mons_2_bullet_2 >= xpos_tank-10) && (ypos_mons_2_bullet_2 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			
			//check if bullets from monster_3 hits tank
			if(mons_3_bullet_alive[0])
			begin
				//hit tank
				if( (xpos_mons_3_bullet_0 <= xpos_tank+10) && (xpos_mons_3_bullet_0 >= xpos_tank-10) && (ypos_mons_3_bullet_0 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_3_bullet_alive[1])
			begin
				//hit tank
				if( (xpos_mons_3_bullet_1 <= xpos_tank+10) && (xpos_mons_3_bullet_1 >= xpos_tank-10) && (ypos_mons_3_bullet_1 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_3_bullet_alive[2])
			begin
				//hit tank
				if( (xpos_mons_3_bullet_2 <= xpos_tank+10) && (xpos_mons_3_bullet_2 >= xpos_tank-10) && (ypos_mons_3_bullet_2 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			
			//check if bullets from monster_3 hits tank
			if(mons_4_bullet_alive[0])
			begin
				//hit tank
				if( (xpos_mons_4_bullet_0 <= xpos_tank+10) && (xpos_mons_4_bullet_0 >= xpos_tank-10) && (ypos_mons_4_bullet_0 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_4_bullet_alive[1])
			begin
				//hit tank
				if( (xpos_mons_4_bullet_1 <= xpos_tank+10) && (xpos_mons_4_bullet_1 >= xpos_tank-10) && (ypos_mons_4_bullet_1 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			if(mons_4_bullet_alive[2])
			begin
				//hit tank
				if( (xpos_mons_4_bullet_2 <= xpos_tank+10) && (xpos_mons_4_bullet_2 >= xpos_tank-10) && (ypos_mons_4_bullet_2 == ypos_tank))
				begin
					tank_destroyed <= 1;
					score <= 0;
				end
			end
			
			// IF tank bullets reached top of screen (range from 32-33), reset bullet to available (=0)-----------------------------------------------------------------------------------------------
			if((ypos_tank_bullet_0>=32) && (ypos_tank_bullet_0<=33)) begin
				tank_bullet_alive[0] <= 1'b0;
				xpos_tank_bullet_0<=1000;
			end
		
			if((ypos_tank_bullet_1>=32) && (ypos_tank_bullet_1<=33)) begin
				tank_bullet_alive[1] <= 1'b0;
				xpos_tank_bullet_1<=1000;
			end
			
			if((ypos_tank_bullet_2>=32) && (ypos_tank_bullet_2<=33)) begin
				tank_bullet_alive[2] <= 1'b0;
				xpos_tank_bullet_2<=1000;
			end
		end
	end
	
	// ----------------------------------------------------------------------------------------Tank_Bullets-----------------------------------------------------------------------------------------
	// tank_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if((rst) || (level_in == 1))
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
		if((rst) || (level_in == 1))
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
		if((rst) || (level_in == 1))
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
		if((rst) || (level_in == 1))
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

			//check if destroyed
			if(monster_destroyed[0] == 1'b1)
			begin
				//move monster out of the screen (???)
				xpos_mons_0 <= 1000;
			end
		end
	end
	
	// monster_1 state block
	always@(posedge clk, posedge rst) 
	begin
		if((rst) || (level_in == 1))
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

			if(monster_destroyed[1] == 1'b1)
			begin
				//move monster out of the screen (???)
				xpos_mons_1 <= 1000;
			end
		end
	end
	
	// monster_2 state block
	always@(posedge clk, posedge rst) 
	begin
		if((rst) || (level_in == 1))
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

			//check if destroyed
			if(monster_destroyed[2] == 1'b1)
			begin
				//move monster out of the screen (???)
				xpos_mons_2 <= 1000;
			end
		end
	end
	
	// monster_3 state block
	always@(posedge clk, posedge rst) 
	begin
		if((rst) || (level_in == 1))
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

			//check if destroyed
			if(monster_destroyed[3] == 1'b1)
			begin
				//move monster out of the screen (???)
				xpos_mons_3 <= 1000;
			end
		end
	end
	
	// monster_4 state block
	always@(posedge clk, posedge rst) 
	begin
		if((rst) || (level_in == 1))
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

			//check if destroyed
			if(monster_destroyed[4] == 1'b1)
			begin
				//move monster out of the screen (???)
				xpos_mons_4 <= 1000;
			end
		end
	end
	// -------------------------------------------------------------------------------------Monster_Bullets-------------------------------------------------------------------------------------------
	// The frequency of the bullets is determined by the positions of previous bullets
	// monster_0_bullet_0 movement (over y axis only!)
	always@(posedge clk, posedge rst) 
	begin
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_0_bullet_0<=250;
			ypos_mons_0_bullet_0<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[0]) begin
				xpos_mons_0_bullet_0<=1000;
			end
			else if (mons_0_bullet_alive[0] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_0_bullet_1<=250;
			ypos_mons_0_bullet_1<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[0]) begin
				xpos_mons_0_bullet_1<=1000;
			end
			else if (mons_0_bullet_alive[1] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_0_bullet_2<=250;
			ypos_mons_0_bullet_2<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[0]) begin
				xpos_mons_0_bullet_2<=1000;
			end
			else if (mons_0_bullet_alive[2] == 1'b1) begin
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
		if((rst) || (level_in == 1)) 
		begin
			xpos_mons_1_bullet_0<=350;
			ypos_mons_1_bullet_0<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[1]) begin
				xpos_mons_1_bullet_0<=1000;
			end
			else if (mons_1_bullet_alive[0] == 1'b1) begin
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
		if((rst) || (level_in == 1)) 
		begin
			xpos_mons_1_bullet_1<=350;
			ypos_mons_1_bullet_1<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[1]) begin
				xpos_mons_1_bullet_1<=1000;
			end
			else if (mons_1_bullet_alive[1] == 1'b1) begin
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
		if((rst) || (level_in == 1)) 
		begin
			xpos_mons_1_bullet_2<=350;
			ypos_mons_1_bullet_2<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[1]) begin
				xpos_mons_1_bullet_2<=1000;
			end
			else if (mons_1_bullet_alive[2] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_2_bullet_0<=450;
			ypos_mons_2_bullet_0<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[2]) begin
				xpos_mons_2_bullet_0<=1000;
			end
			else if (mons_2_bullet_alive[0] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_2_bullet_1<=450;
			ypos_mons_2_bullet_1<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[2]) begin
				xpos_mons_2_bullet_1<=1000;
			end
			else if (mons_2_bullet_alive[1] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_2_bullet_2<=450;
			ypos_mons_2_bullet_2<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[2]) begin
				xpos_mons_2_bullet_2<=1000;
			end
			else if (mons_2_bullet_alive[2] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_3_bullet_0<=550;
			ypos_mons_3_bullet_0<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[3]) begin
				xpos_mons_3_bullet_0<=1000;
			end
			else if (mons_3_bullet_alive[0] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_3_bullet_1<=550;
			ypos_mons_3_bullet_1<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[3]) begin
				xpos_mons_3_bullet_1<=1000;
			end
			else if (mons_3_bullet_alive[1] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_3_bullet_2<=550;
			ypos_mons_3_bullet_2<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[3]) begin
				xpos_mons_3_bullet_2<=1000;
			end
			else if (mons_3_bullet_alive[2] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_4_bullet_0<=650;
			ypos_mons_4_bullet_0<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[4]) begin
				xpos_mons_4_bullet_0<=1000;
			end
			else if (mons_4_bullet_alive[0] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_4_bullet_1<=650;
			ypos_mons_4_bullet_1<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[4]) begin
				xpos_mons_4_bullet_1<=1000;
			end
			else if (mons_4_bullet_alive[1] == 1'b1) begin
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
		if((rst) || (level_in == 1))
		begin
			//rough values for center of screen
			xpos_mons_4_bullet_2<=650;
			ypos_mons_4_bullet_2<=100;
		end
		
		else if (clk) begin
			if (monster_destroyed[4]) begin
				xpos_mons_4_bullet_2<=1000;
			end
			else if (mons_4_bullet_alive[2] == 1'b1) begin
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