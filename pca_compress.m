function [Ak, erro_estimado, erroF, energiaPreservada] = pca_compress(A, k)
    disp("Dentro da funcao pca_compress...");

    try
        % Centralizar dados
        media = mean(A, 1);
        Acent = A - media;
        disp("Dados centralizados.");

        % Covariancia
        C = (Acent' * Acent) / (size(A,1)-1);
        disp("Covariancia calculada.");

        % Autovalores e autovetores
        [V, D] = eig(C);
        disp("Autovalores e autovetores calculados.");

        % Ordenar autovalores
        [autoval, idx] = sort(diag(D), "descend");
        V = V(:, idx);
        disp("Autovalores ordenados.");

        % Verificar se k e valido
        if k > length(autoval)
            error("k maior que o numero de autovalores disponiveis.");
        end

        % Selecionar k componentes
        Vk = V(:, 1:k);
        disp("Componentes selecionados.");

        % Projecao
        Y = Acent * Vk;
        disp("Projecao realizada.");

        % Reconstrucao
        Ak = Y * Vk' + media;
        disp("Reconstrucao concluida.");

        % Metricas
        autoval_total = sum(autoval);
        energiaPreservada = sum(autoval(1:k)) / autoval_total;
        erro_estimado = sqrt(autoval(k+1));  % Renomeado para maior clareza (estimativa do erro)
        erroF = sqrt(sum(autoval(k+1:end)));
        disp("Metricas calculadas.");

    catch err
        disp(["Erro na funcao pca_compress: ", err.message]);
        rethrow(err);
    end
end