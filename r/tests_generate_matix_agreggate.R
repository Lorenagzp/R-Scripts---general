library(data.table)
x <- matrix(c("TIF", 0.9,1,"ZIP", 0.5,2,"ZIP", 0.7,2),
            3, 3, byrow = TRUE)

rownames(x) <- c("a","b","b")
colnames(x) <- c("name","val2","val1")
x <- as.data.frame(x)
x1 <-aggregate(. ~ name, x, mean, na.rm = TRUE)
df2 <- setDT(x)[, lapply(mean), by=.(name)]
