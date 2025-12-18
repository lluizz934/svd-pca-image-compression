function [Ak, erro_estimado, erroF, energiaPreservada] = svd_compress(A, k)
    disp("Dentro da funcao svd_compress...");

    try
        % Decomposicao SVD
        [U, S, V] = svd(A);
        disp("SVD calculada.");

        % Valores singulares
        sigma = diag(S);
        r = length(sigma);
        disp("Valores singulares extraidos.");

        % Verificar se k e valido
        if k > r
            error("k maior que o numero de valores singulares disponiveis.");
        end

        % Reconstrucao truncada
        Ak = U(:,1:k) * S(1:k,1:k) * V(:,1:k)';
        disp("Reconstrucao concluida.");

        % Metricas
        energiaPreservada = sum(sigma(1:k).^2) / sum(sigma.^2);
        erro_estimado = sigma(k+1);  % Proximo valor singular (similar ao erro estimado na PCA)
        erroF = sqrt(sum(sigma(k+1:r).^2));
        disp("Metricas calculadas.");

    catch err
        disp(["Erro na funcao svd_compress: ", err.message]);
        rethrow(err);
    end
end