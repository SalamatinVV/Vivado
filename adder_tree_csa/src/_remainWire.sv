function automatic logic [31 : 0] _remainWire (input logic [31 : 0] x)

    if (x % 3 == 0) begin
        _remainWire = 0                                                 ;
    end else begin
        if ((x - 1) % 3 == 0) begin 
            _remainWire = 2                                             ;       // 4, 7, 10, 13 ...
        end else begin
            _remainWire = 1                                             ;       // 2, 5, 8, 11 ...
        end
    end
    return _remainWire;
endfunction

