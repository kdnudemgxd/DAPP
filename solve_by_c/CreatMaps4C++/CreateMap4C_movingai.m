%% 将地图转换为文本文件，用于C++程序
clear all
%% 生成地图
%分拣窗格行列数
% Row = 8;
% Column = 5;
% [MAP,Entrances,Exits,SortingPanes] = CreateExperimentMAP(Row,Column);
% Obstacle=-1, Target = 0, Robot=1, Space=2, Subgraph = 3
map_file = 'F:\MATLAB_File\PrePBS-DDM-RHCR\PrePBS\MovingAI\random-64-64-10\random-64-64-10.mat';
load(map_file);
%% 转换为文本文件,直接使用
%file_name = sprintf('sorting_map_r_%d_c_%d.txt',size(MAP,1),size(MAP,2));
MAP = mapMatrix;
file_name = sprintf('random-64-64-10.txt');
fp = fopen(file_name,'w');
fprintf(fp,'Grid size (x, y)\n');
fprintf(fp,'%d,%d\n',size(MAP,1),size(MAP,2));
fprintf(fp,'id,type,station,x,y,weight_to_NORTH,weight_to_WEST,weight_to_SOUTH,weight_to_EAST,weight_for_WAIT\n');
num_induct = 1000; %装载口编号
for i = 1:size(MAP,1)
    for j = 1:size(MAP,2)
        %% 编号
        num = (i-1)*size(MAP,2)+(j-1);
        fprintf(fp,'%d,',num);
        %% 节点类型
        %[Exist,num_SortingPanes] = ExistinSortingPanes(SortingPanes,i,j);
        string type_node;
        if MAP(i,j) == -1
            type_node = 'Obstacle';
            num_type_node_str = 'None';
%         elseif any(all([i,j] == Entrances,2)) || any(all([i,j] == Exits,2))
%             %暂时将所有出口和入口均设置为装载点，后续修改
%             type_node = 'Induct';
%             num_induct = num_induct+1;
%             num_type_node_str = sprintf('%d',num_induct);
%         elseif Exist
%             type_node = 'Eject';
%             num_eject = num_SortingPanes+10000; 
%             num_type_node_str = sprintf('%d',num_eject);
        elseif MAP(i,j) == 2
            type_node = 'Travel';
            num_type_node_str = 'None'; 
        end
        fprintf(fp,type_node);
        fprintf(fp,',');
        fprintf(fp,num_type_node_str);
        fprintf(fp,',');
        %% 坐标
         Coordinate = sprintf('%d,%d',i-1,j-1);
         fprintf(fp,Coordinate);
        %% 代价
        cost = compute_cost(MAP,i,j);
        for k = 1:length(cost)
            if cost(k) == -1
                str_k = ',inf';
            else
                str_k = ',1';
            end
            fprintf(fp,str_k);
        end
        fprintf(fp,'\n');
    end
end
fclose(fp);