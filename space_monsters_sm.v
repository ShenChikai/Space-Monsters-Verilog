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
    output reg [11:0] rgb;
    output reg [11:0] background;
    output [7:0] score;

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

    block_controller(clk, bright, rst, left, right, up, hCount, vCount, rgb, background);

    debounce(rst, clk, down, clean_down, pulse_down);

    /*************** State Machine *************/
    always@(posedge clk, posedge rst)
    begin
        if(rst)
            begin
                state <= START;
            end
        else 
            case(state)
                START:
                    begin
                        score <= 0;
                        level_in <= 0;
                    end
                L1I:
                    begin
                        level_in <= 1;
                    end
                L1:
                    begin
                        if(win) state <= L2I;
                        else if(tank_destroyed) state <= FAILED;
                    end
                L2I:
                    begin
                        level_in <= 2;
                    end
                L2:
                    begin
                        if(win) state <= SUCCESS;
                        else if(tank_destroyed) state <= FAILED;
                    end
                SUCCESS:
                    begin
                        if(clean_down) state <= START;
                    end
                FAILED:
                    begin
                        if(clean_down) state <= START;
                    end

    end

endmodule