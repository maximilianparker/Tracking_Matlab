function [e, theta_posx,yhat] = PosX_Model(theta_posx, r, y, T,Delay_its,num)
s=3;
yhat(1:(num*Delay_its)+1) = y(1:(num*Delay_its)+1);

for i=(num*Delay_its):length(r)
    TV = (r(i-T)-r(i-(T+s)))/s;
    Ref = theta_posx(3)*TV;
    Perc = yhat(i-T)-r(i-T) ;
    
   yhat(i) = yhat(i-1) + ((theta_posx(1)*(Ref - Perc) - theta_posx(2)*yhat(i-1)))*0.0016667;
   
end
yhat=transpose(yhat);
e(:)=y(num*Delay_its+1:end,1)-yhat(num*Delay_its+1:end,1);

