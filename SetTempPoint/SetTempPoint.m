function CurrTempGoal = SetTempPoint_210813(MAP,TaskGroup,CurrentPointLocations,GoalPointLocations,TaskSetNum,PredStepNum,SignTaskComplete,EntrancePoints,ExitPoints)
%������Ԥ��Ĳ���������ʱ·�����ã�����ʵ�ּ���������·��������֮���ƽ��
%������Ŀ���֮��ľ��������У��Ծ������PredStepNum�����б����ѡ����ʱĿ��㣬
%����������Ե�������·��������������·���ĳ��ȳ���ԭ�������·������
%�޸�TaskGroup_TΪTaskGroup������Ӧ�µĳ����߼�
%��SignTaskComplete���TaskGroup.TempGoalNum
%������ʱĿ��㲻�������
%�����չ���δ�С�Ĺ��ܣ�����߹滮��ʱ�����óɹ���
%% �޸�bug
% ����ѡ����ں������Ϊ��ʱĿ��㣬����ѡ����ڵ�ԭ��Ϊ��ڲ�Ӧ��ռ�ã�����ѡ����ڵ�ԭ��Ϊ���ڽ���������뿪
% 210720��   ��������Ѱ����ʱ��ʧ��ʱ��չһ�εľ��߸�Ϊ���ŵ��ķ�������չ
%            ѡȡԭĿ���Ϊ��ʱĿ���ʱ���������κδ�ʩ�����Կ��ܳ��ֳ�ͻ�����ͬ�������������ͬ�Ĵ�ʩ
% 210813,   �ھ��ι滮ʧ�ܺ󣬲���A*�㷨�����к����滮����������ʱĿ��㵱���ϰ�������ٲ�����չ���εķ���

