module debounce(rst, clk, btn_press, clean_press);
    input rst, clk;
    input btn_press;
    output reg clean_press;

    reg [19:0] debounce_count;
    reg temp;
    wire [19:0] delay;
    assign delay = 20'd1000000;

    always@(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            debounce_count <= 20'b0;
            temp <= 1'b0;
            clean_press <= 1'b0;
        end
        else
        begin
            if(btn_press)
            begin
                if(debounce_count == delay)
                    clean_press <= temp;
                else
                begin
                    debounce_count <= debounce_count + 1'b1;
                    temp <= btn_press;
                end
            end
            else
            begin
                debounce_count <= 20'b0;
                clean_press <= 1'b0;
            end
        end
    end

endmodule