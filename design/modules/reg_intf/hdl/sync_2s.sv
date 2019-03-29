module sync_2s (
    input   clk,
    input   d,
    output  q
);

logic clk;
logic d;
logic q1;
logic q2;
logic q;

always@(posedge clk)
begin
    q1 <= #1 d;
end

always@(posedge clk)
begin
    q2 <= #1 q1;
end

assign q = q2;


endmodule
