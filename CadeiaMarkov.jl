using Random
using Printf

# ======== Função de Simulação Markov ========
function simular_markov(estados::Vector{String}, transicoes::Matrix{Float64},
                        estado_inicial::Int, n_passos::Int)
    estado_atual = estado_inicial
    historico = [estado_atual]

    for _ in 1:n_passos
        probabilidades = transicoes[estado_atual, :]
        acumuladas = cumsum(probabilidades)
        r = rand()
        proximo_estado = findfirst(x -> r <= x, acumuladas)
        push!(historico, proximo_estado)
        estado_atual = proximo_estado
    end

    return historico
end

# ======== Função para Exibir Matriz ========
function mostrar_matriz(estados, transicoes)
    println("\nMatriz de Transição de Probabilidades:")
    for i in 1:length(estados)
        linha = transicoes[i, :]
        soma = sum(linha)
        if abs(soma - 1.0) > 1e-6
            println("Aviso: A soma das probabilidades na linha $(i) ('$(estados[i])') é $(@sprintf("%.4f", soma)) (esperado ≈ 1.0)")
        end
        linha_formatada = join(map(x -> @sprintf("%.2f", x), linha), "  ")
        println("De $(estados[i]): $linha_formatada")
    end
end

# ======== Inicializar com Matriz de Saúde ========
function matriz_saude_padrao()
    estados = ["Saudável", "Doente", "Recuperado", "Falecido"]
    transicoes = [
        0.7  0.2  0.1  0.0;
        0.1  0.6  0.2  0.1;
        0.8  0.1  0.1  0.0;
        0.0  0.0  0.0  1.0
    ]
    return estados, transicoes
end

# ======== Função Principal ========
function main()
    estados, transicoes = matriz_saude_padrao()

    while true
        println("\n=== MENU PRINCIPAL ===")
        println("[1] Simular matriz atual")
        println("[2] Ver matriz atual")
        println("[3] Adicionar novo estado")
        println("[4] Remover estado")
        println("[5] Criar nova matriz")
        println("[6] Encerrar")
        print("Escolha uma opção: ")
        opcao = readline()

        if opcao == "1"
            println("\nEstados disponíveis:")
            for (i, estado) in enumerate(estados)
                println("[$i] $estado")
            end
            print("Escolha o estado inicial (número): ")
            estado_inicial = parse(Int, readline())
            if estado_inicial < 1 || estado_inicial > length(estados)
                println("Estado inicial inválido!")
                continue
            end
            print("Número de passos da simulação: ")
            n_passos = parse(Int, readline())
            historico_indices = simular_markov(estados, transicoes, estado_inicial, n_passos)
            historico_estados = [estados[i] for i in historico_indices]
        
            println("\nHistórico de índices: ", historico_indices)
        
            println("\nResultado detalhado da simulação:")
            println("Estado inicial: $(historico_estados[1])")
            for i in 2:length(historico_estados)
                estado = historico_estados[i]
                estado_anterior = historico_estados[i - 1]
                dia = i - 1
                if estado == estado_anterior
                    println("Dia $dia: $estado (sem mudança)")
                else
                    println("Dia $dia: $estado (mudou de $estado_anterior para $estado)")
                end
            end

        elseif opcao == "2"
            mostrar_matriz(estados, transicoes)

        elseif opcao == "3"
            print("Nome do novo estado: ")
            novo_estado = readline()
            push!(estados, novo_estado)
        
            n = size(transicoes, 1) 
        
            transicoes_nova = zeros(Float64, n+1, n+1)
        
            println("\n=== Redefinindo TODAS as linhas da matriz ===")
            for i in 1:(n+1)
                println("\nDigite as probabilidades de transição para o estado: $(estados[i])")
                for j in 1:(n+1)
                    print("Probabilidade de $(estados[i]) -> $(estados[j]): ")
                    transicoes_nova[i, j] = parse(Float64, readline())
                end
                soma_linha = sum(transicoes_nova[i, :])
                if abs(soma_linha - 1.0) > 1e-6
                    println("Aviso: A soma das probabilidades da linha '$((estados[i]))' é $(soma_linha), mas deveria ser 1.0")
                end
            end
        
            transicoes = transicoes_nova
            println("\nEstado '$novo_estado' adicionado com sucesso!")

        elseif opcao == "4"
            println("\nEstados disponíveis:")
            for (i, estado) in enumerate(estados)
                println("[$i] $estado")
            end
            print("Qual estado deseja remover (número)? ")
            estado_remover = parse(Int, readline())
            if estado_remover < 1 || estado_remover > length(estados)
                println("Estado inválido!")
                continue
            end
        
            println("Removendo estado: $(estados[estado_remover])")
        
            copia_transicoes = copy(transicoes)
        
            deleteat!(estados, estado_remover)
        
            transicoes = transicoes[setdiff(1:end, estado_remover), setdiff(1:end, estado_remover)]
        
            for i in 1:size(transicoes, 1)
                perdido = copia_transicoes[i, estado_remover]
                if perdido > 0
                    _, idx_max = findmax(transicoes[i, :]) 
                    transicoes[i, idx_max] += perdido
                end
            end
        
            for i in 1:size(transicoes, 1)
                soma = sum(transicoes[i, :])
                if soma > 0
                    transicoes[i, :] ./= soma
                end
            end

        elseif opcao == "5"
            print("Digite o número de estados: ")
            n_estados = parse(Int, readline())
            estados = String[]
            for i in 1:n_estados
                print("Nome do estado $i: ")
                push!(estados, readline())
            end

            transicoes = Matrix{Float64}(undef, n_estados, n_estados)
            for i in 1:n_estados
                println("Digite as probabilidades de transição para o estado $(estados[i]):")
                for j in 1:n_estados
                    print("Probabilidade de $(estados[i]) -> $(estados[j]): ")
                    transicoes[i, j] = parse(Float64, readline())
                end
            end
            println("Nova matriz criada!")

        elseif opcao == "6"
            println("Encerrando programa...")
            break

        else
            println("Opção inválida! Tente novamente.")
        end
    end
end

# ======== Executar Programa ========
main()