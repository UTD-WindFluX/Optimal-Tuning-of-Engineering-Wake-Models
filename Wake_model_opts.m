clear;close all;clc
% Compare different analytical models 
addpath ./Custom_functions;
%% Input

XN_YN = 'WS13_TI5';
pathdata = './Data/';%'/Users/billysatriani/Desktop/Amarillo/2019/021819_PaperfigIT';
%% Initialization

if ~exist('Trymat','var')
    Trymat = load([pathdata,'/24-Oct-2018_X_WS13_Y_TI5_alpha20_Weight0.8_Xnml_nonsym_Veer_0.4_v2_Ct3_v4.mat']);
end

Trymat.Ux_filled{3,1}=[];
Trymat.Ux_filled{5,1}=[];
Trymat.Ux_filled{2,7}=[];
Trymat.Ux_filled{4,8}=[];
Trymat.Ux_filled{2,9}=[];
Trymat.Ux_filled{4,9}=[];

Xm = Trymat.Xm;
Rm = Trymat.Rm;

%%

tic
for ID_X = 5
    for ID_Y =3
        if ~isempty(Trymat.Ux_filled{ID_Y,ID_X})
            disp([': ID_Y: ',num2str(ID_Y),', ID_X: ',num2str(ID_X)]);
            
            % Provide the velocity field from LiDAR for optimization
            U_field = Trymat.Ux_filled{ID_Y,ID_X};
            
            % Jensen model optimization
            k_Jen_vec = 0.001:0.001:0.3;
            Ct_Jen_vec = 0.01:.01:1;
            [Jen]= Jensen_model_opt(U_field, Xm, Rm, Ct_Jen_vec,k_Jen_vec);
            
            % Bastankhah model
            Ct_Bas_vec = 0.4:.01:0.5;%1.71;
            k_Bas_vec = 0.001:0.001:0.1%0.3;
            eps_Bas_vec = 0.2:0.01:0.5;
            [Bast]= Bastankhah_model_opt(U_field, Xm, Rm, Ct_Bas_vec,k_Bas_vec,eps_Bas_vec);
            
            % Larsen model
            Ct_Las_vec = 0.4:.01:1.5;
            c1_Las_vec = 0.01:0.002:0.25;
            x0_Las_vec = 0.01:0.05:3.01;
            [Lars]= Larsen_model_opt(U_field, Xm, Rm, Ct_Las_vec,c1_Las_vec,x0_Las_vec);
            
            % Ainslie model 
            km_Ans_vec = 0.00001:0.002:0.05001;
            kl_Ans_vec = 0.00001:0.002:0.04001; 
            [Ains]= Ainslie_model_opt(U_field, Xm, Rm, km_Ans_vec,kl_Ans_vec);                
            
        end
    end
end
toc

%% Plot the Wake 
close all
figmk(.7,0.6);
subplot(2,3,1)
pcolor(Xm,Rm, U_field);shading flat;axis equal;axis tight;caxis([0.3,1]);c=colorbar;c.Label.String = 'U';
axis([ 0 7 -1.5 1.5]);xlabel('x/D');ylabel('r/D');title('LiDAR')

subplot(2,3,2)
pcolor(Xm,Rm, Jen.Jen_Umopt);shading flat;axis equal;axis tight;caxis([0.3,1]);c=colorbar;c.Label.String = 'U';
axis([ 0 7 -1.5 1.5]);xlabel('x/D');ylabel('r/D');title('Jensen')

subplot(2,3,3)
pcolor(Xm,Rm, Bast.BP_Umopt);shading flat;axis equal;axis tight;caxis([0.3,1]);c=colorbar;c.Label.String = 'U';
axis([-1.5 1.5 0 7]);xlabel('x/D');ylabel('r/D');title('Bastankhhah')

subplot(2,3,5)
pcolor(Xm,Rm, Lars.LS_opt);shading flat;axis equal;axis tight;caxis([0.3,1]);c=colorbar;c.Label.String = 'U';
axis([ 0 7 -1.5 1.5]);xlabel('x/D');ylabel('r/D');title('Larsen')

subplot(2,3,6)
pcolor(Xm,Rm, Ains.AS_opt);shading flat;axis equal;axis tight;caxis([0.3,1]);c=colorbar;c.Label.String = 'U';
axis([ 0 7 -1.5 1.5]);xlabel('x/D');ylabel('r/D');title('Ainslie');
