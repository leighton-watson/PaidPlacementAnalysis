%% Salary and Superannuation %%
clear all; clc;
set(0,'DefaultAxesFontSize',12)
set(0,'DefaultLineLineWidth',3)
cmap = get(gca,'ColorOrder');

%% Load data and format parameters %%

% load salary data
salary_table_unpaid = readtable('unpaid_training_salaries.xlsx');
salary_table_paid = readtable('paid_training_salaries.xlsx');

% load unpaid training parameters 
parameters_table = readtable('unpaid_training_parameters.xlsx');

% Time span for simulation (in years)
tspan = [0, 47]; % simulation time window
tplot = [0, 20]; % plot time window
tstep = 0.01;
TIME = min(tspan):tstep:max(tspan); % time vector to interpolate on

% initialize dataframes to store outputs
num_jobs = 7;
SALARY = zeros(length(TIME),num_jobs);
SUPER = zeros(length(TIME),num_jobs);
SUPER_CONTRIB = zeros(length(TIME),num_jobs);
REPAYMENTS = zeros(length(TIME),num_jobs);
JOB = {};

% Parameters
min_wage = 48152;
min_wage_hourly = 23.15;
employee_super = 0.03;
employer_super = 0.03;
super_growth = 0.05;
repayment_threshold = 24128;
repayment_rate = 0.0;

%% Minimum Wage %%

% Initial conditions for minimum wage worker
initial_salary = min_wage; % Initial salary  (fixed)
initial_super_contrib = 0; % Initial superannuation contribution
initial_super = 0; % Initial superannuation 
initial_cond = [initial_salary, initial_super_contrib, initial_super]; % Initial conditions

% Solve the differential equations for minimum wage job
[t, y] = ode45(@(t, y) min_wage_model(t, y, employee_super, employer_super, super_growth), tspan, initial_cond);

% Extract solutions
salary = y(:, 1); % salary (before tax and superannuation contributions)
super_contrib = salary * employee_super; % employee superannuation contributions paid each year
super = y(:, 3); % superannuation balance

% interpolate and save
SALARY(:,1) = interp1(t,salary,TIME);
SUPER(:,1) = interp1(t,super,TIME);
SUPER_CONTRIB(:,1) = interp1(t,super_contrib,TIME);
JOB(1) = {'MinWage'};


%% Police %%

job_name = 'Police';
salary_data = salary_table_paid{:, job_name};
    
% Initial conditions for each job
initial_salary = salary_data(1); % Initial salary for job 
initial_super = 0; % Initial superannuation for job
initial_cond = [initial_salary, initial_super]; % Initial conditions

% Solve the differential equations for each job
[t, y] = ode45(@(t, y) police_model(t, y, salary_data, super_growth), tspan, initial_cond);

% Extract solutions
salary = zeros(size(t));
super_contrib = zeros(size(t));
for i = 1:length(t)
    [current_salary,employee_super_contrib,~] = compute_police_salary(t(i),salary_data);
    salary(i) = current_salary; % salary
    super_contrib(i) = employee_super_contrib; % employee superannuation contributions
end
super = y(:, 2); % superannuation


% interpolate and save
SALARY(:,2) = interp1(t,salary,TIME);
SUPER(:,2) = interp1(t,super,TIME);
SUPER_CONTRIB(:,2) = interp1(t,super_contrib,TIME);
JOB(2) = {job_name};

%% Firefighter

job_name = 'Firefighter';
salary_data = salary_table_paid{:, job_name};
    
% Initial conditions for each job
initial_salary = salary_data(1); % Initial salary for job 
initial_super = 0; % Initial superannuation for job
initial_cond = [initial_salary, initial_super]; % Initial conditions

% Solve the differential equations for each job
[t, y] = ode45(@(t, y) firefighter_model(t, y, salary_data, super_growth), tspan, initial_cond);

% Extract solutions
salary = zeros(size(t));
super_contrib = zeros(size(t));
for i = 1:length(t)
    [current_salary,employee_super_contrib,~] = compute_firefighter_salary(t(i),salary_data);
    salary(i) = current_salary; % salary
    super_contrib(i) = employee_super_contrib; % employee superannuation contributions
end
super = y(:, 2); % superannuation

% interpolate and save
SALARY(:,3) = interp1(t,salary,TIME);
SUPER(:,3) = interp1(t,super,TIME);
SUPER_CONTRIB(:,3) = interp1(t,super_contrib,TIME);
JOB(3) = {job_name};


%% Unpaid University Training %%

job_names = salary_table_unpaid.Properties.VariableNames(2:end); % Exclude the first column 'Step'

