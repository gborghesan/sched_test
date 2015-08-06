# Test of chain execution of components #

This package contains a c++ component, that has an input and output port, and lua-based supervisor.

The goal is to verify if it is possible to run from a supervisor, that takes care of syncronization, either the update hook or a 
an operation in own or cliend thread. the 3 test are selected in lines 29-31 of start.lua
```
--local mod=1-- call updateHook (in node_i)
--local mod=2-- call step_own (in node_i)
local mod=3-- call step_client (in supervisor)
```

the lua script deploys a number of sched_test components, 
the supervisor is periodic, while the other components are non-periodic.
The main problem that i want to address is wether calling components in this way, the data written in an output port by node _n-1_ is ready in input port of node _n_

The results are shown in files
- report_mod_1.dat : updateHook is called by the supervisor by means of trigger, nodes are configured __and__ started (othewise the call of trigger will not work!).
- report_mod_2.dat : step_own is called by the supervisor, node components are __only__ configured.
- report_mod_3.dat : step_client is called by the supervisor, node components are __only__ configured.

the results are that with the trigger, the operation is non-blocking, and it is not assured that the new data is ready in the input port, while with the other two it behaves as expected (I expect to see the same number in each line, +1 for each line).


another consideration is that if the operation is called and the the node is started, the update hook is also called. This can be verified by modifing
```
 if mod==1 then vect[i]:start(); end
```
to 
```
 vect[i]:start();
```
and see that for each iteration the index increase of 2 (1 in update and 1 in operation).
This suggest that an empty operation is a way to call the the update hook in a blocking way (supposing that the component is in _running_) state.

This modality has been added as mod=4.

lastly: use of event_port: it works as expected.
BUT, since the configureHook triggers automatically the updateHook, (over-riding the fact the update hook should be only data driven), I have to put a boolean to ensure that the first time the update is called, no code is executed. otherwise we have a constant offset in the data vector.

## comment 1 (modality 5) ##
Added, under suggestion of Ruben, data triggered ports (modality 5)
in this case the supervisor does not play any role, and the node1 is the periodic elements periodic.

The only problem that we have here is that the nodes have to be started, thus calling the updatehook once, 
this can cause a race conditions since the starthook+updatehook are non blocking.

In this example, i simply put a boolean flag _first_run_ that makes the node to skip the first execution of the update.

## comment 2 (modality 6) and conclusions ##
After applying nick's patch, we probably have the solution!
the best way to execute components in chain is to use the slave/master activity. In deployment:

```
...
depl:setMasterSlaveActivity("supervisor", comp_name)
...
```
where `comp_name` is the name of node,
and in the update hook of the supervisor, we call sequentially the node's update:
```
function updateHook()
	s=tc:getProperty("names_nodes"):get()
	n=s:totab();

	for   inm,nm   in ipairs(n) do
    	p=tc:getPeer(nm)
    	p:update()
	end
end

```

Again, nodes have to been started, so there is a the problem of racing conditions of start 
(that is blocking and hopefully returns only after having data written into ports and available to other components) 
that calls the update hook (non-blocking), but in many practical cases this problem is not so relevant...


