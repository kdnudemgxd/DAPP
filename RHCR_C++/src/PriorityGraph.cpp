#include "PriorityGraph.h"
#include <boost/graph/copy.hpp>


void PriorityGraph::clear()
{
    G.clear();
}

void PriorityGraph::copy(const PriorityGraph& other)
{
    this->G = other.G;
}

void PriorityGraph::copy(const PriorityGraph& other, const vector<bool>& excluded_nodes)
{
    for (auto row : other.G)
    {
        if (excluded_nodes[row.first])
            continue;
        for (auto i : row.second)
        {
            if (excluded_nodes[i])
                continue;
            this->G[row.first].insert(i);
        }
    }
}

void PriorityGraph::add(int from, int to) // from is lower than to
{
    G[from].insert(to);
}

void PriorityGraph::remove(int from, int to) // from is lower than to
{
    if (G.find(from) != G.end())
    {
        G[from].erase(to);
    }
}
//用来判断在优先级序列中是否存在从from到to的优先级关系？
bool PriorityGraph::connected(int from, int to) const
{
    std::list<int> open_list;
    boost::unordered_set<int> closed_list;

    open_list.push_back(from);
    closed_list.insert(from);
    while (!open_list.empty())//while应该是为了确定间接的优先级关系，即两个没有直接联系的优先级
    {
        int curr = open_list.back();
        open_list.pop_back();
        auto neighbors = G.find(curr);
        if (neighbors == G.end())
            continue;
        for (auto next : neighbors->second)//说明一个from可能对应多个to的优先级关系
        {
            //G为无序map，元素为pair，所以neighbors指向pair，此pair第二个元素是无序set，只存储了int数据
            /*auto a = * neighbors;
            auto e = a.first;
            auto b = a.second;
            auto f = G.size();
            auto c = b.begin();
            auto d = *c;*/
            if (next == to)
                return true;
            if (closed_list.find(next) == closed_list.end())
            {
                open_list.push_back(next);
                closed_list.insert(next);
            }
        }
    }
    return false;
}

/// <summary>
/// 找出优先级图中，所有优先级高于指定agv的其他agv集合
/// </summary>
/// <param name="root"></param>
/// <returns></returns>
boost::unordered_set<int> PriorityGraph::get_reachable_nodes(int root)
{
    clock_t t = std::clock();
    std::list<int> open_list;
    boost::unordered_set<int> closed_list;

    open_list.push_back(root);
    while (!open_list.empty())
    {
        int curr = open_list.back();
        open_list.pop_back();
        auto neighbors = G.find(curr);
        if (neighbors == G.end())
            continue;
        for (auto next : neighbors->second)
        {
            if (closed_list.find(next) == closed_list.end())
            {
                open_list.push_back(next);
                closed_list.insert(next);
            }
        }
    }
    runtime = (std::clock() - t) * 1.0 / CLOCKS_PER_SEC;
    return closed_list;
}


void PriorityGraph::save_as_digraph(std::string fname) const
{
    std::ofstream output;
    output.open(fname, std::ios::out);
    output << "digraph G {" << std::endl;
    output << "size = \"5,5\";" << std::endl;
    output << "center = true;" << std::endl;
    output << "orientation = landscape" << std::endl;
    for (auto row : G)
    {
        for (auto i : row.second)
        {
            output << row.first << " -> " << i << std::endl;
        }
    }
    output << "}" << std::endl;
    output.close();
}


void PriorityGraph::update_number_of_lower_nodes(vector<int>& lower_nodes, int node) const
{
    if (lower_nodes[node] >= 0)
        return;

    lower_nodes[node] = 0;
    std::list<int> open_list;
    boost::unordered_set<int> closed_list;

    open_list.push_back(node);
    while (!open_list.empty())
    {
        int curr = open_list.back();
        open_list.pop_back();
        for (auto row : G)
        {
            if (row.second.find(curr) == row.second.end())
                continue;
            int next = row.first;
            if (closed_list.find(next) == closed_list.end())
            {
                if (lower_nodes[next] < 0)
                    open_list.push_back(next);
                else
                    lower_nodes[node] += lower_nodes[next];
                closed_list.insert(next);
            }

        }
    }
    lower_nodes[node] += closed_list.size();
    return;
}