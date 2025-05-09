# Previsão de Preço de Imóveis no Espírito Santo 🏠📊

Projeto de análise e modelagem preditiva usando dados reais de imóveis. Exploramos variáveis como cidade (Serra, Vitória e Vila Velha), número de quartos, banheiros, vagas e preço.

## 📌 Objetivo

Prever o preço dos imóveis com base nas características do imóvel e localização.

## 📁 Estrutura
- `data/`: dados utilizados
- `modelo/`: arquivos de modelo treinado
- `raspagem.R`: script de Web Scraping
- `analise.ipynb`: relatório reprodutível
- `testar_modelo.R`: script em R para testar o modelo


## 🧪 Modelo
- Tipo: Regressão Linear
- R² obtido: **0.658**
- Observações: Melhor desempenho nas faixas de preço intermediárias.

## 📈 Resultados

![](modelo/performance.png)

### 📊 Métricas do Modelo

| Métrica  | Valor          | Interpretação                         |
|----------|----------------|---------------------------------------|
| **R²**   | 0.658          | Explica 65.8% da variância nos preços |
| **RMSE** | R\$ 479,594.10 | Erro médio de ±R\$ 479k               |
| **MAE**  | R\$ 284,871.80 | Erro absoluto médio de R\$ 284k       |

## 🔧 Como rodar

1.  Clone o repositório
2.  Abra `preco_imoveis.Rproj` no RStudio
3.  Execute `analise.ipynb` ou `testar_modelo.R`

## ⚠️ Aviso: Os dados utilizados neste projeto foram coletados da internet exclusivamente para fins educacionais e de portfólio. Nenhum dado será comercializado ou redistribuído.

Este projeto tem finalidade exclusivamente educacional e pessoal. Os dados utilizados foram coletados por meio de técnicas de web scraping com o objetivo de demonstrar habilidades em ciência de dados, e não serão comercializados, redistribuídos ou utilizados para fins comerciais.

O conteúdo raspado é de domínio público e permanece sob os direitos de seus respectivos proprietários. O uso aqui apresentado não representa a OLX nem tem qualquer vínculo com a plataforma.

## 📁 Sobre os Dados

Os dados utilizados foram coletados via web scraping da OLX, com foco em anúncios de imóveis em cidades do Espírito Santo.

**Por respeito aos termos de uso da plataforma, os dados brutos não são disponibilizados neste repositório.**

Caso deseje reproduzir a análise, consulte o arquivo [`web_scraping.qmd`](raspagem.R) para executar o processo de coleta por conta própria.

O site da OLX é dinâmico, a ocorrência de *bugs* e *tibble* com dimensçao 0x0 não é descartada.

## 📌 Conclusões

- O modelo de regressão apresentou um desempenho **satisfatório** (R² = 0.658), especialmente na faixa de preços entre **500 mil e 1 milhão de reais**.
- Algumas variáveis (como número de quartos e garagens) mostraram **não linearidade** e até **inversões inesperadas** no comportamento dos preços.
- Há sinais de **desigualdade no mercado**, como evidenciado pela distribuição bimodal de preços em cidades como Vitória.

## 🏠 Aplicação prática

Como forma de teste informal e contextualização prática, utilizei o modelo para estimar o valor de mercado de um imóvel real — a casa dos meus avós — localizada no bairro Barcelona, na cidade de Serra/ES. O valor estimado foi de aproximadamente R$ 452.000.

Após uma análise dos anúncios atuais no portal Viva Real, verifiquei que esse valor está alinhado com os preços médios praticados para imóveis semelhantes na mesma região. Essa consistência sugere que, mesmo com simplicidade, o modelo pode ser uma ferramenta útil para análises exploratórias de preços imobiliários em contextos reais.

## 📚 Tecnologias

-   R
-   tidyverse
-   ggplot2
-   Quarto
-   ggthemes
-   viridis
-   caret
-   httr
-   rvest
-   MASS
-   usethis
