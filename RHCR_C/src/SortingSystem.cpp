#include "SortingSystem.h"
#include <stdlib.h>
#include "PBS.h"
#include <boost/tokenizer.hpp>
#include "WHCAStar.h"
#include "ECBS.h"
#include "LRAStar.h"
#include <time.h>

//�׽���ͨ���ļ�
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
    std::vector<bool> used(N, false); //��ʾλ���Ƿ�ռ��

    // Choose random start locations
    // Any non-obstacle locations can be start locations
    // Start locations should be unique
	for (int k = 0; k < num_of_drives;)
	{
		int loc = rand() % N;
		if (G.types[loc] != "Obstacle" && !used[loc])
		{
			int orientation = -1;//����Ϊ-1Ӧ���ǲ�������ת
			if (consider_rotation)
			{
				orientation = rand() % 4;
			}
			starts[k] = State(loc, 0, orientation);
			paths[k].emplace_back(starts[k]);
			used[loc] = true;
			finished_tasks[k].emplace_back(loc, 0);//��������񵽵׼���ʲô��
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
		if (k % 2 == 0) // to induction��һ��ȥװ�ص㣬һ��ȥ�ּ𴦣�
		{
			goal = assign_induct_station(starts[k].location);
			drives_in_induct_stations[goal]++;//�˴���1˵���ڶ�����ֵӦ����ʻ���װ�ؿڵĳ�����Ŀ
		}
		else // to ejection
		{
			goal = assign_eject_station();//���������Ŀ���
		}
		goal_locations[k].emplace_back(goal, 0);
    }
}

//Ϊ�ѵ���Ŀ�ĵصĳ��������µ�Ŀ��
void SortingSystem::update_goal_locations()
{
	for (int k = 0; k < num_of_drives; k++)
	{
		pair<int, int> curr(paths[k][timestep].location, timestep); // current location

		pair<int, int> goal; // The last goal location
		if (goal_locations[k].empty())
		{
			goal = curr;//���Ŀ��Ϊ�գ���ͣ��ԭ��
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
			goal_locations[k].emplace_back(next, 0); //Ŀ���ʱ������Ϊ0����˼�ǣ�
			min_timesteps += G.get_Manhattan_distance(next, goal.first); // G.heuristics.at(next)[goal];
			min_timesteps = max(min_timesteps, goal.second);
			goal = make_pair(next, 0);
		}
	}
}

//ѡ����������ֵ��С��װ�ص�
int SortingSystem::assign_induct_station(int curr) const
{
    int assigned_loc;
	double min_cost = DBL_MAX;
	for (auto induct : drives_in_induct_stations)
	{
		double cost = G.heuristics.at(induct.first)[curr] + c * induct.second;//�˴����۵ĺ�벿����ʲô��˼��ǰ�벿��������ֵ����벿���ǽ�ʻ����װ�ؿڵĳ�������Ϊ��������װ�ؿڵ�ѡȡ
		if (cost < min_cost)
		{
			min_cost = cost;
			assigned_loc = induct.first;
		}
	}
    return assigned_loc;
}

