#include "SortingSystem.h"
#include <stdlib.h>
#include "PBS.h"
#include <boost/tokenizer.hpp>
#include "WHCAStar.h"
#include "ECBS.h"
#include "LRAStar.h"
#include <time.h>

//套接字通信文件
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <WinSock2.h>
#pragma comment(lib,"Ws2_32.lib")
#include <memory.h>

#define BUF_SIZE 40960
#define QUEUE_SIZE 5


SortingSystem::SortingSystem(const SortingGrid& G, MAPFSolver& solver): BasicSystem(G, solver), c(8), G(G) {}


SortingSystem::~SortingSystem() {}


void SortingSystem::initialize_start_locations()
{
    int N = G.size();
    std::vector<bool> used(N, false); //表示位置是否被占用

    // Choose random start locations
    // Any non-obstacle locations can be start locations
    // Start locations should be unique
	for (int k = 0; k < num_of_drives;)
	{
		int loc = rand() % N;
		if (G.types[loc] != "Obstacle" && !used[loc])
		{
			int orientation = -1;//方向为-1应该是不考虑旋转
			if (consider_rotation)
			{
				orientation = rand() % 4;
			}
			starts[k] = State(loc, 0, orientation);
			paths[k].emplace_back(starts[k]);
			used[loc] = true;
			finished_tasks[k].emplace_back(loc, 0);//已完成任务到底记载什么，
			k++;
		}
	}
}


void SortingSystem::initialize_goal_locations()
{
	if (hold_endpoints || useDummyPaths)
		return;
    // Choose random goal locations
    // a close induct location can be a goal location, or
    // any eject locations can be goal locations
    // Goal locations are not necessarily unique
    for (int k = 0; k < num_of_drives; k++)
    {
		int goal;
		if (k % 2 == 0) // to induction，一半去装载点，一半去分拣处？
		{
			goal = assign_induct_station(starts[k].location);
			drives_in_induct_stations[goal]++;//此处加1说明第二个数值应该是驶向该装载口的车辆数目
		}
		else // to ejection
		{
			goal = assign_eject_station();//产生随机的目标点
		}
		goal_locations[k].emplace_back(goal, 0);
    }
}

//为已到达目的地的车辆设置新的目标
void SortingSystem::update_goal_locations()
{
	for (int k = 0; k < num_of_drives; k++)
	{
		pair<int, int> curr(paths[k][timestep].location, timestep); // current location

		pair<int, int> goal; // The last goal location
		if (goal_locations[k].empty())
		{
			goal = curr;//如果目标为空，则停在原地
		}
		else
		{
			goal = goal_locations[k].back();
		}
		int min_timesteps = G.get_Manhattan_distance(curr.first, goal.first); // cannot use h values, because graph edges may have weights  // G.heuristics.at(goal)[curr];
		min_timesteps = max(min_timesteps, goal.second);
		while (min_timesteps <= simulation_window)
			// The agent might finish its tasks during the next planning horizon
		{
			// assign a new task
			int next;
			if (G.types[goal.first] == "Induct")
			{
				next = assign_eject_station();
			}
			else if (G.types[goal.first] == "Eject")
			{
				next = assign_induct_station(curr.first);
				drives_in_induct_stations[next]++; // the drive will go to the next induct station
			}
			else
			{
				std::cout << "ERROR in update_goal_function()" << std::endl;
				std::cout << "The fiducial type should not be " << G.types[curr.first] << std::endl;
				exit(-1);
			}
			goal_locations[k].emplace_back(next, 0); //目标点时间设置为0的意思是？
			min_timesteps += G.get_Manhattan_distance(next, goal.first); // G.heuristics.at(next)[goal];
			min_timesteps = max(min_timesteps, goal.second);
			goal = make_pair(next, 0);
		}
	}
}

//选择依照启发值最小的装载点
int SortingSystem::assign_induct_station(int curr) const
{
    int assigned_loc;
	double min_cost = DBL_MAX;
	for (auto induct : drives_in_induct_stations)
	{
		double cost = G.heuristics.at(induct.first)[curr] + c * induct.second;//此处代价的后半部分是什么意思：前半部分是启发值，后半部分是将驶往该装载口的车辆数作为评估加入装载口的选取
		if (cost < min_cost)
		{
			min_cost = cost;
			assigned_loc = induct.first;
		}
	}
    return assigned_loc;
}

