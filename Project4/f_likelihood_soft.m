function l = f_likelihood_soft(z, N0, sigma2, E)

p_b0 = f_getProb_soft(z, N0, sigma2, E, 0);
p_b1 = f_getProb_soft(z, N0, sigma2, E, 1);
l = log(p_b0 / p_b1);