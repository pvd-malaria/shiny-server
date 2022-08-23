library(tidyverse)
library(htmlwidgets)
library(plotly)

viz2 <- readxl::read_excel('txpositivo.xlsx') %>% 
  janitor::clean_names()

summary(viz2)

library(ggplot2)
library(ggridges)
names(viz2)

library(hash)
ufsExtenso <- hash()
ufsExtenso[['AC']] <- 'Acre'
ufsExtenso[['AL']] <- 'Alagoas'
ufsExtenso[['AP']] <- 'Amapá'
ufsExtenso[['AM']] <- 'Amazonas'
ufsExtenso[['BA']] <- 'Bahia'
ufsExtenso[['CE']] <- 'Ceará'
ufsExtenso[['DF']] <- 'Distrito Federal'
ufsExtenso[['ES']] <- 'Espírito Santo'
ufsExtenso[['GO']] <- 'Goiás'
ufsExtenso[['MA']] <- 'Maranhão'
ufsExtenso[['MT']] <- 'Mato Grosso'
ufsExtenso[['MS']] <- 'Mato Grosso do Sul'
ufsExtenso[['MG']] <- 'Minas Gerais'
ufsExtenso[['PA']] <- 'Pará'
ufsExtenso[['PB']] <- 'Paraíba'
ufsExtenso[['PR']] <- 'Paraná'
ufsExtenso[['PE']] <- 'Pernambuco'
ufsExtenso[['PI']] <- 'Piauí'
ufsExtenso[['RJ']] <- 'Rio de Janeiro'
ufsExtenso[['RN']] <- 'Rio Grande do Norte'
ufsExtenso[['RS']] <- 'Rio Grande do Sul'
ufsExtenso[['RO']] <- 'Rondônia'
ufsExtenso[['RR']] <- 'Roraima'
ufsExtenso[['SC']] <- 'Santa Catarina'
ufsExtenso[['SP']] <- 'São Paulo'
ufsExtenso[['SE']] <- 'Sergipe'
ufsExtenso[['TO']] <- 'Tocantins'

viz2$uf <- sapply(viz2$uf, function(x) ufsExtenso[[x]])

v <- ggplot(viz2, aes(x = propositivo, y = uf, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
  scale_fill_gradient2(low = '#0D456E', mid='#1674b9', high = '#be1724')+
  labs(title = 'Proporção de Casos Positivos (2007 - 2019)') +
  labs(x = 'Proporção', y = NULL) +
  labs(caption = 'Fonte: Sistema de Informações de Vigilância Epidemológica (SIVEP) - Malária') +
  theme(text = element_text(family = 'Roboto'), plot.title = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5))
  #theme_bw()
ggsave(filename = 'ridges.png', plot = v, width = 14, height = 7, units = 'in', dpi = 300)
