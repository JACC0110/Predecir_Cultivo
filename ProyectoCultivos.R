#1. Revisar dataset
Cultivos


#2. Crear columna de rendimientos
rendimientos <- c(
  "arroz" = 4.0, "maiz" = 3.2, "garbanzo" = 1.8,
  "frijol rojo" = 1.2, "frijol negro" = 1.3, "lenteja" = 1.5,
  "granada" = 10, "banano" = 45, "mango" = 12, "uvas" = 20,
  "sandia" = 30, "melon" = 25, "manzana" = 12, "naranja" = 20,
  "papaya" = 35, "coco" = 70, "algodon" = 2.1, "cafe" = 0.8
)

Cultivos$rendimiento <- rendimientos[Cultivos$label_es]

#Convertir label_es en un factor
Cultivos$label_es <- as.factor(Cultivos$label_es)


#3.Implementar red neuronal
# ****************** Primera Version ***************************
library(nnet)

X <- Cultivos[, c("temperature", "ph", "rainfall")]
Y <- Cultivos$label_es

Y_matrix <- class.ind(Y)

set.seed(123)
modelo <- nnet(
x = X,
y = Y_matrix,
size = 10,
softmax = TRUE,
maxit = 500
)


# ****************** Segunda Version ***************************
library(nnet)

X <- scale(Cultivos[, c("temperature", "ph", "rainfall")])
Y <- as.factor(Cultivos$label_es)
Y_matrix <- class.ind(Y)

set.seed(123)
modelo <- nnet(
  x = X,
  y = Y_matrix,
  size = 20,
  decay = 0.01,
  softmax = TRUE,
  maxit = 1500
)


#6. Medir rendimiento
pred <- predict(modelo, X, type = "class")

cat("\n--- Matriz de confusion ---\n")
print(table(Predicho = pred, Real = Y))

accuracy <- mean(pred == Y)
cat("\nAccuracy: ", round(accuracy * 100, 2), "%\n")


#7. Guardar el modelo en archivo.h5
install.packages("BiocManager")
BiocManager::install("rhdf5")

library(rhdf5)

h5file <- "modelo_cultivos.h5"

if (file.exists(h5file)) file.remove(h5file)

h5createFile(h5file)

h5write(modelo$wts,       h5file, "pesos")
h5write(modelo$n,         h5file, "estructura")
h5write(levels(Y),        h5file, "labels")
h5write(colnames(X),      h5file, "features")
h5write(rendimientos,     h5file, "rendimientos")

cat("\nModelo guardado como: modelo_cultivos.h5\n")


#Probar funcionamiento
predecirCultivo <- function(temp, ph, rain, modelo, medias=NULL, desv=NULL) {
  
  # Normalizar datos si se usó scale()
  if (!is.null(medias)) {
    x <- c(temp, ph, rain)
    x <- (x - medias) / desv
  } else {
    x <- c(temp, ph, rain)
  }
  
  # Convertir a matriz (nnet lo requiere)
  x <- matrix(x, nrow = 1)
  
  # Obtener probabilidades
  prob <- predict(modelo, x, type = "raw")
  
  # Obtener cultivo con mayor probabilidad
  idx <- which.max(prob)
  cultivo_pred <- colnames(prob)[idx]
  
  return(cultivo_pred)
}


#Probar Version 1
predecirCultivo(25, 6.5, 150, modelo)


#Probar Version 2
stats <- scale(Cultivos[, c("temperature", "ph", "rainfall")])
medias <- attr(stats, "scaled:center")
desv <- attr(stats, "scaled:scale")

predecirCultivo(25, 6.5, 150, modelo, medias, desv)


