function [e,theta,yhat_p,yhat_v]=test_model_cont(theta,y,r,y_v,r_v,T)

% generate yhat_p (predictions) to start at 500
yhat_v=y_v(1:(500));
yhat_p=y(1:(500));

% loop for length of coordinate trace
for i=501:length(y)
    
    % PCT equation
    error=r(i-T)-yhat_p(i-T); % Error (e)
    ref=theta(2); % Reference (r)
    yhat_p(i)=yhat_p(i-1)+(theta(3)*(theta(1)*(error+ref)-yhat_p(i-1)))*.0016667; %
end

% generate error
e=yhat_p-y;