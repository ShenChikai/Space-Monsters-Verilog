`timescale 1ns / 1ps

module space_monsters_sm(
    clk, bright, rst, left, right, up, down, hCount, vCount,
    rgb, background, score
);
    /** INPUTS  **/
    input clk, bright, rst;
    //buttons
    input left, right, up, down;
    //left and right to move the tank, up to shoot
    input [9:0] hCount, vCount;

    /** OUTPUTS  **/
    output wire [11:0] rgb;
    output wire [11:0] background;
    output reg [2:0] score;

	wire [4:0] monster_destroyed;
    wire [11:0] rgb_out;
    wire [11:0] background_out;
    wire [2:0] score_out;

    reg [6:0] state;

    reg [2:0] level_in;

    localparam 
    START   = 7'b0000001, 
    L1I     = 7'b0000010, 
    L1      = 7'b0000100, 
    L2I     = 7'b0001000,
    L2      = 7'b0010000,
    SUCCESS = 5'b0100000, 
    FAILED  = 7'b1000000;

    block_controller(clk, bright, rst, left, right, up, hCount, vCount, level_in, rgb_out, background_out, monster_destroyed, tank_destroyed, score_out);

    debounce DEB_D(rst, clk, down, clean_down, pulse_down);

    assign rgb = rgb_out;
    assign background = background_out;

    /*************** State Machine *************/
    always@(posedge clk, posedge rst)
    begin
        if(rst)
            begin
                state <= START;
				level_in <= 0;
            end
        else 
        begin
            case(state)
                START:
                    begin
                        score <= 0;
                        state <= L1I;
						level_in <= 0;
                    end
                L1I:
                    begin
                        state <= L1;
                    end
                L1:
                    begin
                        score <= score_out;
                        if((monster_destroyed[0] == 1) && (monster_destroyed[2] == 1) && (monster_destroyed[4] == 1))state <= L2I;
                        else if(tank_destroyed) state <= FAILED;
                    end
                L2I:
                    begin
                        level_in <= 1;
                        state <= L2;
                    end
                L2:
                    begin
                        score <= score_out;
						level_in <= 0;
                        if(monster_destroyed == 5'b11111) state <= SUCCESS;
                        else if(tank_destroyed) state <= FAILED;
                    end
                SUCCESS:
                    begin
                        score <= score_out;
                        if(clean_down) state <= START;
                    end
                FAILED:
                    begin
                        score <= score_out;
                        if(clean_down) state <= START;
                    end
            endcase
        end

    end

endmodule