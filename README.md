# SISTEMA DE MONITORAMENTO DE VAGAS E CONTROLE DE ACESSO EM ESTACIONAMENTO COM FPGA E RASPBERRY PI PICO W.

Este projeto apresenta um **protótipo de sistema embarcado** para controle de acesso e monitoramento de vagas em um estacionamento.  
O sistema foi desenvolvido como parte do **Projeto Integrador do curso de Sistemas de Informação – IFMA**, combinando o uso de uma **Raspberry Pi Pico** e uma **FPGA Colorlight i9** para explorar o processamento **sequencial e paralelo** em aplicações embarcadas.

---

## Funcionalidades

- Leitura de **três sensores ultrassônicos** para detectar a presença de veículos.  
- Cálculo e envio do status das vagas (livre/ocupada) da **Raspberry Pi Pico** para a **FPGA** via GPIO.  
- Controle de **barreira de acesso automático** com servomotor e **sensores infravermelhos**.  
- Exibição do **número de vagas disponíveis** em **display de 7 segmentos**.  
- Operação **autônoma e local**, sem necessidade de conexão externa.

---

## Arquitetura

A comunicação entre as plataformas ocorre por **nível lógico direto (3,3V)**, sem uso de protocolos seriais.  
A divisão de responsabilidades foi feita da seguinte forma:


**Raspberry Pi Pico** - Leitura dos sensores ultrassônicos e envio de sinais de ocupação 
**FPGA Colorlight i9** - Controle da barreira de acesso, contagem das vagas e exibição nos displays

---

## Tecnologias e Ferramentas

- **Linguagens:** C e SystemVerilog  
- **IDE / Ferramentas:** Visual Studio Code, OSS CAD Suite, Lattice Diamond  
- **Bibliotecas:** `hardware/gpio.h`, `hardware/timer.h`, `stdio.h`, `stdlib.h`  
- **Componentes:** Raspberry Pi Pico, FPGA Colorlight i9, sensores HC-SR04, servomotor, displays de 7 segmentos, sensores IR, push-buttons

