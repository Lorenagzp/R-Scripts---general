############## R2
rsq <- function (x, y) cor(x, y) ^ 2
  #rsq(x,y)
  #plot(x,y)

#################################
##Grafica de las 3 fechas por separado, datos normalizados, proteina vs VIs
#################################
graficar_VI_cada_fecha_norm <- function(){
  #Folder para las graficas
  setwd("E:\\rotopixels2018\\1_INDICES\\0_estadisticas\\graficas")
  ##Loop para cada fecha
  for (take in c(1,2,3)) {
    #take <-2 ################################################################# PRUEBAS ejecutar este y el de abajo   
    pdf(paste("proteina_VI_","take",take,"_norm.pdf")) ############ des comentar para guardar PDF
    #graficas por cada VI
    for (vi in unique(table$VI)) {
      #vi <- "MCARI1" ######################################################### PRUEBAS ejecutar este y el de arriba

      formula <- y ~ x
      #ggplot 
      plot1 <- ggplot(table[table$VI==vi & (table$num_medicion==take),], aes(MEAN_NORM_DIAS, N_PERCENT)) + 
        geom_point((aes(size=2,colour = factor(Campos))))+ 
        scale_color_manual(values=c("blue","green","red","yellow","wheat","#FF00FF","black","gray","maroon","navy","#808000", "thistle","sienna","azure","lavender")) + geom_smooth(method = lm, se = FALSE)+ 
        stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
        method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ",
        signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'left', label.y.npc = 0.92, size = 4)+
        xlab(paste(vi," take",take)) + ylab("PROTEIN") + ggtitle(paste("PROTEIN",vi," DAYS-TO-IMAGE-cAPTURE-NORMALIZATION CORRELATION" )) 
      print(plot1)
      
    }
    dev.off() ########################################################## des comentar para guardar PDF
  }

}

#################################
##Grafica de las 3 fechas por separado, proteina vs VIs
#################################
graficar_VI_cada_fecha <- function(){
  #Folder para las graficas
  setwd("E:\\rotopixels2018\\1_INDICES\\0_estadisticas\\graficas")
  #Graficas
  for (take in c(1,2,3)) {
    pdf(paste("proteina_VI_","take",take,".pdf"))
    for (vi in unique(table$VI)) {
      # Dar nombre a la formula
      formula <- y ~ x
      #ggplot 
      plot1 <- ggplot(table[table$VI==vi & (table$num_medicion==take),], aes(MEAN, N_PERCENT)) + 
        geom_point((aes(size=2,colour = factor(Campos))))+ 
        scale_color_manual(values=c("blue","green","red","yellow","wheat","#FF00FF","black","gray","maroon","navy","#808000", "thistle","sienna","azure","lavender")) + geom_smooth(method = lm, se = FALSE)+ 
        stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
                                                                                  method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
                                                                                                                                                        signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'left', label.y.npc = 0.92, size = 4)+
        xlab(paste(vi," take",take)) + ylab("PROTEIN") + ggtitle(paste("PROTEIN",vi," CORRELATION" )) 
      print(plot1)
    }
    dev.off()
  }
  
}

#################################
##Grafica de las 3 fechas juntas, proteina vs VIs
#################################
graficar_VI_todas_fechas <- function(){
  #Folder para las graficas
  setwd("E:\\rotopixels2018\\1_INDICES\\0_estadisticas\\graficas")
  #Graficas
    pdf(paste("proteina_VI_all3takes.pdf"))
    for (vi in unique(table$VI)) {
      # Dar nombre a la formula
      formula <- y ~ x
      #ggplot 
      plot1 <- ggplot(table[table$VI==vi,], aes(MEAN, N_PERCENT)) + 
        geom_point((aes(size=2,colour = factor(Campos))))+ 
        scale_color_manual(values=c("blue","green","red","yellow","wheat","#FF00FF","black","gray","maroon","navy","#808000", "thistle","sienna","azure","lavender")) + geom_smooth(method = lm, se = FALSE)+ 
        stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
                                                                                  method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
                                                                                                                                                        signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'left', label.y.npc = 0.92, size = 4)+
        xlab(vi) + ylab("PROTEIN") + ggtitle(paste("PROTEIN",vi," CORRELATION" )) 
      print(plot1)
    }
    dev.off()
  
}

