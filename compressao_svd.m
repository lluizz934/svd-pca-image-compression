
clc; clear; close all;

% ==== 1. Entrada: Caminho da Imagem ========================================
nome = input("Digite o caminho completo da imagem (ex: C:/caminho/imagem.tiff): ", "s");
disp(["Imagem carregada: ", nome]);

try
    img = im2double(imread(nome));
catch
    error("Erro ao carregar imagem. Verifique caminho/arquivo.");
end

% Detectar se e grayscale ou RGB
if ndims(img) == 2
    tipo = "grayscale";
    [m, n] = size(img);
else
    tipo = "rgb";
    [m, n, ~] = size(img);
end

disp(["Dimensao da imagem: ", num2str(m), " x ", num2str(n)]);
disp(["Tipo detectado: ", tipo]);

% ==== 2. Valor de k ========================================================
k = input("Digite o valor de k (dimensoes singulares): ");

if k <= 0 || k > min(m,n)
    error("Valor de k invalido. Deve estar entre 1 e %d.", min(m,n));
end

disp(["Compactando usando SVD com k = ", num2str(k), "..."]);

% ==== 3. Compressao ========================================================

if strcmp(tipo, "grayscale")
    disp("Chamando svd_compress para grayscale...");
    [img_compress, erro_estimado, erroF, energia] = svd_compress(img, k);
else
    img_compress = zeros(size(img));
    erro_estimado = zeros(3,1);
    erroF = zeros(3,1);
    energia = zeros(3,1);

    for canal = 1:3
        disp(["Chamando svd_compress para canal ", num2str(canal), "..."]);
        [Arec, e_est, eF, en] = svd_compress(img(:,:,canal), k);
        img_compress(:,:,canal) = Arec;
        erro_estimado(canal) = e_est;
        erroF(canal) = eF;
        energia(canal) = en;
    end
end

% ==== 4. Taxa de compressao ===============================================

if strcmp(tipo, "grayscale")
    Taxa = (m*k + k + n*k) / (m*n);
else
    Taxa = (m*k + k + n*k) / (m*n);
end

% ==== 5. Exibir e salvar imagem reconstruida ================================
figure;
imshow(img_compress);
disp("Imagem comprimida exibida na janela grafica.");

nome_saida = sprintf("imagem_svd_k%d.png", k);
imwrite(img_compress, nome_saida);
disp(["Imagem salva como: ", nome_saida]);

% ==== 6. Relatorio =========================================================
nome_relatorio = sprintf("relatorio_svd_k%d.txt", k);
fid = fopen(nome_relatorio, "w");

if fid == -1
    error("ERRO: Nao foi possivel criar o relatorio.");
end

fprintf(fid, "==== RELATORIO DE COMPRESSAO VIA SVD ====\n\n");
fprintf(fid, "Imagem: %s\n", nome);
fprintf(fid, "Tipo: %s\n", tipo);
fprintf(fid, "Dimensoes: %dx%d\n\n", m, n);
fprintf(fid, "Valor de k: %d\n\n", k);

if strcmp(tipo, "grayscale")
    fprintf(fid, "Erro estimado (proximo valor singular): %.6f\n", erro_estimado);
    fprintf(fid, "Erro Frobenius: %.6f\n", erroF);
    fprintf(fid, "Energia preservada: %.2f%%\n\n", 100*energia);
else
    for i = 1:3
        fprintf(fid, "Canal %d:\n", i);
        fprintf(fid, "  Erro estimado (proximo valor singular): %.6f\n", erro_estimado(i));
        fprintf(fid, "  Erro Frobenius: %.6f\n", erroF(i));
        fprintf(fid, "  Energia preservada: %.2f%%\n\n", 100*energia(i));
    end
end

fprintf(fid, "Taxa de compressao aproximada (fracao de armazenamento comprimido/original): %.4f\n", Taxa);
fprintf(fid, "Nota: Esta e uma estimativa aproximada, ignorando overhead de metadados e compressao adicional (e.g., PNG).\n");
fprintf(fid, "Imagem reconstruida: %s\n", nome_saida);
fclose(fid);

disp(["Relatorio gerado: ", nome_relatorio]);
disp("Processo concluido com sucesso.");
