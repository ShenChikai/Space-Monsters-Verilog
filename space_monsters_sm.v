`timescale 1ns / 1ps


module space_monsters_sm(
    clk, bright, rst, left, right, up, Ack, hCount, vCount,
    rgb, background, score
);
    /** INPUTS  **/
    input clk, bright, rst;
    //buttons
    input left, right, up, Ack;
    //left and right to move the tank, up to shoot
    input [9:0] hCount, vCount;

    /** OUTPUTS  **/
    output reg [11:0] rgb;
    output reg [11:0] background;
    output [7:0] score;
    reg q_Start, q_L1I, q_L1, q_Success, q_Failed;
    reg [4:0] state;
    assign {q_Failed, q_Success, q_L1, q_L1I, q_Start} = state;

    //FIVE MONSTERS
    reg [4:0] monster_destroyed_flag;
    reg tank_destroyed_flag;

    localparam 
    START = 5'b00001, 
    L1I = 5'b00010, 
    L1 = 5'b00100, 
    SUCCESS = 5'b01000, 
    FAILED = 5'b10000;

    //tank seperated to 2 parts in drawing
    wire tank_body, tank_head;
    //monster simplified to blocks, FIVE MONSTERS
    wire monster_0, monster_1, monster_2, monster_3, monster_4;
    //TODO: Improve drawing

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

    //Color declaration
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
			rgb = 12'b0000_0000_0000;
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
		else
			rgb = background;
	end

    // draw tank
	assign tank_head =vCount>=(ypos_tank-5) && vCount< (ypos_tank) && hCount>=(xpos_tank-2) && hCount<=(xpos_tank+2);
	assign tank_body =vCount>=(ypos_tank) && vCount<=(ypos_tank+10) && hCount>=(xpos_tank-10) && hCount<=(xpos_tank+10);
	// draw monsters
    //FIVE MONSTERS
	assign monster_0 =vCount>=(ypos_mons_0 -3) && vCount<=(ypos_mons_0 +3) && hCount>=(xpos_mons_0 -5) && hCount<=(xpos_mons_0 +5);
	assign monster_1 =vCount>=(ypos_mons_1 -3) && vCount<=(ypos_mons_1 +3) && hCount>=(xpos_mons_1 -5) && hCount<=(xpos_mons_1 +5);
	assign monster_2 =vCount>=(ypos_mons_2 -3) && vCount<=(ypos_mons_2 +3) && hCount>=(xpos_mons_2 -5) && hCount<=(xpos_mons_2 +5);
	assign monster_3 =vCount>=(ypos_mons_3 -3) && vCount<=(ypos_mons_3 +3) && hCount>=(xpos_mons_3 -5) && hCount<=(xpos_mons_3 +5);
	assign monster_4 =vCount>=(ypos_mons_4 -3) && vCount<=(ypos_mons_4 +3) && hCount>=(xpos_mons_4 -5) && hCount<=(xpos_mons_4 +5);

    /*************** State Machine *************/
    always@(posedge clk, posedge rst)
    begin
        if(rst)
            begin
                state <= START;
                //FIVE MONSTERS
                monster_destroyed_flag <= 5'bXXXXX;
                tank_destroyed_flag <= 1'bX;
                xpos_tank<=10'bXXXXXXXXXX;
			    ypos_tank<=10'bXXXXXXXXXX;
                xpos_mons_0<=10'bXXXXXXXXXX;
			    ypos_mons_0<=10'bXXXXXXXXXX;
                xpos_mons_1<=10'bXXXXXXXXXX;
		        ypos_mons_1<=10'bXXXXXXXXXX;
                xpos_mons_2<=10'bXXXXXXXXXX;
		        ypos_mons_2<=10'bXXXXXXXXXX;
                xpos_mons_3<=10'bXXXXXXXXXX;
			    ypos_mons_3<=10'bXXXXXXXXXX;
                xpos_mons_4<=10'bXXXXXXXXXX;
		        ypos_mons_4<=10'bXXXXXXXXXX;

            end
        else 
            case(state)
                START:
                    score <= 0;
                    //FIVE MONSTERS
                    monster_destroyed_flag <= 5'b00000;
                    tank_destroyed_flag <= 1'b0;
                    //Tank Position
                    xpos_tank<=450;
			        ypos_tank<=450;
                    state <= L1I;
                L1I:
                    //Set shooting frequency, monster number and position
                    //Hardcoded monsters position
                    xpos_mons_0<=250;
			        ypos_mons_0<=100;
                    xpos_mons_1<=350;
			        ypos_mons_1<=100;
                    xpos_mons_2<=450;
			        ypos_mons_2<=100;
                    xpos_mons_3<=550;
			        ypos_mons_3<=100;
                    xpos_mons_4<=650;
			        ypos_mons_4<=100;
                L1:
                SUCCESS:
                FAILED:

    end

    always@(posedge clk, posedge rst) begin
		if(rst)
			background <= PURPLE;

	end

endmodule