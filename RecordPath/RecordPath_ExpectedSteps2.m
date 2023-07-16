function [PathSet,SystemTime] = RecordPath_ExpectedSteps2(RouteNow,FinalTime,SystemTime,StepTime,ExpectedSteps,TaskGroup,TaskSetNum,SignTaskComplete,PathSet,CurrTempGoal)
%��¼����ExpectedSteps���趨������·��������ϵͳʱ��
%ɾ��TaskGroup_T,��Ϊ��TaskGroup�����ж��Ƿ��¼����·�������ж���¼ExpectedSteps���ȵ�·�������Ǽ�¼����·����

%�ж��Ƿ�ȫ����ʻ�����һ��·������ȫ��Ϊ���һ��·��������Ҫ����Ԥ�⣬ֱ�Ӽ�¼����·��
SignEnd = 1;
if any(SignTaskComplete == 0) %����δ������
    SignEnd = 0;
else
    CurrTempGoal_2 = zeros(size(CurrTempGoal,1),2); %��ȡ��ʱĿ�꣬�����ж��Ƿ�ͳ�����ͬ
    for i = 1:size(CurrTempGoal,1)
        if CurrTempGoal(i,3) == 0
            CurrTempGoal_2(i,:) = CurrTempGoal(i,1:2);
        else
            CurrTempGoal_2(i,:) = CurrTempGoal(i,3:4);
        end
    end
    if ~all(all(CurrTempGoal_2 == TaskGroup.ExitPoints(TaskSetNum,:),2)) %��ʱĿ���ͳ��ڲ�ȫ��ͬ����δ���
        SignEnd = 0;
    end
end
if (SignEnd == 1) || (FinalTime < ExpectedSteps)
    %������Ѿ��������һ��,��·������С�ڰ�Ԥ�����õĳ��ȣ�ֻ��Ҫֱ�Ӽ�¼����·�������谴��Ԥ��ʱ���¼
    for i = 1:length(TaskSetNum)
        PathSet{i}((end+1):(end+FinalTime),:) = RouteNow(2:FinalTime+1,:,i);
    end
    SystemTime = SystemTime + FinalTime*StepTime;
else %��ʱδ�������һ��������Ԥ��ʱ����м�¼
    for i = 1:length(TaskSetNum)
        PathSet{i}((end+1):(end+ExpectedSteps),:) = RouteNow(2:ExpectedSteps+1,:,i);
    end
    SystemTime = SystemTime + ExpectedSteps*StepTime;
end
end