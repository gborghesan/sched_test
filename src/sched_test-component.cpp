#include "sched_test-component.hpp"
#include <rtt/Component.hpp>
#include <iostream>

Sched_test::Sched_test(std::string const& name) : TaskContext(name, PreOperational)
{
	counter=0;
	addPort("inport",inport);
	addPort("outport",outport);
	addProperty("v_size",N);
	addProperty("index_of_component",i);
	addProperty("source",source);
	this->addOperation( "step_own",  &Sched_test::step, this, RTT::OwnThread)
	                                   .doc("in OwnThread");
	this->addOperation( "step_client",  &Sched_test::step, this, RTT::ClientThread)
	                                   .doc("in ClientThread");
	this->addOperation( "empty_op",  &Sched_test::empty, this, RTT::OwnThread)
	                                   .doc("empty operation that a side effect calls the updatehook");

	source=false;
}
bool Sched_test::empty(){
	return true;
}

 
bool Sched_test::configureHook(){
	counter=0;
	v_in.resize(N,-1);
	outport.write(v_in);
	return true;
}

bool Sched_test::startHook(){
	return true;
}
void Sched_test::updateHook(){
	//RTT::Logger::In in(this->getName());
	//RTT::log(RTT::Error)<<this->getName()<<": UPDATE"<<RTT::endlog();

	if(!source)
	{
		if(inport.read(v_in)==RTT::NoData)
		{
			std::fill(v_in.begin(), v_in.end(), -1);
			RTT::log(RTT::Error)<<this->getName()<<": no data in inport"<<RTT::endlog();
		}
		else
		{
			v_in[i]=counter;
		}
		outport.write(v_in);
		counter++;
	}

	else
	{
		v_in[i]=counter;
		outport.write(v_in);
		counter++;
	}
}



bool Sched_test::step(){
	//RTT::log(RTT::Error)<<this->getName()<<": STEP"<<RTT::endlog();
	bool ok=true;
	if(!source)
	{
		if(inport.read(v_in)==RTT::NoData)
		{
			std::fill(v_in.begin(), v_in.end(), -1);
			RTT::log(RTT::Error)<<this->getName()<<": no data in inport"<<RTT::endlog();
			ok=false;
		}
		else
		{
			v_in[i]=counter;
		}
		outport.write(v_in);
		counter++;

	}

	else
	{
		v_in[i]=counter;
		outport.write(v_in);
		counter++;
	}
	return ok;
}


void Sched_test::stopHook() {
}

void Sched_test::cleanupHook() {
}

/*
 * Using this macro, only one component may live
 * in one library *and* you may *not* link this library
 * with another component library. Use
 * ORO_CREATE_COMPONENT_TYPE()
 * ORO_LIST_COMPONENT_TYPE(Sched_test)
 * In case you want to link with another library that
 * already contains components.
 *
 * If you have put your component class
 * in a namespace, don't forget to add it here too:
 */
ORO_CREATE_COMPONENT(Sched_test)
