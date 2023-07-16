%% 提取最优性数据
clear
clc
%%
%Filename = '.\CalTime_4_PBS_r_34_c_26_longtask.csv';
Filename = '.\CalTime_4_PBS_random-64-64-10_longtask.csv';
FidRead=fopen(Filename,'r');
Index_L = 0;
Data = zeros(6,1);
while ~feof(FidRead)
    Index_L = Index_L+1;
    str=fgetl(FidRead);
    S = regexp(str,',','split') ;
    for index_S = 1:length(S)
        if strcmp(S{index_S},'R ')
            Data(1,Index_L) = str2double(S{index_S+1});
        elseif strcmp(S{index_S},'C ')
            Data(2,Index_L) = str2double(S{index_S+1});
        elseif strcmp(S{index_S},'N ')
            Data(3,Index_L) = str2double(S{index_S+1});
        elseif strcmp(S{index_S},'D ')
            Data(4,Index_L) = str2double(S{index_S+1});
        elseif strcmp(S{index_S},'Rate ')
            Data(5,Index_L) = str2double(S{index_S+1});
        elseif strcmp(S{index_S},'T ')
            Data(6,Index_L) = str2double(S{index_S+1});
        end
    end
end
fclose(FidRead);
%%
Data_Save = [Data(3:4,:); Data(6,:)];

Attributes = Data_Save(1:end-1,:);
Strength = Data_Save(end,:);
%save PBS_CalTime_r_34_c_26
save PBS_CalTime_random-64-64-10