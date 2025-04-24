# 📌 Introdução

### Neste arquivo vamos:
  
### 1- Ler e interpretar a página em html;

### 2- Encontrar os dados que queremos raspar;

### 3- Tratar e exportar os dados para usarmos posteriormente.

## 📥 Objetivo

### Este documento realiza o **web scraping** dos dados de imóveis utilizados na análise de preços.

## 🔗 Fonte dos Dados

### Os dados foram coletados de um site de anúcios de compra e venda, por meio da biblioteca `rvest`.

## 💻 Código

### Instalando e Carregando os Pacotes necessários

if (!require('httr')) install.packages('httr')
if (!require('rvest')) install.packages('rvest')
if (!require('tidyverse')) install.packages('tidyverse')
if (!require('ggplot2')) install.packages('ggplot2')
if (!require('ggthemes')) install.packages('ggthemes')
if (!require('MASS')) install.packages('MASS')
library(httr)
library(rvest)
library(tidyverse)
library(ggplot2)
library(ggthemes)
library(MASS)  

# Raspagem de dados

### Carregando a página que vamos raspar os dados

url <- 'https://www.olx.com.br/imoveis/venda/estado-es'

pagina <- GET(url,
              add_headers(
                `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
                `Accept-Language` = "en-US,en;q=0.9",
                `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                `Referer` = "https://www.google.com"
              )
)

html <- pagina |> content(as = "text") |> read_html()
cards <- html |> html_elements('section')

### Raspando os dados que vamos utilizar e montando o dataframe

dados <- map_df(cards, function(card) {
  
  # Pega o preço
  preco <- card |> 
    html_element('h3') |> 
    html_text2() |> 
    parse_number(locale = locale(grouping_mark = "."))  # Remove separador de milhar
  
  # Pega a localização
  localizacao <- card |> 
    html_element('.olx-ad-card__location-date-container') |> 
    html_element('p') |> 
    html_text2()
  localizacao <- sub(",.*", "", localizacao)  # remove bairro
  if (length(localizacao) == 0 || is.na(localizacao)) localizacao <- NA_character_
  
  # Pega todos os atributos do card
  atributos <- card |> 
    html_elements('.olx-ad-card__labels-item span') |> 
    html_attr('aria-label')
  
  # Extrai número de quartos
  quartos <- atributos |> 
    str_subset("quarto[s]?") |> 
    str_extract("\\d+") |> 
    as.integer()
  if (length(quartos) == 0) quartos <- NA_integer_
  
  # Banheiros
  banheiros <- atributos |> 
    str_subset("banheiro[s]?") |> 
    str_extract("\\d+") |> 
    as.integer()
  if (length(banheiros) == 0) banheiros <- NA_integer_
  
  # Vagas
  vagas <- atributos |> 
    str_subset("vaga[s]?") |> 
    str_extract("\\d+") |> 
    as.integer()
  if (length(vagas) == 0) vagas <- NA_integer_
  
  # Metros quadrados
  metros <- atributos |> 
    str_subset("metros quadrados") |> 
    str_extract("\\d+") |> 
    as.integer()
  if (length(metros) == 0) metros <- NA_integer_
  
  # Retorna como uma linha de data frame
  tibble(
    preco = preco,
    cidade = localizacao,
    quartos = quartos,
    banheiros = banheiros,
    vagas_garagem = vagas,
    metros_quadrados = metros
  )
})

## Tratando os dados

dados <- dados[!apply(is.na(dados), 1, all), ]


### Assumindo que se o card não mostre o valor é porque não o possui

dados[is.na(dados)] <- 0

dados

# Simulação

car::qqPlot(dados$preco)


### Apontam uma certa normalidade, vamos realisar o teste KS e Shapiro-Wilk de normalidade

### KS

ks.test(dados$preco, 'pnorm')

### Shapiro-Wilk

shapiro.test(dados$preco)

### Ambos os testes apontam uma não normalidade

