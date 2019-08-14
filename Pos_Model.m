function [e,theta_pos,yhat] = Pos_Model(theta_pos, r, y, T,Delay_its,num)

yhat(1:(num*Delay_its)+1) = y(1:(num*Delay_its)+1);

for i=(num*Delay_its):length(r)
    
    Perc = yhat(i-T) - r(i-T);
    yhat(i) = yhat(i-1) + (theta_pos(1)*(theta_pos(2) - Perc) - theta_pos(3)*yhat(i-1))*0.001667;

end
yhat=transpose(yhat);
e(:)=y(num*Delay_its+1:end,1)-yhat(num*Delay_its+1:end,1);