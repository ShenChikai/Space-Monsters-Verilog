`timescale 1ns / 1ps

module tank(clk, rst, left, right, up, xpos_tank, ypos_tank);
/******INPUTS******/
input clk, rst;
input left, right, up;

/******OUTPUTS******/
output reg [9:0] xpos_tank, ypos_tank;

always@(posedge clk, posedge rst)
begin
    if(rst)
    begin
        xpos_tank <= 450;
        ypos_tank <= 450;
    end
    else
        if(left)
        begin
            xpos_tank <= (xpos_tank > 150) ? (xpos_tank-1) : xpos_tank;
        end
        else if(right)
        begin
            xpos_tank <= (xpos_tank < 800) ? (xpos_tank+1) : xpos_tank;
        end
end
