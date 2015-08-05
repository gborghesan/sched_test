require "rttlib"
require "rfsm_rtt"
require "rttros"

----------------------
-- get the deployer --
tc=rtt.getTC()
if tc:getName() == "lua" then
  depl=tc:getPeer("Deployer") 
elseif tc:getName() == "Deployer" then
  depl=tc
end


depl:import("sched_test")

--------------------------------------
-- deploy & configure the lwr agent --
depl:import("rtt_rospack")
rtt_rospack_find=rtt.provides("ros"):getOperation("find")
local path=rtt_rospack_find("sched_test")

depl:loadComponent("supervisor", "OCL::LuaComponent")
supervisor = depl:getPeer("supervisor")
supervisor:exec_file((path.."/scripts/sched.lua"))

--[[ choose one of the 5 value for mod]]--

--local mod=1-- call trigger() (in node_i)
--local mod=2-- call step_own (in node_i)
--local mod=3-- call step_client (in supervisor)

--local mod=4-- call empty_function
--local mod=5-- use event ports
local mod=6-- use master-slave activities and call update() for each node_i

--deploy N_of_comp nodes
vect={}
name_vector={}

N_of_comp=100;
for i=1,N_of_comp do
  vect[i]=i
  
  local comp_name="node" .. i
  depl:loadComponent(comp_name, "Sched_test")
  vect[i] = depl:getPeer(comp_name)
  if mod==6 then
    depl:setMasterSlaveActivity("supervisor", comp_name)
  end
  vect[i]:getProperty("v_size"):set(N_of_comp)
  vect[i]:getProperty("index_of_component"):set(i-1)
  name_vector[i]=comp_name

  if mod==5 then vect[i]:getProperty("use_event_port"):set(true)
	else vect[i]:getProperty("use_event_port"):set(false)
  end
 vect[i]:configure();
  --peers
  depl:connectPeers("supervisor",comp_name)
end

vect[1]:getProperty("source"):set(true);

cp = rtt.Variable('ConnPolicy')
for i=1,N_of_comp-1 do
  local sr_name="node" .. i
  local sk_name="node" .. i+1
  depl:connect(sr_name .. ".outport",sk_name .. ".inport", cp)
end

--configure supervisor
s=rtt.Variable("strings")
s:fromtab(name_vector)
supervisor:getProperty("names_nodes"):set(s)




supervisor:getProperty("modality"):set(mod) 



supervisor:configure()

for i=1,N_of_comp do
  
 if mod==1 then vect[i]:start(); end

 if mod==4 then vect[i]:start(); end
 if mod==5 then vect[i]:start(); end
 if mod==6 then vect[i]:start(); end

end

depl:loadComponent("Reporter","OCL::FileReporting")
Reporter=depl:getPeer("Reporter")
depl:connectPeers(name_vector[N_of_comp],"Reporter")
depl:connectPeers("supervisor","Reporter")
Reporter:reportPort(name_vector[N_of_comp],"outport")
Reporter:getProperty("ReportFile"):set("report_mod_" .. tostring(mod) ..".dat")
Reporter:configure()
Reporter:start()

if mod~=5 then
supervisor:setPeriod(0.1)
supervisor:start()
else
vect[1]:setPeriod(0.1);
vect[1]:start();
end

