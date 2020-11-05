module pulse(rst, clk, press, pulse);
    input rst, clk;
    input press;
    output reg pulse;

    reg flag;

    always@(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            pulse <= 1'b0;
            flag <= 1'b0;
        end
        else
        begin
            if(press)
            begin
                if(~flag)
                begin
                    pulse <= 1'b1;
                    flag <= 1'b1;
                end
            end
            else
                flag <= 1'b0;
        end
    end
endmodule