clc,clear,close all
load data2_ite1
ber_a(1,:) = ber;
save data ber_a;
clear

load data2_ite2
load data
ber_a(2,:) = ber;
save data ber_a
clear

load data2_ite4
load data
ber_a(3,:) = ber;
clear ber
save data

ebn0_range = 10.^(ebn0db / 10.0);
Pe_bound = 7*qfunc(sqrt(2*ebn0_range*3*4/7)) + 7*qfunc(sqrt(2*ebn0_range*4*4/7)) + qfunc(sqrt(2*ebn0_range*7*4/7));

semilogy(ebn0db, ber_a(1,:), 'r','LineWidth',2); hold on;
semilogy(ebn0db, ber_a(2,:), 'g','LineWidth',2); hold on;
semilogy(ebn0db, ber_a(3,:), 'b','LineWidth',2); hold on;
semilogy(ebn0db, Pe_bound, 'k','LineWidth',2); hold on;
axis([-3 6 1e-5 1])
grid on
xlabel('E_b/N_0 (dB)','FontSize',16)
ylabel('BER','FontSize',16)
legend('iteration = 1', 'iteration = 2', 'iteration = 4', 'union bound');