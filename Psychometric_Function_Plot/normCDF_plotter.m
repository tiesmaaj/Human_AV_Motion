function [fig, p_values,ci,threshold] = normCDF_plotter(coherence_lvls, rightward_prob, chosen_threshold, left_coh_vals, right_coh_vals, save_name)
%CREATEFIT(COH_LIST,PC_AUD)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : coh_list
%      Y Output: pc
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 10-Aug-2022 10:09:38


% Create a Normal Cumulative Distribution Function (NormCDF)
%
% X input : coherence_lvls
% Y input : rightward_prob
%
% Define the mean and standard deviation of the normal distribution
[xData, yData] = prepareCurveData(coherence_lvls, rightward_prob);

mu = mean(yData);
sigma = std(yData);
parms = [mu, sigma];

fun_1 = @(b, x)cdf('Normal', x, b(1), b(2));
fun = @(b)sum((fun_1(b,xData) - yData).^2); 
opts = optimset('MaxFunEvals',50000, 'MaxIter',10000); 
fit_par = fminsearch(fun, parms, opts);

x = min(left_coh_vals):.01:max(right_coh_vals);

[p_values, bootstat, ci] = p_value_calc(yData, parms);

p = cdf('Normal', x, fit_par(1), fit_par(2));

threshold_location = find(p >= chosen_threshold, 1);
threshold = x(1, threshold_location);

% Plot fit with data.
% fig = figure( 'Name', 'Psychometric Function' );
scatter(xData, yData)
hold on 
plot(x, p);
legend('% Rightward Resp. vs. Coherence', 'NormCDF', 'Location', 'NorthWest', 'Interpreter', 'none' );
% Label axes
% title(sprintf('Auditory Psych. Func. L&R\n%s',save_name), 'Interpreter','none');
xlabel( 'Coherence ((+)Rightward, (-)Leftward)', 'Interpreter', 'none' );
ylabel( '% Rightward Response', 'Interpreter', 'none' );
xlim([min(left_coh_vals) max(right_coh_vals)])
ylim([0 1])
grid on
text(0,.2,"std of the slope: " + fit_par(2))
% text(0,.1, "p value for CDF coeffs. (std): " + p_values(2))

%text(0,.2,"p value for CDF coeffs. (mean): " + p_values(1))
%text(0,.1, "p value for CDF coeffs. (std): " + p_values(2))
end