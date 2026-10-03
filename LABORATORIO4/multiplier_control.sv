// multiplier_control.sv
// FSM de controle da versao refinada do multiplicador
//
// Fluxograma da versao refinada (uma iteracao por ciclo):
//
//   1. Testar Product[0] (LSB do registrador product, equivale ao Multiplier0)
//   2. Se Product[0] == 1 → Product[63:32] = Product[63:32] + Multiplicand
//      (passos 1 e 2 combinados com o shift no mesmo ciclo)
//   3. Shift Product a direita 1 bit (carry do passo 2 vai para Product[63])
//   4. 32a. repeticao? → Sim: Fim | Nao: voltar ao passo 1
//
// Diferenças em relacao a versao original:
//   - Estados ADD_OR_SKIP e SHIFT fundidos em COMPUTE (add + shift em 1 ciclo)
//   - multiplier_lsb nao e mais exposto pela FSM (testado internamente no datapath)
//   - product_wr e shift_en substituidos por compute_en
//   - Total: ~34 ciclos (1 LOAD + 32 COMPUTE + 1 DONE)
//     vs. ~66 ciclos da versao original (1 LOAD + 32×2 + 1 DONE)
//
// Estados:
//   IDLE    — aguarda sinal 'start'
//   LOAD    — carrega operandos no datapath (1 ciclo)
//   COMPUTE — executa uma iteracao add+shift; repete 32 vezes (count 0..31)
//   DONE    — sinaliza conclusao; retorna a IDLE quando 'start' é resetado

module multiplier_control (
    input  logic clk,
    input  logic rst_n,

    // Interface com o usuário
    input  logic start,
    output logic done,

    // Interface com o datapath
    output logic load,        // Carrega operandos iniciais (1 ciclo)
    output logic compute_en   // Executa 1 iteração add+shift por ciclo
);

    typedef enum logic [3:0] {
        IDLE = 4'b0001,
        LOAD = 4'b0010,
        COMPUTE = 4'b0100,
        DONE = 4'b1000
    } state_t;

    state_t state, next_state;
    logic [5:0] count; // Contador de 0 a 31

    // -----------------------------------------------------------------------
    // Atualização de estado e contador de iterações
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            count <= '0;
        end else begin
            state <= next_state;

            if (state == LOAD) begin
                count <= '0; // Zera o contador na carga inicial
            end else if (state == COMPUTE) begin
                count <= count + 1'b1; // Incrementa a cada iteração
            end
        end
    end

    // -----------------------------------------------------------------------
    // Lógica do próximo estado
    // -----------------------------------------------------------------------
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = LOAD;
            end

            LOAD: begin
                // Executa 1 ciclo de carga e vai direto para COMPUTE
                next_state = COMPUTE;
            end

            COMPUTE: begin
                // Permanece em COMPUTE por 32 ciclos (0 a 31)
                if (count == 31)
                    next_state = DONE;
                else
                    next_state = COMPUTE;
            end

            DONE: begin
                if (!start)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // -----------------------------------------------------------------------
    // Sinais de saída
    // -----------------------------------------------------------------------
    assign load       = (state == LOAD);    // Ativo apenas durante 1 ciclo
    assign compute_en = (state == COMPUTE); // Ativo durante as 32 iterações
    assign done       = (state == DONE);    // Ativo no final da operação

endmodule
