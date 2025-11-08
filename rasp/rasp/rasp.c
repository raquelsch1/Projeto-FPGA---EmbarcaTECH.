// rasp.c - Pico: leituras de 3 sensores ultrassônicos e saída para FPGA
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/timer.h"

#define TRIG_VAGA1_PIN 16   
#define ECHO_VAGA1_PIN 17   

#define TRIG_VAGA2_PIN 18   
#define ECHO_VAGA2_PIN 19   

#define TRIG_VAGA3_PIN 8    
#define ECHO_VAGA3_PIN 9    

// Pinos de saída para FPGA (status das vagas)
#define OUT_VAGA1 28  
#define OUT_VAGA2 20  
#define OUT_VAGA3 4 

#define DISTANCIA_LIMITE 15.0f   // cm -> limite para considerar "ocupada"
#define TIMEOUT_US 30000         // timeout para leitura do echo 
#define POLL_DELAY_MS 2000        // intervalo entre leituras 

static uint8_t ultima_leitura = 0;

// inicializa trigger/echo dos ultrassônicos
void setup_ultrasonic(uint trig_pin, uint echo_pin) {
    gpio_init(trig_pin);
    gpio_set_dir(trig_pin, GPIO_OUT);
    gpio_put(trig_pin, 0); 

    gpio_init(echo_pin);
    gpio_set_dir(echo_pin, GPIO_IN);
}

// função que mede distância com saída em cm
float distancia_valor(uint trig_pin, uint echo_pin) {
    gpio_put(trig_pin, 1);
    sleep_us(10);
    gpio_put(trig_pin, 0);

    absolute_time_t start_wait = get_absolute_time();
    while (gpio_get(echo_pin) == 0) {
        if (absolute_time_diff_us(start_wait, get_absolute_time()) > TIMEOUT_US) {
            return 400.0f;
        }
    }
    absolute_time_t start_time = get_absolute_time();

    while (gpio_get(echo_pin) == 1) {
        if (absolute_time_diff_us(start_time, get_absolute_time()) > TIMEOUT_US) {
            return 400.0f;
        }
    }
    absolute_time_t end_time = get_absolute_time();

    int64_t pulse_duration = absolute_time_diff_us(start_time, end_time); 
    float distance = (pulse_duration * 0.0343f) / 2.0f;
    if (distance < 2.0f || distance > 400.0f) return 400.0f;
    return distance;
}

int main() {
    stdio_init_all(); 
    sleep_ms(100);

    // configura sensores
    setup_ultrasonic(TRIG_VAGA1_PIN, ECHO_VAGA1_PIN);
    setup_ultrasonic(TRIG_VAGA2_PIN, ECHO_VAGA2_PIN);
    setup_ultrasonic(TRIG_VAGA3_PIN, ECHO_VAGA3_PIN);

    // configura saídas para FPGA
    gpio_init(OUT_VAGA1); gpio_set_dir(OUT_VAGA1, GPIO_OUT); gpio_put(OUT_VAGA1, 0);
    gpio_init(OUT_VAGA2); gpio_set_dir(OUT_VAGA2, GPIO_OUT); gpio_put(OUT_VAGA2, 0);
    gpio_init(OUT_VAGA3); gpio_set_dir(OUT_VAGA3, GPIO_OUT); gpio_put(OUT_VAGA3, 0);

    printf("Iniciando leituras ultrassonicas...\n");

    while (true) {
        // medir distancias
        float d1 = distancia_valor(TRIG_VAGA1_PIN, ECHO_VAGA1_PIN);
        float d2 = distancia_valor(TRIG_VAGA2_PIN, ECHO_VAGA2_PIN);
        float d3 = distancia_valor(TRIG_VAGA3_PIN, ECHO_VAGA3_PIN);

        // decidir ocupacao (1 = ocupado, 0 = livre)
        int v1 = (d1 < DISTANCIA_LIMITE) ? 1 : 0;
        int v2 = (d2 < DISTANCIA_LIMITE) ? 1 : 0;
        int v3 = (d3 < DISTANCIA_LIMITE) ? 1 : 0;

        // montar status (opcional)
        uint8_t status = (v3 << 2) | (v2 << 1) | v1;

        // enviar para FPGA (saidas atualizadas sempre)
        gpio_put(OUT_VAGA1, v1);
        gpio_put(OUT_VAGA2, v2);
        gpio_put(OUT_VAGA3, v3);

        printf("Status 0x%02X | V1=%s %.1fcm | V2=%s %.1fcm | V3=%s %.1fcm\n",
            status,
            v1? "OCUP": "LIVRE", d1,
            v2? "OCUP": "LIVRE", d2,
            v3? "OCUP": "LIVRE", d3
        );

        ultima_leitura = status;

        sleep_ms(POLL_DELAY_MS);
    }

    return 0;
}
