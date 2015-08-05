#ifndef OROCOS_Sched_test_COMPONENT_HPP
#define OROCOS_Sched_test_COMPONENT_HPP

#include <rtt/RTT.hpp>

class Sched_test : public RTT::TaskContext{
  public:
    Sched_test(std::string const& name);

    bool configureHook();
    bool startHook();
    void updateHook();
    void stopHook();
    void cleanupHook();
    bool step();
    bool empty();


  private:
    int N;
    int i;
    bool source;
    bool use_event_port;

    bool first_run;

    RTT::InputPort<std::vector<double> > inport;
    RTT::OutputPort<std::vector<double> > outport;
    int counter;
    std::vector<double> v_in;
};
#endif
