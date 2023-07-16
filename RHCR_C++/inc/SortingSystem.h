#pragma once
#include "BasicSystem.h"
#include "SortingGraph.h"
#include <boost/tokenizer.hpp>


class SortingSystem :
	public BasicSystem
{
public:
    int c; // param for induct assignment��Ϊװ�ؿڰ��������õĲ���

	SortingSystem(const SortingGrid& G, MAPFSolver& solver);
    ~SortingSystem();

    void simulate(int simulation_time);

private:
	const SortingGrid& G;

    // record usage of induct stations
    boost::unordered_map<int, int> drives_in_induct_stations; // induct location + #drives that intends to go to this induct station��
    //װ�ؿںͶ�Ӧ��ʻ����װ�ؿڵĳ�����ţ�Ӧ������Ŀ���Ǳ�Űɣ�
	void initialize();
    void initialize_matlab(boost::tokenizer< boost::char_separator<char> > tok);

    // assign tasks
    void initialize_start_locations();
    void initialize_goal_locations();
	void update_goal_locations();

    void initialize_start_locations_matlab(boost::tokenizer< boost::char_separator<char> > tok);
    void initialize_goal_locations_matlab(boost::tokenizer< boost::char_separator<char> > tok);

    int assign_induct_station(int curr) const;
    int assign_eject_station() const;
};

