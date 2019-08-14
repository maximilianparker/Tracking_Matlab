clear
%% Settings
num=61;         % Number of independent delay values to measure at
Fs_orig=60;     % Original data sample frequency
Fs=600;         % New sample freq (if interpolated data)
Ts=0.0016667;   % Sample rate (s)
Delay_its=5;    % Jump in delay values

%% Optimisation bounds (parameters)
%POS
lb_pos=[1,-500,0];
ub_pos=[500,500,1];
%POSX
lb_posx=[1,0,0];
ub_posx=[500,1,50];


%% Optim settings
opt = optimoptions('lsqnonlin', 'MaxIter', 2000, 'MaxFunEvals', 2000, 'TolFun', 1e-7);

for k = [1]
    % Sets a for loop such that it will run through the numerically indexed
    % files
   for a = 1:num-1
        % Read CSV file
        M = xlsread(sprintf('T_%d.xlsx', k));
        r = M(:,3);
        y = M(:,2);       
       
        % Init conds
        theta_pos(:,1)=[1,0,0];      
        theta_posx(:,1)=[1,0,0];
        % parameter estimation
       if a==1
            T=1; % Delay
            pos=@(x0)Pos_Model(x0,r,y,T,Delay_its,num);
            posx=@(x0)PosX_Model(x0,r,y,T,Delay_its,num);
            
            % Optimise
            theta_pos(:,a) = lsqnonlin(pos, theta_pos(:), lb_pos, ub_pos, opt); % 
            theta_posx(:,a) = lsqnonlin(posx, theta_posx(:), lb_posx, ub_posx, opt); % 
       else
           T=Delay_its*a;
           pos=@(x0)Pos_Model(x0,r,y,T,Delay_its,num);
           posx=@(x0)PosX_Model(x0,r,y,T,Delay_its,num);
           % Optimise
           theta_pos(:,a) = lsqnonlin(pos, theta_pos(:,a-1), lb_pos, ub_pos, opt);
           theta_posx(:,a) = lsqnonlin(posx, theta_posx(:,a-1), lb_posx, ub_posx, opt);
       end
       
        [e_pos,~,yhat_pos] = Pos1_Model500(theta_pos(:,a), r, y, T,Delay_its,num);
        [e_posx,~,yhat_posx] = PosX_Model500(theta_posx(:,a), r, y, T,Delay_its,num);
        
        % Align y and r with e for time t
        r = r(num*Delay_its+1:end);
        y = y(num*Delay_its+1:end);
        yhat_pos=yhat_pos(num*Delay_its+1:end);
        yhat_posx=yhat_posx(num*Delay_its+1:end);
        
        % Track RMSE
        if T==1
        pos_s(1:num-1,2)=std(r-y);
        posx_s(1:num-1,2)=std(r-y);
        end
        
        % Generate Model RMSE = root mean square error fit of model simulated cursor to
        % actual cursor
        pos_s(a,3) = std(e_pos);
        posx_s(a,3) = std(e_posx);
        
        % Fit of simulated model cursor (yhat) to target (r)
        eModel_pos = yhat_pos-r;
        pos_s(a,6) = std(eModel_pos);
        eModel_posx = yhat_posx-r;
        posx_s(a,6) = std(eModel_posx);
        
        % Correlation Coefficient (yhat to y)
        corr = corrcoef(y,yhat_pos);
        pos_s(a,4) = corr(2);
        corr = corrcoef(y,yhat_posx);
        posx_s(a,4) = corr(2);
           
        %% Remove bias
        x = r - mean(r);
        y = y - mean(y);
        yhat_pos=yhat_pos-mean(yhat_pos);
        yhat_posx=yhat_posx-mean(yhat_posx);
        
        t=1:length(y);
        
        %% Coherence, gain and phase
        window=round(.9*length(y));
        overlap=round(.9*window);
        
        [Cxy,f] = mscohere(x,y,window,overlap,[],Fs);
        Pxy  = cpsd(x,y,window,overlap,[],Fs);
        [ampx, f]=pwelch(x,window,overlap,[],Fs);
        ampy=pwelch(y,window,overlap,[],Fs);
        
        Cxyhat_y_pos = mscohere(y,yhat_pos,window,overlap,[],Fs);
        Cxyhat_y_posx = mscohere(y,yhat_posx,window,overlap,[],Fs);
       
        
        Pxyhat_y_pos =cpsd(y,yhat_pos,window,overlap,[],Fs);       
        Pxyhat_y_posx =cpsd(y,yhat_posx,window,overlap,[],Fs);               

        ampyhat_pos=pwelch(yhat_pos,window,overlap,[],Fs);
        ampyhat_posx=pwelch(yhat_posx,window,overlap,[],Fs);

        % Reference Input gain and threshold
        maxgain=mean(maxk(ampx, 3));
        Uppercutoff = .75*maxgain;
        index = find(abs(ampx) > Uppercutoff);
        vals = abs(ampx(index));
        index2=index-1;
        Input_freqs(1:length(index))=index2(1:length(index))*(f(2)-f(1));
        
        d=1:1:length(index);    
        GYRef(d)=abs(ampx(index(d)));
        GYOut(d)=abs(ampy(index(d)));
        Magdiff(d)=GYOut(d)/GYRef(d);
        GYCoh(d)=(Cxy(index(d)));
        PYOut_deg(d)=(rad2deg(mean(-angle(Pxy(index(d))))));
        period(d)=1./Input_freqs(d);
        tdeg(d)=period(d)./360;
        phasedelayms(d)=tdeg(d).*PYOut_deg(d);
        
        GYhatout_pos(d)=abs(ampyhat_pos(index(d)));
        GYhatout_posx(d)=abs(ampyhat_posx(index(d)));
        
        Magdiffyhat_y_pos(d)=GYhatout_pos(d)/GYOut(d);
        Magdiffyhat_y_posx(d)=GYhatout_posx(d)/GYOut(d);
        
        GYCoh_yhat_y_pos(d)=(Cxyhat_y_pos(index(d)));
        GYCoh_yhat_y_posx(d)=(Cxyhat_y_posx(index(d)));
        
        PYOut_yhat_y_deg_pos(d)=(rad2deg(mean(-angle(Pxyhat_y_pos(index(d))))));
        PYOut_yhat_y_deg_posx(d)=(rad2deg(mean(-angle(Pxyhat_y_posx(index(d))))));
        
        pd_yhat_y_pos(d)=tdeg(d).*PYOut_yhat_y_deg_pos(d);
        pd_yhat_y_posx(d)=tdeg(d).*PYOut_yhat_y_deg_posx(d);
        
