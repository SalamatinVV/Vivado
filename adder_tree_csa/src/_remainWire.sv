module _remainWire ();
function automatic logic [31 : 0] RM (input logic [31: 0] x_stage ) ;
    localparam NUMBER_OF_STAGES = StageCount(I_DATA_N) ;
    logic [0 : NUMBER_OF_STAGES - 1][0 : 1][O_DATA_W - 1 : 0] remWire_func = '0 ; 
    for (int stage = 0; stage <= NUMBER_OF_STAGES; stage++) begin
        if (stage == 0) begin
                if(I_DATA_N % 3 == 0) begin
                    remWire_func[stage][0] = '0;
                    remWire_func[stage][1] = '0;
                end else if(I_DATA_N % 3 == 1) begin
                    remWire_func[stage][0] = '1;
                    remWire_func[stage][1] = '0;
                end else begin
                    remWire_func[stage][0] = '1;
                    remWire_func[stage][1] = '1;
                end   
        end else if(stage == 1) begin
            localparam CSA_CURR = CsaCount (stage - 1)        ;
            localparam CSA_NEXT = CsaCount (stage    )        ;
            localparam diff     = CSA_CURR * 2 - CSA_NEXT * 3 ;
                if (diff == 0) begin
                    remWire_func[stage][0] = '0;
                    remWire_func[stage][1] = '0;
                end else if(diff == 1) begin
                    remWire_func[stage][0] = '1; 
                    remWire_func[stage][1] = '0;
                end else if (diff == 2) begin
                    remWire_func[stage][0] = '1;
                    remWire_func[stage][1] = '1;
                end
        end else begin
            localparam CSA_CURR = CsaCount (stage - 1)        ;
            localparam CSA_NEXT = CsaCount (stage    )        ;
            localparam CSA_BEF  = CsaCount (stage - 2)        ;
            localparam diff     = CSA_CURR * 2 - CSA_NEXT * 3 ;
            localparam diff_bef = CSA_CURR * 3 - CSA_BEF * 2  ;

                if (diff_bef == 1) begin
                    for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                        for (int k = 0; k < 2; k++) begin
                            if (remWire_func[j][k] != 0) begin
                                remWire_func[j][k] = '0;
                                if (x_stage == stage) begin
                                    return m = j;
                                    return k = n;
                                end
                            end
                        end
                    end
                end else if (diff_bef == 2) begin
                    for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                        for (int k = 0; k < 2; k++) begin
                            if (remWire_func[j][k] != 0) begin
                                remWire_func[j][k] = '0;
                                if (x_stage == stage) begin
                                    return m = j;
                                    return k = n;
                                end
                            end
                        end
                    end
                    for (int j = 0; j < NUMBER_OF_STAGES; j++) begin
                        for (int k = 0; k < 2; k++) begin
                            if (remWire_func[j][k] != 0) begin
                                remWire_func[j][k] = '0;
                                if (x_stage == stage) begin
                                    return f = j;
                                    return g = n;
                                end
                            end
                        end
                    end
                end

            if (diff = 0) begin
                remWire_func[stage][0] = '0;
                remWire_func[stage][1] = '0;
            end else if(diff == 1) begin
                remWire_func[stage][0] = '1; 
                remWire_func[stage][1] = '0;
            end else if (diff == 2) begin
                remWire_func[stage][0] = '1;
                remWire_func[stage][1] = '1;
            end
        end
    end
endfunction
endmodule