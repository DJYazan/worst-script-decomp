--This is supposed to be used in Roblox Studio. You will also need to get the bytecode.

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function enc(data)
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-- This turns the base64 bytecode into somewhat readable code.
function dec(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

function decompilebytecode(bytecode)
	return dec(bytecode); -- Useless but idk why
end;

function lua(bytecode)

	local code = { -- Table that is going to include the code in strings.
		"--Decompiled with bad decompiler @" .. os.date()
	}

	local func = { -- Only two functions are included. Feel free to expand it.
		"wait";
		"print";
	};

	local Services = { -- All Services, well almost all..
		"Workspace";
		"ReplicatedStorage";
		"Run Service";
		"Players";
		"Lighting";
		"ReplicatedFirst";
		"StarterGui";
		"StarterPack";
		"StarterPlayer";
		"SoundService";
		"HttpService";
		"InsertService";
		"MarketplaceService";
		"Chat";
		"Teams";
		"TweenService";
		"CollectionService";
		"TestService";
		"LogService";
		"RunService";
		"Debris";
	};

	bytecode = decompilebytecode(bytecode);

	local vcount = 1
	local lcount = 1

	for	i, v in pairs(Services) do
		if string.find(bytecode, v) then
			print("Spotted Pattern: ", v .. " Service logic implement")
			local prefix = "local l__" .. v .. "__" .. lcount ..  " = " .. "game:GetService([[" .. v:gsub(" ", "") .. "]])" -- No Arguments for now, just basic code :)
			table.insert(code, prefix)
			lcount += 1
		end
		for i, v1 in pairs(game:GetService(v:gsub(" ", "")):GetChildren()) do
			if string.find(bytecode, v1.Name) then
				print("Spotted Pattern: ", v .. " Child logic implement")
				local __temp = {game:GetService(v)[v1]}
				local prefix = "local v" .. vcount .. " = " .. __temp[1]
				table.insert(code, prefix)
			end
		end
	end

	for i, v in pairs(func) do
		if string.find(bytecode, v) then
			print("Spotted Pattern: ", v .. " Function logic implement")
			local prefix = "local v" .. vcount .. " = " .. v .. "(" .. ")" -- No Arguments for now, just basic code :)
			table.insert(code, prefix)
			vcount += 1
		end
	end

	if string.find(bytecode, "{") then
		print("Spotted Pattern: {}")
		local prefix = "local v" .. vcount .. " = " .. "{" .. "}" -- No Arguments for now, just basic code :)
		table.insert(code, prefix)
		vcount += 1
	end

	if string.find(bytecode, "function") then
		local prefix
		for line in bytecode:gmatch("[^\r\n]+") do
			print(line)
			prefix = "local v" .. vcount .. " = " .. line
			table.insert(code, prefix)
		end
		print("Spotted Pattern: function")
		vcount += 1
	end
	
	return code;
end;

--Gets the script's bytecode if not provided.

local bytecode = "BQIQBUxvYmJ5CkxvYmJ5Vm9pY2UER2FtZQxJbnRlcm1pc3Npb24FRm9vbHMEZ2FtZQZHYW1lSWQLUnVuIFNlcnZpY2UISXNTdHVkaW8HUGxhY2VJZAVwcmludBLimqDvuI/imqDvuI/imqDvuI8BWwFdECBGT1JDRUQgTU9ERSBUTyApLiBDSEFOR0UgSU4gUkVQTElDQVRFREZJUlNUID4gR0VUUExBQ0VJRCEBDQAAAQAASaMAAAD/AAQAAAAAAG8BAAAwAQA+AQAAAG8BAgAwAQC2AwAAAG8BBAAwAQC9BQAAAG8BBgAwAQDRBwAAAG8BBgAwAQC+CAAAAKQCCgAAAJBATQECuwsAAAANARMADAAAgP8BBAAAAAAAbwINADACAT4BAAAAbwIOADACAbYDAAAAbwIPADACAb0FAAAAbwIQADACAdEHAAAAbwIQADACAb4IAAAAUgABAKQCCgAAAJBATQECzxEAAAC8AQEKEgAAAJ8BAgIOARYApAIKAAAAkEBNAQLFEwAAADABAL0FAAAAjAMBAIwBAwCMAgEAqAEMAKQEFQAAAEBBbwYWAG8HFwBSCAMAbwkYAG8KGQBvCwUAbwwaAHMFBgyfBAIBiwH0/4IAAgAbAgAAsOlGRvhBAwECAAD4eBPtBkIDAgIAADCqV3r5QQMDAgAAEOWLpgNCAwQDBQMGBAAAkEADBwIAACCTbZDsQQIAAHB8GqYDQgIAAPiqb7wFQgIAAOAjKKYDQgIAADBwKKYDQgMIAwkDCgMLBAAAQEEDDAMNAw4DDwMQAAEAARgAAgABAAABAAABAAABAAABAAADAAAAAAABAAEAAAEAAAEAAAEAAAEAAAAEAAAAAAAAAAIAAAAAAAEAAAABAAAAAAAAAAAAAP8GAQAAAAAA" -- The bytecode thats gonna be decompiled.

print(decompilebytecode(bytecode))

print(lua(bytecode))

--This is as far as you can get in Roblox Studio since it only supports luau.
