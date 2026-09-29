module lock_controller
#(
    parameter WIDTH = 4
)
(
    input clk, rst,
    
    input [WIDTH-1:0] digit_in,
    
    output reg unlocked_led

);

    localparam [WIDTH-1:0] CODE0 = 4'd5;
    localparam [WIDTH-1:0] CODE1 = 4'd3;
    localparam [WIDTH-1:0] CODE2 = 4'd7;

    localparam [1:0] LOCKED   = 2'd0;
    localparam [1:0] WAIT_D2  = 2'd1;
    localparam [1:0] WAIT_D3  = 2'd2;
    localparam [1:0] UNLOCKED = 2'd3;

    reg [1:0] state, next_state;

    always @(posedge clk or posedge rst) 
        if (rst)
            state <= LOCKED;
        else
            state <= next_state;
    
    always @(*) begin
        next_state = state;  
        case (state)
            LOCKED   :  if   (digit_in == CODE0)  next_state = WAIT_D2;
                        else                      next_state = LOCKED;
            WAIT_D2  :  if   (digit_in == CODE1)  next_state = WAIT_D3;
                        else                      next_state = LOCKED;
            WAIT_D3  :  if   (digit_in == CODE2)  next_state = UNLOCKED;
                        else                      next_state = LOCKED;
            UNLOCKED :                            next_state = UNLOCKED;
            default  :                            next_state = LOCKED;
        endcase
    end    
    
    
    always @(posedge clk or posedge rst) 
        if (rst)
            unlocked_led <= 0;
        else if(state == UNLOCKED)
            unlocked_led <= 1'b1;

    
    
endmodule