/// <summary>
/// 随机选取一个分拣窗格所相邻的随机位置作为目标
/// </summary>
/// <returns></returns>
int SortingSystem::assign_eject_station() const
{
	int n = rand() % G.ejects.size();
	boost::unordered_map<std::string, std::list<int> >::const_iterator it = G.ejects.begin();
	std::advance(it, n);//前进n个位置的意思是随机挑选出口，因为map无法随机访问，所以采用advance，逐步访问
	int p = rand() % it->second.size();
	auto it2 = it->second.begin();//随机得到一个相邻的停车点
	std::advance(it2, p);//前进n个位置，list可以随机访问，此处应该是通过下标访问
	return *it2;//最终返回应该是一个可以到达的点（位于分拣窗格四周）
}

//void SortingSystem::simulate(int simulation_time)
//{
//    std::cout << "*** Simulating " << seed << " ***" << std::endl;
//    this->simulation_time = simulation_time;
//    initialize();
//	
//	for (; timestep < simulation_time; timestep += simulation_window)
//	{
//		std::cout << "Timestep " << timestep << std::endl;
//
//		update_start_locations();
//		update_goal_locations();
//		solve();
//
//		// move drives
//		auto new_finished_tasks = move();
//		std::cout << new_finished_tasks.size() << " tasks has been finished" << std::endl;
//
//		// update tasks
//		for (auto task : new_finished_tasks)
//		{
//			int id, loc, t;
//			std::tie(id, loc, t) = task;
//			finished_tasks[id].emplace_back(loc, t);
//			num_of_tasks++;
//			if (G.types[loc] == "Induct")
//			{
//				drives_in_induct_stations[loc]--; // the drive will leave the current induct station
//			}
//		}
//		
//		
//
//		if (congested())
//		{
//			cout << "***** Too many traffic jams ***" << endl;
//			break;
//		}
//	}
//
//    update_start_locations();
//    std::cout << std::endl << "Done!" << std::endl;
//    save_results();
//}