/// <summary>
/// ���ѡȡһ���ּ𴰸������ڵ����λ����ΪĿ��
/// </summary>
/// <returns></returns>
int SortingSystem::assign_eject_station() const
{
	int n = rand() % G.ejects.size();
	boost::unordered_map<std::string, std::list<int> >::const_iterator it = G.ejects.begin();
	std::advance(it, n);//ǰ��n��λ�õ���˼�������ѡ���ڣ���Ϊmap�޷�������ʣ����Բ���advance���𲽷���
	int p = rand() % it->second.size();
	auto it2 = it->second.begin();//����õ�һ�����ڵ�ͣ����
	std::advance(it2, p);//ǰ��n��λ�ã�list����������ʣ��˴�Ӧ����ͨ���±����
	return *it2;//���շ���Ӧ����һ�����Ե���ĵ㣨λ�ڷּ𴰸����ܣ�
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
/// �޸İ汾��ʵ�����׽�������ȡMATLAB���������ݣ����󷵻����׽�����
/// </summary>
/// <param name="simulation_time"></param>
void SortingSystem::simulate(int simulation_time)
{
	//��ʼ���׽���
	// ��ʼ��windows sockets����ʹ��2.0�汾
	WSADATA wsd;
	WSAStartup(MAKEWORD(2, 0), &wsd);
	// ����TCP�׽ӿڣ�ʹ��5174�˿ڣ��󶨱��ص�ַ
	SOCKET s = NULL;
	s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	struct sockaddr_in ch;
	memset(&ch, 0, sizeof(ch));
	ch.sin_family = AF_INET;
	ch.sin_addr.s_addr = INADDR_ANY;
	ch.sin_port = htons(5174);
	int b = bind(s, (struct sockaddr*)&ch, sizeof(ch));
	// ��ʼ�����������������QUEQE_Size=5���ȴ�
	int l = listen(s, QUEUE_SIZE);
	printf("���ڼ���������5174�˿�\n");

	std::cout << "*** Simulating " << seed << " ***" << std::endl;
	this->simulation_time = simulation_time;

	while (true)
	{
		
		// ���յȴ������е�һ���ͻ������󣬽�������
		SOCKET* psc = (SOCKET*)malloc(sizeof(SOCKET));
		*psc = accept(s, 0, 0);
		printf("һ���ͻ����Ѿ����ӵ�������5174�˿�,SOCKET�� : %u \n", *psc);
			
		// �����µ��׽��ִ�������
		int receByt = 0;
		char buf[BUF_SIZE];	//ע��BUF_SIZE���ܲ�����
		while (1)
		{
			// ��ȡ�ͻ�������������Ϣ�����������ݾ�һֱ�ȴ��������жϷ���0���������󷵻�-1
			receByt = recv(*psc, buf, BUF_SIZE, 0);
			//buf[receByt] = '\0';
			if (receByt != 0)
			{
				printf("������Ϣ������\n");
				break;
			}
		}   
		//��ȡ��������
		string buf_str(buf);
		boost::char_separator<char> sep(","); //ָ������Ϊ�ָ��
		boost::tokenizer< boost::char_separator<char> > tok(buf_str, sep);
		boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
		this->num_of_drives = atoi((*beg).c_str()); // ��ȡ������
		beg++;
		//ע��simulation_window,��������simulation_window<=planning_window,
		//δ�޸�simulation_window����֪����ʵ�����Ƿ���Ӱ��
		this->planning_window = atoi((*beg).c_str()); // ��ȡ���ͻ���ڳ���
		
		
		//��ȡ������Ϣ
		initialize_matlab(tok);
		
		//��Ⲣ����

		//�������
		clock_t startTime, endTime;
		startTime = clock();
		bool sol = solve();
		////�ж�ӵ��,���ӵ�£������ʧ��
		//if (congested())
		//{
		//	cout << "***** Too many traffic jams ***" << endl;
		//	sol = false;
		//}
		endTime = clock();
		double caltime = (double)(endTime - startTime) / CLOCKS_PER_SEC;
		//��ȡ����������������׽��ֻ�������
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
			//·������
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
		//�ر��׽��֣��ͷſռ�
		int ic = closesocket(*psc);
		free(psc);
		//���·��
		update_initial_paths(paths);
	}

	// �ر��׽��ֽӿںͷ���
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
/// ��ʼ�������
/// װ����ǰ�ļ�¼��·������Ϣ����λ��
/// ��������ڣ������������µ�����Ŀ����Ϣ
/// ��drives_in_induct_stations���м������������ظ����������
/// </summary>
void SortingSystem::initialize()
{
	initialize_solvers();

	starts.resize(num_of_drives);//��ʼ�������
	goal_locations.resize(num_of_drives);//��ʼ���յ���
	paths.resize(num_of_drives);//��ʼ��·����
	finished_tasks.resize(num_of_drives);//����������¼

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
		{	//ÿһ���������һ��װ�ص��һ��Ŀ��㣬��װ�أ�Ȼ��ּ�
			cout << "Randomly generating initial locations" << endl;
			initialize_start_locations();//������ʼλ�ã�
			initialize_goal_locations();//Ȼ�����װ�ص�ͷּ��
		}
	}

	// initialize induct station counter
	for (int k = 0; k < num_of_drives; k++)
	{
		// goals
		int goal = goal_locations[k].back().first;
		if (G.types[goal] == "Induct")
		{
			//��ǰ��initialize_goal_locations()���Ѿ��ӹ����˴��ٴμӵ����壿
			//�ѵ���load_records��û�ӣ��˴�����load_records����������initialize_goal_locations
			//��ʹ�����������֤��auto a = drives_in_induct_stations[goal];
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

//matlab���Ӱ汾

/// <summary>
/// ΪMATLAB���������ĳ�ʼ��
/// ��Ҫ������������������յ���г�ʼ��
/// </summary>
void SortingSystem::initialize_matlab(boost::tokenizer< boost::char_separator<char> > tok)
{
	initialize_solvers();

	starts.resize(num_of_drives);//��ʼ�������
	goal_locations.resize(num_of_drives);//��ʼ���յ���
	paths.resize(num_of_drives);//��ʼ��·����
	finished_tasks.resize(num_of_drives);//����������¼

	for (const auto induct : G.inducts)
	{
		drives_in_induct_stations[induct.second] = 0;
	}

	initialize_start_locations_matlab(tok);//������ʼλ�ã�
	initialize_goal_locations_matlab(tok);//Ȼ�����װ�ص�ͷּ��

	// initialize induct station counter
	for (int k = 0; k < num_of_drives; k++)
	{
		// goals
		int goal = goal_locations[k].back().first;
		if (G.types[goal] == "Induct")
		{
			//��ǰ��initialize_goal_locations()���Ѿ��ӹ����˴��ٴμӵ����壿
			//�ѵ���load_records��û�ӣ��˴�����load_records����������initialize_goal_locations
			//��ʹ�����������֤��auto a = drives_in_induct_stations[goal];
			drives_in_induct_stations[goal]++;
		}
		else if (G.types[goal] != "Eject")
		{
			//MATLAB�е�����������ɣ�����Ŀ��㲻����ڻ�ּ𴰸�����ȡ���Գ��ڵļ��
			/*std::cout << "ERROR in the type of goal locations" << std::endl;
			std::cout << "The fiducial type of the goal of agent " << k << " is " << G.types[goal] << std::endl;
			exit(-1);*/
		}
	}
}

/// <summary>
/// Ϊ�׽��ִ�������������������
/// </summary>
void SortingSystem::initialize_start_locations_matlab(boost::tokenizer< boost::char_separator<char> > tok)
{
	int N = G.size();
	std::vector<bool> used(N, false); //��ʾλ���Ƿ�ռ��

	// Choose random start locations
	// Any non-obstacle locations can be start locations
	// Start locations should be unique
	boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
	
	this->num_of_drives = atoi((*beg).c_str()); // ��ȡ������
	beg++; //�������Ѿ���ȡ�������һ����
	beg++; //������ͻ����
	for (int k = 0; k < num_of_drives;)
	{
		auto test_1 = *beg; //���Ե�����
		int loc = atoi((*beg).c_str());//���ж�ȡ�����������
		if (G.types[loc] != "Obstacle" && !used[loc])
		{
			int orientation = -1;//����Ϊ-1Ӧ���ǲ�������ת
			if (consider_rotation)
			{
				orientation = rand() % 4;
			}
			starts[k] = State(loc, 0, orientation);
			paths[k].emplace_back(starts[k]);
			used[loc] = true;
			finished_tasks[k].emplace_back(loc, 0);//��������񵽵׼���ʲô��
			k++;
		}
		beg++;
	}
}


void SortingSystem::initialize_goal_locations_matlab(boost::tokenizer< boost::char_separator<char> > tok)
{
	//��ʱע�ͣ���ֹ���յ�
	if (hold_endpoints || useDummyPaths)
		return;
	// Choose random goal locations
	// a close induct location can be a goal location, or
	// any eject locations can be goal locations
	// Goal locations are not necessarily unique
	boost::tokenizer< boost::char_separator<char> >::iterator beg = tok.begin();
	advance(beg, num_of_drives + 2); //����������ǰ�ƽ�num_of_drives+2���룬����Ŀ�������ô�
	for (int k = 0; k < num_of_drives; k++)
	{
		//����������
		goal_locations[k].clear();
	}
	for (int k = 0; k < num_of_drives; k++)
	{
		//�м��
		int goal = atoi((*beg).c_str());//���ж�ȡ�����յ�����;
		beg++;
		goal_locations[k].emplace_back(goal, 0);
	}
	for (int k = 0; k < num_of_drives; k++)
	{
		//����
		int goal = atoi((*beg).c_str());//���ж�ȡ�����յ�����;
		beg++;
		if (goal >= 0)
		{
			//С��0ʱ����ʱ�����ڵڶ���Ŀ��㣬����Ҫ���Ŀ���
			goal_locations[k].emplace_back(goal, 0);
		}
		
	}
}