#################################
##Grafica de las 3 fechas juntas, proteina vs VIs, nomalizado
#################################
graficar_VI_todas_fechas_norm <- function(){
  #Folder para las graficas
  setwd("E:\\rotopixels2018\\1_INDICES\\0_estadisticas\\graficas")
  #Graficas
  pdf(paste("proteina_VI_all3takes_norm.pdf"))
  for (vi in unique(table$VI)) {
    # Dar nombre a la formula
    formula <- y ~ x
    #ggplot 
    plot1 <- ggplot(table[table$VI==vi,], aes(MEAN_NORM_DIAS, N_PERCENT)) + 
      geom_point((aes(size=2,colour = factor(Campos))))+ 
      scale_color_manual(values=c("blue","green","red","yellow","wheat","#FF00FF","black","gray","maroon","navy","#808000", "thistle","sienna","azure","lavender")) + geom_smooth(method = lm, se = FALSE)+ 
      stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
                                                                                method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
                                                                                                                                                      signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'left', label.y.npc = 0.92, size = 4)+
      xlab(vi) + ylab("PROTEIN") + ggtitle(paste("PROTEIN",vi," DAYS-TO-IMAGE-cAPTURE-NORMALIZATION CORRELATION" )) 
    print(plot1)
  }
  dev.off()
  
}

#################################
##Grafica de las 3 fechas juntas, proteina vs VIs, nomalizado, separado por campo
#################################
graficar_VI_todas_fechas_por_campo_norm <- function(){
  #Folder para las graficas
  setwd("E:\\rotopixels2018\\1_INDICES\\0_estadisticas\\graficas")
  #Graficas
  pdf(paste("proteina_VI_all3takes_byField_norm.pdf"))
  #recorrer todos los campos
  for (campo in table$Campos) {
    #Generar graficas de todos los indices
    for (vi in unique(table$VI)) {
      # Dar nombre a la formula
      formula <- y ~ x
      #ggplot 
      plot1 <- ggplot(table[table$Campos==campo & table$VI==vi,], aes(MEAN_NORM_DIAS, N_PERCENT)) + 
        geom_point((aes(size=2,colour = factor(Campos))))+ 
        scale_color_manual(values=c("blue","green","red","yellow","wheat","#FF00FF","black","gray","maroon","navy","#808000", "thistle","sienna","azure","lavender")) + geom_smooth(method = lm, se = FALSE)+ 
        stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
                                                                                  method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
                                                                                                                                                        signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'left', label.y.npc = 0.92, size = 4)+
        xlab(vi) + ylab("PROTEIN") + ggtitle(paste(campo," PROTEIN",vi," DAYS-TO-IMAGE-cAPTURE-NORMALIZATION CORRELATION" )) 
      print(plot1)
    }    
  }

  dev.off()
  
}



