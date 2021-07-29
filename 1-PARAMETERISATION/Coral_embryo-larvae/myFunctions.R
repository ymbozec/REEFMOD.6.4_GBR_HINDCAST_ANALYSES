
## f.stderr : function for estimating the standard error
f.stderr <- function(x) sqrt(var(x)/length(x))


## model_validation : plots for validation
model_validation=function(M)    
  {
#     par(mar=c(5,4,4,2), mfrow=c(1,2), pty="m")

    # Residuals vs fitted values
    plot(fitted(M), residuals(M), pch=19,cex=1.1) ; abline(h=0)

    # Normal distribution: QQ plot
    standardRes <- residuals(M)/summary(M)$sigma
    qqnorm(standardRes, main = "",pch=19,cex=1.1 ) ; abline(a = 0, b = 1)

    # Independence -> lagged residuals (lag plot)
    # plot(residuals(M), c(residuals(M)[-1], NA), xlab = "Residuals", ylab = "Lagged residuals")
  }

## model_validation2 : plots for validation
model_validation2=function(M)    
  {
    par(mar=c(5,4,4,2), mfrow=c(1,3), pty="m")

    # Residuals vs fitted values
    A=cbind(fitted(M), residuals(M), rep(1,length(fitted(M))))
    B=aggregate(A[,3], list(x=A[,1],y=A[,2]),sum)
    plot(B[,1],B[,2],cex=B[,3]) ; abline(h=0)

    # Normal distribution: QQ plot
    standardRes <- residuals(M)/summary(M)$sigma
    qqnorm(standardRes, main = "") ; abline(a = 0, b = 1)

    # Independence -> lagged residuals (lag plot)
    plot(residuals(M), c(residuals(M)[-1], NA), xlab = "Residuals", ylab = "Lagged residuals")
  }
