module portao_top (
    input  wire        clk,        
    input  wire        I1,         // Botão 1
    input  wire        I2,         // Botão 2 
    input  wire        S1,         // Sensor IR 1
    input  wire        S2,         // Sensor IR 2 
    output logic       SERVO1,     // Servo 1
    output logic       SERVO2      // Servo 2 
);
    // Parâmetros de configurações
    localparam int F_CLK         = 25_000_000;
    localparam int PERIODO_MAX   = F_CLK / 50;  
    localparam int PERIODO_W     = 19;       

    localparam int PULSO_0_GRAUS   = 25_000;    
    localparam int PULSO_180_GRAUS = 50_000;    
    localparam int PULSO_W         = 16;        

    // Posições dos servos
    logic [PULSO_W-1:0] pulso_ciclos_s1 = PULSO_0_GRAUS; 
    logic [PULSO_W-1:0] pulso_ciclos_s2 = PULSO_0_GRAUS; 

    function int DB_CYCLES_5MS(); DB_CYCLES_5MS = F_CLK/200; endfunction 
    localparam int DB_MAX = DB_CYCLES_5MS();
    localparam int DB_W   = $clog2(DB_MAX); 

    // Lógica de Debounce e Sincronização de Entradas ---
    
    logic [1:0] sync_i1 = '0; 
    logic [DB_W-1:0] cnt_i1 = '0; 
    logic q_i1 = 1'b0; 
    logic q_d_i1 = 1'b0; 

    logic [1:0] sync_i2 = '0; 
    logic [DB_W-1:0] cnt_i2 = '0; 
    logic q_i2 = 1'b0; 
    logic q_d_i2 = 1'b0; 

    always_ff @(posedge clk) begin
        sync_i1 <= {sync_i1[0], I1};
        if (sync_i1[1] == q_i1)
            cnt_i1 <= '0;
        else if (cnt_i1 == DB_MAX-1) begin
            cnt_i1 <= '0;
            q_i1 <= sync_i1[1];
        end else
            cnt_i1 <= cnt_i1 + 1;
        q_d_i1 <= q_i1;

        sync_i2 <= {sync_i2[0], I2};
        if (sync_i2[1] == q_i2)
            cnt_i2 <= '0;
        else if (cnt_i2 == DB_MAX-1) begin
            cnt_i2 <= '0;
            q_i2 <= sync_i2[1];
        end else
            cnt_i2 <= cnt_i2 + 1;
        q_d_i2 <= q_i2;
    end

    wire press_event_s1 = q_i1 & ~q_d_i1; 
    wire press_event_s2 = q_i2 & ~q_d_i2; 

    logic [1:0] sync_s1 = '0;
    logic [1:0] sync_s2 = '0;

    always_ff @(posedge clk) begin
        sync_s1 <= {sync_s1[0], S1}; 
        sync_s2 <= {sync_s2[0], S2};
    end
    
    wire sensor_presence_s1 = ~sync_s1[1]; // HIGH = presença
    wire sensor_presence_s2 = ~sync_s2[1]; // HIGH = presença 

    // Máquina de Estados e Lógica de Controle dos Servos ---

    typedef enum logic [0:0] {
        FECHADO = 1'b0, 
        ABERTO  = 1'b1  
    } servo_state_t;

    servo_state_t servo_state_s1 = FECHADO;
    servo_state_t servo_state_s2 = FECHADO; 

    // FSM
    always_ff @(posedge clk) begin
        if (press_event_s1) begin 
            if (servo_state_s1 == FECHADO) begin
                servo_state_s1 <= ABERTO;
            end else begin
                if (~sensor_presence_s1) begin
                    servo_state_s1 <= FECHADO;
                end
            end
        end 
        else if (servo_state_s1 == ABERTO && ~sensor_presence_s1) begin
            servo_state_s1 <= FECHADO;
        end
    end

    always_ff @(posedge clk) begin
        if (press_event_s2) begin 
            if (servo_state_s2 == FECHADO) begin
                servo_state_s2 <= ABERTO;
            end else begin
                if (~sensor_presence_s2) begin
                    servo_state_s2 <= FECHADO;
                end
            end
        end 
        else if (servo_state_s2 == ABERTO && ~sensor_presence_s2) begin
            servo_state_s2 <= FECHADO;
        end
    end

    // Posição do servo
    always_ff @(posedge clk) begin
        pulso_ciclos_s1 <= (servo_state_s1 == ABERTO) ? PULSO_180_GRAUS : PULSO_0_GRAUS;
        pulso_ciclos_s2 <= (servo_state_s2 == ABERTO) ? PULSO_180_GRAUS : PULSO_0_GRAUS;
    end


    // Geração de PWM para o servo
    logic [PERIODO_W-1:0] periodo_cnt = '0;
    always_ff @(posedge clk) begin
        if (periodo_cnt == PERIODO_MAX - 1)
            periodo_cnt <= '0;
        else
            periodo_cnt <= periodo_cnt + 1;
    end

    always_comb begin
        SERVO1 = (periodo_cnt < pulso_ciclos_s1);
        
        SERVO2 = (periodo_cnt < pulso_ciclos_s2);
    end

endmodule