/// <summary>
/// 修改版本，实现在套接字中提取MATLAB发出的数据，求解后返回至套接字中
/// </summary>
/// <param name="simulation_time"></param>
void SortingSystem::simulate(int simulation_time)
{
	//初始化套接字
	// 初始化windows sockets服务，使用2.0版本
	WSADATA wsd;
	WSAStartup(MAKEWORD(2, 0), &wsd);
	// 建立TCP套接口，使用5174端口，绑定本地地址
	SOCKET s = NULL;
	s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	struct sockaddr_in ch;
	memset(&ch, 0, sizeof(ch));
	ch.sin_family = AF_INET;
	ch.sin_addr.s_addr = INADDR_ANY;
	ch.sin_port = htons(5174);
	int b = bind(s, (struct sockaddr*)&ch, sizeof(ch));
	// 开始监听，队列中最多有QUEQE_Size=5个等待
	int l = listen(s, QUEUE_SIZE);
	printf("正在监听本机的5174端口\n");

	std::cout << "*** Simulating " << seed << " ***" << std::endl;
	this->simulation_time = simulation_time;

	while (true)
	{
		
		// 接收等待队列中第一个客户机请求，建立连接
		SOCKET* psc = (SOCKET*)malloc(sizeof(SOCKET));
		*psc = accept(s, 0, 0);
		printf("一个客户端已经连接到本机的5174端口,SOCKET是 : %u \n", *psc);
			
		// 建立新的套接字处理数据
		int receByt = 0;
		char buf[BUF_SIZE];	//注意BUF_SIZE可能不够用
		while (1)
		{
			// 读取客户机发送来的消息，读不到数据就一直等待，连接中断返回0，发生错误返回-1
			receByt = recv(*psc, buf, BUF_SIZE, 0);
			//buf[receByt] = '\0';
			if (receByt != 0)
			{
				printf("接收消息结束！\n");
				break;
			}
		}   
		//提取任务数据
		string buf_str(buf);
		boost::char_separator<char> sep(","); //指定逗号为分割符
		boost::tokenizer< boost::char_separator<char> > tok(buf_str, sep);
		boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
		this->num_of_drives = atoi((*beg).c_str()); // 读取任务数
		beg++;
		//注意simulation_window,在理论上simulation_window<=planning_window,
		//未修改simulation_window，不知道在实际中是否有影响
		this->planning_window = atoi((*beg).c_str()); // 读取解冲突窗口长度
		
		
		//读取任务信息
		initialize_matlab(tok);
		
		//求解并返回

		//进行求解
		clock_t startTime, endTime;
		startTime = clock();
		bool sol = solve();
		////判断拥堵,如果拥堵，则计算失败
		//if (congested())
		//{
		//	cout << "***** Too many traffic jams ***" << endl;
		//	sol = false;
		//}
		endTime = clock();
		double caltime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		//提取求解结果，并返回至套接字缓冲区中
		int k = 0;
		buf[0] = sol?'1':'0';
		buf[1] = ';';
		k = k + 2;
		auto caltime_str = std::to_string(caltime);
		for (size_t i = 0; i < caltime_str.size(); i++)
		{
			buf[k] = caltime_str[i];
			k++;
		}
		buf[k] = ';';
		k ++;
		
		for (size_t i = 0; i < paths.size(); i++)
		{
			//路径长度
			auto path_length = paths[i].size();
			auto path_length_str = std::to_string(path_length);
			for (size_t i = 0; i < path_length_str.size(); i++)
			{
				buf[k] = path_length_str[i];
				k++;
			}
			buf[k] = ',';
			k++;
			for (size_t j = 0; j < paths[i].size(); j++)
			{
				auto path_point = std::to_string(paths[i][j].location);
				for (size_t l = 0; l < path_point.size(); l++)
				{
					buf[k] = path_point[l];
					k++;
				}

				if (j == path_length - 1)
				{
					buf[k] = ';';
					k++;
				}
				else
				{
					buf[k] = ',';
					k++;
				}
				
				if (k > BUF_SIZE - 100)
				{
					send(*psc, buf, k , 0);
					k = 0;
				}
			}
			
		}

		send(*psc, buf, k , 0);
		char end_str[] = "end";
		send(*psc, end_str, 3, 0);
		//关闭套接字，释放空间
		int ic = closesocket(*psc);
		free(psc);
		//清除路径
		update_initial_paths(paths);
	}

	// 关闭套接字接口和服务
	int is = closesocket(s);
	WSACleanup();
	return ;



	for (; timestep < simulation_time; timestep += simulation_window)
	{
		std::cout << "Timestep " << timestep << std::endl;

		update_start_locations();
		update_goal_locations();
		solve();

		// move drives
		auto new_finished_tasks = move();
		std::cout << new_finished_tasks.size() << " tasks has been finished" << std::endl;

		// update tasks
		for (auto task : new_finished_tasks)
		{
			int id, loc, t;
			std::tie(id, loc, t) = task;
			finished_tasks[id].emplace_back(loc, t);
			num_of_tasks++;
			if (G.types[loc] == "Induct")
			{
				drives_in_induct_stations[loc]--; // the drive will leave the current induct station
			}
		}



		if (congested())
		{
			cout << "***** Too many traffic jams ***" << endl;
			break;
		}
	}

	update_start_locations();
	std::cout << std::endl << "Done!" << std::endl;
	save_results();
}

/// <summary>
/// 初始化求解器
/// 装载以前的记录（路径等信息）和位置
/// 如果不存在，则重新生成新的任务目标信息
/// 对drives_in_induct_stations进行计数，但存在重复计数的情况
/// </summary>
void SortingSystem::initialize()
{
	initialize_solvers();

	starts.resize(num_of_drives);//初始化起点数
	goal_locations.resize(num_of_drives);//初始化终点数
	paths.resize(num_of_drives);//初始化路径数
	finished_tasks.resize(num_of_drives);//已完成任务记录

	for (const auto induct : G.inducts)
	{
		drives_in_induct_stations[induct.second] = 0;
	}

	bool succ = load_records(); // continue simulating from the records
	if (!succ)
	{
		timestep = 0;
		succ = load_locations();
		if (!succ)
		{	//每一个任务均有一个装载点和一个目标点，先装载，然后分拣
			cout << "Randomly generating initial locations" << endl;
			initialize_start_locations();//分配起始位置，
			initialize_goal_locations();//然后分配装载点和分拣点
		}
	}

	// initialize induct station counter
	for (int k = 0; k < num_of_drives; k++)
	{
		// goals
		int goal = goal_locations[k].back().first;
		if (G.types[goal] == "Induct")
		{
			//在前文initialize_goal_locations()处已经加过，此处再次加的意义？
			//难道是load_records中没加，此处阶梯load_records，但忽略了initialize_goal_locations
			//可使用以下语句验证：auto a = drives_in_induct_stations[goal];
			drives_in_induct_stations[goal]++;
		}
		else if (G.types[goal] != "Eject")
		{
			std::cout << "ERROR in the type of goal locations" << std::endl;
			std::cout << "The fiducial type of the goal of agent " << k << " is " << G.types[goal] << std::endl;
			exit(-1);
		}
	}
}

