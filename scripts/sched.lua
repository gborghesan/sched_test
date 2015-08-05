require("rttlib")
tc=rtt.getTC()
if tc:getName() == "lua" then
  depl=tc:getPeer("Deployer")	
elseif tc:getName() == "Deployer" then
  depl=tc
end


-- The Lua component starts its life in PreOperational, so
-- configureHook can be used to set stuff up.

local inport
local outport
local  names_nodes= rtt.Property("strings","names_nodes")
local  modality= rtt.Property("int","modality")
tc:addProperty(names_nodes);
tc:addProperty(modality);
function configureHook()



  return true
end

-- all hooks are optional!
--function startHook() return true end

function updateHook()

  s=tc:getProperty("names_nodes"):get()
  n=s:totab();

  flag=tc:getProperty("modality"):get()
  for   inm,nm   in ipairs(n)
  do
    p=tc:getPeer(nm)
    if flag==1 then
      p:trigger()
      --p:activate()
    elseif flag==2 then
      op = p:getOperation("step_own")
      op();
    elseif flag==3 then  
      op = p:getOperation("step_client")
      op();
    elseif flag==4 then  
      op = p:getOperation("empty_op")
      op();
    elseif flag==6 then
      p:update()
    end
  end

  --  local fs, ev_in = inport:read()
  --  outport:write(ev_in.data)
end



function cleanupHook()
  tc:removeProperty("names_nodes");
  names_nodes:delete();
  tc:removeProperty("modality");
  modality:delete();
end
