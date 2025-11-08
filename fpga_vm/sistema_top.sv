// system_top.sv instancia estacionamento_top + portao_top

module sistema_top (
    input  wire        clk,           // 25 MHz
    // IO do estacionamento_top ---
    input  wire        vaga1_in,
    input  wire        vaga2_in,
    input  wire        vaga3_in,
    output wire [6:0]  seg1,
    // IO do portao_top ---
    input  wire        I1,
    input  wire        I2,
    input  wire        S1,
    input  wire        S2,
    output wire        SERVO1,
    output wire        SERVO2
);

    // instancia do monitor de vagas (estacionamento_top)
    estacionamento_top u_estacionamento (
        .clk       (clk),
        .vaga1_in  (vaga1_in),
        .vaga2_in  (vaga2_in),
        .vaga3_in  (vaga3_in),
        .seg1      (seg1)
    );

    // instancia do controlador da barreira de acesso (portao_top)
    portao_top u_portao (
        .clk    (clk),
        .I1     (I1),
        .I2     (I2),
        .S1     (S1),
        .S2     (S2),
        .SERVO1 (SERVO1),
        .SERVO2 (SERVO2)
    );

endmodule