//matlab交接版本

/// <summary>
/// 为MATLAB调用所做的初始化
/// 主要对任务数和任务的起终点进行初始化
/// </summary>
void SortingSystem::initialize_matlab(boost::tokenizer< boost::char_separator<char> > tok)
{
	initialize_solvers();

	starts.resize(num_of_drives);//初始化起点数
	goal_locations.resize(num_of_drives);//初始化终点数
	paths.resize(num_of_drives);//初始化路径数
	finished_tasks.resize(num_of_drives);//已完成任务记录

	for (const auto induct : G.inducts)
	{
		drives_in_induct_stations[induct.second] = 0;
	}

	initialize_start_locations_matlab(tok);//分配起始位置，
	initialize_goal_locations_matlab(tok);//然后分配装载点和分拣点

	// initialize induct station counter
	for (int k = 0; k < num_of_drives; k++)
	{
		// goals
		int goal = goal_locations[k].back().first;
		if (G.types[goal] == "Induct")
		{
			//在前文initialize_goal_locations()处已经加过，此处再次加的意义？
			//难道是load_records中没加，此处阶梯load_records，但忽略了initialize_goal_locations
			//可使用以下语句验证：auto a = drives_in_induct_stations[goal];
			drives_in_induct_stations[goal]++;
		}
		else if (G.types[goal] != "Eject")
		{
			//MATLAB中的任务随机生成，可能目标点不是入口或分拣窗格，所以取消对出口的检测
			/*std::cout << "ERROR in the type of goal locations" << std::endl;
			std::cout << "The fiducial type of the goal of agent " << k << " is " << G.types[goal] << std::endl;
			exit(-1);*/
		}
	}
}

/// <summary>
/// 为套接字传输过来的任务设置起点
/// </summary>
void SortingSystem::initialize_start_locations_matlab(boost::tokenizer< boost::char_separator<char> > tok)
{
	int N = G.size();
	std::vector<bool> used(N, false); //表示位置是否被占用

	// Choose random start locations
	// Any non-obstacle locations can be start locations
	// Start locations should be unique
	boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
	
	this->num_of_drives = atoi((*beg).c_str()); // 读取任务数
	beg++; //任务数已经读取，跨过第一个数
	beg++; //跨过解冲突窗口
	for (int k = 0; k < num_of_drives;)
	{
		auto test_1 = *beg; //测试迭代器
		int loc = atoi((*beg).c_str());//从中读取任务起点数据
		if (G.types[loc] != "Obstacle" && !used[loc])
		{
			int orientation = -1;//方向为-1应该是不考虑旋转
			if (consider_rotation)
			{
				orientation = rand() % 4;
			}
			starts[k] = State(loc, 0, orientation);
			paths[k].emplace_back(starts[k]);
			used[loc] = true;
			finished_tasks[k].emplace_back(loc, 0);//已完成任务到底记载什么，
			k++;
		}
		beg++;
	}
}


void SortingSystem::initialize_goal_locations_matlab(boost::tokenizer< boost::char_separator<char> > tok)
{
	//暂时注释，防止无终点
	if (hold_endpoints || useDummyPaths)
		return;
	// Choose random goal locations
	// a close induct location can be a goal location, or
	// any eject locations can be goal locations
	// Goal locations are not necessarily unique
	boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
	advance(beg, num_of_drives + 2); //将迭代器向前推进num_of_drives+2距离，到达目标点的设置处
	for (int k = 0; k < num_of_drives; k++)
	{
		//清除旧任务点
		goal_locations[k].clear();
	}
	for (int k = 0; k < num_of_drives; k++)
	{
		//中间点
		int goal = atoi((*beg).c_str());//从中读取任务终点数据;
		beg++;
		goal_locations[k].emplace_back(goal, 0);
	}
	for (int k = 0; k < num_of_drives; k++)
	{
		//出口
		int goal = atoi((*beg).c_str());//从中读取任务终点数据;
		beg++;
		if (goal >= 0)
		{
			//小于0时，此时不存在第二个目标点，不需要添加目标点
			goal_locations[k].emplace_back(goal, 0);
		}
		
	}
}