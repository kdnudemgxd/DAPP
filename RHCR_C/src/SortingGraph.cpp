#include "SortingGraph.h"
#include <fstream>
#include <boost/tokenizer.hpp>
#include "StateTimeAStar.h"
#include <sstream>
#include <random>
#include <chrono>

/// <summary>
/// 装载地图，提取地图中的节点类型（induct，eject，obstacle），并将eject对应存储到station的list中
/// </summary>
/// <param name="fname"></param>
/// <returns></returns>
bool SortingGrid::load_map(std::string fname)
{
    std::string line;
    std::ifstream myfile ((fname).c_str());
	if (!myfile.is_open())
    {
	    std::cout << "Map file " << fname << " does not exist. " << std::endl;
        return false;
    }
	
    std::cout << "*** Loading map ***" << std::endl;
    clock_t t = std::clock();
	std::size_t pos = fname.rfind('.');      // position of the file extension
    map_name = fname.substr(0, pos);     // get the name without extension
    getline (myfile, line); // skip the words "grid size"
	getline(myfile, line);
	boost::char_separator<char> sep(","); //指定逗号为分割符
	boost::tokenizer< boost::char_separator<char> > tok(line, sep); 
	boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
	this->rows = atoi((*beg).c_str()); // read number of cols
	beg++;
	this->cols = atoi((*beg).c_str()); // read number of rows
	move[0] = 1;
	move[1] = -cols;
	move[2] = -1;
	move[3] = cols;

	getline(myfile, line); // skip the headers

	//read tyeps, station ids and edge weights
	this->types.resize(rows * cols);
	this->weights.resize(rows * cols);
	for (int i = 0; i < rows * cols; i++)
	{
		getline(myfile, line);
		boost::tokenizer< boost::char_separator<char> > tok(line, sep);
		beg = tok.begin();
		beg++; // skip id
		this->types[i] = std::string(beg->c_str()); // read type
		beg++;
		if (types[i] == "Induct")
			this->inducts[beg->c_str()] = i; // read induct station id
		else if (types[i] == "Eject")
		{
			boost::unordered_map<std::string, std::list<int> >::iterator it = ejects.find(beg->c_str());
			if (it == ejects.end())//如果未找到与编号对应的station，则创建此station的list
			{
				this->ejects[beg->c_str()] = std::list<int>();
			}
			this->ejects[beg->c_str()].push_back(i); // read eject station id，将eject放入对应的station的list中
		}
		beg++;
		beg++; // skip x
		beg++; // skip y
		weights[i].resize(5);
		for (int j = 0; j < 5; j++) // read edge weights
		{
			if (std::string(beg->c_str()) == "inf")
				weights[i][j] = WEIGHT_MAX;
			else
				weights[i][j] = std::stod(beg->c_str());
			beg++;
		}
	}

	myfile.close();
    double runtime = (std::clock() - t) / CLOCKS_PER_SEC;
    std::cout << "Map size: " << rows << "x" << cols << " with " << inducts.size() << " induct stations and " <<
        ejects.size() << " eject stations." << std::endl;
    std::cout << "Done! (" << runtime << " s)" << std::endl;
    return true;
}


void SortingGrid::preprocessing(bool consider_rotation)
{
	std::cout << "*** PreProcessing map ***" << std::endl;
	clock_t t = std::clock();
	this->consider_rotation = consider_rotation;
	std::string fname;
	if (consider_rotation)
		fname = map_name + "_rotation_heuristics_table.txt";
	else
		fname = map_name + "_heuristics_table.txt";
	std::ifstream myfile(fname.c_str());
	bool succ = false;
	if (myfile.is_open())
	{
		succ = load_heuristics_table(myfile);
		myfile.close();
		// ensure that the heuristic table is correct
		// 由于更改了程序启发值的生成，可能生成所有节点的启发表，所以取消此处的启发表检测
		//for (auto h : heuristics)
		//{
		//	if (types[h.first] != "Induct" && types[h.first] != "Eject")//启发表中的Induct和Eject是什么
		//	{
		//		cout << "The heuristic table does not match the map!" << endl;
		//		exit(-1);
		//	}
		//}
	}
	if (!succ)//如果提取启发表不成功，则重新计算启发表，启发表只针对装载点和分拣窗格？
	{
		//初始程序只计算装载点和分拣窗格
		/*for (auto induct : inducts)
		{
			heuristics[induct.second] = compute_heuristics(induct.second);
		}
		for (auto eject_station : ejects)
		{
			for (int eject : eject_station.second)
			{
				heuristics[eject] = compute_heuristics(eject);
			}
		}*/
		//修改启发表计算所有节点的启发值，而不是只针对装载点和分拣窗格
		for (size_t i = 0; i < rows * cols; i++)
		{
			heuristics[i] = compute_heuristics(i);
		}
		save_heuristics_table(fname);
	}

	double runtime = (std::clock() - t) / CLOCKS_PER_SEC;
	std::cout << "Done! (" << runtime << " s)" << std::endl;
}
