
local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 81) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local FlatIdent_7126A = 0;
				local b;
				while true do
					if (FlatIdent_7126A == 1) then
						return b;
					end
					if (FlatIdent_7126A == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_7126A = 1;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local FlatIdent_2661B = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_2661B == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_2661B == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_2661B = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_7366E = 0;
			while true do
				if (0 == FlatIdent_7366E) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local Type = gBit(Descriptor, 2, 3);
				local Mask = gBit(Descriptor, 4, 6);
				local Inst = {gBits16(),gBits16(),nil,nil};
				if (Type == 0) then
					local FlatIdent_781F8 = 0;
					while true do
						if (FlatIdent_781F8 == 0) then
							Inst[3] = gBits16();
							Inst[4] = gBits16();
							break;
						end
					end
				elseif (Type == 1) then
					Inst[3] = gBits32();
				elseif (Type == 2) then
					Inst[3] = gBits32() - (2 ^ 16);
				elseif (Type == 3) then
					local FlatIdent_6FA1 = 0;
					while true do
						if (0 == FlatIdent_6FA1) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
							break;
						end
					end
				end
				if (gBit(Mask, 1, 1) == 1) then
					Inst[2] = Consts[Inst[2]];
				end
				if (gBit(Mask, 2, 2) == 1) then
					Inst[3] = Consts[Inst[3]];
				end
				if (gBit(Mask, 3, 3) == 1) then
					Inst[4] = Consts[Inst[4]];
				end
				Instrs[Idx] = Inst;
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 47) then
					if (Enum <= 23) then
						if (Enum <= 11) then
							if (Enum <= 5) then
								if (Enum <= 2) then
									if (Enum <= 0) then
										Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
									elseif (Enum > 1) then
										local FlatIdent_E652 = 0;
										local A;
										while true do
											if (0 == FlatIdent_E652) then
												A = Inst[2];
												do
													return Unpack(Stk, A, A + Inst[3]);
												end
												break;
											end
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									end
								elseif (Enum <= 3) then
									Stk[Inst[2]] = -Stk[Inst[3]];
								elseif (Enum > 4) then
									local FlatIdent_27957 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_27957 == 8) then
											do
												return;
											end
											break;
										end
										if (FlatIdent_27957 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_27957 = 5;
										end
										if (FlatIdent_27957 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_27957 = 4;
										end
										if (FlatIdent_27957 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_27957 = 7;
										end
										if (FlatIdent_27957 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_27957 = 6;
										end
										if (FlatIdent_27957 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											FlatIdent_27957 = 1;
										end
										if (FlatIdent_27957 == 7) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_27957 = 8;
										end
										if (FlatIdent_27957 == 1) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_27957 = 2;
										end
										if (FlatIdent_27957 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_27957 = 3;
										end
									end
								else
									local FlatIdent_66799 = 0;
									local A;
									while true do
										if (2 == FlatIdent_66799) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_66799 = 3;
										end
										if (4 == FlatIdent_66799) then
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_66799 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_66799 = 1;
										end
										if (FlatIdent_66799 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_66799 = 2;
										end
										if (FlatIdent_66799 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_66799 = 4;
										end
									end
								end
							elseif (Enum <= 8) then
								if (Enum <= 6) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 7) then
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_189F0 = 0;
									local A;
									local Results;
									local Edx;
									while true do
										if (FlatIdent_189F0 == 1) then
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
										if (FlatIdent_189F0 == 0) then
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											FlatIdent_189F0 = 1;
										end
									end
								end
							elseif (Enum <= 9) then
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							elseif (Enum > 10) then
								local B;
								local Edx;
								local Results, Limit;
								local A;
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A]());
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 17) then
							if (Enum <= 14) then
								if (Enum <= 12) then
									Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
								elseif (Enum == 13) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								end
							elseif (Enum <= 15) then
								local FlatIdent_8D1A5 = 0;
								local B;
								local A;
								while true do
									if (3 == FlatIdent_8D1A5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_8D1A5 = 4;
									end
									if (FlatIdent_8D1A5 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_8D1A5 = 2;
									end
									if (FlatIdent_8D1A5 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										FlatIdent_8D1A5 = 1;
									end
									if (FlatIdent_8D1A5 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_8D1A5 = 3;
									end
									if (5 == FlatIdent_8D1A5) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (4 == FlatIdent_8D1A5) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_8D1A5 = 5;
									end
								end
							elseif (Enum > 16) then
								local FlatIdent_8435E = 0;
								local A;
								local Results;
								local Limit;
								local Edx;
								while true do
									if (FlatIdent_8435E == 2) then
										for Idx = A, Top do
											local FlatIdent_29E69 = 0;
											while true do
												if (FlatIdent_29E69 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										break;
									end
									if (FlatIdent_8435E == 1) then
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_8435E = 2;
									end
									if (FlatIdent_8435E == 0) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										FlatIdent_8435E = 1;
									end
								end
							else
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 20) then
							if (Enum <= 18) then
								local FlatIdent_466B2 = 0;
								local A;
								local Results;
								local Limit;
								local Edx;
								while true do
									if (FlatIdent_466B2 == 0) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										FlatIdent_466B2 = 1;
									end
									if (1 == FlatIdent_466B2) then
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_466B2 = 2;
									end
									if (2 == FlatIdent_466B2) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										break;
									end
								end
							elseif (Enum > 19) then
								local A = Inst[2];
								local Cls = {};
								for Idx = 1, #Lupvals do
									local List = Lupvals[Idx];
									for Idz = 0, #List do
										local FlatIdent_2BE02 = 0;
										local Upv;
										local NStk;
										local DIP;
										while true do
											if (FlatIdent_2BE02 == 1) then
												DIP = Upv[2];
												if ((NStk == Stk) and (DIP >= A)) then
													Cls[DIP] = NStk[DIP];
													Upv[1] = Cls;
												end
												break;
											end
											if (FlatIdent_2BE02 == 0) then
												Upv = List[Idz];
												NStk = Upv[1];
												FlatIdent_2BE02 = 1;
											end
										end
									end
								end
							else
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 21) then
							local Results;
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results = {Stk[A](Unpack(Stk, A + 1, Top))};
							Edx = 0;
							for Idx = A, Inst[4] do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						elseif (Enum > 22) then
							local FlatIdent_3CF01 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_3CF01 == 5) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_3CF01 = 6;
								end
								if (FlatIdent_3CF01 == 3) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_3CF01 = 4;
								end
								if (FlatIdent_3CF01 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_3CF01 = 2;
								end
								if (FlatIdent_3CF01 == 6) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_3CF01 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_3CF01 = 1;
								end
								if (FlatIdent_3CF01 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CF01 = 3;
								end
								if (FlatIdent_3CF01 == 4) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_3CF01 = 5;
								end
							end
						elseif (Stk[Inst[2]] == Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 35) then
						if (Enum <= 29) then
							if (Enum <= 26) then
								if (Enum <= 24) then
									local T;
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								elseif (Enum > 25) then
									local A = Inst[2];
									local C = Inst[4];
									local CB = A + 2;
									local Result = {Stk[A](Stk[A + 1], Stk[CB])};
									for Idx = 1, C do
										Stk[CB + Idx] = Result[Idx];
									end
									local R = Result[1];
									if R then
										local FlatIdent_40070 = 0;
										while true do
											if (FlatIdent_40070 == 0) then
												Stk[CB] = R;
												VIP = Inst[3];
												break;
											end
										end
									else
										VIP = VIP + 1;
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]];
								end
							elseif (Enum <= 27) then
								Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
							elseif (Enum == 28) then
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							else
								local FlatIdent_86900 = 0;
								while true do
									if (FlatIdent_86900 == 0) then
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										break;
									end
								end
							end
						elseif (Enum <= 32) then
							if (Enum <= 30) then
								local A = Inst[2];
								local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								local Edx = 0;
								for Idx = A, Inst[4] do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
							elseif (Enum > 31) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							elseif (Stk[Inst[2]] ~= Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 33) then
							local FlatIdent_81225 = 0;
							local A;
							local Results;
							local Limit;
							local Edx;
							while true do
								if (FlatIdent_81225 == 2) then
									for Idx = A, Top do
										local FlatIdent_5E109 = 0;
										while true do
											if (FlatIdent_5E109 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									break;
								end
								if (FlatIdent_81225 == 0) then
									A = Inst[2];
									Results, Limit = _R(Stk[A]());
									FlatIdent_81225 = 1;
								end
								if (FlatIdent_81225 == 1) then
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_81225 = 2;
								end
							end
						elseif (Enum > 34) then
							local FlatIdent_2DA99 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_2DA99 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_2DA99 = 1;
								end
								if (FlatIdent_2DA99 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_2DA99 = 3;
								end
								if (FlatIdent_2DA99 == 3) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_2DA99 = 4;
								end
								if (FlatIdent_2DA99 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_2DA99 = 2;
								end
								if (FlatIdent_2DA99 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									FlatIdent_2DA99 = 5;
								end
								if (FlatIdent_2DA99 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2DA99 = 6;
								end
								if (6 == FlatIdent_2DA99) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
							end
						else
							local A;
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							if not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						end
					elseif (Enum <= 41) then
						if (Enum <= 38) then
							if (Enum <= 36) then
								local FlatIdent_43626 = 0;
								local B;
								local A;
								while true do
									if (0 == FlatIdent_43626) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_43626 = 1;
									end
									if (FlatIdent_43626 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_43626 = 4;
									end
									if (FlatIdent_43626 == 5) then
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_43626 == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_43626 = 2;
									end
									if (FlatIdent_43626 == 2) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_43626 = 3;
									end
									if (FlatIdent_43626 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_43626 = 5;
									end
								end
							elseif (Enum > 37) then
								local FlatIdent_6E549 = 0;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_6E549) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6E549 = 3;
									end
									if (FlatIdent_6E549 == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6E549 = 7;
									end
									if (FlatIdent_6E549 == 7) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_6E549 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_6E549 = 6;
									end
									if (FlatIdent_6E549 == 3) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_6E549 = 4;
									end
									if (FlatIdent_6E549 == 1) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_6E549 = 2;
									end
									if (4 == FlatIdent_6E549) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_6E549 = 5;
									end
									if (FlatIdent_6E549 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6E549 = 1;
									end
								end
							elseif (Stk[Inst[2]] < Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 39) then
							local FlatIdent_8BA1E = 0;
							while true do
								if (FlatIdent_8BA1E == 0) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_8BA1E = 1;
								end
								if (FlatIdent_8BA1E == 3) then
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_8BA1E == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_8BA1E = 2;
								end
								if (FlatIdent_8BA1E == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8BA1E = 3;
								end
							end
						elseif (Enum == 40) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local T;
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							T = Stk[A];
							B = Inst[3];
							for Idx = 1, B do
								T[Idx] = Stk[A + Idx];
							end
						end
					elseif (Enum <= 44) then
						if (Enum <= 42) then
							local FlatIdent_6DFD9 = 0;
							local Results;
							local Edx;
							local Limit;
							local B;
							local A;
							while true do
								if (FlatIdent_6DFD9 == 3) then
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_1E4CB = 0;
										while true do
											if (FlatIdent_1E4CB == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6DFD9 = 4;
								end
								if (FlatIdent_6DFD9 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_6DFD9 = 2;
								end
								if (FlatIdent_6DFD9 == 2) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_6DFD9 = 3;
								end
								if (FlatIdent_6DFD9 == 0) then
									Results = nil;
									Edx = nil;
									Results, Limit = nil;
									B = nil;
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_6DFD9 = 1;
								end
								if (FlatIdent_6DFD9 == 5) then
									VIP = Inst[3];
									break;
								end
								if (4 == FlatIdent_6DFD9) then
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6DFD9 = 5;
								end
							end
						elseif (Enum == 43) then
							local FlatIdent_1D701 = 0;
							local A;
							while true do
								if (FlatIdent_1D701 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_1D701 = 5;
								end
								if (FlatIdent_1D701 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_1D701 = 4;
								end
								if (FlatIdent_1D701 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_1D701 = 2;
								end
								if (5 == FlatIdent_1D701) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_1D701 = 6;
								end
								if (FlatIdent_1D701 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									FlatIdent_1D701 = 3;
								end
								if (FlatIdent_1D701 == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_1D701 = 1;
								end
								if (FlatIdent_1D701 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									break;
								end
								if (FlatIdent_1D701 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1D701 = 7;
								end
							end
						else
							Upvalues[Inst[3]] = Stk[Inst[2]];
						end
					elseif (Enum <= 45) then
						local FlatIdent_71493 = 0;
						local A;
						local B;
						while true do
							if (FlatIdent_71493 == 1) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								break;
							end
							if (FlatIdent_71493 == 0) then
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_71493 = 1;
							end
						end
					elseif (Enum > 46) then
						local FlatIdent_75331 = 0;
						local K;
						local B;
						local A;
						while true do
							if (0 == FlatIdent_75331) then
								K = nil;
								B = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_75331 = 1;
							end
							if (FlatIdent_75331 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_75331 = 2;
							end
							if (FlatIdent_75331 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75331 = 3;
							end
							if (FlatIdent_75331 == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_75331 = 8;
							end
							if (FlatIdent_75331 == 11) then
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								FlatIdent_75331 = 12;
							end
							if (FlatIdent_75331 == 9) then
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75331 = 10;
							end
							if (FlatIdent_75331 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_75331 = 5;
							end
							if (FlatIdent_75331 == 13) then
								VIP = Inst[3];
								break;
							end
							if (6 == FlatIdent_75331) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_75331 = 7;
							end
							if (FlatIdent_75331 == 12) then
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75331 = 13;
							end
							if (FlatIdent_75331 == 5) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75331 = 6;
							end
							if (FlatIdent_75331 == 10) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								FlatIdent_75331 = 11;
							end
							if (FlatIdent_75331 == 8) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_75331 = 9;
							end
							if (FlatIdent_75331 == 3) then
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_75331 = 4;
							end
						end
					else
						local B;
						local A;
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
					end
				elseif (Enum <= 71) then
					if (Enum <= 59) then
						if (Enum <= 53) then
							if (Enum <= 50) then
								if (Enum <= 48) then
									local FlatIdent_1CFC3 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_1CFC3 == 5) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1CFC3 = 6;
										end
										if (7 == FlatIdent_1CFC3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_1CFC3 = 8;
										end
										if (FlatIdent_1CFC3 == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1CFC3 = 10;
										end
										if (FlatIdent_1CFC3 == 11) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											FlatIdent_1CFC3 = 12;
										end
										if (FlatIdent_1CFC3 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_1CFC3 = 5;
										end
										if (FlatIdent_1CFC3 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_1CFC3 = 2;
										end
										if (FlatIdent_1CFC3 == 8) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_1CFC3 = 9;
										end
										if (FlatIdent_1CFC3 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_1CFC3 = 4;
										end
										if (FlatIdent_1CFC3 == 12) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_1CFC3 == 2) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_1CFC3 = 3;
										end
										if (FlatIdent_1CFC3 == 10) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1CFC3 = 11;
										end
										if (FlatIdent_1CFC3 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_1CFC3 = 1;
										end
										if (FlatIdent_1CFC3 == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_1CFC3 = 7;
										end
									end
								elseif (Enum == 49) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
								else
									Stk[Inst[2]] = Inst[3] ~= 0;
								end
							elseif (Enum <= 51) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
							elseif (Enum > 52) then
								local FlatIdent_89126 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_89126 == 3) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_89126 = 4;
									end
									if (FlatIdent_89126 == 5) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										FlatIdent_89126 = 6;
									end
									if (FlatIdent_89126 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_89126 = 1;
									end
									if (FlatIdent_89126 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_89126 = 3;
									end
									if (FlatIdent_89126 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_89126 = 5;
									end
									if (FlatIdent_89126 == 1) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_89126 = 2;
									end
									if (FlatIdent_89126 == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										break;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
							end
						elseif (Enum <= 56) then
							if (Enum <= 54) then
								local FlatIdent_42B8B = 0;
								local A;
								while true do
									if (FlatIdent_42B8B == 0) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										break;
									end
								end
							elseif (Enum == 55) then
								if (Stk[Inst[2]] == Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Inst[2] < Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 57) then
							Stk[Inst[2]] = Env[Inst[3]];
						elseif (Enum == 58) then
							local FlatIdent_2B4B0 = 0;
							while true do
								if (FlatIdent_2B4B0 == 5) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									break;
								end
								if (1 == FlatIdent_2B4B0) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2B4B0 = 2;
								end
								if (FlatIdent_2B4B0 == 0) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2B4B0 = 1;
								end
								if (3 == FlatIdent_2B4B0) then
									Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2B4B0 = 4;
								end
								if (FlatIdent_2B4B0 == 2) then
									Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2B4B0 = 3;
								end
								if (FlatIdent_2B4B0 == 4) then
									Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_2B4B0 = 5;
								end
							end
						else
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 65) then
						if (Enum <= 62) then
							if (Enum <= 60) then
								local FlatIdent_29A75 = 0;
								local B;
								local K;
								while true do
									if (FlatIdent_29A75 == 0) then
										B = Inst[3];
										K = Stk[B];
										FlatIdent_29A75 = 1;
									end
									if (1 == FlatIdent_29A75) then
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										break;
									end
								end
							elseif (Enum == 61) then
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								do
									return;
								end
							else
								local FlatIdent_97E60 = 0;
								local A;
								while true do
									if (0 == FlatIdent_97E60) then
										A = Inst[2];
										Stk[A] = Stk[A]();
										break;
									end
								end
							end
						elseif (Enum <= 63) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
						elseif (Enum == 64) then
							Stk[Inst[2]] = {};
						else
							local FlatIdent_93FA5 = 0;
							local T;
							local B;
							local A;
							while true do
								if (FlatIdent_93FA5 == 0) then
									T = nil;
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_93FA5 = 1;
								end
								if (FlatIdent_93FA5 == 5) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_93FA5 = 6;
								end
								if (FlatIdent_93FA5 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_93FA5 = 4;
								end
								if (4 == FlatIdent_93FA5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_93FA5 = 5;
								end
								if (FlatIdent_93FA5 == 6) then
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
									break;
								end
								if (FlatIdent_93FA5 == 2) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_93FA5 = 3;
								end
								if (1 == FlatIdent_93FA5) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_93FA5 = 2;
								end
							end
						end
					elseif (Enum <= 68) then
						if (Enum <= 66) then
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							if Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum > 67) then
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						end
					elseif (Enum <= 69) then
						local FlatIdent_82A94 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_82A94 == 7) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_82A94 = 8;
							end
							if (FlatIdent_82A94 == 6) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_82A94 = 7;
							end
							if (FlatIdent_82A94 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_82A94 = 6;
							end
							if (FlatIdent_82A94 == 2) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_82A94 = 3;
							end
							if (FlatIdent_82A94 == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_82A94 = 9;
							end
							if (FlatIdent_82A94 == 3) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_82A94 = 4;
							end
							if (FlatIdent_82A94 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_82A94 = 5;
							end
							if (FlatIdent_82A94 == 0) then
								B = nil;
								A = nil;
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_82A94 = 1;
							end
							if (FlatIdent_82A94 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_82A94 = 2;
							end
							if (FlatIdent_82A94 == 9) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								break;
							end
						end
					elseif (Enum == 70) then
						local FlatIdent_6038 = 0;
						local Edx;
						local Results;
						local Limit;
						local B;
						local A;
						while true do
							if (FlatIdent_6038 == 10) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_6038 == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_6038 = 3;
							end
							if (FlatIdent_6038 == 5) then
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_28E8A = 0;
									while true do
										if (FlatIdent_28E8A == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								FlatIdent_6038 = 6;
							end
							if (FlatIdent_6038 == 9) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6038 = 10;
							end
							if (FlatIdent_6038 == 1) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_6038 = 2;
							end
							if (FlatIdent_6038 == 8) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_6038 = 9;
							end
							if (FlatIdent_6038 == 4) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_6038 = 5;
							end
							if (FlatIdent_6038 == 7) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
								FlatIdent_6038 = 8;
							end
							if (FlatIdent_6038 == 0) then
								Edx = nil;
								Results, Limit = nil;
								B = nil;
								A = nil;
								FlatIdent_6038 = 1;
							end
							if (FlatIdent_6038 == 6) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								FlatIdent_6038 = 7;
							end
							if (FlatIdent_6038 == 3) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6038 = 4;
							end
						end
					else
						Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
					end
				elseif (Enum <= 83) then
					if (Enum <= 77) then
						if (Enum <= 74) then
							if (Enum <= 72) then
								VIP = Inst[3];
							elseif (Enum > 73) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_8751C = 0;
								local A;
								local T;
								local B;
								while true do
									if (FlatIdent_8751C == 1) then
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
										break;
									end
									if (FlatIdent_8751C == 0) then
										A = Inst[2];
										T = Stk[A];
										FlatIdent_8751C = 1;
									end
								end
							end
						elseif (Enum <= 75) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						elseif (Enum > 76) then
							if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local FlatIdent_8A1DB = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_8A1DB == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8A1DB = 2;
								end
								if (FlatIdent_8A1DB == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_8A1DB = 1;
								end
								if (FlatIdent_8A1DB == 2) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_8A1DB = 3;
								end
								if (FlatIdent_8A1DB == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_8A1DB = 4;
								end
								if (FlatIdent_8A1DB == 5) then
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_8A1DB == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_8A1DB = 5;
								end
							end
						end
					elseif (Enum <= 80) then
						if (Enum <= 78) then
							do
								return Stk[Inst[2]];
							end
						elseif (Enum == 79) then
							Stk[Inst[2]] = Upvalues[Inst[3]];
						else
							do
								return;
							end
						end
					elseif (Enum <= 81) then
						local A = Inst[2];
						Stk[A] = Stk[A](Stk[A + 1]);
					elseif (Enum == 82) then
						Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
					else
						local FlatIdent_11D04 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_11D04 == 0) then
								B = nil;
								A = nil;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								FlatIdent_11D04 = 1;
							end
							if (7 == FlatIdent_11D04) then
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_11D04 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_11D04 = 6;
							end
							if (1 == FlatIdent_11D04) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								FlatIdent_11D04 = 2;
							end
							if (FlatIdent_11D04 == 3) then
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_11D04 = 4;
							end
							if (FlatIdent_11D04 == 6) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_11D04 = 7;
							end
							if (FlatIdent_11D04 == 2) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								FlatIdent_11D04 = 3;
							end
							if (FlatIdent_11D04 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_11D04 = 5;
							end
						end
					end
				elseif (Enum <= 89) then
					if (Enum <= 86) then
						if (Enum <= 84) then
							local FlatIdent_45D0C = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_45D0C == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_45D0C = 1;
								end
								if (FlatIdent_45D0C == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
								if (FlatIdent_45D0C == 4) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_45D0C = 5;
								end
								if (FlatIdent_45D0C == 2) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_45D0C = 3;
								end
								if (FlatIdent_45D0C == 1) then
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_45D0C = 2;
								end
								if (FlatIdent_45D0C == 3) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_45D0C = 4;
								end
							end
						elseif (Enum == 85) then
							Stk[Inst[2]] = Inst[3];
						else
							Stk[Inst[2]]();
						end
					elseif (Enum <= 87) then
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]]();
						VIP = VIP + 1;
						Inst = Instr[VIP];
						do
							return;
						end
					elseif (Enum == 88) then
						local B;
						local A;
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
					else
						local FlatIdent_3BEFE = 0;
						local A;
						while true do
							if (0 == FlatIdent_3BEFE) then
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					end
				elseif (Enum <= 92) then
					if (Enum <= 90) then
						if not Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum > 91) then
						local FlatIdent_5AC6 = 0;
						local A;
						while true do
							if (FlatIdent_5AC6 == 4) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								FlatIdent_5AC6 = 5;
							end
							if (FlatIdent_5AC6 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_5AC6 == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_5AC6 = 1;
							end
							if (FlatIdent_5AC6 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_5AC6 = 3;
							end
							if (FlatIdent_5AC6 == 1) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_5AC6 = 2;
							end
							if (FlatIdent_5AC6 == 3) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								FlatIdent_5AC6 = 4;
							end
						end
					else
						local FlatIdent_33B1E = 0;
						local B;
						local A;
						while true do
							if (5 == FlatIdent_33B1E) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_33B1E = 6;
							end
							if (1 == FlatIdent_33B1E) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_33B1E = 2;
							end
							if (2 == FlatIdent_33B1E) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_33B1E = 3;
							end
							if (FlatIdent_33B1E == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_33B1E = 5;
							end
							if (FlatIdent_33B1E == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_33B1E = 4;
							end
							if (6 == FlatIdent_33B1E) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_33B1E = 7;
							end
							if (FlatIdent_33B1E == 0) then
								B = nil;
								A = nil;
								A = Inst[2];
								FlatIdent_33B1E = 1;
							end
							if (FlatIdent_33B1E == 7) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
								break;
							end
						end
					end
				elseif (Enum <= 93) then
					local B;
					local A;
					Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = {};
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
				elseif (Enum > 94) then
					local NewProto = Proto[Inst[3]];
					local NewUvals;
					local Indexes = {};
					NewUvals = Setmetatable({}, {__index=function(_, Key)
						local FlatIdent_6F0B1 = 0;
						local Val;
						while true do
							if (0 == FlatIdent_6F0B1) then
								Val = Indexes[Key];
								return Val[1][Val[2]];
							end
						end
					end,__newindex=function(_, Key, Value)
						local FlatIdent_66193 = 0;
						local Val;
						while true do
							if (FlatIdent_66193 == 0) then
								Val = Indexes[Key];
								Val[1][Val[2]] = Value;
								break;
							end
						end
					end});
					for Idx = 1, Inst[4] do
						local FlatIdent_89940 = 0;
						local Mvm;
						while true do
							if (FlatIdent_89940 == 1) then
								if (Mvm[1] == 25) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
								break;
							end
							if (FlatIdent_89940 == 0) then
								VIP = VIP + 1;
								Mvm = Instr[VIP];
								FlatIdent_89940 = 1;
							end
						end
					end
					Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
				else
					local B;
					local A;
					Stk[Inst[2]] = Env[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A](Stk[A + 1]);
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Upvalues[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = {};
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]][Inst[3]] = Inst[4];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					do
						return;
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!513Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q7470476574034C3Q00682Q7470733A2Q2F7261772E67697468756275736572636F6E74656E742E636F6D2F55492D496E746572666163652F437573746F6D4649656C642F6D61696E2F5261794669656C642E6C7561030C3Q0043726561746557696E646F7703043Q004E616D6503143Q0043612Q745374617220436C6F7365742076312E31030C3Q004C6F6164696E675469746C6503173Q0043612Q7453746172204265647761727320536372697074030F3Q004C6F6164696E675375627469746C6503163Q00412Q6C204578656375746F722053752Q706F7274656403133Q00436F6E66696775726174696F6E536176696E6703073Q00456E61626C65642Q01030A3Q00466F6C6465724E616D65030F3Q0043612Q7453746172436F6E6669677303083Q0046696C654E616D65030C3Q00436C6F736574436F6E66696703093Q004B657953797374656D0100030A3Q004765745365727669636503073Q00506C6179657273030A3Q0052756E5365727669636503103Q0055736572496E7075745365727669636503113Q005265706C69636174656453746F7261676503083Q004C69676874696E67030B3Q004C6F63616C506C61796572028Q00026Q004940026Q002040025Q008051C0026Q00594003093Q0048656172746265617403073Q00436F2Q6E65637403093Q0043726561746554616203083Q004D6F76656D656E74030C3Q00437265617465546F2Q676C65030B3Q0053702Q656420422Q6F7374030C3Q0043752Q72656E7456616C756503043Q00466C6167030C3Q0053702Q65645F546F2Q676C6503083Q0043612Q6C6261636B030C3Q00437265617465536C69646572030B3Q0053702Q656420506F77657203053Q0052616E6765026Q002E4003093Q00496E6372656D656E74026Q00F03F030B3Q0053702Q65645F506F776572030D3Q0043726561746553656374696F6E03143Q004A756D7020262046612Q6C2053652Q74696E677303123Q00456E61626C6520436C6F736574204A756D70030B3Q004A756D705F546F2Q676C65030B3Q004A756D7020486569676874026Q003440030A3Q004A756D705F56616C7565030E3Q004E6F2D46612Q6C2044616D616765030D3Q004E6F46612Q6C5F546F2Q676C65030D3Q00496E66696E697465204A756D70030E3Q00496E664A756D705F546F2Q676C6503083Q00466C79204D6F6465030A3Q00466C795F546F2Q676C65030C3Q00436F6D626174205574696C7303173Q00536D2Q6F74682056656C6F6369747920284E6F2D4B4229030B3Q004E6F4B425F546F2Q676C6503113Q004B6E6F636B6261636B2054616B656E202503083Q004B425F56616C756503073Q0056697375616C7303073Q00426F7820455350030A3Q004553505F546F2Q676C65030C3Q00456E656D696573204F6E6C79030E3Q00456E656D6965735F546F2Q676C6503083Q0053652Q74696E6773030C3Q0043726561746542752Q746F6E03093Q0046505320422Q6F737403073Q00446973636F726403183Q00436F707920446973636F726420496E76697465204C696E6B030B3Q00506C61796572412Q646564030E3Q00506C6179657252656D6F76696E67030E3Q00436861726163746572412Q64656403113Q004C6F6164436F6E66696775726174696F6E0003012Q0012463Q00013Q00122Q000100023Q00202Q00010001000300122Q000300046Q000100039Q0000026Q0001000200202Q00013Q00054Q00033Q000500302Q00030006000700303F00030008000900300F0003000A000B4Q00043Q000300302Q0004000D000E00302Q0004000F001000302Q00040011001200102Q0003000C000400302Q0003001300144Q00010003000200122Q000200023Q00202Q000200020015001255000400164Q004500020004000200122Q000300023Q00202Q00030003001500122Q000500176Q00030005000200122Q000400023Q00202Q00040004001500122Q000600186Q00040006000200122Q000500023Q00202D000500050015001235000700196Q00050007000200122Q000600023Q00202Q00060006001500122Q0008001A6Q00060008000200202Q00070002001B4Q00085Q00122Q0009001C6Q000A6Q0032000B5Q001233000C001D6Q000D5Q00122Q000E001E6Q000F5Q00122Q0010001F6Q00115Q00122Q001200206Q001300016Q00145Q00065F00153Q000100012Q00193Q00074Q004000165Q00065F00170001000100022Q00193Q00064Q00197Q00065F00180002000100012Q00193Q00163Q00065F00190003000100062Q00193Q00074Q00193Q00184Q00193Q00134Q00193Q00144Q00193Q00154Q00193Q00163Q00065F001A0004000100022Q00193Q00024Q00193Q00193Q002001001B0003002100202D001B001B002200065F001D00050001000F2Q00193Q00074Q00193Q00114Q00193Q00124Q00193Q000D4Q00193Q000E4Q00193Q000F4Q00193Q00104Q00193Q000A4Q00193Q00044Q00193Q000B4Q00193Q000C4Q00193Q00084Q00193Q00094Q00193Q00164Q00193Q00184Q0017001B001D000100202Q001B0001002300122Q001D00246Q001B001D000200202Q001C001B00254Q001E3Q000400302Q001E0006002600302Q001E0027001400302Q001E0028002900065F001F0006000100012Q00193Q00083Q001041001E002A001F4Q001C001E000100202Q001C001B002B4Q001E3Q000600302Q001E0006002C4Q001F00023Q00122Q0020001C3Q00122Q0021002E6Q001F0002000100104B001E002D001F00303F001E002F003000303F001E0027001C00303F001E0028003100065F001F0007000100012Q00193Q00093Q00102E001E002A001F4Q001C001E000100202Q001C001B003200122Q001E00336Q001C001E000100202Q001C001B00254Q001E3Q000400302Q001E0006003400302Q001E0027001400302Q001E0028003500065F001F0008000100012Q00193Q000D3Q001041001E002A001F4Q001C001E000100202Q001C001B002B4Q001E3Q000600302Q001E000600364Q001F00023Q00122Q002000303Q00122Q002100376Q001F0002000100104B001E002D001F00303F001E002F003000303F001E0027001E00303F001E0028003800065F001F0009000100012Q00193Q000E3Q00103B001E002A001F4Q001C001E000100202Q001C001B00254Q001E3Q000400302Q001E0006003900302Q001E0027001400302Q001E0028003A00065F001F000A000100012Q00193Q000F3Q00103B001E002A001F4Q001C001E000100202Q001C001B00254Q001E3Q000400302Q001E0006003B00302Q001E0027001400302Q001E0028003C00065F001F000B000100012Q00193Q000A3Q00103B001E002A001F4Q001C001E000100202Q001C001B00254Q001E3Q000400302Q001E0006003D00302Q001E0027001400302Q001E0028003E00065F001F000C000100012Q00193Q000B3Q001053001E002A001F4Q001C001E000100202Q001C0001002300122Q001E003F6Q001C001E000200202Q001D001C00254Q001F3Q000400302Q001F0006004000303F001F0027001400303F001F0028004100065F0020000D000100012Q00193Q00113Q001041001F002A00204Q001D001F000100202Q001D001C002B4Q001F3Q000600302Q001F000600424Q002000023Q00122Q0021001C3Q00122Q002200206Q00200002000100104B001F002D002000303F001F002F003000303F001F0027002000303F001F0028004300065F0020000E000100012Q00193Q00123Q001053001F002A00204Q001D001F000100202Q001D0001002300122Q001F00446Q001D001F000200202Q001E001D00254Q00203Q000400302Q00200006004500303F00200027000E00303F00200028004600065F0021000F000100022Q00193Q00134Q00193Q001A3Q00103B0020002A00214Q001E0020000100202Q001E001D00254Q00203Q000400302Q00200006004700302Q00200027001400302Q00200028004800065F00210010000100022Q00193Q00144Q00193Q001A3Q0010530020002A00214Q001E0020000100202Q001E0001002300122Q002000496Q001E0020000200202Q001F001E004A4Q00213Q000200302Q00210006004B00065F00220011000100012Q00193Q00173Q0010530021002A00224Q001F0021000100202Q001F0001002300122Q0021004C6Q001F0021000200202Q0020001F004A4Q00223Q000200302Q00220006004D00065F00230012000100012Q00197Q0010260022002A00234Q0020002200014Q0020001A6Q00200001000100202Q00200002004E00202Q0020002000224Q002200196Q00200022000100202Q00200002004F00202Q0020002000222Q0019002200184Q005900200022000100200100200007005000202D00200020002200065F00220013000100012Q00193Q001A4Q005900200022000100202D00203Q00512Q00360020000200012Q00503Q00013Q00143Q00083Q0003093Q00506C61796572477569030E3Q0046696E6446697273744368696C6403103Q004D61737465724553505F466F6C64657203083Q00496E7374616E63652Q033Q006E657703063Q00466F6C64657203043Q004E616D6503063Q00506172656E7400124Q004C7Q00206Q000100206Q000200122Q000200038Q0002000200064Q0010000100010004483Q00100001001239000100043Q00202B00010001000500122Q000200066Q0001000200026Q00013Q00304Q000700034Q00015Q00202Q00010001000100104Q000800012Q004E3Q00024Q00503Q00017Q00183Q00030D3Q00476C6F62616C536861646F7773010003063Q00466F67456E64023Q00C088C30042030A3Q004272696768746E652Q73026Q00E03F03093Q00436C6F636B54696D65026Q002840030E3Q004F7574642Q6F72416D6269656E7403063Q00436F6C6F723303073Q0066726F6D524742026Q00594003073Q00416D6269656E7403053Q00706169727303043Q0067616D65030E3Q0047657444657363656E64616E747303053Q007063612Q6C03063Q004E6F7469667903053Q005469746C65030B3Q00506572666F726D616E636503073Q00436F6E74656E74031F3Q00436F6C6F7273204C6F636B65642E205465787475726573204B692Q6C65642E03083Q004475726174696F6E026Q000840002D4Q00157Q00304Q000100029Q0000304Q000300049Q0000304Q000500069Q0000304Q000700089Q0000122Q0001000A3Q00202Q00010001000B00122Q0002000C3Q00122Q0003000C3Q00122Q0004000C6Q00010004000200104Q000900019Q0000122Q0001000A3Q00202Q00010001000B00122Q0002000C3Q00122Q0003000C3Q00122Q0004000C6Q00010004000200104Q000D000100124Q000E3Q00122Q0001000F3Q00202Q0001000100104Q000100029Q00000200044Q00230001001239000500113Q00065F00063Q000100012Q00193Q00044Q00360005000200012Q001400035Q00061A3Q001E000100020004483Q001E00012Q004F3Q00013Q0020055Q00124Q00023Q000300302Q00020013001400302Q00020015001600302Q0002001700186Q000200016Q00013Q00013Q00163Q002Q033Q0049734103053Q00446563616C03073Q0054657874757265030C3Q005472616E73706172656E6379026Q00F03F03083Q00426173655061727403083Q004D65736850617274030B3Q005265666C656374616E6365028Q00030A3Q0043617374536861646F77010003083Q004D6174657269616C03043Q00456E756D03073Q00506C6173746963030D3Q00536D2Q6F7468506C6173746963030B3Q005370656369616C4D65736803043Q004D65736803093Q00546578747572654964034Q00030F3Q005061727469636C65456D692Q74657203053Q00547261696C03073Q00456E61626C656400514Q00077Q00206Q000100122Q000200028Q0002000200064Q000C000100010004483Q000C00012Q004F7Q00202D5Q0001001255000200034Q00203Q0002000200060D3Q000F00013Q0004483Q000F00012Q004F7Q00303F3Q000400050004483Q005000012Q004F7Q00202D5Q0001001255000200064Q00203Q0002000200065A3Q001B000100010004483Q001B00012Q004F7Q00202D5Q0001001255000200074Q00203Q0002000200060D3Q003300013Q0004483Q003300012Q004F7Q0030063Q000800099Q0000304Q000A000B9Q0000206Q000C00122Q0001000D3Q00202Q00010001000C00202Q00010001000E00064Q0050000100010004483Q005000012Q004F7Q0020275Q000C00122Q0001000D3Q00202Q00010001000C00202Q00010001000F00064Q0050000100010004483Q005000012Q004F7Q0012130001000D3Q00202Q00010001000C00202Q00010001000E00104Q000C000100044Q005000012Q004F7Q00202D5Q0001001255000200104Q00203Q0002000200065A3Q003F000100010004483Q003F00012Q004F7Q00202D5Q0001001255000200114Q00203Q0002000200060D3Q004200013Q0004483Q004200012Q004F7Q00303F3Q001200130004483Q005000012Q004F7Q00202D5Q0001001255000200144Q00203Q0002000200065A3Q004E000100010004483Q004E00012Q004F7Q00202D5Q0001001255000200154Q00203Q0002000200060D3Q005000013Q0004483Q005000012Q004F7Q00303F3Q0016000B2Q00503Q00017Q00043Q002Q033Q00626F7803073Q0044657374726F7903093Q0062692Q6C626F61726400011B4Q004F00016Q001C000100013Q00060D0001001A00013Q0004483Q001A00012Q004F00016Q001C000100013Q00200100010001000100060D0001000E00013Q0004483Q000E00012Q004F00016Q001C000100013Q00200100010001000100202D0001000100022Q00360001000200012Q004F00016Q001C000100013Q00200100010001000300060D0001001800013Q0004483Q001800012Q004F00016Q001C000100013Q00200100010001000300202D0001000100022Q00360001000200012Q004F00015Q00202Q00013Q00042Q00503Q00017Q00043Q00030E3Q00436861726163746572412Q64656403073Q00436F2Q6E65637403183Q0047657450726F70657274794368616E6765645369676E616C03043Q005465616D01194Q004F00015Q0006373Q0004000100010004483Q000400012Q00503Q00013Q00065F00013Q000100072Q004F3Q00014Q00198Q004F3Q00024Q004F8Q004F3Q00034Q004F3Q00044Q004F3Q00053Q00203000023Q000100202Q0002000200024Q000400016Q00020004000100202Q00023Q000300122Q000400046Q00020004000200202Q0002000200024Q000400016Q0002000400014Q000200016Q0002000100016Q00013Q00013Q00313Q0003093Q00436861726163746572030E3Q00436861726163746572412Q64656403043Q0057616974030C3Q0057616974466F724368696C6403103Q0048756D616E6F6964522Q6F7450617274026Q00144003043Q005465616D0003083Q00496E7374616E63652Q033Q006E6577030C3Q0053656C656374696F6E426F7803043Q004E616D6503063Q00455350426F7803073Q0041646F726E2Q6503063Q00436F6C6F723303073Q0066726F6D524742028Q00025Q00E06F40030D3Q004C696E65546869636B6E652Q73029A5Q99A93F03133Q00537572666163655472616E73706172656E6379026Q66EE3F03063Q00506172656E74030C3Q0042692Q6C626F61726447756903043Q0053697A6503053Q005544696D32026Q005940026Q004940030B3Q00416C776179734F6E546F702Q01030B3Q0053747564734F2Q6673657403073Q00566563746F7233026Q000C40030E3Q0046696E6446697273744368696C6403043Q004865616403093Q00546578744C6162656C026Q00F03F03163Q004261636B67726F756E645472616E73706172656E6379030A3Q0054657874436F6C6F723303043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q00284003163Q00546578745374726F6B655472616E73706172656E6379026Q00E03F2Q033Q00626F7803093Q0062692Q6C626F61726403053Q006C6162656C007F4Q00229Q00000100018Q000200016Q00023Q00064Q0007000100010004483Q000700012Q00503Q00014Q004F3Q00013Q0020015Q000100065A3Q000F000100010004483Q000F00012Q004F3Q00013Q0020015Q000200202D5Q00032Q00513Q0002000200202D00013Q0004001255000300053Q001255000400064Q002000010004000200065A00010016000100010004483Q001600012Q00503Q00014Q004F000200013Q00200100020002000700261F00020020000100080004483Q002000012Q004F000200013Q0020010002000200072Q004F000300033Q00200100030003000700064D00020021000100030004483Q002100012Q001D00026Q0032000200014Q004F000300043Q00060D0003002800013Q0004483Q0028000100060D0002002800013Q0004483Q002800012Q00503Q00013Q001239000300093Q00200400030003000A00122Q0004000B6Q00030002000200302Q0003000C000D00102Q0003000E3Q00062Q0002003800013Q0004483Q003800010012390004000F3Q00204A00040004001000122Q000500113Q00122Q000600123Q00122Q000700116Q00040007000200062Q0004003E000100010004483Q003E00010012390004000F3Q00204400040004001000122Q000500123Q00122Q000600113Q00122Q000700116Q00040007000200104B0003000F000400300B00030013001400302Q0003001500164Q000400056Q00040001000200102Q00030017000400122Q000400093Q00202Q00040004000A00122Q000500186Q000600056Q000600016Q00043Q000200122Q0005001A3Q00202Q00050005000A00122Q000600113Q00122Q0007001B3Q00122Q000800113Q00122Q0009001C6Q00050009000200102Q00040019000500302Q0004001D001E00122Q000500203Q00202Q00050005000A00122Q000600113Q00122Q000700213Q00122Q000800116Q00050008000200102Q0004001F000500202Q00053Q002200122Q000700236Q00050007000200062Q00050060000100010004483Q006000012Q0019000500013Q00104B0004000E000500123D000500093Q00202Q00050005000A00122Q000600246Q000700046Q00050007000200122Q0006001A3Q00202Q00060006000A00122Q000700253Q00122Q000800113Q00122Q000900253Q00122Q000A00116Q0006000A000200102Q00050019000600302Q00050026002500202Q00060003000F00102Q00050027000600122Q000600293Q00202Q00060006002800202Q00060006002A00102Q00050028000600302Q0005002B002C00302Q0005002D002E4Q000600066Q000700016Q00083Q000300102Q0008002F000300102Q00080030000400102Q0008003100054Q0006000700086Q00017Q00023Q0003053Q007061697273030A3Q00476574506C6179657273000C3Q00122A3Q00016Q00015Q00202Q0001000100024Q000100029Q00000200044Q000900012Q004F000500014Q0019000600044Q003600050002000100061A3Q0006000100020004483Q000600012Q00503Q00017Q00283Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F6964030D3Q004D6F7665446972656374696F6E03093Q004D61676E6974756465028Q0003163Q00412Q73656D626C794C696E65617256656C6F63697479027Q0040026Q00594003073Q00566563746F72332Q033Q006E657703013Q005803013Q005903013Q005A030A3Q004A756D70486569676874029A5Q99D93F030D3Q00466C2Q6F724D6174657269616C03043Q00456E756D03083Q004D6174657269616C2Q033Q00416972026Q0044C003093Q0049734B6579446F776E03073Q004B6579436F646503053Q005370616365030B3Q004368616E6765537461746503113Q0048756D616E6F696453746174655479706503073Q004A756D70696E6703093Q004C656674536869667403063Q00434672616D65027B14AE47E17A843F03053Q00706169727303083Q00506F736974696F6E03053Q006C6162656C03043Q005465787403043Q004E616D6503023Q00205B03043Q006D61746803053Q00666C2Q6F7203013Q005D00A94Q004F7Q0020015Q000100060D3Q000900013Q0004483Q0009000100202D00013Q0002001255000300034Q002000010003000200065A0001000A000100010004483Q000A00012Q00503Q00013Q00200100013Q000300200100023Q00042Q004F000300013Q00060D0003002200013Q0004483Q0022000100200100030002000500200100030003000600261600030022000100070004483Q00220001002001000300010008002001000400030006000E3800090022000100040004483Q002200012Q004F000400023Q00200A00040004000A00122Q0005000B3Q00202Q00050005000C00202Q00060003000D4Q00060006000400202Q00070003000E00202Q00080003000F4Q0008000800044Q00050008000200102Q0001000800052Q004F000300033Q00060D0003002800013Q0004483Q002800012Q004F000300043Q00200C00030003001100104B0002001000032Q004F000300053Q00060D0003003E00013Q0004483Q003E0001002001000300020012001239000400133Q0020010004000400140020010004000400150006370003003E000100040004483Q003E000100200100030001000800200100030003000E0026250003003E000100160004483Q003E00010012390003000B3Q00201000030003000C00202Q00040001000800202Q00040004000D4Q000500063Q00202Q00060001000800202Q00060006000F4Q00030006000200102Q0001000800032Q004F000300073Q00060D0003004E00013Q0004483Q004E00012Q004F000300083Q00204200030003001700122Q000500133Q00202Q00050005001800202Q0005000500194Q00030005000200062Q0003004E00013Q0004483Q004E000100202D00030002001A001239000500133Q00200100050005001B00200100050005001C2Q00590003000500012Q004F000300093Q00060D0003007700013Q0004483Q007700012Q004F000300083Q00204200030003001700122Q000500133Q00202Q00050005001800202Q0005000500194Q00030005000200062Q0003005C00013Q0004483Q005C00012Q004F0003000A3Q00065A0003005D000100010004483Q005D0001001255000300074Q004F000400083Q00204200040004001700122Q000600133Q00202Q00060006001800202Q00060006001D4Q00040006000200062Q0004006900013Q0004483Q006900012Q004F0004000A4Q0003000400043Q00065A0004006A000100010004483Q006A0001001255000400074Q003400030003000400205C0004000200054Q0005000A6Q00040004000500122Q0005000B3Q00202Q00050005000C00122Q000600076Q000700033Q00122Q000800076Q0005000800024Q00040004000500102Q00010008000400044Q008500012Q004F0003000B3Q00060D0003008500013Q0004483Q00850001002001000300020005002001000300030006000E3800070085000100030004483Q0085000100200100030001001E00203A0004000200054Q0005000C6Q00040004000500202Q00040004001F4Q00030003000400102Q0001001E0003001239000300204Q004F0004000D4Q00080003000200050004483Q00A6000100200100080006000100060D000800A300013Q0004483Q00A3000100200100080006000100202D000800080002001255000A00034Q00200008000A000200060D000800A300013Q0004483Q00A3000100200100080001002100202F00090006000100202Q00090009000300202Q0009000900214Q00080008000900202Q00080008000600202Q00090007002200202Q000A0006002400122Q000B00253Q00122Q000C00263Q00202Q000C000C00274Q000D00086Q000C0002000200122Q000D00286Q000A000A000D00102Q00090023000A00044Q00A600012Q004F0008000E4Q0019000900064Q003600080002000100061A00030089000100020004483Q008900012Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001024Q002C8Q00503Q00019Q002Q0001044Q002C8Q004F000100014Q00560001000100012Q00503Q00019Q002Q0001044Q002C8Q004F000100014Q00560001000100012Q00503Q00019Q003Q00034Q004F8Q00563Q000100012Q00503Q00017Q00093Q00030C3Q00736574636C6970626F617264031B3Q00682Q7470733A2Q2F646973636F72642E2Q672F337657325650376B03063Q004E6F7469667903053Q005469746C6503083Q0053752Q63652Q732103073Q00436F6E74656E7403283Q00446973636F726420696E76697465206C696E6B20636F7069656420746F20636C6970626F6172642E03083Q004475726174696F6E026Q000840000B3Q00125E3Q00013Q00122Q000100028Q000200019Q0000206Q00034Q00023Q000300302Q00020004000500302Q00020006000700302Q0002000800096Q000200016Q00017Q00033Q0003043Q007461736B03043Q0077616974026Q00F03F00073Q0012573Q00013Q00206Q000200122Q000100038Q000200019Q006Q000100016Q00017Q00", GetFEnv(), ...);
