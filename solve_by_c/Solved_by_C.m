function [RouteNow,CalTime_Sum,Sign_Succ,Path_Length_Set] = Solved_by_C(MAP,PredStepNum,Starts,Ends,ExpectedSteps)
% 将任务信息转换为线性坐标，并通过套接字传输给C语言程序求解
%   此处显示详细说明
%% 改进
% 220505 实现求解失败时（总距离未变近）增加预期步数再次求解
%% 参数
CalTime_Sum = 0;
%% 将起点和重点转换为线性坐标
% 此处，如果第二个目标点不存在，即（0,0），则转换得到的编号是负数，可在C++端进行判断
Starts4C = (Starts(:,1)-1)*size(MAP,2) + (Starts(:,2)-1);
Ends4C_1 = (Ends(:,1)-1)*size(MAP,2) + (Ends(:,2)-1);
Ends4C_2 = (Ends(:,3)-1)*size(MAP,2) + (Ends(:,4)-1);

% 初始距离

Distance_I = sum(abs(Ends(:,1:2) - Starts) + abs(Ends(:,3:4) - Ends(:,1:2)),2);

while 1
    %% 将数字转换为字符串
    % 输入任务数
    tasknumstr = num2str(length(Starts4C));
    buf = [tasknumstr ]; %任务数
    buf = [buf,',',num2str(PredStepNum)]; %此次规划距离
    for i = 1:length(Starts4C)
        buf = [buf,',',num2str(Starts4C(i))];
    end
    for i = 1:length(Ends4C_1)
        buf = [buf,',',num2str(Ends4C_1(i))];
    end
    for i = 1:length(Ends4C_2)
        buf = [buf,',',num2str(Ends4C_2(i))];
    end
    buf = [buf, ','];
    
    %% 发送给C++进程求解
    % 设置连接参数，要连接的地址为127.0.0.1(即本地主机)，端口号为5174，作为客户机连接。
    % 建立连接
    try
        Client = tcpclient("127.0.0.1",5174, 'Timeout', 100);
    catch
        Client = tcpclient("127.0.0.1",5174, 'Timeout', 100);
    end
    %发送求解
    write(Client,uint8(buf));
    %% 取得求解结果
    % 数据格式：
    % Sign_Succ;
    % CalTime;
    % path_length,path1;
    % path_length,path2;
    % ...
    data = read(Client);
    while isempty(data) || ~strcmp(char(data(end-2:end)),'end')
        data = [data read(Client)];
    end
    data = char(data);
    data = strsplit(data,';'); % 分割字符串
    Sign_Succ = str2num(data{1});
    CalTime = 0;
    path_length = 0;
    %% 返回数据
    CalTime = str2double(data{2});
    CalTime_Sum = CalTime_Sum + CalTime;
    RouteNow = zeros(1,2,length(Starts4C));
    Path_Length_Set = zeros(1,length(Starts4C));
    Distance_E_1 = zeros(length(Starts4C),1);
    if Sign_Succ
        for i = 1:length(Starts4C)
            path_str = strsplit(data{i+2},',');
            path_length = str2num(path_str{1});
            Path_Length_Set(i) = path_length;
            path_line = zeros(1,path_length);
            for j = 1:path_length
                path_line(j) = str2num(path_str{1+j});
            end
            % 转换为二维坐标表示,此处应该加1所对应的坐标增加值，然后再转换，最后反转横纵坐标
            path_line = path_line  + 1;%加1
            sz = size(MAP);
            [row,col] = ind2sub(fliplr(sz),path_line);%反坐标转换
            % 旋转
            row = row' ;
            col = col' ;
            RouteNow(1:path_length,1:2,i) = [col row];%反转横纵坐标
            
            %%  计算距离
            if PredStepNum+1 > path_length || sum(RouteNow(PredStepNum+1,1:2,i)) == 0
                % 路径全部规划||规划长度超过此路径长度
                Distance_E_1(i) = 0;
            elseif ismember(Ends(i,1:2),RouteNow(1:PredStepNum+1,1:2,i),'row')
                % 已访问分拣位置，只计算与出口的距离
                Distance_E_1(i) = sum(abs(Ends(i,3:4)-RouteNow(PredStepNum+1,1:2,i)));
            else
                % 未访问分拣位置,计算到分拣窗格位置以及分拣窗格到出口位置
                Distance_E_1(i) = sum(abs(Ends(i,1:2)-RouteNow(PredStepNum+1,1:2,i)) + ...
                    abs(Ends(i,3:4)-Ends(i,1:2)));
            end
        end
    else
        % 如果求解失败，则减少求解步数再次求解，但要求大于等于预期步数
        % 如果已经等于预期步数，则求解失败
        if PredStepNum == ExpectedSteps
            break;
        else
            PredStepNum = ceil(PredStepNum/2);
            PredStepNum = max(ExpectedSteps,PredStepNum);
            continue;
        end
    end
    Path_Length_Set = Path_Length_Set - 1; %所给出的路径长度是路径点数，需要减1
    % 判断路径是否缩短，如果未缩短，则增加预期步数，再次计算；如果缩短，则结束计算，返回结果
%     PredStepNum = PredStepNum + 1;
%     if sum(Distance_I > Distance_E_1)/length(Starts4C) > 0.5
%         break;
%     end
    break;
end
end