######################## PRUEBAS ##########################################
####################Grafica con R cuadrado########################
pruebas <- function(){
  #Agregar columna de "num_medicion" a "table_complete"#
  #Esto para poder cambiar de simbolo/color cada fecha#
  #Tambien investigar como colocar linea a cada grupo de datos#
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  # Dar nombre a la formula
  formula <- y ~ poly(x, 3, raw = TRUE)
  #ggplot 
  ggplot(table[table$VI=="NDVI" & table$num_medicion==3,], aes(MEAN, N_PERCENT)) + 
    geom_point(color="red") + geom_smooth(method = lm, se = FALSE)+ 
    stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
                                                                              method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
                                                                                                                                                    signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'right', label.y.npc = 0.35, size = 3)+
    xlab("NDVI fecha 3") + ylab("PROTEIN") + ggtitle("PROTEIN-VI CORRELATION ") 
  
  #NDVI 2
  
  ####################Grafica con R cuadrado y p-value 15/01/2019########################
  #para dejarlo como estaba, solo eliminar el size del geom.point y scale_color_manual
  
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  # Dar nombre a la formula
  formula <- y ~ poly(x, 2, raw = TRUE)
  #ggplot 
  ggplot(table[table$VI=="NDVI" & table$num_medicion==2,], aes(MEAN_NORM_DIAS, N_PERCENT)) + 
    geom_point((aes(size=2,colour = factor(Campos))))+ 
    scale_color_manual(values=c("blue","green","red","yellow","wheat","#FF00FF","black","gray","maroon","navy","#808000", "thistle","sienna","azure","lavender")) + geom_smooth(method = lm, se = FALSE)+ 
    stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+stat_fit_glance(method = 'lm',
                                                                              method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", 
                                                                                                                                                    signif(..p.value.., digits = 4), sep = "")), label.x.npc = 'left', label.y.npc = 0.92, size = 4)+
    xlab("NDVI TAKE 2") + ylab("PROTEIN") + ggtitle("PROTEIN-VI CORRELATION ") 
  
  
  
  
  ############Grafica sin estandarizar con distincion de los campos.Se grafica por cada indice en determinada toma###################################
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  # Dar nombre a la formula
  formula <- y ~ poly(x, 3, raw = TRUE)
  #ggplot 
  ggplot(table[table$VI=="NDVI" & table$num_medicion==2,], aes(MEAN, N_PERCENT,shape=factor(Campos), fill=factor(Campos), col=factor(Campos))) + 
    geom_point(size=2)+ stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+xlab("NDVI fecha 3") + ylab("PROTEIN") +
    ggtitle("PROTEIN-VI CORRELATION ")+scale_shape_manual(values=rep(c(21:25), times=8))
  
  
  #Graficas con indices estandarizados
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  # Dar nombre a la formula
  formula <- y ~ poly(x, 3, raw = TRUE)
  #ggplot 
  ggplot(table[table$VI=="NDVI" & table$num_medicion==3,], aes(MEAN_NORM_DIAS, N_PERCENT)) + 
    geom_point((aes(color= factor(Campos))))+ 
    stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+xlab("NDVI VALUE (3)") + ylab("PROTEIN") +
    ggtitle("PROTEIN-VI CORRELATION ") 
  
  ############Grafica sin estandarizar con distincion de los campos.Se grafica por cada indice en determinada toma###################################
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  # Dar nombre a la formula
  formula <- y ~ poly(x, 3, raw = TRUE)
  #ggplot 
  ggplot(table[table$VI=="NDVI" & table$num_medicion==3,], aes(MEAN, N_PERCENT,shape=factor(Campos), fill=factor(Campos), col=factor(Campos))) + 
    geom_point(size=2)+ stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+xlab("NDVI fecha 3") + ylab("PROTEIN") +
    ggtitle("PROTEIN-VI CORRELATION ")+scale_shape_manual(values=rep(c(21:25), times=8))
  
  
  ##############R cuadrado de un indice con la 3 fechas de diferente color################
  ###https://ggplot2.tidyverse.org/reference/scale_manual.html###
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  # Dar nombre a la formula
  formula <- y ~ poly(x, 3, raw = TRUE)
  #ggplot usando table y filtrando por fila
  ggplot(table[table$VI=="NDVI",], aes(MEAN, N_PERCENT)) + 
    geom_point((aes(colour = factor(num_medicion)))) + 
    scale_color_manual(values=c("blue","green","red"))+
    geom_smooth(method = lm, se = TRUE)+ 
    stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+ 
    xlab("NDVI") + ylab("PROTEIN") +
    ggtitle("PROTEIN-VI CORRELATION ") 
  
  #Graficas separadas con r2 y p-value.Me dijo el doc que preferia por separado.
  x <- 1:100 #Investigar este calculo de abajo. 
  y <- (x + x^2 + x^3) + rnorm(length(x), mean = 0, sd = mean(x^3) / 4)
  my.data <- data.frame(x = x, y = y,
                        group = c("A", "B"),
                        y2 = y * c(0.5,2),
                        w = sqrt(x))
  ggplot(table[table$VI=="NDVI",], aes(MEAN, N_PERCENT, colour = factor(num_medicion))) +
    geom_point() + facet_grid(. ~ num_medicion, scales = "free")+geom_smooth(method = lm, se = FALSE)+ 
    stat_poly_eq(formula = formula,rr.digits=4, parse = TRUE)+ stat_fit_glance(method = 'lm',
                                                                               method.args = list(formula = formula),geom = 'text',aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                                                                               label.x.npc = 'right', label.y.npc = 0.35, size = 3)+
    xlab("NDVI") + ylab("PROTEIN") + ggtitle("PROTEIN-VI CORRELATION ") 
  
  
  ##########################PRUEBA PARA TERMINAR###############################################
  
  
  ####################Grafica con R cuadrado y p-value para guardar graficas ########################
}

plot_ly(data = table, x = ~MEAN_NORM_DIAS, y = ~N_PERCENT,type="scatter", mode="markers",symbol=~num_medicion, 
       symbols = c('18','x','circle'),marker = list(size = 8),color=~num_medicion, colors = c("blue","green","red"))


