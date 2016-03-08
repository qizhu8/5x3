function prob = f_getProb_soft(z, N0, sigma2, E, b)

C = 1 / sigma2 / sqrt(2 * pi * N0) * exp(-z*z / N0);
mu = 1 / 2 / sigma2 + E / N0;
v = -z * sqrt(E) / N0;
if b == 1
	v = -v;
end

prob = C * (1 / 2 / mu - v / mu * sqrt(pi / mu) * exp(v * v / mu) * qfunc(v * sqrt(2 / mu)) );