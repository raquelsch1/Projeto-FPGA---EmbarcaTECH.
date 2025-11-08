// estacionamento_top.sv 
// Recebe 3 sinais digitais (vagas) e atualiza o display

module estacionamento_top(
    input  wire        clk,           
    input  wire        vaga1_in,      
    input  wire        vaga2_in,      
    input  wire        vaga3_in,      
    output reg  [6:0]  seg1
);

    // sincronização + debounce
    reg vaga1_sync;
    reg [2:0] vaga1_db;

    reg vaga2_sync;
    reg [2:0] vaga2_db;

    reg vaga3_sync;
    reg [2:0] vaga3_db;

    wire vaga1_estavel = &vaga1_db; // 1 se os 3 últimos envios forem 1
    wire vaga2_estavel = &vaga2_db;
    wire vaga3_estavel = &vaga3_db;

    reg [1:0] vagas_livres;

    reg [6:0] segbits;

    // sincronização e atualização do diplay 
    always @(posedge clk) begin
        vaga1_sync <= vaga1_in;
        vaga1_db <= {vaga1_db[1:0], vaga1_sync};

        vaga2_sync <= vaga2_in;
        vaga2_db <= {vaga2_db[1:0], vaga2_sync};

        vaga3_sync <= vaga3_in;
        vaga3_db <= {vaga3_db[1:0], vaga3_sync};

        // calcular vagas livres: 3 - ocupadas
        vagas_livres <= 3 - ( {2'b00, vaga1_estavel} + {2'b00, vaga2_estavel} + {2'b00, vaga3_estavel} );

        seg1 <= segbits;
    end

    // atualização do display
    always @(*) begin
        case (vagas_livres)
            2'd0: segbits = 7'b1111110; // '0'
            2'd1: segbits = 7'b0110000; // '1'
            2'd2: segbits = 7'b1101101; // '2'
            2'd3: segbits = 7'b1111001; // '3'
            default: segbits = 7'b0000000; // apagado
        endcase
    end

endmodule