%% AVERAGE WEIGHTING PROCEDURE
        vals_total=sum(vals(1:length(index)));
        j=1:1:length(index);
        weights(j)=vals(j)/vals_total;
        if T==1
            magdifxy=sum(Magdiff(j).*weights(j));
            pos_s(1:num-1,14)=magdifxy;
            posx_s(1:num-11,14)=magdifxy;

            cohxy=sum(GYCoh(j).*weights(j));
            pos_s(1:num-1,15)=cohxy;
            posx_s(1:num-1,15)=cohxy;

            inputf=sum(Input_freqs(j).*weights(j));
            pos_s(1:num-1,16)=inputf;
            posx_s(1:num-1,16)=inputf;

            phasexy=sum(phasedelayms(j).*weights(j));
            pos_s(1:num-1,17)=phasexy;
            posx_s(1:num-1,17)=phasexy;

            pos_s(1:num-1,1)=1:1:num-1;
            posx_s(1:num-1,1)=1:1:num-1;
 
        end   
        pos_s(a,18)=sum(Magdiffyhat_y_pos(j).*weights(j));
        pos_s(a,19)=sum(GYCoh_yhat_y_pos(j).*weights(j));
        pos_s(a,20)=sum(pd_yhat_y_pos(j).*weights(j));
        
        posx_s(a,18)=sum(Magdiffyhat_y_posx(j).*weights(j));
        posx_s(a,19)=sum(GYCoh_yhat_y_posx(j).*weights(j));
        posx_s(a,20)=sum(pd_yhat_y_posx(j).*weights(j));
        
   end
        % parameters
        pos_s(:,[7,8,9]) = transpose(theta_pos([1,2,3],:));
        posx_s(:,[7,8,9])=transpose(theta_posx([1,2,3],:));    

        
    %% Write the above values to Excel file
    
    % Filename
    filename2 = 'Pos1_P.xlsx';
    filename3 = 'PosX_P.xlsx';
    % Headers
     B = {'Delay', 'TrackRMS', 'ModelRMS', 'Correlation', 'AIC', 'RMS_R-Yhat' 'PGain', 'PRef', 'PDamp','Vgain', 'VDamp', 'Xgain', [],'MagnitudediffM', 'CoherenceM', 'inputfreq','phasems', 'magdiffyhaty', 'GYCoh_yhat_y', 'pd_yhat_y'};
 
        % Specifies row A for header insertion
        xlRange = 'A1';
        % Write info
        xlswrite(filename2,B,k,xlRange)
        % Write data to the file
        xlRange = 'A2:T61';
        xlswrite(filename2,pos_s,k,xlRange)
        
        % Write info
        xlRange = 'A1';
        xlswrite(filename3,B,k,xlRange)
        % Write data to the file
        xlRange = 'A2:T61';
        xlswrite(filename3,posx_s,k,xlRange)
  
clear theta_pos theta_posx
end