for j = 1:length(job_names)
    job_name = job_names{j};
    salary_data = salary_table_unpaid{:, job_name};
    
    % Extract parameters for the current job
    job_params = parameters_table(strcmp(parameters_table.Job, job_name), :);
    uni_years = job_params.TimeUni;
    uni_fees = job_params.UniCost;
    %placement_hours = 0;
    placement_hours = job_params.PlacementHoursYearly;

    % Initial conditions for each job
    initial_salary = 0; % Initial salary for job (starts unpaid)
    initial_super = 0; % Initial superannuation for job
    initial_loan = 0; % Initial student loan for job
    initial_cond = [initial_salary, initial_super, initial_loan]; % Initial conditions

    % Solve the differential equations for each job
    [t, y] = ode45(@(t, y) university_job_model(t, y, salary_data, employee_super, employer_super, super_growth, uni_years, uni_fees, placement_hours, min_wage_hourly, repayment_threshold, repayment_rate), tspan, initial_cond);
    
    % Extract solutions
    super = y(:, 2);
    loan = y(:, 3);
    salary = zeros(size(t));
    repayments = zeros(size(t));
    salary_after_repayments = zeros(size(t));
    super_contrib = zeros(size(t));
    for i = 1:length(t)
        loan_balance = loan(i);
        [current_salary, repayment_amount, salary_after_repayments, loan_change, employee_super_contrib] = compute_current_salary(t(i), uni_years, uni_fees, salary_data, employee_super, loan_balance, repayment_threshold, repayment_rate, placement_hours, min_wage_hourly);
        repayments(i) = repayment_amount;
        salary_after_repayments(i) = salary_after_repayments;
        salary(i) = current_salary;
        super_contrib(i) = employee_super_contrib;
    end

    % interpolate and save
    SALARY(:,3+j) = interp1(t,salary,TIME);
    SUPER(:,3+j) = interp1(t,super,TIME);
    SUPER_CONTRIB(:,3+j) = interp1(t,super_contrib,TIME);
    REPAYMENTS(:,3+j) = interp1(t,repayments,TIME);
    JOB(3+j) = {job_name};
    
end


%% Plotting 

POSTTAX_SALARY = calculate_post_tax_salary(SALARY);
POSTTAX_AND_SUPERCONTRIB_SALARY = POSTTAX_SALARY - SUPER_CONTRIB - REPAYMENTS;
CUM_SALARY = zeros(size(SALARY));

cmap2 = [0,0,0;cmap(1,:);cmap(2,:);cmap(3,:);cmap(4,:);cmap(5,:);cmap(6,:)];
lstyle = {'--','-.','-.','-','-','-','-'};
figHand = figure(1); clf;
set(figHand,'Position',[100 100 1400 1200])
for j = 1:num_jobs
    % salary
    subplot(2,2,1);
    plot(TIME,SALARY(:,j),'Color',cmap2(j,:),'LineStyle',lstyle{j}); hold on;

    % post tax and super contributions salary
    subplot(2,2,2);
    plot(TIME,POSTTAX_AND_SUPERCONTRIB_SALARY(:,j),'Color',cmap2(j,:),'LineStyle',lstyle{j});
    hold on;

    % cumulative salary (post tax and super contributions)
    cum_salary = cumtrapz(TIME,POSTTAX_AND_SUPERCONTRIB_SALARY(:,j));
    CUM_SALARY(:,j) = cum_salary;
    subplot(2,2,3);
    plot(TIME,cum_salary,'Color',cmap2(j,:),'LineStyle',lstyle{j});
    hold on;
  
    % superannuation
    subplot(2,2,4);
    plot(TIME,SUPER(:,j),'Color',cmap2(j,:),'LineStyle',lstyle{j});
    hold on;
    
end

% format plots
for k = 1:4
    subplot(2,2,k);
    xlim(tplot);
    grid on;
    xlabel('Time (years)')
end

subplot(2,2,1); title('(a) Salary')
ylabel('Salary ($)')
legend(JOB,'location','SouthEast')

subplot(2,2,2); title({'(b) Salary (After Tax and Employee', 'Superannuation Contributions)'});
ylabel('Salary ($)')
legend(JOB,'location','SouthEast')

subplot(2,2,3); title({'(c) Cumulative Salary (After Tax and', 'Employee Superannuation Contributions)'})
ylabel('Cumulative Salary ($)')
legend(JOB,'location','NorthWest')

subplot(2,2,4); title('(d) Superannuation')
ylabel('Superannuation ($)')
legend(JOB,'location','NorthWest')
ylim([0 5e5])

% %% Find when different jobs exceed minimum wage
% 
% cum_min_wage_salary = CUM_SALARY(:,1);
% min_wage_super = SUPER(:,1);
% SALARY_IDX = zeros(4,1);
% SUPER_IDX = zeros(4,1);
% for k = 1:4
%     idx1 = find(SUPER(:,3+k)>min_wage_super,1,'first');
%     SUPER_IDX(k) = idx1;
% 
%     idx2 = find(CUM_SALARY(:,3+k)>cum_min_wage_salary,1,'first');
%     SALARY_IDX(k) = idx2;
% 
%     disp(JOB{3+k});
%     disp('Salary exceed minimum wage salary')
%     disp(TIME(idx2));
% 
%     disp('Superannuation exceed minimum wage superannuation')
%     disp(TIME(idx1));
% end


%% Find out when different jobs exceed police and fire
police_cum_salary = CUM_SALARY(:,2);
fire_cum_salary = CUM_SALARY(:,3);
for k = 1:4
    idx_police = find(CUM_SALARY(:,3+k)>police_cum_salary,1,'first');
    idx_fire = find(CUM_SALARY(:,3+k)>fire_cum_salary,1,'first');

    disp(JOB{3+k});
    disp('Time to exceed police cumulative salary')
    disp(TIME(idx_police))

    disp('Time to exceed fire cumulative salary')
    disp(TIME(idx_fire))

end








