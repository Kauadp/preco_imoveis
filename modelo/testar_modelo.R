
# LENDO O MODELO E A BASE DE DADOS DE TESTE
dados_teste <- readRDS('data/dados_teste.rds')
modelo <- readRDS('modelo/modelo.rds')

# CRIANDO UMA FUNÇÃO PARA USAR O MODELO
avaliar_modelo <- function(modelo, dados_teste) {
  
  # Faz as predições
  predicoes <- as.vector(10^(predict(modelo, newdata = dados_teste)))
  reais <- (dados_teste$preco)
  
  # Calcula as métricas
  metrics <- postResample(predicoes, reais)
  
  # Cria lista de resultados
  list(
    predicoes = predicoes,
    reais = reais,
    metrics = metrics
  )
}

resultado <- avaliar_modelo(modelo, dados_teste)

resultado$metrics

# CRIANDO UM GRÁFICO PARA MELHOR ENTENDIMENTO DA PERFORMANCE DO MODELO
data.frame(
  Reais = dados_teste$preco,
  Predito = resultado$predicoes
) |> 
  ggplot(aes(x = Reais/1e6, y = Predito/1e6)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  scale_x_continuous("Preço Real (R$ milhões)", limits = c(0, 4)) +
  scale_y_continuous("Preço Predito (R$ milhões)", limits = c(0, 3)) +
  annotate("text", x = 1, y = 2.5, 
           label = paste("R² =", round(resultados$metrics["Rsquared"], 3))) +
  labs(title = "Desempenho do Modelo por Faixa de Preço em Milhões") + 
  theme_fivethirtyeight()

# SALVANDO O GRAFICO
ggsave('modelo/performance.png')