%% ����
% CurrTempGoal ��Ӧ�������ʱĿ���,һ��������һ����ʱĿ��㣬�����ּ𴰸������������������һ���Ƿּ𴰸�
CurrTempGoal = zeros(size(TaskSetNum,1),4);
LengthToDes = sum(abs(GoalPointLocations-CurrentPointLocations),2);
ExistingTempPoint = zeros(size(TaskSetNum,1),2); %��ѡ�����ʱ�滮Ŀ���
for i = 1:length(LengthToDes)
    ExtendValue = 0;
    Succ = 0;
    while Succ == 0
        Succ = 1;
        if LengthToDes(i) < PredStepNum
           %% ����Ŀ������С�ڹ滮�Ĳ�����������Ŀ��㶨Ϊ�м�㣬��ȥ�˶ξ��룬Ȼ���ڷּ𴰸�ͳ���֮��ѡ������ʵ�λ����Ϊ��ʱ�滮Ŀ���
            if SignTaskComplete(TaskSetNum(i)) == 1
                %��ʱ��Ŀ���Ƿּ𴰸���Ӧ�Էּ𴰸�Ϊ�м�㣬�Էּ𴰸������֮���ĳ����Ϊ��ʱ�滮Ŀ������Ϊ���趨�����ȥ���ڵ㵽�ּ𴰸�ľ���
                CurrTempGoal(i,1:2) = GoalPointLocations(i,:);
                In_StPt = GoalPointLocations(i,:);
                In_GlPt = TaskGroup.ExitPoints(TaskSetNum(i),:);%�����Ӧ����
                In_Dis = PredStepNum - LengthToDes(i); %��ȥһ���ľ���
                LenSoPaToExit = sum(abs(In_GlPt - In_StPt)); %�ּ𴰸񵽴�
                if In_Dis >= LenSoPaToExit
                    TempPoint = In_GlPt;
                else
                    [TempPoint,SelSucc] = SelectPointInRec_210726(MAP,In_StPt,In_GlPt,In_Dis,ExistingTempPoint,EntrancePoints,ExitPoints,ExtendValue);
                    if SelSucc == 0
                        %ѡ���ʧ�ܵ�����£�����A*���й滮
                        Map_Occup = ExistingTempPoint;
                        NumAGV = 1; %����DDM�ж��ܶȵĲ������ڴ˴�����
                        StartPoint = In_StPt;
                        EndPoint = In_GlPt;
                        SinglePath = SingleAGVpath(MAP,Map_Occup,NumAGV,StartPoint,EndPoint);
                        TempPoint = SinglePath(In_Dis+1,:);
                    end
                end
                CurrTempGoal(i,3:4) = TempPoint;
            else
                %��ʱ��Ŀ���ǳ��ڣ����Գ���Ϊ��ʱ�滮Ŀ���
                CurrTempGoal(i,1:2) = GoalPointLocations(i,:);
                TempPoint = GoalPointLocations(i,:);
            end
        elseif LengthToDes(i) == PredStepNum
            %% ����Ŀ��������ڹ滮�Ĳ����������ڵ�Ŀ�������Ϊ��ʱ�滮Ŀ���
            TempPoint = GoalPointLocations(i,:);
            CurrTempGoal(i,1:2) = GoalPointLocations(i,:);
            % ���Ѿ���ռ�ã������̾��������ʱĿ���滮��ͬ��һ�����
            Index_Temp = ismember(ExistingTempPoint,TempPoint,'row');
            if ~isempty(Index_Temp) && ~ismember(TempPoint,EntrancePoints,'row') && ~ismember(TempPoint,ExitPoints,'row')
                In_StPt = CurrentPointLocations(i,:);
                In_GlPt = GoalPointLocations(i,:);
                %In_Dis = PredStepNum - 1;
                In_Dis = PredStepNum; %�˴�Ӧ�ò���Ҫ��1
                [TempPoint,SelSucc] = SelectPointInRec_210726(MAP,In_StPt,In_GlPt,In_Dis,ExistingTempPoint,EntrancePoints,ExitPoints,ExtendValue);
                if SelSucc == 0
                        %ѡ���ʧ�ܵ�����£�����A*���й滮
                        Map_Occup = ExistingTempPoint;
                        NumAGV = 1; %����DDM�ж��ܶȵĲ������ڴ˴�����
                        StartPoint = In_StPt;
                        EndPoint = In_GlPt;
                        SinglePath = SingleAGVpath(MAP,Map_Occup,NumAGV,StartPoint,EndPoint);
                        TempPoint = SinglePath(In_Dis+1,:);
                end
                CurrTempGoal(i,1:2) = TempPoint; %��¼�����ֻ��һ��
            end
        else
            %% ����Ŀ��������ڹ滮�Ĳ������ڴ˴�Ŀ���֮ǰѡ����ʾ���ĵ���Ϊ��ʱ�滮Ŀ���
            In_StPt = CurrentPointLocations(i,:);
            In_GlPt = GoalPointLocations(i,:);
            In_Dis = PredStepNum;
            [TempPoint,SelSucc] = SelectPointInRec_210726(MAP,In_StPt,In_GlPt,In_Dis,ExistingTempPoint,EntrancePoints,ExitPoints,ExtendValue);
            
            if SelSucc == 0
                        %ѡ���ʧ�ܵ�����£�����A*���й滮
                        Map_Occup = ExistingTempPoint;
                        NumAGV = 1; %����DDM�ж��ܶȵĲ������ڴ˴�����
                        StartPoint = In_StPt;
                        EndPoint = In_GlPt;
                        SinglePath = SingleAGVpath(MAP,Map_Occup,NumAGV,StartPoint,EndPoint);
                        TempPoint = SinglePath(In_Dis+1,:);
             end
            CurrTempGoal(i,1:2) = TempPoint; %��¼�����ֻ��һ��
        end
        %����ѡ��TempPoint��¼��ExistingTempPoint�У�����ѡ���µ�TempPoint�ıȶ�
        ExistingTempPoint(i,:) = TempPoint;
    end
end

end

