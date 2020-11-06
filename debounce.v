module debounce(rst, clk, btn_press, clean, single);
    input rst, clk;
    input btn_press;
    output clean, single;

    parameter N_dc = 5;

    (* fsm_encoding = "user" *)
    reg [3:0] state;
    reg [N_dc-1:0] debounce_count;

    assign {clean, single} = state[3:2];

    localparam
        INI     = 4'b0000,
        WQ      = 4'b0001,
        SCEN_st = 4'b1100,
        CCR     = 4'b1000,
        WFCR    = 4'b1001;
    
    always@(posedge clk, posedge rst)
    begin : Debounce_State_Machine
        if(rst)
            begin
                state <= INI;
                debounce_count <= 'bx;
            end
        else
            begin
                case(state)
                    INI:
                    begin
                        debounce_count <= 0;
                        if(btn_press) state <= WQ;
                    end
                    WQ:
                    begin
                        debounce_count <= debounce_count + 1;
                        if(!btn_press) state <= INI;
                        else if(debounce_count[N_dc-2]) //0.084sec
                        begin
                            state <= SCEN_st;
                        end
                    end 
                    SCEN_st:
                    begin
                        debounce_count <= 0;
                        state <= CCR;
                    end
                    CCR:
                    begin
                        debounce_count <= 0;
                        if(!btn_press) state <= WFCR;
                    end
                    WFCR:
                    begin
                        debounce_count <= debounce_count +1;
                        if(btn_press) state <= CCR;
                        else if(debounce_count[N_dc-2]) state <= INI;
                    end
                endcase
            end
    end

endmodule