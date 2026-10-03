// =============================================================================
// sc_control.sv
// Unidade de Controle Principal - RISC-V de ciclo único (Seção 4.4 - Patterson & Hennessy)
//
// Decodifica o opcode de 7 bits e ativa os sinais de controle para o caminho de dados.
//
// Instruções suportadas:
//   Tipo R  (0110011): add, sub, and, or, slt
//   Tipo I  (0000011): lw
//   Tipo S  (0100011): sw
//   Tipo B  (1100011): beq
//
// Resumo dos sinais de controle:
//
//   Sinal     | Tipo R | lw | sw | beq
//   ----------|--------|----|----|-----
//   ALUSrc    |   0    |  1 |  1 |  0    0=reg, 1=imed
//   MemtoReg  |   0    |  1 |  - |  -    0=ALU, 1=mem
//   RegWrite  |   1    |  1 |  0 |  0
//   MemRead   |   0    |  1 |  0 |  0
//   MemWrite  |   0    |  0 |  1 |  0
//   Branch    |   0    |  0 |  0 |  1
//   ALUOp[1]  |   1    |  0 |  0 |  0
//   ALUOp[0]  |   0    |  0 |  0 |  1
//
//   Codificação do ALUOp:
//     2'b00 = Load/Store (força SOMA)
//     2'b01 = Desvio     (força SUB)
//     2'b10 = Tipo R     (O Controle da ULA decodifica Funct3/Funct7)
//
// Exercício:
//   Implemente o bloco always_comb abaixo.
//   Use as constantes de opcode e a tabela de sinais de controle acima como referência.
//   Valide sua implementação executando o sc_cpu_tb contra o golden.txt.
// =============================================================================

`timescale 1ns / 1ps

module sc_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic [1:0] ALUOp
);

    localparam R_TYPE = 7'b0110011; // add, sub, and, or, slt
    localparam LOAD   = 7'b0000011; // lw
    localparam STORE  = 7'b0100011; // sw
    localparam BRANCH = 7'b1100011; // beq

    always_comb begin
        // Define valores padrão seguros para todos os sinais antes da instrução case.
        // Isso evita latches e garante que opcodes não reconhecidos não gerem
        // efeitos colaterais (sem escrita na memória, sem escrita em registradores).
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            R_TYPE: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b10;
            end

            LOAD: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            STORE: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            BRANCH: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end

            default: ; // os sinais permanecem nos valores padrão seguros
        endcase
    end

endmodule