dados |> 
  ggplot(aes(x = preco)) +
  geom_density(size = 1.2) +
  labs(
    title = 'Distribuição de Preços',
    x = 'Preço',
    y = 'Densidade'
  ) +
  theme_fivethirtyeight()

### O gráifco sugere uma acentuação a direita, ou seja, uma assimetria positiva, vamos log transformar os dados para tentar reduzir a assimetria

dados$log_preco <- log10(dados$preco)

dados |> 
  ggplot(aes(x = log_preco)) +
  geom_density(size = 1.2) +
  labs(
    title = 'Distribuição de Preços Log Transformados',
    x = 'Preço',
    y = 'Densidade'
  ) +
  theme_fivethirtyeight()

### Observe que a transformação melhorou significativamente a assimetria, vamos recalcular os testes de normalidade para os preços transformados agora

### KS

ks.test(dados$log_preco, 'pnorm')

### Shapiro-Wilk

shapiro.test(dados$log_preco)

### Os testes se contradizem, porem é sabido que o teste KS é mais sensível à assimetrias, vamos analisar melhor

dados |> 
  ggplot(aes(x = log_preco)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "skyblue", alpha = 0.7) +
  geom_density(color = "red", linewidth = 1, aes(linetype = "Dados Transformados"), size = 1.2) +
  stat_function(fun = dnorm, 
                args = list(mean = mean(dados$log_preco), 
                            sd = sd(dados$log_preco)),
                aes(linetype = "Normal Teórica"),
                color = "blue", linewidth = 1,
                size = 1.2) +
  scale_linetype_manual(name = "Distribuição",
                        values = c("Dados Transformados" = "solid",
                                   "Normal Teórica" = "dashed")) +
  labs(title = "Dados Transformados vs. Normal Teórica",
       x = "Valores Log-Transformados",
       y = "Densidade") +
  theme_fivethirtyeight() +
  theme(legend.position = "bottom")

### O gráfico sugere que a distribuição dos dados transformados segue a distribuição normal teórica, combinando com o resultado do teste de Shapiro, evidencia que os dados são normais.

car::qqPlot(dados$log_preco)

### Fica mais claro que nunca que os dados transformados seguem uma distribuição normal. Logo os dados originais são Log-Normais.

### Ajustando os dados

fit <- fitdistr(dados$preco, "lognormal")  

preco_sim <- rlnorm(69, fit$estimate['meanlog'], fit$estimate['sdlog'])

df_plot <- data.frame(
  Valores = c(dados$preco, preco_sim),
  Tipo = rep(c("Dados Reais", "Dados Simulados"), each = length(dados$preco))
)

ggplot(df_plot, aes(x = Valores, fill = Tipo, color = Tipo)) +
  geom_density(alpha = 0.5, linewidth = 0.8) +
  scale_fill_manual(values = c("Dados Reais" = "#E69F00", "Dados Simulados" = "#56B4E9")) +
  scale_color_manual(values = c("Dados Reais" = "#D55E00", "Dados Simulados" = "#0072B2")) +
  labs(
    title = "Comparação de Densidade: Dados Reais vs. Simulados",
    subtitle = paste("Ajuste Log-Normal (μ =", round(fit$estimate['meanlog'], 2), ", σ =",
                     round(fit$estimate['sdlog'], 2), ")"),
    x = "Valores (Escala Original)",
    y = "Densidade",
    caption = "Dados simulados a partir da distribuição log-normal ajustada."
  ) +
  theme_fivethirtyeight() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  ) +
  scale_x_continuous(labels = scales::comma)

### Os dados simulados se ajustam suficientemente bem, é possível ver que os dados simulados subestimam um pouco os dados reais.
### Sabendo que o ajuste log-normal nos dados tem relevância, podemos exportar os dados e seguir com adiante com a análise

write.csv2(dados, 'data/dados_raspados.csv', fileEncoding = 'ISO-8859-1')

### Com os novos dados, podemos continuar com o projeto.
