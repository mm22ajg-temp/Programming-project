evaluate_design <- function(lambda, gamma, n1, n2) {
  
  # Estimate the type I error rate, type II error rate, and the expected 
  # sample size of a design defined by its decision rule parameters 
  # (lambda, gamma) and sample size parameters (n1, n2).
  
  # Set the number of simulations.
  M <- 10^4
  
  # Create an empty vector to store simulated Ns.
  Ns <- rep(NA, M)
  
  # Create empty vectors to count the number of successes and failures at
  # each stage.
  Stage_1_s <- rep(0, M)
  Stage_2_s <- rep(0, M)
  Stage_1_f <- rep(0, M)
  Stage_2_f <- rep(0, M)
  
  for (i in 1:M) {
    
    # Simulate the stage 1 and stage 2 data conditional on theta.
    y1 <- rbinom(1, n1, theta)
    y2 <- rbinom(1, n2, theta)
    
    # Get posterior Beta(a1, b1) and Beta(a2, b2) parameters.
    a1 <- 0.5 + y1
    b1 <- 0.5 + n1 - y1
    a2 <- 0.5 + y2
    b2 <- 0.5 + n2 - y2
    
    # Probability of futility at each stage.
    fut1 <- pbeta(0.5, a1, b1)
    fut2 <- pbeta(0.5, a2, b2)
    
    # Thresholds at each stage to determine progression, based on the 
    # decision rule.
    C1 <- 1 - lambda * (n1 / n2)^gamma
    C2 <- 1 - lambda * (n2 / n2)^gamma
    
    # Count the number of progressions at each stage.
    if (fut1 < C1) {
      Stage_1_s[i] <- 1
    } else {
      Stage_1_f[i] <- 1
    }
    if (fut2 < C2) {
      Stage_2_s[i] <- 1
    } else {
      Stage_2_f[i] <- 1
    }
    
    # Estimate the type I and type II error rates.
    type_I_error <- mean(Stage_1_s & Stage_2_s)
    type_II_error <- mean(Stage_1_f | Stage_2_f)
    
    # Note the final total sample size for each simulation.
    if (fut1 >= C1) {
      Ns[i] <- n1
    } else {
      Ns[i] <- n2
    }
  }

  # Return the estimated expected sample size, type I error rate, and 
  # type II error rate.
  return(c(mean(Ns), type_I_error, type_II_error))
}

# Example
# Decision rule parameters:
lambda <- 0.8
gamma <- 0.3

# Sample size parameters:
n1 <- 30
n2 <- 60

# Under the null hypothesis:
theta <- 0.5
evaluate_design(lambda, gamma, n1, n2)

# Under the alternative hypothesis:
theta <- 0.7
evaluate_design(lambda, gamma, n1, n2)

