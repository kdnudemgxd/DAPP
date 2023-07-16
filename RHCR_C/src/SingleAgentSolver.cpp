#include "SingleAgentSolver.h"


double SingleAgentSolver::compute_h_value(const BasicGraph& G, int curr, int goal_id,
                             const vector<pair<int, int> >& goal_location) const
{
    double h = G.heuristics.at(goal_location[goal_id].first)[curr];
    goal_id++;
    while (goal_id < (int) goal_location.size())
    {
        //此段程序用于测试启发值提取错误的bug，最后验证是原程序未计算所有位置启发值所导致
        /*int a = goal_location[goal_id].first;
        int b = goal_location[goal_id - 1].first;
        auto c = G.heuristics.at(a);
        int d = c[b];*/
        h += G.heuristics.at(goal_location[goal_id].first)[goal_location[goal_id - 1].first];
        goal_id++;
    }
    return h;
}
