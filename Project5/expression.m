clc,clear,close all;
syms l0 l1 n
C = n*(l1 - l0)/(log(l1) - log(l0))
B1 = exp(C - n*l1 - C * log(C/n/l1))
B0 = exp(C - n*l0 - C * log(C/n/l0))

sum_b = simplify(B1 + B0)