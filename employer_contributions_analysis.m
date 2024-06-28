%% kiwisaver employer contributions 

salary = [0:100:150000];
employer_contribution = zeros(size(salary));

for i = 1:length(salary)
    tax_rate = esct_calc(salary(i));
    employer_contribution(i) = (1 - tax_rate) * 0.03 * salary(i);
end

figure(1); clf;
plot(salary, employer_contribution);


% for 84000 employer contribution = 1764
% need to make 87800 to have a bigger employer contribution