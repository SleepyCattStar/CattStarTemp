-- UPDATED THIS SCRIPT
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
			local FlatIdent_500AB = 0;
			while true do
				if (FlatIdent_500AB == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local FlatIdent_16D8E = 0;
			local a;
			while true do
				if (FlatIdent_16D8E == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local b = Rep(a, repeatNext);
						repeatNext = nil;
						return b;
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_95CAC = 0;
			local Res;
			while true do
				if (FlatIdent_95CAC == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local FlatIdent_76979 = 0;
		local a;
		while true do
			if (FlatIdent_76979 == 1) then
				return a;
			end
			if (FlatIdent_76979 == 0) then
				a = Byte(ByteString, DIP, DIP);
				DIP = DIP + 1;
				FlatIdent_76979 = 1;
			end
		end
	end
	local function gBits16()
		local FlatIdent_24A02 = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_24A02 == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_24A02 == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_24A02 = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_89ECE = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_89ECE == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_8199B = 0;
						while true do
							if (FlatIdent_8199B == 0) then
								Exponent = 1;
								IsNormal = 0;
								break;
							end
						end
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_89ECE == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_89ECE = 3;
			end
			if (FlatIdent_89ECE == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_89ECE = 2;
			end
			if (FlatIdent_89ECE == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_89ECE = 1;
			end
		end
	end
	local function gString(Len)
		local FlatIdent_39B0 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_39B0 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_39B0 = 3;
			end
			if (3 == FlatIdent_39B0) then
				return Concat(FStr);
			end
			if (FlatIdent_39B0 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_39B0 = 2;
			end
			if (FlatIdent_39B0 == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_54A2D = 0;
					while true do
						if (0 == FlatIdent_54A2D) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_39B0 = 1;
			end
		end
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
			local FlatIdent_61B23 = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_61B23 == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_61B23 = 1;
				end
				if (FlatIdent_61B23 == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_946F = 0;
			local Descriptor;
			while true do
				if (FlatIdent_946F == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_6053C = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_6053C == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_6053C = 1;
							end
							if (FlatIdent_6053C == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_6053C = 3;
							end
							if (FlatIdent_6053C == 1) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									local FlatIdent_6A83E = 0;
									while true do
										if (FlatIdent_6A83E == 0) then
											Inst[3] = gBits32() - (2 ^ 16);
											Inst[4] = gBits16();
											break;
										end
									end
								end
								FlatIdent_6053C = 2;
							end
							if (FlatIdent_6053C == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
						end
					end
					break;
				end
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
				local FlatIdent_24149 = 0;
				while true do
					if (1 == FlatIdent_24149) then
						if (Enum <= 183) then
							if (Enum <= 91) then
								if (Enum <= 45) then
									if (Enum <= 22) then
										if (Enum <= 10) then
											if (Enum <= 4) then
												if (Enum <= 1) then
													if (Enum > 0) then
														local FlatIdent_3317B = 0;
														local Edx;
														local Results;
														local Limit;
														local A;
														while true do
															if (8 == FlatIdent_3317B) then
																Top = (Limit + A) - 1;
																Edx = 0;
																for Idx = A, Top do
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																end
																break;
															end
															if (FlatIdent_3317B == 2) then
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																FlatIdent_3317B = 3;
															end
															if (FlatIdent_3317B == 7) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																A = Inst[2];
																Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
																FlatIdent_3317B = 8;
															end
															if (FlatIdent_3317B == 5) then
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																FlatIdent_3317B = 6;
															end
															if (FlatIdent_3317B == 0) then
																Edx = nil;
																Results, Limit = nil;
																A = nil;
																Stk[Inst[2]] = Inst[3];
																FlatIdent_3317B = 1;
															end
															if (FlatIdent_3317B == 4) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																VIP = VIP + 1;
																FlatIdent_3317B = 5;
															end
															if (FlatIdent_3317B == 3) then
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Env[Inst[3]];
																FlatIdent_3317B = 4;
															end
															if (1 == FlatIdent_3317B) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																FlatIdent_3317B = 2;
															end
															if (FlatIdent_3317B == 6) then
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																FlatIdent_3317B = 7;
															end
														end
													else
														local FlatIdent_E0D0 = 0;
														local Edx;
														local Results;
														local Limit;
														local A;
														while true do
															if (FlatIdent_E0D0 == 0) then
																Edx = nil;
																Results, Limit = nil;
																A = nil;
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																FlatIdent_E0D0 = 1;
															end
															if (FlatIdent_E0D0 == 2) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																FlatIdent_E0D0 = 3;
															end
															if (FlatIdent_E0D0 == 3) then
																Stk[Inst[2]] = Env[Inst[3]];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
																VIP = VIP + 1;
																FlatIdent_E0D0 = 4;
															end
															if (FlatIdent_E0D0 == 6) then
																A = Inst[2];
																Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
																Top = (Limit + A) - 1;
																Edx = 0;
																for Idx = A, Top do
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																end
																break;
															end
															if (FlatIdent_E0D0 == 1) then
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																FlatIdent_E0D0 = 2;
															end
															if (FlatIdent_E0D0 == 4) then
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																FlatIdent_E0D0 = 5;
															end
															if (FlatIdent_E0D0 == 5) then
																VIP = VIP + 1;
																Inst = Instr[VIP];
																Stk[Inst[2]] = Inst[3];
																VIP = VIP + 1;
																Inst = Instr[VIP];
																FlatIdent_E0D0 = 6;
															end
														end
													end
												elseif (Enum <= 2) then
													Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
												elseif (Enum == 3) then
													local FlatIdent_292FD = 0;
													local A;
													while true do
														if (FlatIdent_292FD == 2) then
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															FlatIdent_292FD = 3;
														end
														if (FlatIdent_292FD == 5) then
															Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_292FD = 6;
														end
														if (FlatIdent_292FD == 7) then
															Inst = Instr[VIP];
															Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
															break;
														end
														if (3 == FlatIdent_292FD) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_292FD = 4;
														end
														if (FlatIdent_292FD == 0) then
															A = nil;
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_292FD = 1;
														end
														if (FlatIdent_292FD == 4) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_292FD = 5;
														end
														if (FlatIdent_292FD == 1) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_292FD = 2;
														end
														if (FlatIdent_292FD == 6) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_292FD = 7;
														end
													end
												else
													local A;
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
												end
											elseif (Enum <= 7) then
												if (Enum <= 5) then
													local FlatIdent_145B1 = 0;
													local T;
													local Edx;
													local Results;
													local Limit;
													local A;
													while true do
														if (3 == FlatIdent_145B1) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_145B1 = 4;
														end
														if (0 == FlatIdent_145B1) then
															T = nil;
															Edx = nil;
															Results, Limit = nil;
															A = nil;
															FlatIdent_145B1 = 1;
														end
														if (FlatIdent_145B1 == 1) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_145B1 = 2;
														end
														if (FlatIdent_145B1 == 6) then
															T = Stk[A];
															for Idx = A + 1, Top do
																Insert(T, Stk[Idx]);
															end
															break;
														end
														if (FlatIdent_145B1 == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_145B1 = 3;
														end
														if (FlatIdent_145B1 == 5) then
															for Idx = A, Top do
																local FlatIdent_9622C = 0;
																while true do
																	if (FlatIdent_9622C == 0) then
																		Edx = Edx + 1;
																		Stk[Idx] = Results[Edx];
																		break;
																	end
																end
															end
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_145B1 = 6;
														end
														if (FlatIdent_145B1 == 4) then
															A = Inst[2];
															Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
															Top = (Limit + A) - 1;
															Edx = 0;
															FlatIdent_145B1 = 5;
														end
													end
												elseif (Enum > 6) then
													local FlatIdent_2D88C = 0;
													local B;
													local A;
													while true do
														if (FlatIdent_2D88C == 3) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_2D88C = 4;
														end
														if (FlatIdent_2D88C == 0) then
															B = nil;
															A = nil;
															A = Inst[2];
															FlatIdent_2D88C = 1;
														end
														if (6 == FlatIdent_2D88C) then
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
														if (FlatIdent_2D88C == 1) then
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															FlatIdent_2D88C = 2;
														end
														if (FlatIdent_2D88C == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_2D88C = 3;
														end
														if (5 == FlatIdent_2D88C) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_2D88C = 6;
														end
														if (4 == FlatIdent_2D88C) then
															Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_2D88C = 5;
														end
													end
												else
													local B;
													local A;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if (Stk[Inst[2]] > Inst[4]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
												end
											elseif (Enum <= 8) then
												local FlatIdent_2F37F = 0;
												while true do
													if (FlatIdent_2F37F == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_2F37F = 1;
													end
													if (FlatIdent_2F37F == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2F37F = 3;
													end
													if (FlatIdent_2F37F == 3) then
														Stk[Inst[2]][Inst[3]] = Inst[4];
														break;
													end
													if (FlatIdent_2F37F == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_2F37F = 2;
													end
												end
											elseif (Enum == 9) then
												local FlatIdent_4D434 = 0;
												local A;
												local T;
												while true do
													if (FlatIdent_4D434 == 0) then
														A = Inst[2];
														T = Stk[A];
														FlatIdent_4D434 = 1;
													end
													if (FlatIdent_4D434 == 1) then
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
												end
											else
												local FlatIdent_3D56F = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_3D56F == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3D56F = 4;
													end
													if (FlatIdent_3D56F == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3D56F = 5;
													end
													if (2 == FlatIdent_3D56F) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3D56F = 3;
													end
													if (FlatIdent_3D56F == 1) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3D56F = 2;
													end
													if (FlatIdent_3D56F == 6) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_61800 = 0;
															while true do
																if (FlatIdent_61800 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														FlatIdent_3D56F = 7;
													end
													if (FlatIdent_3D56F == 5) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_3D56F = 6;
													end
													if (FlatIdent_3D56F == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_3D56F = 8;
													end
													if (FlatIdent_3D56F == 8) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
													if (0 == FlatIdent_3D56F) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														FlatIdent_3D56F = 1;
													end
												end
											end
										elseif (Enum <= 16) then
											if (Enum <= 13) then
												if (Enum <= 11) then
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												elseif (Enum == 12) then
													local FlatIdent_94366 = 0;
													local B;
													local A;
													while true do
														if (FlatIdent_94366 == 0) then
															B = nil;
															A = nil;
															A = Inst[2];
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_94366 = 1;
														end
														if (FlatIdent_94366 == 12) then
															Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															FlatIdent_94366 = 13;
														end
														if (FlatIdent_94366 == 9) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = {};
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_94366 = 10;
														end
														if (FlatIdent_94366 == 1) then
															Stk[Inst[2]] = {};
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															FlatIdent_94366 = 2;
														end
														if (FlatIdent_94366 == 17) then
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
															break;
														end
														if (2 == FlatIdent_94366) then
															Inst = Instr[VIP];
															Stk[Inst[2]][Inst[3]] = Inst[4];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_94366 = 3;
														end
														if (10 == FlatIdent_94366) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_94366 = 11;
														end
														if (FlatIdent_94366 == 3) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A](Stk[A + 1]);
															FlatIdent_94366 = 4;
														end
														if (FlatIdent_94366 == 6) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_94366 = 7;
														end
														if (FlatIdent_94366 == 4) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_94366 = 5;
														end
														if (FlatIdent_94366 == 5) then
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															FlatIdent_94366 = 6;
														end
														if (FlatIdent_94366 == 16) then
															Inst = Instr[VIP];
															A = Inst[2];
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_94366 = 17;
														end
														if (FlatIdent_94366 == 7) then
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															B = Stk[Inst[3]];
															FlatIdent_94366 = 8;
														end
														if (FlatIdent_94366 == 15) then
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A](Stk[A + 1]);
															VIP = VIP + 1;
															FlatIdent_94366 = 16;
														end
														if (FlatIdent_94366 == 8) then
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]];
															FlatIdent_94366 = 9;
														end
														if (14 == FlatIdent_94366) then
															A = Inst[2];
															Stk[A](Stk[A + 1]);
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_94366 = 15;
														end
														if (FlatIdent_94366 == 13) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_94366 = 14;
														end
														if (11 == FlatIdent_94366) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_94366 = 12;
														end
													end
												else
													local FlatIdent_90A41 = 0;
													local Results;
													local Edx;
													local Limit;
													local B;
													local A;
													while true do
														if (FlatIdent_90A41 == 6) then
															VIP = Inst[3];
															break;
														end
														if (FlatIdent_90A41 == 4) then
															Results, Limit = _R(Stk[A](Stk[A + 1]));
															Top = (Limit + A) - 1;
															Edx = 0;
															for Idx = A, Top do
																local FlatIdent_1CA5D = 0;
																while true do
																	if (FlatIdent_1CA5D == 0) then
																		Edx = Edx + 1;
																		Stk[Idx] = Results[Edx];
																		break;
																	end
																end
															end
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_90A41 = 5;
														end
														if (FlatIdent_90A41 == 5) then
															A = Inst[2];
															Results = {Stk[A](Unpack(Stk, A + 1, Top))};
															Edx = 0;
															for Idx = A, Inst[4] do
																local FlatIdent_900FA = 0;
																while true do
																	if (FlatIdent_900FA == 0) then
																		Edx = Edx + 1;
																		Stk[Idx] = Results[Edx];
																		break;
																	end
																end
															end
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_90A41 = 6;
														end
														if (FlatIdent_90A41 == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_90A41 = 3;
														end
														if (FlatIdent_90A41 == 3) then
															B = Stk[Inst[3]];
															Stk[A + 1] = B;
															Stk[A] = B[Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_90A41 = 4;
														end
														if (FlatIdent_90A41 == 1) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_90A41 = 2;
														end
														if (FlatIdent_90A41 == 0) then
															Results = nil;
															Edx = nil;
															Results, Limit = nil;
															B = nil;
															A = nil;
															Stk[Inst[2]] = {};
															FlatIdent_90A41 = 1;
														end
													end
												end
											elseif (Enum <= 14) then
												local FlatIdent_272FB = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_272FB == 6) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														break;
													end
													if (FlatIdent_272FB == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_272FB = 1;
													end
													if (FlatIdent_272FB == 4) then
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_272FB = 5;
													end
													if (FlatIdent_272FB == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_272FB = 4;
													end
													if (FlatIdent_272FB == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_272FB = 3;
													end
													if (FlatIdent_272FB == 1) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_272FB = 2;
													end
													if (FlatIdent_272FB == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_272FB = 6;
													end
												end
											elseif (Enum > 15) then
												local B;
												local A;
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
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
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
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
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
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
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
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
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
												VIP = Inst[3];
											else
												local FlatIdent_1CF31 = 0;
												local B;
												local T;
												local A;
												while true do
													if (FlatIdent_1CF31 == 23) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 24;
													end
													if (FlatIdent_1CF31 == 19) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 20;
													end
													if (FlatIdent_1CF31 == 1) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 2;
													end
													if (FlatIdent_1CF31 == 17) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 18;
													end
													if (FlatIdent_1CF31 == 12) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_1CF31 = 13;
													end
													if (FlatIdent_1CF31 == 22) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 23;
													end
													if (3 == FlatIdent_1CF31) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_1CF31 = 4;
													end
													if (FlatIdent_1CF31 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_1CF31 = 5;
													end
													if (FlatIdent_1CF31 == 14) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1CF31 = 15;
													end
													if (FlatIdent_1CF31 == 9) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 10;
													end
													if (FlatIdent_1CF31 == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_1CF31 = 11;
													end
													if (FlatIdent_1CF31 == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1CF31 = 14;
													end
													if (FlatIdent_1CF31 == 21) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 22;
													end
													if (FlatIdent_1CF31 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_1CF31 = 6;
													end
													if (FlatIdent_1CF31 == 0) then
														B = nil;
														T = nil;
														A = nil;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1CF31 = 1;
													end
													if (FlatIdent_1CF31 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 3;
													end
													if (FlatIdent_1CF31 == 6) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1CF31 = 7;
													end
													if (FlatIdent_1CF31 == 8) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 9;
													end
													if (25 == FlatIdent_1CF31) then
														Inst = Instr[VIP];
														A = Inst[2];
														T = Stk[A];
														B = Inst[3];
														for Idx = 1, B do
															T[Idx] = Stk[A + Idx];
														end
														break;
													end
													if (FlatIdent_1CF31 == 18) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 19;
													end
													if (FlatIdent_1CF31 == 7) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1CF31 = 8;
													end
													if (FlatIdent_1CF31 == 16) then
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														FlatIdent_1CF31 = 17;
													end
													if (FlatIdent_1CF31 == 20) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 21;
													end
													if (FlatIdent_1CF31 == 15) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_1CF31 = 16;
													end
													if (FlatIdent_1CF31 == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_1CF31 = 12;
													end
													if (FlatIdent_1CF31 == 24) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1CF31 = 25;
													end
												end
											end
										elseif (Enum <= 19) then
											if (Enum <= 17) then
												local B;
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												do
													return Stk[A](Unpack(Stk, A + 1, Inst[3]));
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												do
													return Unpack(Stk, A, Top);
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
											elseif (Enum > 18) then
												local FlatIdent_6679B = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_6679B == 0) then
														B = nil;
														A = nil;
														A = Inst[2];
														FlatIdent_6679B = 1;
													end
													if (FlatIdent_6679B == 1) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_6679B = 2;
													end
													if (FlatIdent_6679B == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_6679B = 5;
													end
													if (FlatIdent_6679B == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_6679B = 4;
													end
													if (FlatIdent_6679B == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_6679B = 7;
													end
													if (FlatIdent_6679B == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														FlatIdent_6679B = 3;
													end
													if (FlatIdent_6679B == 7) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														break;
													end
													if (FlatIdent_6679B == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_6679B = 6;
													end
												end
											else
												local Edx;
												local Results, Limit;
												local A;
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
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_BCAB = 0;
													while true do
														if (FlatIdent_BCAB == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
											end
										elseif (Enum <= 20) then
											local FlatIdent_3F7F4 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_3F7F4 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3F7F4 = 1;
												end
												if (FlatIdent_3F7F4 == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_3F7F4 == 1) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_3F7F4 = 2;
												end
												if (2 == FlatIdent_3F7F4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3F7F4 = 3;
												end
												if (FlatIdent_3F7F4 == 3) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													FlatIdent_3F7F4 = 4;
												end
												if (FlatIdent_3F7F4 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3F7F4 = 6;
												end
												if (FlatIdent_3F7F4 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3F7F4 = 5;
												end
											end
										elseif (Enum > 21) then
											local FlatIdent_73DFF = 0;
											local A;
											local Results;
											local Edx;
											while true do
												if (FlatIdent_73DFF == 1) then
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_956D = 0;
														while true do
															if (FlatIdent_956D == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													break;
												end
												if (FlatIdent_73DFF == 0) then
													A = Inst[2];
													Results = {Stk[A](Stk[A + 1])};
													FlatIdent_73DFF = 1;
												end
											end
										else
											local FlatIdent_25F6B = 0;
											local A;
											while true do
												if (FlatIdent_25F6B == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 3;
												end
												if (8 == FlatIdent_25F6B) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 9;
												end
												if (FlatIdent_25F6B == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 2;
												end
												if (FlatIdent_25F6B == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 8;
												end
												if (FlatIdent_25F6B == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 1;
												end
												if (FlatIdent_25F6B == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 4;
												end
												if (9 == FlatIdent_25F6B) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_25F6B == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_25F6B = 6;
												end
												if (FlatIdent_25F6B == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_25F6B = 7;
												end
												if (FlatIdent_25F6B == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_25F6B = 5;
												end
											end
										end
									elseif (Enum <= 33) then
										if (Enum <= 27) then
											if (Enum <= 24) then
												if (Enum > 23) then
													local FlatIdent_7613F = 0;
													local A;
													while true do
														if (FlatIdent_7613F == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_7613F = 3;
														end
														if (FlatIdent_7613F == 3) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_7613F = 4;
														end
														if (FlatIdent_7613F == 5) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_7613F = 6;
														end
														if (FlatIdent_7613F == 7) then
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															break;
														end
														if (FlatIdent_7613F == 4) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_7613F = 5;
														end
														if (6 == FlatIdent_7613F) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_7613F = 7;
														end
														if (FlatIdent_7613F == 0) then
															A = nil;
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_7613F = 1;
														end
														if (1 == FlatIdent_7613F) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_7613F = 2;
														end
													end
												else
													local B;
													local A;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
													Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
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
												end
											elseif (Enum <= 25) then
												local FlatIdent_3B868 = 0;
												local A;
												while true do
													if (FlatIdent_3B868 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 7;
													end
													if (FlatIdent_3B868 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 2;
													end
													if (FlatIdent_3B868 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 4;
													end
													if (4 == FlatIdent_3B868) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_3B868 = 5;
													end
													if (FlatIdent_3B868 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3B868 = 6;
													end
													if (2 == FlatIdent_3B868) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 3;
													end
													if (9 == FlatIdent_3B868) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														break;
													end
													if (FlatIdent_3B868 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 8;
													end
													if (FlatIdent_3B868 == 8) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 9;
													end
													if (FlatIdent_3B868 == 0) then
														A = nil;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_3B868 = 1;
													end
												end
											elseif (Enum == 26) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
											else
												local FlatIdent_8EA6E = 0;
												local A;
												local Results;
												local Limit;
												local Edx;
												while true do
													if (FlatIdent_8EA6E == 1) then
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_8EA6E = 2;
													end
													if (2 == FlatIdent_8EA6E) then
														for Idx = A, Top do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														break;
													end
													if (FlatIdent_8EA6E == 0) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_8EA6E = 1;
													end
												end
											end
										elseif (Enum <= 30) then
											if (Enum <= 28) then
												local FlatIdent_14EC9 = 0;
												local A;
												while true do
													if (FlatIdent_14EC9 == 0) then
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														break;
													end
												end
											elseif (Enum > 29) then
												local FlatIdent_163A8 = 0;
												local A;
												while true do
													if (FlatIdent_163A8 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 2;
													end
													if (FlatIdent_163A8 == 8) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 9;
													end
													if (FlatIdent_163A8 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 3;
													end
													if (FlatIdent_163A8 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_163A8 = 5;
													end
													if (FlatIdent_163A8 == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_163A8 = 6;
													end
													if (FlatIdent_163A8 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 4;
													end
													if (FlatIdent_163A8 == 9) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														break;
													end
													if (FlatIdent_163A8 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 8;
													end
													if (0 == FlatIdent_163A8) then
														A = nil;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 1;
													end
													if (FlatIdent_163A8 == 6) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_163A8 = 7;
													end
												end
											else
												local FlatIdent_8B7B0 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_8B7B0 == 9) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														FlatIdent_8B7B0 = 10;
													end
													if (FlatIdent_8B7B0 == 2) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8B7B0 = 3;
													end
													if (3 == FlatIdent_8B7B0) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8B7B0 = 4;
													end
													if (FlatIdent_8B7B0 == 8) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_8B7B0 = 9;
													end
													if (FlatIdent_8B7B0 == 6) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_8B7B0 = 7;
													end
													if (FlatIdent_8B7B0 == 7) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8B7B0 = 8;
													end
													if (10 == FlatIdent_8B7B0) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A]();
														break;
													end
													if (1 == FlatIdent_8B7B0) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_8B7B0 = 2;
													end
													if (0 == FlatIdent_8B7B0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8B7B0 = 1;
													end
													if (FlatIdent_8B7B0 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8B7B0 = 6;
													end
													if (4 == FlatIdent_8B7B0) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_8B7B0 = 5;
													end
												end
											end
										elseif (Enum <= 31) then
											local Edx;
											local Results, Limit;
											local A;
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
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_8BE54 = 0;
												while true do
													if (FlatIdent_8BE54 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
										elseif (Enum > 32) then
											local A;
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
										else
											local FlatIdent_6F99F = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (2 == FlatIdent_6F99F) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6F99F = 3;
												end
												if (FlatIdent_6F99F == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6F99F = 5;
												end
												if (FlatIdent_6F99F == 8) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_6F99F == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_6F99F = 1;
												end
												if (FlatIdent_6F99F == 1) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6F99F = 2;
												end
												if (3 == FlatIdent_6F99F) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6F99F = 4;
												end
												if (5 == FlatIdent_6F99F) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_6F99F = 6;
												end
												if (6 == FlatIdent_6F99F) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													FlatIdent_6F99F = 7;
												end
												if (FlatIdent_6F99F == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_6F99F = 8;
												end
											end
										end
									elseif (Enum <= 39) then
										if (Enum <= 36) then
											if (Enum <= 34) then
												local FlatIdent_45CCF = 0;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_45CCF == 1) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45CCF = 2;
													end
													if (FlatIdent_45CCF == 2) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45CCF = 3;
													end
													if (FlatIdent_45CCF == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45CCF = 4;
													end
													if (FlatIdent_45CCF == 4) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45CCF = 5;
													end
													if (5 == FlatIdent_45CCF) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_4D907 = 0;
															while true do
																if (FlatIdent_4D907 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														break;
													end
													if (FlatIdent_45CCF == 0) then
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45CCF = 1;
													end
												end
											elseif (Enum > 35) then
												local FlatIdent_47EEF = 0;
												local NewProto;
												local NewUvals;
												local Indexes;
												while true do
													if (FlatIdent_47EEF == 2) then
														for Idx = 1, Inst[4] do
															local FlatIdent_3416F = 0;
															local Mvm;
															while true do
																if (FlatIdent_3416F == 1) then
																	if (Mvm[1] == 263) then
																		Indexes[Idx - 1] = {Stk,Mvm[3]};
																	else
																		Indexes[Idx - 1] = {Upvalues,Mvm[3]};
																	end
																	Lupvals[#Lupvals + 1] = Indexes;
																	break;
																end
																if (FlatIdent_3416F == 0) then
																	VIP = VIP + 1;
																	Mvm = Instr[VIP];
																	FlatIdent_3416F = 1;
																end
															end
														end
														Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
														break;
													end
													if (FlatIdent_47EEF == 1) then
														Indexes = {};
														NewUvals = Setmetatable({}, {__index=function(_, Key)
															local FlatIdent_55FDA = 0;
															local Val;
															while true do
																if (FlatIdent_55FDA == 0) then
																	Val = Indexes[Key];
																	return Val[1][Val[2]];
																end
															end
														end,__newindex=function(_, Key, Value)
															local FlatIdent_77CC3 = 0;
															local Val;
															while true do
																if (FlatIdent_77CC3 == 0) then
																	Val = Indexes[Key];
																	Val[1][Val[2]] = Value;
																	break;
																end
															end
														end});
														FlatIdent_47EEF = 2;
													end
													if (FlatIdent_47EEF == 0) then
														NewProto = Proto[Inst[3]];
														NewUvals = nil;
														FlatIdent_47EEF = 1;
													end
												end
											else
												local FlatIdent_87C42 = 0;
												while true do
													if (FlatIdent_87C42 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_87C42 = 2;
													end
													if (FlatIdent_87C42 == 2) then
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_87C42 = 3;
													end
													if (FlatIdent_87C42 == 4) then
														if (Stk[Inst[2]] < Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_87C42 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_87C42 = 4;
													end
													if (FlatIdent_87C42 == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_87C42 = 1;
													end
												end
											end
										elseif (Enum <= 37) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
										elseif (Enum > 38) then
											local FlatIdent_6F3E4 = 0;
											local A;
											while true do
												if (FlatIdent_6F3E4 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_6F3E4 = 2;
												end
												if (FlatIdent_6F3E4 == 0) then
													A = nil;
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6F3E4 = 1;
												end
												if (FlatIdent_6F3E4 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6F3E4 = 4;
												end
												if (FlatIdent_6F3E4 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_6F3E4 = 8;
												end
												if (4 == FlatIdent_6F3E4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													FlatIdent_6F3E4 = 5;
												end
												if (FlatIdent_6F3E4 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_6F3E4 = 7;
												end
												if (FlatIdent_6F3E4 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6F3E4 = 6;
												end
												if (FlatIdent_6F3E4 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_6F3E4 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6F3E4 = 9;
												end
												if (2 == FlatIdent_6F3E4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6F3E4 = 3;
												end
											end
										else
											local FlatIdent_5EF9 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_5EF9 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_5EF9 = 2;
												end
												if (FlatIdent_5EF9 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_5EF9 = 4;
												end
												if (FlatIdent_5EF9 == 2) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5EF9 = 3;
												end
												if (4 == FlatIdent_5EF9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (0 == FlatIdent_5EF9) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_5EF9 = 1;
												end
											end
										end
									elseif (Enum <= 42) then
										if (Enum <= 40) then
											local FlatIdent_3F6AB = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_3F6AB == 3) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_3F6AB = 4;
												end
												if (2 == FlatIdent_3F6AB) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3F6AB = 3;
												end
												if (FlatIdent_3F6AB == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_3F6AB = 1;
												end
												if (FlatIdent_3F6AB == 5) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_3F6AB = 6;
												end
												if (FlatIdent_3F6AB == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_3F6AB = 5;
												end
												if (FlatIdent_3F6AB == 6) then
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
													break;
												end
												if (1 == FlatIdent_3F6AB) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3F6AB = 2;
												end
											end
										elseif (Enum == 41) then
											local FlatIdent_202CC = 0;
											local B;
											local A;
											while true do
												if (2 == FlatIdent_202CC) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_202CC = 3;
												end
												if (7 == FlatIdent_202CC) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_202CC = 8;
												end
												if (FlatIdent_202CC == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_202CC = 1;
												end
												if (FlatIdent_202CC == 5) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_202CC = 6;
												end
												if (FlatIdent_202CC == 1) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_202CC = 2;
												end
												if (FlatIdent_202CC == 6) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_202CC = 7;
												end
												if (FlatIdent_202CC == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (3 == FlatIdent_202CC) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													FlatIdent_202CC = 4;
												end
												if (FlatIdent_202CC == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_202CC = 5;
												end
											end
										else
											local FlatIdent_904EC = 0;
											local A;
											while true do
												if (FlatIdent_904EC == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 2;
												end
												if (FlatIdent_904EC == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 8;
												end
												if (FlatIdent_904EC == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 1;
												end
												if (FlatIdent_904EC == 9) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_904EC == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 4;
												end
												if (FlatIdent_904EC == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 9;
												end
												if (FlatIdent_904EC == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 7;
												end
												if (FlatIdent_904EC == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_904EC = 6;
												end
												if (FlatIdent_904EC == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_904EC = 5;
												end
												if (FlatIdent_904EC == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_904EC = 3;
												end
											end
										end
									elseif (Enum <= 43) then
										local FlatIdent_5E6B6 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5E6B6 == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_5E6B6 = 5;
											end
											if (FlatIdent_5E6B6 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5E6B6 = 4;
											end
											if (FlatIdent_5E6B6 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_5E6B6 = 3;
											end
											if (FlatIdent_5E6B6 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5E6B6 = 7;
											end
											if (FlatIdent_5E6B6 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5E6B6 = 1;
											end
											if (7 == FlatIdent_5E6B6) then
												Inst = Instr[VIP];
												B = Stk[Inst[4]];
												if B then
													VIP = VIP + 1;
												else
													local FlatIdent_7C89 = 0;
													while true do
														if (FlatIdent_7C89 == 0) then
															Stk[Inst[2]] = B;
															VIP = Inst[3];
															break;
														end
													end
												end
												break;
											end
											if (FlatIdent_5E6B6 == 5) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5E6B6 = 6;
											end
											if (FlatIdent_5E6B6 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5E6B6 = 2;
											end
										end
									elseif (Enum > 44) then
										local FlatIdent_D895 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_D895 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_D895 = 6;
											end
											if (FlatIdent_D895 == 1) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_D895 = 2;
											end
											if (4 == FlatIdent_D895) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_D895 = 5;
											end
											if (FlatIdent_D895 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_D895 = 1;
											end
											if (FlatIdent_D895 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_D895 = 4;
											end
											if (FlatIdent_D895 == 6) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Stk[Inst[4]]];
												break;
											end
											if (FlatIdent_D895 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_D895 = 3;
											end
										end
									else
										local FlatIdent_5A6B8 = 0;
										local A;
										while true do
											if (FlatIdent_5A6B8 == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 7;
											end
											if (FlatIdent_5A6B8 == 19) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 20;
											end
											if (FlatIdent_5A6B8 == 18) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 19;
											end
											if (FlatIdent_5A6B8 == 7) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 8;
											end
											if (31 == FlatIdent_5A6B8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												break;
											end
											if (FlatIdent_5A6B8 == 27) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 28;
											end
											if (FlatIdent_5A6B8 == 14) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 15;
											end
											if (2 == FlatIdent_5A6B8) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5A6B8 = 3;
											end
											if (23 == FlatIdent_5A6B8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 24;
											end
											if (FlatIdent_5A6B8 == 29) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5A6B8 = 30;
											end
											if (FlatIdent_5A6B8 == 15) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_5A6B8 = 16;
											end
											if (FlatIdent_5A6B8 == 28) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 29;
											end
											if (FlatIdent_5A6B8 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 2;
											end
											if (FlatIdent_5A6B8 == 24) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5A6B8 = 25;
											end
											if (FlatIdent_5A6B8 == 17) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 18;
											end
											if (20 == FlatIdent_5A6B8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5A6B8 = 21;
											end
											if (FlatIdent_5A6B8 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5A6B8 = 1;
											end
											if (FlatIdent_5A6B8 == 21) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 22;
											end
											if (FlatIdent_5A6B8 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 4;
											end
											if (FlatIdent_5A6B8 == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5A6B8 = 10;
											end
											if (26 == FlatIdent_5A6B8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_5A6B8 = 27;
											end
											if (12 == FlatIdent_5A6B8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 13;
											end
											if (FlatIdent_5A6B8 == 8) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 9;
											end
											if (FlatIdent_5A6B8 == 22) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5A6B8 = 23;
											end
											if (FlatIdent_5A6B8 == 16) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 17;
											end
											if (FlatIdent_5A6B8 == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5A6B8 = 14;
											end
											if (FlatIdent_5A6B8 == 25) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 26;
											end
											if (30 == FlatIdent_5A6B8) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 31;
											end
											if (FlatIdent_5A6B8 == 10) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5A6B8 = 11;
											end
											if (FlatIdent_5A6B8 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A6B8 = 6;
											end
											if (FlatIdent_5A6B8 == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5A6B8 = 12;
											end
											if (FlatIdent_5A6B8 == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_5A6B8 = 5;
											end
										end
									end
								elseif (Enum <= 68) then
									if (Enum <= 56) then
										if (Enum <= 50) then
											if (Enum <= 47) then
												if (Enum > 46) then
													local FlatIdent_2C2F3 = 0;
													local A;
													while true do
														if (FlatIdent_2C2F3 == 0) then
															A = nil;
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_2C2F3 = 1;
														end
														if (FlatIdent_2C2F3 == 4) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_2C2F3 = 5;
														end
														if (FlatIdent_2C2F3 == 1) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_2C2F3 = 2;
														end
														if (FlatIdent_2C2F3 == 2) then
															Stk[A](Stk[A + 1]);
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_2C2F3 = 3;
														end
														if (FlatIdent_2C2F3 == 3) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															FlatIdent_2C2F3 = 4;
														end
														if (FlatIdent_2C2F3 == 5) then
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
													end
												else
													local FlatIdent_28DC7 = 0;
													while true do
														if (FlatIdent_28DC7 == 2) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_28DC7 = 3;
														end
														if (0 == FlatIdent_28DC7) then
															Upvalues[Inst[3]] = Stk[Inst[2]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Upvalues[Inst[3]];
															FlatIdent_28DC7 = 1;
														end
														if (FlatIdent_28DC7 == 3) then
															if Stk[Inst[2]] then
																VIP = VIP + 1;
															else
																VIP = Inst[3];
															end
															break;
														end
														if (FlatIdent_28DC7 == 1) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															FlatIdent_28DC7 = 2;
														end
													end
												end
											elseif (Enum <= 48) then
												local FlatIdent_82714 = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_82714 == 4) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_82714 = 5;
													end
													if (FlatIdent_82714 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_82714 = 3;
													end
													if (FlatIdent_82714 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_82714 = 2;
													end
													if (FlatIdent_82714 == 6) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
													if (FlatIdent_82714 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_82714 = 4;
													end
													if (FlatIdent_82714 == 0) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														FlatIdent_82714 = 1;
													end
													if (FlatIdent_82714 == 5) then
														for Idx = A, Top do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_82714 = 6;
													end
												end
											elseif (Enum > 49) then
												local FlatIdent_3EDDC = 0;
												while true do
													if (1 == FlatIdent_3EDDC) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3EDDC = 2;
													end
													if (2 == FlatIdent_3EDDC) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3EDDC = 3;
													end
													if (FlatIdent_3EDDC == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_3EDDC = 1;
													end
													if (FlatIdent_3EDDC == 3) then
														if (Stk[Inst[2]] < Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
												end
											else
												local FlatIdent_45AC8 = 0;
												local Edx;
												local Results;
												local Limit;
												local B;
												local A;
												while true do
													if (FlatIdent_45AC8 == 5) then
														Stk[Inst[2]] = #Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if (Inst[2] < Stk[Inst[4]]) then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_45AC8 == 3) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_82BF = 0;
															while true do
																if (FlatIdent_82BF == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														FlatIdent_45AC8 = 4;
													end
													if (FlatIdent_45AC8 == 2) then
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_45AC8 = 3;
													end
													if (4 == FlatIdent_45AC8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_45AC8 = 5;
													end
													if (FlatIdent_45AC8 == 0) then
														Edx = nil;
														Results, Limit = nil;
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_45AC8 = 1;
													end
													if (FlatIdent_45AC8 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														FlatIdent_45AC8 = 2;
													end
												end
											end
										elseif (Enum <= 53) then
											if (Enum <= 51) then
												local FlatIdent_7B2EE = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (3 == FlatIdent_7B2EE) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_7B2EE = 4;
													end
													if (1 == FlatIdent_7B2EE) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_7B2EE = 2;
													end
													if (FlatIdent_7B2EE == 0) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														FlatIdent_7B2EE = 1;
													end
													if (4 == FlatIdent_7B2EE) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_7B2EE = 5;
													end
													if (FlatIdent_7B2EE == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_7B2EE = 3;
													end
													if (FlatIdent_7B2EE == 5) then
														for Idx = A, Top do
															local FlatIdent_89940 = 0;
															while true do
																if (FlatIdent_89940 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_7B2EE = 6;
													end
													if (FlatIdent_7B2EE == 6) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
												end
											elseif (Enum > 52) then
												local FlatIdent_6D04B = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_6D04B == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_6D04B = 1;
													end
													if (FlatIdent_6D04B == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														FlatIdent_6D04B = 5;
													end
													if (FlatIdent_6D04B == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Stk[Inst[4]]];
														FlatIdent_6D04B = 2;
													end
													if (FlatIdent_6D04B == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														FlatIdent_6D04B = 3;
													end
													if (FlatIdent_6D04B == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_6D04B == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_6D04B = 4;
													end
												end
											else
												local FlatIdent_4D902 = 0;
												local A;
												while true do
													if (FlatIdent_4D902 == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														FlatIdent_4D902 = 8;
													end
													if (FlatIdent_4D902 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														for Idx = Inst[2], Inst[3] do
															Stk[Idx] = nil;
														end
														FlatIdent_4D902 = 7;
													end
													if (FlatIdent_4D902 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_4D902 = 2;
													end
													if (FlatIdent_4D902 == 8) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_4D902 = 9;
													end
													if (FlatIdent_4D902 == 5) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_4D902 = 6;
													end
													if (3 == FlatIdent_4D902) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_4D902 = 4;
													end
													if (FlatIdent_4D902 == 0) then
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_4D902 = 1;
													end
													if (FlatIdent_4D902 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_4D902 = 3;
													end
													if (9 == FlatIdent_4D902) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (4 == FlatIdent_4D902) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_4D902 = 5;
													end
												end
											end
										elseif (Enum <= 54) then
											local A;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
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
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										elseif (Enum == 55) then
											local FlatIdent_25440 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_25440 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_25440 = 8;
												end
												if (FlatIdent_25440 == 2) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_25440 = 3;
												end
												if (FlatIdent_25440 == 9) then
													do
														return;
													end
													break;
												end
												if (FlatIdent_25440 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_25440 = 6;
												end
												if (FlatIdent_25440 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_25440 = 1;
												end
												if (FlatIdent_25440 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_25440 = 7;
												end
												if (FlatIdent_25440 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_25440 = 5;
												end
												if (FlatIdent_25440 == 8) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_25440 = 9;
												end
												if (FlatIdent_25440 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_25440 = 2;
												end
												if (FlatIdent_25440 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_25440 = 4;
												end
											end
										else
											local FlatIdent_356A = 0;
											while true do
												if (3 == FlatIdent_356A) then
													if (Inst[2] < Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_356A == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_356A = 3;
												end
												if (0 == FlatIdent_356A) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_356A = 1;
												end
												if (FlatIdent_356A == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_356A = 2;
												end
											end
										end
									elseif (Enum <= 62) then
										if (Enum <= 59) then
											if (Enum <= 57) then
												local FlatIdent_32B1C = 0;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_32B1C == 8) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_2C3E6 = 0;
															while true do
																if (FlatIdent_2C3E6 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														break;
													end
													if (FlatIdent_32B1C == 3) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_32B1C = 4;
													end
													if (FlatIdent_32B1C == 0) then
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														Stk[Inst[2]] = Inst[3];
														FlatIdent_32B1C = 1;
													end
													if (FlatIdent_32B1C == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_32B1C = 5;
													end
													if (FlatIdent_32B1C == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_32B1C = 2;
													end
													if (FlatIdent_32B1C == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_32B1C = 8;
													end
													if (FlatIdent_32B1C == 6) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_32B1C = 7;
													end
													if (FlatIdent_32B1C == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B1C = 3;
													end
													if (FlatIdent_32B1C == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_32B1C = 6;
													end
												end
											elseif (Enum == 58) then
												local FlatIdent_9018E = 0;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_9018E == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_9018E = 8;
													end
													if (FlatIdent_9018E == 5) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9018E = 6;
													end
													if (FlatIdent_9018E == 3) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_9018E = 4;
													end
													if (FlatIdent_9018E == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_9018E = 2;
													end
													if (FlatIdent_9018E == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9018E = 3;
													end
													if (FlatIdent_9018E == 0) then
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														Stk[Inst[2]] = Inst[3];
														FlatIdent_9018E = 1;
													end
													if (6 == FlatIdent_9018E) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_9018E = 7;
													end
													if (FlatIdent_9018E == 8) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														break;
													end
													if (FlatIdent_9018E == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_9018E = 5;
													end
												end
											else
												local FlatIdent_2FBBB = 0;
												local A;
												while true do
													if (FlatIdent_2FBBB == 0) then
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														break;
													end
												end
											end
										elseif (Enum <= 60) then
											local B;
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
											Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
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
										elseif (Enum > 61) then
											local FlatIdent_2394 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_2394 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2394 = 1;
												end
												if (3 == FlatIdent_2394) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2394 = 4;
												end
												if (FlatIdent_2394 == 4) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_2394 = 5;
												end
												if (FlatIdent_2394 == 6) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_2394 == 2) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_2394 = 3;
												end
												if (FlatIdent_2394 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_2394 = 6;
												end
												if (FlatIdent_2394 == 1) then
													Stk[Inst[2]]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_2394 = 2;
												end
											end
										else
											local FlatIdent_88CF3 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (6 == FlatIdent_88CF3) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_88CF3 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_88CF3 = 2;
												end
												if (FlatIdent_88CF3 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_88CF3 = 1;
												end
												if (FlatIdent_88CF3 == 4) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_88CF3 = 5;
												end
												if (FlatIdent_88CF3 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_88CF3 = 3;
												end
												if (FlatIdent_88CF3 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_88CF3 = 4;
												end
												if (FlatIdent_88CF3 == 5) then
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_88CF3 = 6;
												end
											end
										end
									elseif (Enum <= 65) then
										if (Enum <= 63) then
											local FlatIdent_4087C = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_4087C == 4) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_4087C = 5;
												end
												if (FlatIdent_4087C == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4087C = 4;
												end
												if (FlatIdent_4087C == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_4087C = 1;
												end
												if (FlatIdent_4087C == 6) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_4087C == 5) then
													for Idx = A, Top do
														local FlatIdent_6426D = 0;
														while true do
															if (FlatIdent_6426D == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_4087C = 6;
												end
												if (FlatIdent_4087C == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_4087C = 2;
												end
												if (FlatIdent_4087C == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4087C = 3;
												end
											end
										elseif (Enum > 64) then
											local FlatIdent_3CB5D = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_3CB5D == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_3CB5D = 6;
												end
												if (6 == FlatIdent_3CB5D) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													break;
												end
												if (FlatIdent_3CB5D == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3CB5D = 4;
												end
												if (FlatIdent_3CB5D == 4) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_3CB5D = 5;
												end
												if (FlatIdent_3CB5D == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3CB5D = 1;
												end
												if (FlatIdent_3CB5D == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_3CB5D = 2;
												end
												if (2 == FlatIdent_3CB5D) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													FlatIdent_3CB5D = 3;
												end
											end
										else
											local FlatIdent_10CBF = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_10CBF == 3) then
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10CBF = 4;
												end
												if (FlatIdent_10CBF == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10CBF = 5;
												end
												if (FlatIdent_10CBF == 7) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													break;
												end
												if (FlatIdent_10CBF == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_10CBF = 1;
												end
												if (FlatIdent_10CBF == 6) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10CBF = 7;
												end
												if (FlatIdent_10CBF == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_10CBF = 3;
												end
												if (FlatIdent_10CBF == 1) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_10CBF = 2;
												end
												if (FlatIdent_10CBF == 5) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10CBF = 6;
												end
											end
										end
									elseif (Enum <= 66) then
										local FlatIdent_5A1B9 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (6 == FlatIdent_5A1B9) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_5A1B9 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5A1B9 = 3;
											end
											if (FlatIdent_5A1B9 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5A1B9 = 2;
											end
											if (FlatIdent_5A1B9 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5A1B9 = 4;
											end
											if (0 == FlatIdent_5A1B9) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_5A1B9 = 1;
											end
											if (FlatIdent_5A1B9 == 4) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_5A1B9 = 5;
											end
											if (FlatIdent_5A1B9 == 5) then
												for Idx = A, Top do
													local FlatIdent_397EE = 0;
													while true do
														if (FlatIdent_397EE == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5A1B9 = 6;
											end
										end
									elseif (Enum == 67) then
										local B;
										local A;
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
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
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
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
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
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
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
										A = Inst[2];
										Stk[A](Stk[A + 1]);
									else
										local A = Inst[2];
										local Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											local FlatIdent_4FE0C = 0;
											while true do
												if (FlatIdent_4FE0C == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
									end
								elseif (Enum <= 79) then
									if (Enum <= 73) then
										if (Enum <= 70) then
											if (Enum == 69) then
												local FlatIdent_7CC7D = 0;
												local A;
												while true do
													if (FlatIdent_7CC7D == 0) then
														A = Inst[2];
														do
															return Stk[A](Unpack(Stk, A + 1, Inst[3]));
														end
														break;
													end
												end
											else
												local FlatIdent_FF71 = 0;
												local A;
												local Results;
												local Edx;
												while true do
													if (FlatIdent_FF71 == 1) then
														Edx = 0;
														for Idx = A, Inst[4] do
															local FlatIdent_39DD3 = 0;
															while true do
																if (FlatIdent_39DD3 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														break;
													end
													if (0 == FlatIdent_FF71) then
														A = Inst[2];
														Results = {Stk[A](Unpack(Stk, A + 1, Top))};
														FlatIdent_FF71 = 1;
													end
												end
											end
										elseif (Enum <= 71) then
											local T;
											local Edx;
											local Results, Limit;
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
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_5C48A = 0;
												while true do
													if (FlatIdent_5C48A == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
										elseif (Enum == 72) then
											local FlatIdent_654E4 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_654E4 == 4) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_654E4 = 5;
												end
												if (FlatIdent_654E4 == 6) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_654E4 == 5) then
													for Idx = A, Top do
														local FlatIdent_568D2 = 0;
														while true do
															if (FlatIdent_568D2 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_654E4 = 6;
												end
												if (FlatIdent_654E4 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_654E4 = 4;
												end
												if (2 == FlatIdent_654E4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_654E4 = 3;
												end
												if (FlatIdent_654E4 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_654E4 = 2;
												end
												if (FlatIdent_654E4 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_654E4 = 1;
												end
											end
										else
											local FlatIdent_29C18 = 0;
											while true do
												if (FlatIdent_29C18 == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]]();
													FlatIdent_29C18 = 1;
												end
												if (FlatIdent_29C18 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_29C18 = 2;
												end
												if (FlatIdent_29C18 == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_29C18 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_29C18 = 3;
												end
											end
										end
									elseif (Enum <= 76) then
										if (Enum <= 74) then
											if (Stk[Inst[2]] < Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum > 75) then
											local FlatIdent_47BE5 = 0;
											local A;
											local Index;
											local Step;
											while true do
												if (1 == FlatIdent_47BE5) then
													Step = Stk[A + 2];
													if (Step > 0) then
														if (Index > Stk[A + 1]) then
															VIP = Inst[3];
														else
															Stk[A + 3] = Index;
														end
													elseif (Index < Stk[A + 1]) then
														VIP = Inst[3];
													else
														Stk[A + 3] = Index;
													end
													break;
												end
												if (FlatIdent_47BE5 == 0) then
													A = Inst[2];
													Index = Stk[A];
													FlatIdent_47BE5 = 1;
												end
											end
										elseif (Stk[Inst[2]] > Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 77) then
										local FlatIdent_893EA = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_893EA == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_893EA = 3;
											end
											if (FlatIdent_893EA == 5) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_893EA = 6;
											end
											if (FlatIdent_893EA == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_893EA = 2;
											end
											if (FlatIdent_893EA == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_893EA = 7;
											end
											if (FlatIdent_893EA == 7) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_893EA == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_893EA = 4;
											end
											if (0 == FlatIdent_893EA) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_893EA = 1;
											end
											if (FlatIdent_893EA == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_893EA = 5;
											end
										end
									elseif (Enum > 78) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
										A = Inst[2];
										Stk[A](Stk[A + 1]);
									else
										local A;
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
									end
								elseif (Enum <= 85) then
									if (Enum <= 82) then
										if (Enum <= 80) then
											local FlatIdent_2F4C2 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_2F4C2 == 2) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2F4C2 = 3;
												end
												if (4 == FlatIdent_2F4C2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_2F4C2 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_2F4C2 = 1;
												end
												if (FlatIdent_2F4C2 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_2F4C2 = 2;
												end
												if (FlatIdent_2F4C2 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_2F4C2 = 4;
												end
											end
										elseif (Enum > 81) then
											if (Stk[Inst[2]] < Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
										end
									elseif (Enum <= 83) then
										VIP = Inst[3];
									elseif (Enum == 84) then
										if (Stk[Inst[2]] ~= Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_96219 = 0;
										local B;
										local T;
										local A;
										while true do
											if (FlatIdent_96219 == 6) then
												A = Inst[2];
												T = Stk[A];
												B = Inst[3];
												FlatIdent_96219 = 7;
											end
											if (FlatIdent_96219 == 2) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_96219 = 3;
											end
											if (5 == FlatIdent_96219) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_96219 = 6;
											end
											if (FlatIdent_96219 == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_96219 = 5;
											end
											if (FlatIdent_96219 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_96219 = 2;
											end
											if (FlatIdent_96219 == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_96219 = 4;
											end
											if (FlatIdent_96219 == 0) then
												B = nil;
												T = nil;
												A = nil;
												FlatIdent_96219 = 1;
											end
											if (FlatIdent_96219 == 7) then
												for Idx = 1, B do
													T[Idx] = Stk[A + Idx];
												end
												break;
											end
										end
									end
								elseif (Enum <= 88) then
									if (Enum <= 86) then
										local FlatIdent_48EC5 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (6 == FlatIdent_48EC5) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_5CB64 = 0;
													while true do
														if (0 == FlatIdent_5CB64) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_48EC5 = 7;
											end
											if (0 == FlatIdent_48EC5) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_48EC5 = 1;
											end
											if (5 == FlatIdent_48EC5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_48EC5 = 6;
											end
											if (FlatIdent_48EC5 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_48EC5 = 8;
											end
											if (FlatIdent_48EC5 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_48EC5 = 4;
											end
											if (FlatIdent_48EC5 == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_48EC5 = 2;
											end
											if (FlatIdent_48EC5 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_48EC5 = 3;
											end
											if (FlatIdent_48EC5 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_48EC5 = 5;
											end
											if (FlatIdent_48EC5 == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
										end
									elseif (Enum == 87) then
										local FlatIdent_462B = 0;
										while true do
											if (FlatIdent_462B == 5) then
												if (Stk[Inst[2]] == Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_462B == 0) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_462B = 1;
											end
											if (3 == FlatIdent_462B) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_462B = 4;
											end
											if (FlatIdent_462B == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_462B = 5;
											end
											if (FlatIdent_462B == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_462B = 3;
											end
											if (FlatIdent_462B == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_462B = 2;
											end
										end
									else
										local FlatIdent_5B6DF = 0;
										local K;
										local B;
										local A;
										while true do
											if (FlatIdent_5B6DF == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_5B6DF == 2) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5B6DF = 3;
											end
											if (FlatIdent_5B6DF == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_5B6DF = 8;
											end
											if (FlatIdent_5B6DF == 0) then
												K = nil;
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_5B6DF = 1;
											end
											if (FlatIdent_5B6DF == 8) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												FlatIdent_5B6DF = 9;
											end
											if (FlatIdent_5B6DF == 6) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5B6DF = 7;
											end
											if (FlatIdent_5B6DF == 3) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5B6DF = 4;
											end
											if (FlatIdent_5B6DF == 1) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5B6DF = 2;
											end
											if (FlatIdent_5B6DF == 5) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5B6DF = 6;
											end
											if (FlatIdent_5B6DF == 4) then
												B = Inst[3];
												K = Stk[B];
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5B6DF = 5;
											end
										end
									end
								elseif (Enum <= 89) then
									local FlatIdent_27E9F = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (9 == FlatIdent_27E9F) then
											do
												return;
											end
											break;
										end
										if (0 == FlatIdent_27E9F) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											FlatIdent_27E9F = 1;
										end
										if (FlatIdent_27E9F == 8) then
											Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_27E9F = 9;
										end
										if (FlatIdent_27E9F == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A]());
											FlatIdent_27E9F = 6;
										end
										if (FlatIdent_27E9F == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_27E9F = 8;
										end
										if (FlatIdent_27E9F == 3) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_27E9F = 4;
										end
										if (FlatIdent_27E9F == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_27E9F = 3;
										end
										if (FlatIdent_27E9F == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_27E9F = 5;
										end
										if (FlatIdent_27E9F == 1) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_27E9F = 2;
										end
										if (FlatIdent_27E9F == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_42214 = 0;
												while true do
													if (FlatIdent_42214 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_27E9F = 7;
										end
									end
								elseif (Enum == 90) then
									local FlatIdent_48DDA = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_48DDA == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_48DDA = 3;
										end
										if (FlatIdent_48DDA == 4) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_48DDA = 5;
										end
										if (FlatIdent_48DDA == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_48DDA = 4;
										end
										if (8 == FlatIdent_48DDA) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_48DDA == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_48DDA = 6;
										end
										if (0 == FlatIdent_48DDA) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_48DDA = 1;
										end
										if (FlatIdent_48DDA == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_48DDA = 8;
										end
										if (1 == FlatIdent_48DDA) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_48DDA = 2;
										end
										if (FlatIdent_48DDA == 6) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_48DDA = 7;
										end
									end
								else
									local FlatIdent_5B76B = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_5B76B == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5B76B = 6;
										end
										if (FlatIdent_5B76B == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B76B = 2;
										end
										if (FlatIdent_5B76B == 4) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5B76B = 5;
										end
										if (FlatIdent_5B76B == 6) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_5B76B == 2) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_5B76B = 3;
										end
										if (FlatIdent_5B76B == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_5B76B = 4;
										end
										if (0 == FlatIdent_5B76B) then
											B = nil;
											A = nil;
											for Idx = Inst[2], Inst[3] do
												Stk[Idx] = nil;
											end
											VIP = VIP + 1;
											FlatIdent_5B76B = 1;
										end
									end
								end
							elseif (Enum <= 137) then
								if (Enum <= 114) then
									if (Enum <= 102) then
										if (Enum <= 96) then
											if (Enum <= 93) then
												if (Enum == 92) then
													local FlatIdent_382D5 = 0;
													local T;
													local Edx;
													local Results;
													local Limit;
													local A;
													while true do
														if (FlatIdent_382D5 == 3) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_382D5 = 4;
														end
														if (FlatIdent_382D5 == 4) then
															A = Inst[2];
															Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
															Top = (Limit + A) - 1;
															Edx = 0;
															FlatIdent_382D5 = 5;
														end
														if (FlatIdent_382D5 == 1) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_382D5 = 2;
														end
														if (FlatIdent_382D5 == 6) then
															T = Stk[A];
															for Idx = A + 1, Top do
																Insert(T, Stk[Idx]);
															end
															break;
														end
														if (FlatIdent_382D5 == 0) then
															T = nil;
															Edx = nil;
															Results, Limit = nil;
															A = nil;
															FlatIdent_382D5 = 1;
														end
														if (FlatIdent_382D5 == 5) then
															for Idx = A, Top do
																local FlatIdent_375DB = 0;
																while true do
																	if (0 == FlatIdent_375DB) then
																		Edx = Edx + 1;
																		Stk[Idx] = Results[Edx];
																		break;
																	end
																end
															end
															VIP = VIP + 1;
															Inst = Instr[VIP];
															A = Inst[2];
															FlatIdent_382D5 = 6;
														end
														if (FlatIdent_382D5 == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_382D5 = 3;
														end
													end
												else
													local B;
													local A;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
												end
											elseif (Enum <= 94) then
												local FlatIdent_7D387 = 0;
												while true do
													if (FlatIdent_7D387 == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														FlatIdent_7D387 = 1;
													end
													if (FlatIdent_7D387 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_7D387 = 4;
													end
													if (FlatIdent_7D387 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_7D387 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_7D387 = 3;
													end
													if (FlatIdent_7D387 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_7D387 = 2;
													end
												end
											elseif (Enum == 95) then
												local FlatIdent_55E6D = 0;
												local K;
												local B;
												local A;
												while true do
													if (FlatIdent_55E6D == 10) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_55E6D = 11;
													end
													if (FlatIdent_55E6D == 3) then
														Stk[Inst[2]] = K;
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_55E6D = 4;
													end
													if (FlatIdent_55E6D == 11) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														FlatIdent_55E6D = 12;
													end
													if (FlatIdent_55E6D == 1) then
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_55E6D = 2;
													end
													if (FlatIdent_55E6D == 15) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_55E6D = 16;
													end
													if (12 == FlatIdent_55E6D) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_55E6D = 13;
													end
													if (FlatIdent_55E6D == 2) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														B = Inst[3];
														K = Stk[B];
														for Idx = B + 1, Inst[4] do
															K = K .. Stk[Idx];
														end
														FlatIdent_55E6D = 3;
													end
													if (FlatIdent_55E6D == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_55E6D = 8;
													end
													if (FlatIdent_55E6D == 5) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_55E6D = 6;
													end
													if (FlatIdent_55E6D == 17) then
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														break;
													end
													if (FlatIdent_55E6D == 14) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_55E6D = 15;
													end
													if (FlatIdent_55E6D == 8) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_55E6D = 9;
													end
													if (FlatIdent_55E6D == 9) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_55E6D = 10;
													end
													if (FlatIdent_55E6D == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_55E6D = 7;
													end
													if (FlatIdent_55E6D == 4) then
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_55E6D = 5;
													end
													if (FlatIdent_55E6D == 0) then
														K = nil;
														B = nil;
														A = nil;
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_55E6D = 1;
													end
													if (FlatIdent_55E6D == 16) then
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_55E6D = 17;
													end
													if (13 == FlatIdent_55E6D) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_55E6D = 14;
													end
												end
											else
												local A;
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
											end
										elseif (Enum <= 99) then
											if (Enum <= 97) then
												local A;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
											elseif (Enum > 98) then
												local FlatIdent_5B973 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_5B973 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_5B973 = 4;
													end
													if (FlatIdent_5B973 == 2) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Stk[Inst[4]]];
														FlatIdent_5B973 = 3;
													end
													if (FlatIdent_5B973 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_5B973 = 1;
													end
													if (FlatIdent_5B973 == 8) then
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_5B973 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_5B973 = 7;
													end
													if (FlatIdent_5B973 == 5) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_5B973 = 6;
													end
													if (FlatIdent_5B973 == 7) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3] ~= 0;
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5B973 = 8;
													end
													if (FlatIdent_5B973 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5B973 = 2;
													end
													if (FlatIdent_5B973 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5B973 = 5;
													end
												end
											else
												local FlatIdent_482B9 = 0;
												local B;
												local A;
												while true do
													if (3 == FlatIdent_482B9) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_482B9 = 4;
													end
													if (FlatIdent_482B9 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_482B9 = 1;
													end
													if (FlatIdent_482B9 == 6) then
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_482B9 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_482B9 = 5;
													end
													if (FlatIdent_482B9 == 5) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_482B9 = 6;
													end
													if (FlatIdent_482B9 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_482B9 = 2;
													end
													if (FlatIdent_482B9 == 2) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_482B9 = 3;
													end
												end
											end
										elseif (Enum <= 100) then
											local FlatIdent_5D375 = 0;
											local A;
											while true do
												if (FlatIdent_5D375 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5D375 = 5;
												end
												if (8 == FlatIdent_5D375) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5D375 = 9;
												end
												if (FlatIdent_5D375 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_5D375 = 6;
												end
												if (FlatIdent_5D375 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A]();
													FlatIdent_5D375 = 2;
												end
												if (FlatIdent_5D375 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5D375 = 4;
												end
												if (6 == FlatIdent_5D375) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_5D375 = 7;
												end
												if (FlatIdent_5D375 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_5D375 == 0) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_5D375 = 1;
												end
												if (FlatIdent_5D375 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_5D375 = 3;
												end
												if (FlatIdent_5D375 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_5D375 = 8;
												end
											end
										elseif (Enum == 101) then
											if (Stk[Inst[2]] <= Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local FlatIdent_8F83C = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_8F83C == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_8F83C = 4;
												end
												if (FlatIdent_8F83C == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_8F83C = 2;
												end
												if (FlatIdent_8F83C == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_8F83C = 5;
												end
												if (FlatIdent_8F83C == 5) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_8F83C == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_8F83C = 1;
												end
												if (FlatIdent_8F83C == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_8F83C = 3;
												end
											end
										end
									elseif (Enum <= 108) then
										if (Enum <= 105) then
											if (Enum <= 103) then
												local FlatIdent_161F1 = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_161F1 == 5) then
														for Idx = A, Top do
															local FlatIdent_2FB2F = 0;
															while true do
																if (FlatIdent_2FB2F == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_161F1 = 6;
													end
													if (2 == FlatIdent_161F1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_161F1 = 3;
													end
													if (4 == FlatIdent_161F1) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_161F1 = 5;
													end
													if (0 == FlatIdent_161F1) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														FlatIdent_161F1 = 1;
													end
													if (FlatIdent_161F1 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_161F1 = 2;
													end
													if (FlatIdent_161F1 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_161F1 = 4;
													end
													if (6 == FlatIdent_161F1) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
												end
											elseif (Enum > 104) then
												local FlatIdent_1009C = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_1009C == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1009C = 3;
													end
													if (FlatIdent_1009C == 1) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_1009C = 2;
													end
													if (FlatIdent_1009C == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1009C = 5;
													end
													if (FlatIdent_1009C == 6) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_31524 = 0;
															while true do
																if (FlatIdent_31524 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														FlatIdent_1009C = 7;
													end
													if (8 == FlatIdent_1009C) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
													if (FlatIdent_1009C == 5) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														FlatIdent_1009C = 6;
													end
													if (0 == FlatIdent_1009C) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														FlatIdent_1009C = 1;
													end
													if (FlatIdent_1009C == 7) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_1009C = 8;
													end
													if (FlatIdent_1009C == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_1009C = 4;
													end
												end
											else
												local B;
												local A;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
											end
										elseif (Enum <= 106) then
											local FlatIdent_21669 = 0;
											local A;
											while true do
												if (FlatIdent_21669 == 1) then
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_21669 = 2;
												end
												if (FlatIdent_21669 == 2) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_21669 = 3;
												end
												if (FlatIdent_21669 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_21669 = 4;
												end
												if (FlatIdent_21669 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_21669 = 1;
												end
												if (FlatIdent_21669 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													break;
												end
											end
										elseif (Enum == 107) then
											local FlatIdent_82AEE = 0;
											while true do
												if (FlatIdent_82AEE == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_82AEE = 3;
												end
												if (FlatIdent_82AEE == 3) then
													if (Inst[2] < Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_82AEE == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_82AEE = 2;
												end
												if (0 == FlatIdent_82AEE) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_82AEE = 1;
												end
											end
										else
											local T;
											local Edx;
											local Results, Limit;
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
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_1A340 = 0;
												while true do
													if (FlatIdent_1A340 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
										end
									elseif (Enum <= 111) then
										if (Enum <= 109) then
											local FlatIdent_547F2 = 0;
											local T;
											local B;
											local A;
											while true do
												if (FlatIdent_547F2 == 0) then
													T = nil;
													B = nil;
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_547F2 = 1;
												end
												if (FlatIdent_547F2 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_547F2 = 6;
												end
												if (FlatIdent_547F2 == 14) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_547F2 = 15;
												end
												if (FlatIdent_547F2 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_547F2 = 4;
												end
												if (FlatIdent_547F2 == 16) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_547F2 = 17;
												end
												if (FlatIdent_547F2 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_547F2 = 3;
												end
												if (FlatIdent_547F2 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_547F2 = 7;
												end
												if (FlatIdent_547F2 == 22) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 23;
												end
												if (FlatIdent_547F2 == 20) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 21;
												end
												if (FlatIdent_547F2 == 17) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_547F2 = 18;
												end
												if (FlatIdent_547F2 == 23) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 24;
												end
												if (FlatIdent_547F2 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_547F2 = 8;
												end
												if (FlatIdent_547F2 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 9;
												end
												if (FlatIdent_547F2 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													FlatIdent_547F2 = 2;
												end
												if (FlatIdent_547F2 == 19) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_547F2 = 20;
												end
												if (FlatIdent_547F2 == 21) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 22;
												end
												if (FlatIdent_547F2 == 12) then
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_547F2 = 13;
												end
												if (FlatIdent_547F2 == 11) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 12;
												end
												if (FlatIdent_547F2 == 25) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													T = Stk[A];
													B = Inst[3];
													for Idx = 1, B do
														T[Idx] = Stk[A + Idx];
													end
													break;
												end
												if (FlatIdent_547F2 == 15) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_547F2 = 16;
												end
												if (FlatIdent_547F2 == 18) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_547F2 = 19;
												end
												if (FlatIdent_547F2 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_547F2 = 5;
												end
												if (FlatIdent_547F2 == 24) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 25;
												end
												if (FlatIdent_547F2 == 9) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 10;
												end
												if (FlatIdent_547F2 == 10) then
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_547F2 = 11;
												end
												if (FlatIdent_547F2 == 13) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_547F2 = 14;
												end
											end
										elseif (Enum > 110) then
											local FlatIdent_75609 = 0;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (0 == FlatIdent_75609) then
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_75609 = 1;
												end
												if (FlatIdent_75609 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_75609 = 6;
												end
												if (FlatIdent_75609 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_75609 = 2;
												end
												if (FlatIdent_75609 == 6) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													break;
												end
												if (FlatIdent_75609 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_75609 = 3;
												end
												if (FlatIdent_75609 == 3) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_75609 = 4;
												end
												if (FlatIdent_75609 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_75609 = 5;
												end
											end
										else
											local FlatIdent_2C822 = 0;
											local A;
											while true do
												if (FlatIdent_2C822 == 0) then
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
											end
										end
									elseif (Enum <= 112) then
										local FlatIdent_5E68D = 0;
										local B;
										local A;
										while true do
											if (3 == FlatIdent_5E68D) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5E68D = 4;
											end
											if (0 == FlatIdent_5E68D) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_5E68D = 1;
											end
											if (FlatIdent_5E68D == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_5E68D == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5E68D = 3;
											end
											if (1 == FlatIdent_5E68D) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5E68D = 2;
											end
										end
									elseif (Enum == 113) then
										local FlatIdent_550FD = 0;
										local A;
										local T;
										local B;
										while true do
											if (FlatIdent_550FD == 1) then
												B = Inst[3];
												for Idx = 1, B do
													T[Idx] = Stk[A + Idx];
												end
												break;
											end
											if (FlatIdent_550FD == 0) then
												A = Inst[2];
												T = Stk[A];
												FlatIdent_550FD = 1;
											end
										end
									else
										local FlatIdent_53FE3 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_53FE3 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_53FE3 = 5;
											end
											if (FlatIdent_53FE3 == 6) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (5 == FlatIdent_53FE3) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_53FE3 = 6;
											end
											if (1 == FlatIdent_53FE3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_53FE3 = 2;
											end
											if (FlatIdent_53FE3 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_53FE3 = 4;
											end
											if (FlatIdent_53FE3 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_53FE3 = 1;
											end
											if (FlatIdent_53FE3 == 2) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_53FE3 = 3;
											end
										end
									end
								elseif (Enum <= 125) then
									if (Enum <= 119) then
										if (Enum <= 116) then
											if (Enum == 115) then
												local FlatIdent_49774 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_49774 == 7) then
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
														FlatIdent_49774 = 8;
													end
													if (FlatIdent_49774 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_49774 = 3;
													end
													if (4 == FlatIdent_49774) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_49774 = 5;
													end
													if (FlatIdent_49774 == 3) then
														Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_49774 = 4;
													end
													if (FlatIdent_49774 == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_49774 = 2;
													end
													if (5 == FlatIdent_49774) then
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
														FlatIdent_49774 = 6;
													end
													if (FlatIdent_49774 == 8) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_49774 = 9;
													end
													if (FlatIdent_49774 == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_49774 = 14;
													end
													if (FlatIdent_49774 == 14) then
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
														FlatIdent_49774 = 15;
													end
													if (FlatIdent_49774 == 12) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														FlatIdent_49774 = 13;
													end
													if (FlatIdent_49774 == 10) then
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
														FlatIdent_49774 = 11;
													end
													if (FlatIdent_49774 == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_49774 = 12;
													end
													if (15 == FlatIdent_49774) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														break;
													end
													if (FlatIdent_49774 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_49774 = 1;
													end
													if (FlatIdent_49774 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Stk[A + 1]);
														FlatIdent_49774 = 7;
													end
													if (FlatIdent_49774 == 9) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_49774 = 10;
													end
												end
											else
												local FlatIdent_190B2 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_190B2 == 3) then
														Stk[A] = B[Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														FlatIdent_190B2 = 4;
													end
													if (FlatIdent_190B2 == 6) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
														break;
													end
													if (FlatIdent_190B2 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_190B2 = 6;
													end
													if (0 == FlatIdent_190B2) then
														B = nil;
														A = nil;
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_190B2 = 1;
													end
													if (1 == FlatIdent_190B2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_190B2 = 2;
													end
													if (FlatIdent_190B2 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_190B2 = 3;
													end
													if (FlatIdent_190B2 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_190B2 = 5;
													end
												end
											end
										elseif (Enum <= 117) then
											local FlatIdent_5BCDC = 0;
											local A;
											local B;
											while true do
												if (FlatIdent_5BCDC == 1) then
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													break;
												end
												if (FlatIdent_5BCDC == 0) then
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_5BCDC = 1;
												end
											end
										elseif (Enum > 118) then
											local FlatIdent_7D3AF = 0;
											local B;
											while true do
												if (FlatIdent_7D3AF == 0) then
													B = Stk[Inst[4]];
													if not B then
														VIP = VIP + 1;
													else
														local FlatIdent_A788 = 0;
														while true do
															if (FlatIdent_A788 == 0) then
																Stk[Inst[2]] = B;
																VIP = Inst[3];
																break;
															end
														end
													end
													break;
												end
											end
										else
											local FlatIdent_2E5A7 = 0;
											local A;
											while true do
												if (0 == FlatIdent_2E5A7) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 1;
												end
												if (3 == FlatIdent_2E5A7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 4;
												end
												if (FlatIdent_2E5A7 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 3;
												end
												if (FlatIdent_2E5A7 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 7;
												end
												if (FlatIdent_2E5A7 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 9;
												end
												if (FlatIdent_2E5A7 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 8;
												end
												if (FlatIdent_2E5A7 == 9) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (4 == FlatIdent_2E5A7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 5;
												end
												if (FlatIdent_2E5A7 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 6;
												end
												if (FlatIdent_2E5A7 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2E5A7 = 2;
												end
											end
										end
									elseif (Enum <= 122) then
										if (Enum <= 120) then
											local T;
											local Edx;
											local Results, Limit;
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
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_30311 = 0;
												while true do
													if (FlatIdent_30311 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
										elseif (Enum > 121) then
											Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
										else
											local Edx;
											local Results, Limit;
											local A;
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
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_5881D = 0;
												while true do
													if (FlatIdent_5881D == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
										end
									elseif (Enum <= 123) then
										local FlatIdent_79C00 = 0;
										local Step;
										local Index;
										local A;
										while true do
											if (FlatIdent_79C00 == 0) then
												Step = nil;
												Index = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_79C00 = 1;
											end
											if (FlatIdent_79C00 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_79C00 = 5;
											end
											if (FlatIdent_79C00 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												for Idx = Inst[2], Inst[3] do
													Stk[Idx] = nil;
												end
												FlatIdent_79C00 = 4;
											end
											if (FlatIdent_79C00 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_79C00 = 3;
											end
											if (FlatIdent_79C00 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = #Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_79C00 = 6;
											end
											if (FlatIdent_79C00 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_79C00 = 2;
											end
											if (6 == FlatIdent_79C00) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_79C00 = 7;
											end
											if (FlatIdent_79C00 == 8) then
												Step = Stk[A + 2];
												if (Step > 0) then
													if (Index > Stk[A + 1]) then
														VIP = Inst[3];
													else
														Stk[A + 3] = Index;
													end
												elseif (Index < Stk[A + 1]) then
													VIP = Inst[3];
												else
													Stk[A + 3] = Index;
												end
												break;
											end
											if (FlatIdent_79C00 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Index = Stk[A];
												FlatIdent_79C00 = 8;
											end
										end
									elseif (Enum > 124) then
										if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 131) then
									if (Enum <= 128) then
										if (Enum <= 126) then
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
											Stk[Inst[2]] = Env[Inst[3]];
										elseif (Enum == 127) then
											local B;
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
											Stk[Inst[2]] = Env[Inst[3]];
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
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local FlatIdent_477F5 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_477F5 == 1) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_477F5 = 2;
												end
												if (FlatIdent_477F5 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_477F5 = 1;
												end
												if (FlatIdent_477F5 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_477F5 = 5;
												end
												if (FlatIdent_477F5 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_477F5 = 3;
												end
												if (FlatIdent_477F5 == 8) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_477F5 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_477F5 = 6;
												end
												if (FlatIdent_477F5 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_477F5 = 4;
												end
												if (FlatIdent_477F5 == 7) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_477F5 = 8;
												end
												if (FlatIdent_477F5 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_477F5 = 7;
												end
											end
										end
									elseif (Enum <= 129) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3] ~= 0;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									elseif (Enum > 130) then
										local FlatIdent_E12B = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_E12B == 2) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_E12B = 3;
											end
											if (4 == FlatIdent_E12B) then
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_24505 = 0;
													while true do
														if (FlatIdent_24505 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_E12B = 5;
											end
											if (FlatIdent_E12B == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_E12B = 2;
											end
											if (FlatIdent_E12B == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_E12B = 1;
											end
											if (FlatIdent_E12B == 3) then
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_7B7BF = 0;
													while true do
														if (FlatIdent_7B7BF == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_E12B = 4;
											end
											if (FlatIdent_E12B == 5) then
												VIP = Inst[3];
												break;
											end
										end
									else
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
											local FlatIdent_5907 = 0;
											while true do
												if (FlatIdent_5907 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_74A9D = 0;
											while true do
												if (FlatIdent_74A9D == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 134) then
									if (Enum <= 132) then
										local FlatIdent_6B8AF = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_6B8AF == 1) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_6B8AF = 2;
											end
											if (FlatIdent_6B8AF == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_6B8AF = 7;
											end
											if (FlatIdent_6B8AF == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6B8AF = 1;
											end
											if (FlatIdent_6B8AF == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6B8AF = 3;
											end
											if (FlatIdent_6B8AF == 8) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_6B8AF == 5) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6B8AF = 6;
											end
											if (3 == FlatIdent_6B8AF) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_6B8AF = 4;
											end
											if (FlatIdent_6B8AF == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6B8AF = 8;
											end
											if (FlatIdent_6B8AF == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6B8AF = 5;
											end
										end
									elseif (Enum > 133) then
										local FlatIdent_51A5F = 0;
										local A;
										while true do
											if (FlatIdent_51A5F == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_51A5F = 3;
											end
											if (FlatIdent_51A5F == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_51A5F = 8;
											end
											if (FlatIdent_51A5F == 10) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_51A5F = 11;
											end
											if (FlatIdent_51A5F == 1) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_51A5F = 2;
											end
											if (FlatIdent_51A5F == 5) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_51A5F = 6;
											end
											if (FlatIdent_51A5F == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_51A5F = 5;
											end
											if (FlatIdent_51A5F == 9) then
												Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_51A5F = 10;
											end
											if (0 == FlatIdent_51A5F) then
												A = nil;
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_51A5F = 1;
											end
											if (FlatIdent_51A5F == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_51A5F = 7;
											end
											if (FlatIdent_51A5F == 8) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_51A5F = 9;
											end
											if (FlatIdent_51A5F == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_51A5F = 12;
											end
											if (3 == FlatIdent_51A5F) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_51A5F = 4;
											end
											if (13 == FlatIdent_51A5F) then
												Stk[A](Stk[A + 1]);
												break;
											end
											if (FlatIdent_51A5F == 12) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_51A5F = 13;
											end
										end
									else
										local FlatIdent_618E5 = 0;
										local A;
										while true do
											if (3 == FlatIdent_618E5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_618E5 = 4;
											end
											if (FlatIdent_618E5 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_618E5 = 3;
											end
											if (FlatIdent_618E5 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_618E5 = 6;
											end
											if (4 == FlatIdent_618E5) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_618E5 = 5;
											end
											if (FlatIdent_618E5 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_618E5 = 2;
											end
											if (FlatIdent_618E5 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_618E5 = 1;
											end
											if (FlatIdent_618E5 == 7) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (6 == FlatIdent_618E5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_618E5 = 7;
											end
										end
									end
								elseif (Enum <= 135) then
									local FlatIdent_EDE4 = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (FlatIdent_EDE4 == 8) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_EDE4 == 1) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_EDE4 = 2;
										end
										if (FlatIdent_EDE4 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_EDE4 = 8;
										end
										if (2 == FlatIdent_EDE4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_EDE4 = 3;
										end
										if (3 == FlatIdent_EDE4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_EDE4 = 4;
										end
										if (FlatIdent_EDE4 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_EDE4 = 5;
										end
										if (FlatIdent_EDE4 == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_40FB7 = 0;
												while true do
													if (FlatIdent_40FB7 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_EDE4 = 7;
										end
										if (FlatIdent_EDE4 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_EDE4 = 6;
										end
										if (FlatIdent_EDE4 == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_EDE4 = 1;
										end
									end
								elseif (Enum == 136) then
									local FlatIdent_40BE1 = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (FlatIdent_40BE1 == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_26896 = 0;
												while true do
													if (FlatIdent_26896 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_40BE1 = 7;
										end
										if (5 == FlatIdent_40BE1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_40BE1 = 6;
										end
										if (FlatIdent_40BE1 == 8) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_40BE1 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_40BE1 = 8;
										end
										if (FlatIdent_40BE1 == 1) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_40BE1 = 2;
										end
										if (FlatIdent_40BE1 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_40BE1 = 4;
										end
										if (FlatIdent_40BE1 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_40BE1 = 3;
										end
										if (FlatIdent_40BE1 == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_40BE1 = 1;
										end
										if (4 == FlatIdent_40BE1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_40BE1 = 5;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 160) then
								if (Enum <= 148) then
									if (Enum <= 142) then
										if (Enum <= 139) then
											if (Enum == 138) then
												if (Stk[Inst[2]] <= Stk[Inst[4]]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											else
												local FlatIdent_85AC = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_85AC == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_85AC = 4;
													end
													if (FlatIdent_85AC == 0) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														FlatIdent_85AC = 1;
													end
													if (FlatIdent_85AC == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_85AC = 3;
													end
													if (FlatIdent_85AC == 4) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_85AC = 5;
													end
													if (FlatIdent_85AC == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_85AC = 2;
													end
													if (FlatIdent_85AC == 6) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
													if (FlatIdent_85AC == 5) then
														for Idx = A, Top do
															local FlatIdent_9363D = 0;
															while true do
																if (FlatIdent_9363D == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_85AC = 6;
													end
												end
											end
										elseif (Enum <= 140) then
											Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
										elseif (Enum == 141) then
											local FlatIdent_23D60 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_23D60 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_23D60 = 4;
												end
												if (FlatIdent_23D60 == 1) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_23D60 = 2;
												end
												if (4 == FlatIdent_23D60) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_23D60 = 5;
												end
												if (FlatIdent_23D60 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_23D60 = 3;
												end
												if (FlatIdent_23D60 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_23D60 = 1;
												end
												if (5 == FlatIdent_23D60) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_23D60 = 6;
												end
												if (FlatIdent_23D60 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
											end
										else
											local FlatIdent_8982C = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_8982C == 5) then
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_8982C = 6;
												end
												if (FlatIdent_8982C == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8982C = 4;
												end
												if (FlatIdent_8982C == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8982C = 3;
												end
												if (FlatIdent_8982C == 4) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_8982C = 5;
												end
												if (FlatIdent_8982C == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_8982C = 1;
												end
												if (FlatIdent_8982C == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8982C = 2;
												end
												if (6 == FlatIdent_8982C) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
											end
										end
									elseif (Enum <= 145) then
										if (Enum <= 143) then
											local FlatIdent_5D693 = 0;
											while true do
												if (FlatIdent_5D693 == 0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5D693 = 1;
												end
												if (FlatIdent_5D693 == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5D693 = 4;
												end
												if (FlatIdent_5D693 == 1) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5D693 = 2;
												end
												if (2 == FlatIdent_5D693) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5D693 = 3;
												end
												if (FlatIdent_5D693 == 4) then
													if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
											end
										elseif (Enum > 144) then
											local FlatIdent_818FA = 0;
											local A;
											while true do
												if (0 == FlatIdent_818FA) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 1;
												end
												if (FlatIdent_818FA == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 2;
												end
												if (FlatIdent_818FA == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 4;
												end
												if (9 == FlatIdent_818FA) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_818FA == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 7;
												end
												if (4 == FlatIdent_818FA) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_818FA = 5;
												end
												if (FlatIdent_818FA == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 9;
												end
												if (FlatIdent_818FA == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_818FA = 6;
												end
												if (FlatIdent_818FA == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 3;
												end
												if (FlatIdent_818FA == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_818FA = 8;
												end
											end
										else
											local FlatIdent_252D3 = 0;
											local A;
											while true do
												if (FlatIdent_252D3 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_252D3 = 1;
												end
												if (FlatIdent_252D3 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_252D3 = 4;
												end
												if (FlatIdent_252D3 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_252D3 = 6;
												end
												if (FlatIdent_252D3 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_252D3 = 5;
												end
												if (FlatIdent_252D3 == 7) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_252D3 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_252D3 = 3;
												end
												if (FlatIdent_252D3 == 1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_252D3 = 2;
												end
												if (FlatIdent_252D3 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_252D3 = 7;
												end
											end
										end
									elseif (Enum <= 146) then
										local FlatIdent_B038 = 0;
										local A;
										while true do
											if (FlatIdent_B038 == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 9;
											end
											if (0 == FlatIdent_B038) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 1;
											end
											if (5 == FlatIdent_B038) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_B038 = 6;
											end
											if (FlatIdent_B038 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 3;
											end
											if (FlatIdent_B038 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 2;
											end
											if (FlatIdent_B038 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 4;
											end
											if (FlatIdent_B038 == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_B038 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 7;
											end
											if (FlatIdent_B038 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_B038 = 5;
											end
											if (FlatIdent_B038 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_B038 = 8;
											end
										end
									elseif (Enum == 147) then
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local T;
										local Edx;
										local Results, Limit;
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
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_186E9 = 0;
											while true do
												if (FlatIdent_186E9 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
									end
								elseif (Enum <= 154) then
									if (Enum <= 151) then
										if (Enum <= 149) then
											local T;
											local Edx;
											local Results, Limit;
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
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
										elseif (Enum == 150) then
											local FlatIdent_6ED36 = 0;
											local A;
											while true do
												if (FlatIdent_6ED36 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6ED36 = 3;
												end
												if (FlatIdent_6ED36 == 7) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_6ED36 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6ED36 = 5;
												end
												if (FlatIdent_6ED36 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6ED36 = 7;
												end
												if (FlatIdent_6ED36 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6ED36 = 1;
												end
												if (FlatIdent_6ED36 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_6ED36 = 4;
												end
												if (FlatIdent_6ED36 == 1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_6ED36 = 2;
												end
												if (FlatIdent_6ED36 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6ED36 = 6;
												end
											end
										else
											local A = Inst[2];
											local C = Inst[4];
											local CB = A + 2;
											local Result = {Stk[A](Stk[A + 1], Stk[CB])};
											for Idx = 1, C do
												Stk[CB + Idx] = Result[Idx];
											end
											local R = Result[1];
											if R then
												local FlatIdent_39A8C = 0;
												while true do
													if (FlatIdent_39A8C == 0) then
														Stk[CB] = R;
														VIP = Inst[3];
														break;
													end
												end
											else
												VIP = VIP + 1;
											end
										end
									elseif (Enum <= 152) then
										local FlatIdent_18888 = 0;
										local Step;
										local Index;
										local A;
										while true do
											if (FlatIdent_18888 == 3) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = #Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_18888 = 4;
											end
											if (FlatIdent_18888 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Index = Stk[A];
												Step = Stk[A + 2];
												FlatIdent_18888 = 6;
											end
											if (FlatIdent_18888 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												for Idx = Inst[2], Inst[3] do
													Stk[Idx] = nil;
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_18888 = 3;
											end
											if (FlatIdent_18888 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_18888 = 2;
											end
											if (FlatIdent_18888 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_18888 = 5;
											end
											if (FlatIdent_18888 == 6) then
												if (Step > 0) then
													if (Index > Stk[A + 1]) then
														VIP = Inst[3];
													else
														Stk[A + 3] = Index;
													end
												elseif (Index < Stk[A + 1]) then
													VIP = Inst[3];
												else
													Stk[A + 3] = Index;
												end
												break;
											end
											if (FlatIdent_18888 == 0) then
												Step = nil;
												Index = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_18888 = 1;
											end
										end
									elseif (Enum == 153) then
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
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
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_7C7D6 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (0 == FlatIdent_7C7D6) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_7C7D6 = 1;
											end
											if (3 == FlatIdent_7C7D6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7C7D6 = 4;
											end
											if (FlatIdent_7C7D6 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7C7D6 = 3;
											end
											if (FlatIdent_7C7D6 == 6) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_7C7D6 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_7C7D6 = 2;
											end
											if (FlatIdent_7C7D6 == 4) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_7C7D6 = 5;
											end
											if (5 == FlatIdent_7C7D6) then
												for Idx = A, Top do
													local FlatIdent_2BA7A = 0;
													while true do
														if (FlatIdent_2BA7A == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_7C7D6 = 6;
											end
										end
									end
								elseif (Enum <= 157) then
									if (Enum <= 155) then
										Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
									elseif (Enum == 156) then
										local FlatIdent_17FFB = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (4 == FlatIdent_17FFB) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_17FFB = 5;
											end
											if (0 == FlatIdent_17FFB) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_17FFB = 1;
											end
											if (FlatIdent_17FFB == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_17FFB = 8;
											end
											if (FlatIdent_17FFB == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_17FFB = 6;
											end
											if (FlatIdent_17FFB == 6) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_66159 = 0;
													while true do
														if (FlatIdent_66159 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_17FFB = 7;
											end
											if (FlatIdent_17FFB == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_17FFB = 2;
											end
											if (FlatIdent_17FFB == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_17FFB = 4;
											end
											if (FlatIdent_17FFB == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_17FFB = 3;
											end
											if (FlatIdent_17FFB == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
										end
									else
										local B;
										local T;
										local A;
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
										T = Stk[A];
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
									end
								elseif (Enum <= 158) then
									local K;
									local B;
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
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
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
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
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
									Stk[Inst[2]] = Stk[Inst[3]];
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
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
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
									Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
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
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
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
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
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
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return Stk[Inst[2]];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								elseif (Enum == 159) then
									local FlatIdent_3AE5D = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_3AE5D == 1) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3AE5D = 2;
										end
										if (FlatIdent_3AE5D == 7) then
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_88281 = 0;
												while true do
													if (0 == FlatIdent_88281) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											FlatIdent_3AE5D = 8;
										end
										if (FlatIdent_3AE5D == 4) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3AE5D = 5;
										end
										if (FlatIdent_3AE5D == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											FlatIdent_3AE5D = 1;
										end
										if (FlatIdent_3AE5D == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_3AE5D = 4;
										end
										if (FlatIdent_3AE5D == 6) then
											for Idx = A, Top do
												local FlatIdent_8B384 = 0;
												while true do
													if (FlatIdent_8B384 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_3AE5D = 7;
										end
										if (FlatIdent_3AE5D == 5) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_3AE5D = 6;
										end
										if (2 == FlatIdent_3AE5D) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_3AE5D = 3;
										end
										if (FlatIdent_3AE5D == 8) then
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
									end
								else
									local Edx;
									local Results, Limit;
									local A;
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
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
								end
							elseif (Enum <= 171) then
								if (Enum <= 165) then
									if (Enum <= 162) then
										if (Enum > 161) then
											local FlatIdent_89850 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_89850 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_89850 = 1;
												end
												if (FlatIdent_89850 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_89850 = 5;
												end
												if (FlatIdent_89850 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_89850 = 4;
												end
												if (FlatIdent_89850 == 1) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_89850 = 2;
												end
												if (FlatIdent_89850 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_89850 = 3;
												end
												if (FlatIdent_89850 == 8) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_89850 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_89850 = 8;
												end
												if (FlatIdent_89850 == 6) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													FlatIdent_89850 = 7;
												end
												if (FlatIdent_89850 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_89850 = 6;
												end
											end
										else
											local FlatIdent_66E7B = 0;
											local A;
											while true do
												if (FlatIdent_66E7B == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_66E7B = 3;
												end
												if (FlatIdent_66E7B == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_66E7B = 7;
												end
												if (FlatIdent_66E7B == 7) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_66E7B == 1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_66E7B = 2;
												end
												if (FlatIdent_66E7B == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_66E7B = 4;
												end
												if (FlatIdent_66E7B == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_66E7B = 1;
												end
												if (5 == FlatIdent_66E7B) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_66E7B = 6;
												end
												if (FlatIdent_66E7B == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_66E7B = 5;
												end
											end
										end
									elseif (Enum <= 163) then
										local A;
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum > 164) then
										local A;
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
									else
										local FlatIdent_4F33 = 0;
										local A;
										while true do
											if (FlatIdent_4F33 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_4F33 = 3;
											end
											if (FlatIdent_4F33 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4F33 = 4;
											end
											if (FlatIdent_4F33 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4F33 = 6;
											end
											if (6 == FlatIdent_4F33) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												break;
											end
											if (FlatIdent_4F33 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_4F33 = 1;
											end
											if (FlatIdent_4F33 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_4F33 = 2;
											end
											if (FlatIdent_4F33 == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_4F33 = 5;
											end
										end
									end
								elseif (Enum <= 168) then
									if (Enum <= 166) then
										local FlatIdent_100D9 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_100D9 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_100D9 = 3;
											end
											if (3 == FlatIdent_100D9) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_100D9 = 4;
											end
											if (FlatIdent_100D9 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_100D9 = 6;
											end
											if (FlatIdent_100D9 == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_100D9 = 2;
											end
											if (FlatIdent_100D9 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_100D9 = 5;
											end
											if (FlatIdent_100D9 == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_100D9 == 6) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_22181 = 0;
													while true do
														if (FlatIdent_22181 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_100D9 = 7;
											end
											if (FlatIdent_100D9 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_100D9 = 8;
											end
											if (FlatIdent_100D9 == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_100D9 = 1;
											end
										end
									elseif (Enum > 167) then
										Stk[Inst[2]] = Inst[3];
									else
										local T;
										local Edx;
										local Results, Limit;
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
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_93E2 = 0;
											while true do
												if (0 == FlatIdent_93E2) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
									end
								elseif (Enum <= 169) then
									Stk[Inst[2]] = {};
								elseif (Enum == 170) then
									local FlatIdent_7B58B = 0;
									local A;
									while true do
										if (FlatIdent_7B58B == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7B58B = 5;
										end
										if (FlatIdent_7B58B == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7B58B = 3;
										end
										if (FlatIdent_7B58B == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7B58B = 2;
										end
										if (0 == FlatIdent_7B58B) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7B58B = 1;
										end
										if (FlatIdent_7B58B == 7) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (6 == FlatIdent_7B58B) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7B58B = 7;
										end
										if (FlatIdent_7B58B == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7B58B = 4;
										end
										if (FlatIdent_7B58B == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7B58B = 6;
										end
									end
								else
									local Results;
									local Edx;
									local Results, Limit;
									local B;
									local A;
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
										local FlatIdent_46188 = 0;
										while true do
											if (FlatIdent_46188 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
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
								end
							elseif (Enum <= 177) then
								if (Enum <= 174) then
									if (Enum <= 172) then
										local FlatIdent_3166D = 0;
										local A;
										local T;
										while true do
											if (FlatIdent_3166D == 0) then
												A = Inst[2];
												T = Stk[A];
												FlatIdent_3166D = 1;
											end
											if (FlatIdent_3166D == 1) then
												for Idx = A + 1, Inst[3] do
													Insert(T, Stk[Idx]);
												end
												break;
											end
										end
									elseif (Enum > 173) then
										local A;
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									else
										local FlatIdent_345F5 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_345F5 == 6) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_14A39 = 0;
													while true do
														if (FlatIdent_14A39 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_345F5 = 7;
											end
											if (FlatIdent_345F5 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_345F5 = 6;
											end
											if (FlatIdent_345F5 == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_345F5 = 2;
											end
											if (FlatIdent_345F5 == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (0 == FlatIdent_345F5) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_345F5 = 1;
											end
											if (FlatIdent_345F5 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_345F5 = 5;
											end
											if (FlatIdent_345F5 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_345F5 = 4;
											end
											if (FlatIdent_345F5 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_345F5 = 8;
											end
											if (FlatIdent_345F5 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_345F5 = 3;
											end
										end
									end
								elseif (Enum <= 175) then
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
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
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Inst[2] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 176) then
									local FlatIdent_59C91 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_59C91 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_59C91 = 4;
										end
										if (FlatIdent_59C91 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_59C91 = 2;
										end
										if (2 == FlatIdent_59C91) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_59C91 = 3;
										end
										if (4 == FlatIdent_59C91) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_59C91 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_59C91 = 1;
										end
									end
								else
									local FlatIdent_84929 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_84929 == 9) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_84929 = 10;
										end
										if (26 == FlatIdent_84929) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 27;
										end
										if (FlatIdent_84929 == 32) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 33;
										end
										if (FlatIdent_84929 == 19) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 20;
										end
										if (FlatIdent_84929 == 27) then
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 28;
										end
										if (FlatIdent_84929 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 1;
										end
										if (FlatIdent_84929 == 23) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 24;
										end
										if (FlatIdent_84929 == 17) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 18;
										end
										if (FlatIdent_84929 == 16) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 17;
										end
										if (FlatIdent_84929 == 12) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											FlatIdent_84929 = 13;
										end
										if (FlatIdent_84929 == 14) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_84929 = 15;
										end
										if (FlatIdent_84929 == 15) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_84929 = 16;
										end
										if (FlatIdent_84929 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 3;
										end
										if (FlatIdent_84929 == 22) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_84929 = 23;
										end
										if (FlatIdent_84929 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_84929 = 6;
										end
										if (FlatIdent_84929 == 8) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 9;
										end
										if (FlatIdent_84929 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_84929 = 2;
										end
										if (20 == FlatIdent_84929) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_84929 = 21;
										end
										if (FlatIdent_84929 == 31) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 32;
										end
										if (FlatIdent_84929 == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 11;
										end
										if (FlatIdent_84929 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 7;
										end
										if (FlatIdent_84929 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 5;
										end
										if (13 == FlatIdent_84929) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_84929 = 14;
										end
										if (FlatIdent_84929 == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_84929 = 4;
										end
										if (FlatIdent_84929 == 29) then
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_84929 = 30;
										end
										if (FlatIdent_84929 == 24) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_84929 = 25;
										end
										if (FlatIdent_84929 == 28) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 29;
										end
										if (FlatIdent_84929 == 33) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											break;
										end
										if (FlatIdent_84929 == 21) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_84929 = 22;
										end
										if (FlatIdent_84929 == 18) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_84929 = 19;
										end
										if (FlatIdent_84929 == 25) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_84929 = 26;
										end
										if (30 == FlatIdent_84929) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_84929 = 31;
										end
										if (FlatIdent_84929 == 7) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_84929 = 8;
										end
										if (11 == FlatIdent_84929) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_84929 = 12;
										end
									end
								end
							elseif (Enum <= 180) then
								if (Enum <= 178) then
									local FlatIdent_7BA0C = 0;
									local A;
									while true do
										if (1 == FlatIdent_7BA0C) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_7BA0C = 2;
										end
										if (3 == FlatIdent_7BA0C) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_7BA0C == 2) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											FlatIdent_7BA0C = 3;
										end
										if (FlatIdent_7BA0C == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7BA0C = 1;
										end
									end
								elseif (Enum > 179) then
									local T;
									local Edx;
									local Results, Limit;
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
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_4C8C9 = 0;
										while true do
											if (FlatIdent_4C8C9 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									for Idx = A + 1, Top do
										Insert(T, Stk[Idx]);
									end
								else
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] <= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 181) then
								local FlatIdent_25EB1 = 0;
								local T;
								local Edx;
								local Results;
								local Limit;
								local A;
								while true do
									if (FlatIdent_25EB1 == 0) then
										T = nil;
										Edx = nil;
										Results, Limit = nil;
										FlatIdent_25EB1 = 1;
									end
									if (FlatIdent_25EB1 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_25EB1 = 5;
									end
									if (FlatIdent_25EB1 == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										FlatIdent_25EB1 = 6;
									end
									if (FlatIdent_25EB1 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_25EB1 = 8;
									end
									if (6 == FlatIdent_25EB1) then
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_6BA80 = 0;
											while true do
												if (0 == FlatIdent_6BA80) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										FlatIdent_25EB1 = 7;
									end
									if (FlatIdent_25EB1 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_25EB1 = 3;
									end
									if (FlatIdent_25EB1 == 8) then
										T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
										break;
									end
									if (FlatIdent_25EB1 == 1) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_25EB1 = 2;
									end
									if (3 == FlatIdent_25EB1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_25EB1 = 4;
									end
								end
							elseif (Enum == 182) then
								local FlatIdent_5D59E = 0;
								while true do
									if (FlatIdent_5D59E == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 2;
									end
									if (6 == FlatIdent_5D59E) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 7;
									end
									if (FlatIdent_5D59E == 3) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 4;
									end
									if (FlatIdent_5D59E == 8) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 9;
									end
									if (FlatIdent_5D59E == 7) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 8;
									end
									if (2 == FlatIdent_5D59E) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 3;
									end
									if (FlatIdent_5D59E == 4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 5;
									end
									if (FlatIdent_5D59E == 9) then
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (5 == FlatIdent_5D59E) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 6;
									end
									if (FlatIdent_5D59E == 0) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D59E = 1;
									end
								end
							else
								local A;
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
							end
						elseif (Enum <= 275) then
							if (Enum <= 229) then
								if (Enum <= 206) then
									if (Enum <= 194) then
										if (Enum <= 188) then
											if (Enum <= 185) then
												if (Enum == 184) then
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
													do
														return Stk[A](Unpack(Stk, A + 1, Inst[3]));
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													do
														return Unpack(Stk, A, Top);
													end
												else
													local FlatIdent_EA8F = 0;
													local A;
													while true do
														if (FlatIdent_EA8F == 0) then
															A = nil;
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_EA8F = 1;
														end
														if (FlatIdent_EA8F == 4) then
															Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_EA8F = 5;
														end
														if (FlatIdent_EA8F == 1) then
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															FlatIdent_EA8F = 2;
														end
														if (FlatIdent_EA8F == 6) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_EA8F = 7;
														end
														if (FlatIdent_EA8F == 2) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_EA8F = 3;
														end
														if (7 == FlatIdent_EA8F) then
															A = Inst[2];
															Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
															break;
														end
														if (FlatIdent_EA8F == 3) then
															Inst = Instr[VIP];
															Stk[Inst[2]] = Env[Inst[3]];
															VIP = VIP + 1;
															Inst = Instr[VIP];
															FlatIdent_EA8F = 4;
														end
														if (FlatIdent_EA8F == 5) then
															VIP = VIP + 1;
															Inst = Instr[VIP];
															Stk[Inst[2]] = Inst[3];
															VIP = VIP + 1;
															FlatIdent_EA8F = 6;
														end
													end
												end
											elseif (Enum <= 186) then
												local T;
												local Edx;
												local Results, Limit;
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
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_65794 = 0;
													while true do
														if (FlatIdent_65794 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
											elseif (Enum == 187) then
												if not Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
											else
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											end
										elseif (Enum <= 191) then
											if (Enum <= 189) then
												local FlatIdent_3111D = 0;
												local Results;
												local Edx;
												local Limit;
												local B;
												local A;
												while true do
													if (FlatIdent_3111D == 5) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Stk[A + 1]));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_3111D = 6;
													end
													if (FlatIdent_3111D == 6) then
														for Idx = A, Top do
															local FlatIdent_67F5 = 0;
															while true do
																if (FlatIdent_67F5 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results = {Stk[A](Unpack(Stk, A + 1, Top))};
														FlatIdent_3111D = 7;
													end
													if (FlatIdent_3111D == 7) then
														Edx = 0;
														for Idx = A, Inst[4] do
															local FlatIdent_63561 = 0;
															while true do
																if (FlatIdent_63561 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_3111D == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_3111D = 4;
													end
													if (FlatIdent_3111D == 0) then
														Results = nil;
														Edx = nil;
														Results, Limit = nil;
														B = nil;
														A = nil;
														FlatIdent_3111D = 1;
													end
													if (4 == FlatIdent_3111D) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3111D = 5;
													end
													if (FlatIdent_3111D == 1) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_3111D = 2;
													end
													if (FlatIdent_3111D == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_3111D = 3;
													end
												end
											elseif (Enum > 190) then
												local FlatIdent_2EE94 = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_2EE94 == 8) then
														Stk[Inst[2]] = Inst[3] ~= 0;
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2EE94 = 9;
													end
													if (FlatIdent_2EE94 == 1) then
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_2EE94 = 2;
													end
													if (FlatIdent_2EE94 == 9) then
														Upvalues[Inst[3]] = Stk[Inst[2]];
														break;
													end
													if (FlatIdent_2EE94 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														FlatIdent_2EE94 = 3;
													end
													if (FlatIdent_2EE94 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_2EE94 = 4;
													end
													if (FlatIdent_2EE94 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_2EE94 = 5;
													end
													if (FlatIdent_2EE94 == 5) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_2EE94 = 6;
													end
													if (7 == FlatIdent_2EE94) then
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_2EE94 = 8;
													end
													if (FlatIdent_2EE94 == 0) then
														B = nil;
														A = nil;
														A = Inst[2];
														FlatIdent_2EE94 = 1;
													end
													if (FlatIdent_2EE94 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_2EE94 = 7;
													end
												end
											else
												local FlatIdent_44B69 = 0;
												local A;
												while true do
													if (FlatIdent_44B69 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_44B69 = 2;
													end
													if (FlatIdent_44B69 == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_44B69 == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_44B69 = 1;
													end
													if (FlatIdent_44B69 == 2) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_44B69 = 3;
													end
													if (FlatIdent_44B69 == 3) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_44B69 = 4;
													end
												end
											end
										elseif (Enum <= 192) then
											local FlatIdent_5DDA1 = 0;
											local Edx;
											local Results;
											local A;
											while true do
												if (FlatIdent_5DDA1 == 2) then
													for Idx = A, Inst[4] do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5DDA1 = 3;
												end
												if (FlatIdent_5DDA1 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5DDA1 = 5;
												end
												if (FlatIdent_5DDA1 == 0) then
													Edx = nil;
													Results = nil;
													A = nil;
													FlatIdent_5DDA1 = 1;
												end
												if (FlatIdent_5DDA1 == 6) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_5DDA1 = 7;
												end
												if (3 == FlatIdent_5DDA1) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5DDA1 = 4;
												end
												if (FlatIdent_5DDA1 == 7) then
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (5 == FlatIdent_5DDA1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5DDA1 = 6;
												end
												if (1 == FlatIdent_5DDA1) then
													A = Inst[2];
													Results = {Stk[A](Stk[A + 1])};
													Edx = 0;
													FlatIdent_5DDA1 = 2;
												end
											end
										elseif (Enum > 193) then
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
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
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
										else
											local B;
											local A;
											Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum <= 200) then
										if (Enum <= 197) then
											if (Enum <= 195) then
												local B;
												local A;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
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
											elseif (Enum > 196) then
												local B;
												local A;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
											else
												local FlatIdent_ADCD = 0;
												local B;
												local K;
												while true do
													if (FlatIdent_ADCD == 0) then
														B = Inst[3];
														K = Stk[B];
														FlatIdent_ADCD = 1;
													end
													if (1 == FlatIdent_ADCD) then
														for Idx = B + 1, Inst[4] do
															K = K .. Stk[Idx];
														end
														Stk[Inst[2]] = K;
														break;
													end
												end
											end
										elseif (Enum <= 198) then
											do
												return Stk[Inst[2]];
											end
										elseif (Enum > 199) then
											local FlatIdent_7F8E1 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_7F8E1 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7F8E1 = 5;
												end
												if (FlatIdent_7F8E1 == 13) then
													VIP = Inst[3];
													break;
												end
												if (1 == FlatIdent_7F8E1) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7F8E1 = 2;
												end
												if (11 == FlatIdent_7F8E1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													FlatIdent_7F8E1 = 12;
												end
												if (FlatIdent_7F8E1 == 9) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_7F8E1 = 10;
												end
												if (8 == FlatIdent_7F8E1) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_7F8E1 = 9;
												end
												if (FlatIdent_7F8E1 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_7F8E1 = 4;
												end
												if (6 == FlatIdent_7F8E1) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_7F8E1 = 7;
												end
												if (FlatIdent_7F8E1 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_7F8E1 = 3;
												end
												if (FlatIdent_7F8E1 == 12) then
													Edx = 0;
													for Idx = A, Inst[4] do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7F8E1 = 13;
												end
												if (FlatIdent_7F8E1 == 5) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7F8E1 = 6;
												end
												if (FlatIdent_7F8E1 == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													FlatIdent_7F8E1 = 1;
												end
												if (10 == FlatIdent_7F8E1) then
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_3AB30 = 0;
														while true do
															if (FlatIdent_3AB30 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													FlatIdent_7F8E1 = 11;
												end
												if (FlatIdent_7F8E1 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_7F8E1 = 8;
												end
											end
										else
											local FlatIdent_30526 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (8 == FlatIdent_30526) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_30526 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_30526 = 4;
												end
												if (FlatIdent_30526 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_30526 = 6;
												end
												if (6 == FlatIdent_30526) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_89204 = 0;
														while true do
															if (FlatIdent_89204 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													FlatIdent_30526 = 7;
												end
												if (FlatIdent_30526 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_30526 = 5;
												end
												if (FlatIdent_30526 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_30526 = 3;
												end
												if (FlatIdent_30526 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_30526 = 1;
												end
												if (FlatIdent_30526 == 1) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_30526 = 2;
												end
												if (FlatIdent_30526 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_30526 = 8;
												end
											end
										end
									elseif (Enum <= 203) then
										if (Enum <= 201) then
											local FlatIdent_243C5 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_243C5 == 5) then
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_8971C = 0;
														while true do
															if (FlatIdent_8971C == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_243C5 = 6;
												end
												if (FlatIdent_243C5 == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													A = nil;
													FlatIdent_243C5 = 1;
												end
												if (FlatIdent_243C5 == 4) then
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_5D2CC = 0;
														while true do
															if (FlatIdent_5D2CC == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_243C5 = 5;
												end
												if (FlatIdent_243C5 == 1) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_243C5 = 2;
												end
												if (FlatIdent_243C5 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													FlatIdent_243C5 = 4;
												end
												if (6 == FlatIdent_243C5) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_243C5 == 2) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_243C5 = 3;
												end
											end
										elseif (Enum > 202) then
											local FlatIdent_26D57 = 0;
											local A;
											while true do
												if (FlatIdent_26D57 == 1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_26D57 = 2;
												end
												if (FlatIdent_26D57 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_26D57 = 3;
												end
												if (FlatIdent_26D57 == 7) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_26D57 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_26D57 = 7;
												end
												if (FlatIdent_26D57 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_26D57 = 4;
												end
												if (FlatIdent_26D57 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_26D57 = 5;
												end
												if (FlatIdent_26D57 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_26D57 = 1;
												end
												if (5 == FlatIdent_26D57) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_26D57 = 6;
												end
											end
										else
											local A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									elseif (Enum <= 204) then
										local K;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
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
										Stk[Inst[2]] = Env[Inst[3]];
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
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										B = Inst[3];
										K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
									elseif (Enum == 205) then
										local FlatIdent_5CC45 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5CC45 == 4) then
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Upvalues[Inst[3]] = Stk[Inst[2]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5CC45 = 5;
											end
											if (FlatIdent_5CC45 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5CC45 = 4;
											end
											if (FlatIdent_5CC45 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_5CC45 = 2;
											end
											if (FlatIdent_5CC45 == 5) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5CC45 = 6;
											end
											if (FlatIdent_5CC45 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_5CC45 = 3;
											end
											if (FlatIdent_5CC45 == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_5CC45 = 7;
											end
											if (FlatIdent_5CC45 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_5CC45 = 1;
											end
											if (FlatIdent_5CC45 == 7) then
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
										end
									else
										local FlatIdent_35634 = 0;
										local A;
										while true do
											if (4 == FlatIdent_35634) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_35634 = 5;
											end
											if (FlatIdent_35634 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_35634 = 1;
											end
											if (FlatIdent_35634 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_35634 = 3;
											end
											if (3 == FlatIdent_35634) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_35634 = 4;
											end
											if (FlatIdent_35634 == 7) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_35634 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_35634 = 2;
											end
											if (FlatIdent_35634 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_35634 = 7;
											end
											if (FlatIdent_35634 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_35634 = 6;
											end
										end
									end
								elseif (Enum <= 217) then
									if (Enum <= 211) then
										if (Enum <= 208) then
											if (Enum > 207) then
												local FlatIdent_5E0A = 0;
												local B;
												local A;
												while true do
													if (0 == FlatIdent_5E0A) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_5E0A = 1;
													end
													if (FlatIdent_5E0A == 2) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5E0A = 3;
													end
													if (FlatIdent_5E0A == 5) then
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_5E0A = 6;
													end
													if (6 == FlatIdent_5E0A) then
														Inst = Instr[VIP];
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_5E0A == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = #Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_5E0A = 2;
													end
													if (FlatIdent_5E0A == 4) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5E0A = 5;
													end
													if (FlatIdent_5E0A == 3) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_5E0A = 4;
													end
												end
											else
												local FlatIdent_24361 = 0;
												local A;
												while true do
													if (FlatIdent_24361 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_24361 = 5;
													end
													if (0 == FlatIdent_24361) then
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_24361 = 1;
													end
													if (FlatIdent_24361 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_24361 = 4;
													end
													if (FlatIdent_24361 == 7) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														break;
													end
													if (FlatIdent_24361 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_24361 = 7;
													end
													if (FlatIdent_24361 == 2) then
														Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_24361 = 3;
													end
													if (FlatIdent_24361 == 5) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_24361 = 6;
													end
													if (FlatIdent_24361 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_24361 = 2;
													end
												end
											end
										elseif (Enum <= 209) then
											local FlatIdent_8FE1 = 0;
											local A;
											while true do
												if (FlatIdent_8FE1 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8FE1 = 4;
												end
												if (FlatIdent_8FE1 == 4) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8FE1 = 5;
												end
												if (7 == FlatIdent_8FE1) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (6 == FlatIdent_8FE1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8FE1 = 7;
												end
												if (FlatIdent_8FE1 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8FE1 = 6;
												end
												if (FlatIdent_8FE1 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_8FE1 = 3;
												end
												if (FlatIdent_8FE1 == 1) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8FE1 = 2;
												end
												if (FlatIdent_8FE1 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_8FE1 = 1;
												end
											end
										elseif (Enum == 210) then
											local FlatIdent_81B51 = 0;
											local A;
											while true do
												if (2 == FlatIdent_81B51) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 3;
												end
												if (FlatIdent_81B51 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 7;
												end
												if (FlatIdent_81B51 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 9;
												end
												if (FlatIdent_81B51 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 2;
												end
												if (4 == FlatIdent_81B51) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_81B51 = 5;
												end
												if (FlatIdent_81B51 == 9) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_81B51 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 1;
												end
												if (FlatIdent_81B51 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 4;
												end
												if (FlatIdent_81B51 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_81B51 = 6;
												end
												if (FlatIdent_81B51 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_81B51 = 8;
												end
											end
										elseif (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 214) then
										if (Enum <= 212) then
											local FlatIdent_6C44A = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_6C44A == 6) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_62A3E = 0;
														while true do
															if (0 == FlatIdent_62A3E) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													FlatIdent_6C44A = 7;
												end
												if (FlatIdent_6C44A == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_6C44A = 6;
												end
												if (FlatIdent_6C44A == 1) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_6C44A = 2;
												end
												if (FlatIdent_6C44A == 8) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (3 == FlatIdent_6C44A) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6C44A = 4;
												end
												if (FlatIdent_6C44A == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_6C44A = 8;
												end
												if (FlatIdent_6C44A == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6C44A = 5;
												end
												if (FlatIdent_6C44A == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_6C44A = 1;
												end
												if (FlatIdent_6C44A == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_6C44A = 3;
												end
											end
										elseif (Enum == 213) then
											local A;
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
										else
											local FlatIdent_934DA = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_934DA == 5) then
													Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_934DA = 6;
												end
												if (FlatIdent_934DA == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_934DA = 2;
												end
												if (FlatIdent_934DA == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_934DA = 8;
												end
												if (FlatIdent_934DA == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_934DA = 4;
												end
												if (FlatIdent_934DA == 12) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													break;
												end
												if (FlatIdent_934DA == 9) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_934DA = 10;
												end
												if (FlatIdent_934DA == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_934DA = 5;
												end
												if (FlatIdent_934DA == 10) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_934DA = 11;
												end
												if (FlatIdent_934DA == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_934DA = 7;
												end
												if (FlatIdent_934DA == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Upvalues[Inst[3]] = Stk[Inst[2]];
													VIP = VIP + 1;
													FlatIdent_934DA = 1;
												end
												if (FlatIdent_934DA == 11) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_934DA = 12;
												end
												if (FlatIdent_934DA == 8) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_934DA = 9;
												end
												if (FlatIdent_934DA == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_934DA = 3;
												end
											end
										end
									elseif (Enum <= 215) then
										Stk[Inst[2]] = {};
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
									elseif (Enum > 216) then
										local FlatIdent_97D97 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_97D97 == 4) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_97D97 = 5;
											end
											if (FlatIdent_97D97 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_97D97 = 1;
											end
											if (FlatIdent_97D97 == 6) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_97D97 = 7;
											end
											if (3 == FlatIdent_97D97) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97D97 = 4;
											end
											if (FlatIdent_97D97 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_97D97 = 2;
											end
											if (FlatIdent_97D97 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_97D97 = 8;
											end
											if (FlatIdent_97D97 == 8) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												break;
											end
											if (2 == FlatIdent_97D97) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_97D97 = 3;
											end
											if (FlatIdent_97D97 == 5) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97D97 = 6;
											end
										end
									else
										local A;
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
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
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 223) then
									if (Enum <= 220) then
										if (Enum <= 218) then
											local A = Inst[2];
											do
												return Unpack(Stk, A, Top);
											end
										elseif (Enum == 219) then
											local FlatIdent_2399A = 0;
											local B;
											local A;
											while true do
												if (0 == FlatIdent_2399A) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2399A = 1;
												end
												if (FlatIdent_2399A == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2399A = 3;
												end
												if (FlatIdent_2399A == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_2399A = 5;
												end
												if (FlatIdent_2399A == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_2399A = 6;
												end
												if (FlatIdent_2399A == 7) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2399A = 8;
												end
												if (FlatIdent_2399A == 8) then
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_2399A == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_2399A = 4;
												end
												if (FlatIdent_2399A == 6) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2399A = 7;
												end
												if (FlatIdent_2399A == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2399A = 2;
												end
											end
										else
											local FlatIdent_10E2D = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_10E2D == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_10E2D = 5;
												end
												if (5 == FlatIdent_10E2D) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_10E2D = 6;
												end
												if (3 == FlatIdent_10E2D) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_10E2D = 4;
												end
												if (FlatIdent_10E2D == 2) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_10E2D = 3;
												end
												if (FlatIdent_10E2D == 6) then
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_10E2D == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_10E2D = 1;
												end
												if (FlatIdent_10E2D == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_10E2D = 2;
												end
											end
										end
									elseif (Enum <= 221) then
										local FlatIdent_7E127 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_7E127 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_7E127 = 8;
											end
											if (FlatIdent_7E127 == 3) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_7E127 = 4;
											end
											if (FlatIdent_7E127 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_7E127 = 9;
											end
											if (4 == FlatIdent_7E127) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												FlatIdent_7E127 = 5;
											end
											if (FlatIdent_7E127 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]]();
												FlatIdent_7E127 = 1;
											end
											if (9 == FlatIdent_7E127) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_7E127 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_7E127 = 2;
											end
											if (FlatIdent_7E127 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_7E127 = 7;
											end
											if (FlatIdent_7E127 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_7E127 = 6;
											end
											if (FlatIdent_7E127 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_7E127 = 3;
											end
										end
									elseif (Enum > 222) then
										local FlatIdent_FDB9 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_FDB9 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_FDB9 = 5;
											end
											if (FlatIdent_FDB9 == 3) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_FDB9 = 4;
											end
											if (FlatIdent_FDB9 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_FDB9 = 3;
											end
											if (FlatIdent_FDB9 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_FDB9 = 2;
											end
											if (0 == FlatIdent_FDB9) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_FDB9 = 1;
											end
											if (FlatIdent_FDB9 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									else
										local FlatIdent_81325 = 0;
										local B;
										local T;
										local A;
										while true do
											if (FlatIdent_81325 == 6) then
												A = Inst[2];
												T = Stk[A];
												B = Inst[3];
												FlatIdent_81325 = 7;
											end
											if (FlatIdent_81325 == 0) then
												B = nil;
												T = nil;
												A = nil;
												FlatIdent_81325 = 1;
											end
											if (FlatIdent_81325 == 2) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81325 = 3;
											end
											if (FlatIdent_81325 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81325 = 6;
											end
											if (4 == FlatIdent_81325) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81325 = 5;
											end
											if (FlatIdent_81325 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81325 = 2;
											end
											if (FlatIdent_81325 == 3) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81325 = 4;
											end
											if (FlatIdent_81325 == 7) then
												for Idx = 1, B do
													T[Idx] = Stk[A + Idx];
												end
												break;
											end
										end
									end
								elseif (Enum <= 226) then
									if (Enum <= 224) then
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] < Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum == 225) then
										local FlatIdent_62932 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_62932 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_62932 = 3;
											end
											if (FlatIdent_62932 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_62932 = 4;
											end
											if (6 == FlatIdent_62932) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_62932 == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_62932 = 1;
											end
											if (1 == FlatIdent_62932) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_62932 = 2;
											end
											if (FlatIdent_62932 == 5) then
												for Idx = A, Top do
													local FlatIdent_7DBD1 = 0;
													while true do
														if (FlatIdent_7DBD1 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_62932 = 6;
											end
											if (FlatIdent_62932 == 4) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_62932 = 5;
											end
										end
									else
										local FlatIdent_27A0C = 0;
										local A;
										while true do
											if (FlatIdent_27A0C == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if (Stk[Inst[2]] < Inst[4]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_27A0C == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												FlatIdent_27A0C = 4;
											end
											if (FlatIdent_27A0C == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_27A0C = 3;
											end
											if (FlatIdent_27A0C == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_27A0C = 1;
											end
											if (FlatIdent_27A0C == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A]();
												FlatIdent_27A0C = 2;
											end
										end
									end
								elseif (Enum <= 227) then
									local K;
									local B;
									local A;
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
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								elseif (Enum == 228) then
									Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								else
									local A = Inst[2];
									local Results = {Stk[A]()};
									local Limit = Inst[4];
									local Edx = 0;
									for Idx = A, Limit do
										local FlatIdent_F111 = 0;
										while true do
											if (FlatIdent_F111 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
								end
							elseif (Enum <= 252) then
								if (Enum <= 240) then
									if (Enum <= 234) then
										if (Enum <= 231) then
											if (Enum > 230) then
												local FlatIdent_78541 = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_78541 == 0) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														FlatIdent_78541 = 1;
													end
													if (FlatIdent_78541 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_78541 = 2;
													end
													if (5 == FlatIdent_78541) then
														for Idx = A, Top do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_78541 = 6;
													end
													if (FlatIdent_78541 == 4) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_78541 = 5;
													end
													if (FlatIdent_78541 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_78541 = 3;
													end
													if (FlatIdent_78541 == 6) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
													if (FlatIdent_78541 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_78541 = 4;
													end
												end
											else
												local B;
												local A;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
											end
										elseif (Enum <= 232) then
											local FlatIdent_80889 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_80889 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_80889 = 1;
												end
												if (FlatIdent_80889 == 31) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 32;
												end
												if (FlatIdent_80889 == 18) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_80889 = 19;
												end
												if (FlatIdent_80889 == 3) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_80889 = 4;
												end
												if (17 == FlatIdent_80889) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_80889 = 18;
												end
												if (FlatIdent_80889 == 27) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_80889 = 28;
												end
												if (5 == FlatIdent_80889) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_80889 = 6;
												end
												if (FlatIdent_80889 == 24) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 25;
												end
												if (FlatIdent_80889 == 14) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_80889 = 15;
												end
												if (FlatIdent_80889 == 25) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_80889 = 26;
												end
												if (FlatIdent_80889 == 2) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 3;
												end
												if (FlatIdent_80889 == 29) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_80889 = 30;
												end
												if (32 == FlatIdent_80889) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_80889 == 7) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 8;
												end
												if (FlatIdent_80889 == 22) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_80889 = 23;
												end
												if (FlatIdent_80889 == 30) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 31;
												end
												if (23 == FlatIdent_80889) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 24;
												end
												if (FlatIdent_80889 == 11) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_80889 = 12;
												end
												if (FlatIdent_80889 == 19) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													FlatIdent_80889 = 20;
												end
												if (FlatIdent_80889 == 21) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_80889 = 22;
												end
												if (FlatIdent_80889 == 16) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_80889 = 17;
												end
												if (FlatIdent_80889 == 13) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_80889 = 14;
												end
												if (FlatIdent_80889 == 6) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_80889 = 7;
												end
												if (FlatIdent_80889 == 26) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_80889 = 27;
												end
												if (FlatIdent_80889 == 8) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 9;
												end
												if (FlatIdent_80889 == 9) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_80889 = 10;
												end
												if (FlatIdent_80889 == 10) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_80889 = 11;
												end
												if (FlatIdent_80889 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_80889 = 5;
												end
												if (12 == FlatIdent_80889) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 13;
												end
												if (FlatIdent_80889 == 20) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_80889 = 21;
												end
												if (FlatIdent_80889 == 15) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_80889 = 16;
												end
												if (1 == FlatIdent_80889) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_80889 = 2;
												end
												if (FlatIdent_80889 == 28) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_80889 = 29;
												end
											end
										elseif (Enum == 233) then
											local FlatIdent_1CC3 = 0;
											local A;
											while true do
												if (FlatIdent_1CC3 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 8;
												end
												if (FlatIdent_1CC3 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 5;
												end
												if (5 == FlatIdent_1CC3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 6;
												end
												if (1 == FlatIdent_1CC3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 2;
												end
												if (FlatIdent_1CC3 == 9) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_1CC3 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 4;
												end
												if (FlatIdent_1CC3 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 1;
												end
												if (2 == FlatIdent_1CC3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 3;
												end
												if (FlatIdent_1CC3 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 7;
												end
												if (FlatIdent_1CC3 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1CC3 = 9;
												end
											end
										else
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
											Stk[Inst[2]] = Stk[Inst[3]];
										end
									elseif (Enum <= 237) then
										if (Enum <= 235) then
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
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
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
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
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
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
											Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
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
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
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
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
										elseif (Enum > 236) then
											local FlatIdent_2BE31 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_2BE31 == 5) then
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_2BE31 = 6;
												end
												if (FlatIdent_2BE31 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2BE31 = 3;
												end
												if (FlatIdent_2BE31 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2BE31 = 4;
												end
												if (FlatIdent_2BE31 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_2BE31 = 1;
												end
												if (FlatIdent_2BE31 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_2BE31 = 2;
												end
												if (FlatIdent_2BE31 == 6) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (4 == FlatIdent_2BE31) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_2BE31 = 5;
												end
											end
										else
											local FlatIdent_7FA38 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_7FA38 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_7FA38 = 3;
												end
												if (FlatIdent_7FA38 == 7) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7FA38 = 8;
												end
												if (FlatIdent_7FA38 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_7FA38 = 1;
												end
												if (FlatIdent_7FA38 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_7FA38 = 4;
												end
												if (FlatIdent_7FA38 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_7FA38 = 5;
												end
												if (FlatIdent_7FA38 == 1) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_7FA38 = 2;
												end
												if (FlatIdent_7FA38 == 6) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_7FA38 = 7;
												end
												if (FlatIdent_7FA38 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_7FA38 = 6;
												end
												if (FlatIdent_7FA38 == 8) then
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
											end
										end
									elseif (Enum <= 238) then
										local FlatIdent_4A877 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_4A877 == 5) then
												for Idx = A, Top do
													local FlatIdent_4CA9C = 0;
													while true do
														if (FlatIdent_4CA9C == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_4A877 = 6;
											end
											if (4 == FlatIdent_4A877) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_4A877 = 5;
											end
											if (FlatIdent_4A877 == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_4A877 = 1;
											end
											if (FlatIdent_4A877 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4A877 = 4;
											end
											if (FlatIdent_4A877 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_4A877 = 3;
											end
											if (FlatIdent_4A877 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_4A877 = 2;
											end
											if (FlatIdent_4A877 == 6) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
										end
									elseif (Enum == 239) then
										local A;
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
									else
										local FlatIdent_3B9AB = 0;
										local A;
										while true do
											if (FlatIdent_3B9AB == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_3B9AB = 5;
											end
											if (6 == FlatIdent_3B9AB) then
												if (Stk[Inst[2]] == Inst[4]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_3B9AB == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_3B9AB = 4;
											end
											if (5 == FlatIdent_3B9AB) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] % Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B9AB = 6;
											end
											if (FlatIdent_3B9AB == 0) then
												A = nil;
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_3B9AB = 1;
											end
											if (FlatIdent_3B9AB == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B9AB = 2;
											end
											if (FlatIdent_3B9AB == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_3B9AB = 3;
											end
										end
									end
								elseif (Enum <= 246) then
									if (Enum <= 243) then
										if (Enum <= 241) then
											local FlatIdent_23742 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_23742 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_23742 = 4;
												end
												if (FlatIdent_23742 == 5) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_23742 = 6;
												end
												if (FlatIdent_23742 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_23742 = 1;
												end
												if (FlatIdent_23742 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_23742 = 2;
												end
												if (FlatIdent_23742 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_23742 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_23742 = 5;
												end
												if (FlatIdent_23742 == 2) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_23742 = 3;
												end
											end
										elseif (Enum > 242) then
											local FlatIdent_4B6D1 = 0;
											local A;
											while true do
												if (FlatIdent_4B6D1 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 8;
												end
												if (FlatIdent_4B6D1 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 2;
												end
												if (FlatIdent_4B6D1 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 1;
												end
												if (FlatIdent_4B6D1 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 6;
												end
												if (3 == FlatIdent_4B6D1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 4;
												end
												if (FlatIdent_4B6D1 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 3;
												end
												if (FlatIdent_4B6D1 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 9;
												end
												if (FlatIdent_4B6D1 == 9) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_4B6D1 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 5;
												end
												if (6 == FlatIdent_4B6D1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_4B6D1 = 7;
												end
											end
										else
											local FlatIdent_578B5 = 0;
											local A;
											while true do
												if (FlatIdent_578B5 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_578B5 = 8;
												end
												if (FlatIdent_578B5 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_578B5 = 2;
												end
												if (FlatIdent_578B5 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_578B5 = 9;
												end
												if (FlatIdent_578B5 == 0) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_578B5 = 1;
												end
												if (FlatIdent_578B5 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													FlatIdent_578B5 = 7;
												end
												if (2 == FlatIdent_578B5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_578B5 = 3;
												end
												if (9 == FlatIdent_578B5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_578B5 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_578B5 = 6;
												end
												if (FlatIdent_578B5 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_578B5 = 4;
												end
												if (FlatIdent_578B5 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_578B5 = 5;
												end
											end
										end
									elseif (Enum <= 244) then
										local FlatIdent_43D12 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_43D12 == 6) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_43D12 == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_43D12 = 1;
											end
											if (FlatIdent_43D12 == 5) then
												for Idx = A, Top do
													local FlatIdent_3B5FF = 0;
													while true do
														if (FlatIdent_3B5FF == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_43D12 = 6;
											end
											if (4 == FlatIdent_43D12) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_43D12 = 5;
											end
											if (FlatIdent_43D12 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_43D12 = 4;
											end
											if (FlatIdent_43D12 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_43D12 = 3;
											end
											if (FlatIdent_43D12 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_43D12 = 2;
											end
										end
									elseif (Enum > 245) then
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
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
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
										local FlatIdent_1BD14 = 0;
										local B;
										local A;
										while true do
											if (0 == FlatIdent_1BD14) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1BD14 = 1;
											end
											if (FlatIdent_1BD14 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												FlatIdent_1BD14 = 4;
											end
											if (2 == FlatIdent_1BD14) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_1BD14 = 3;
											end
											if (FlatIdent_1BD14 == 5) then
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_1BD14 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1BD14 = 2;
											end
											if (FlatIdent_1BD14 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_1BD14 = 5;
											end
										end
									end
								elseif (Enum <= 249) then
									if (Enum <= 247) then
										local FlatIdent_61534 = 0;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (8 == FlatIdent_61534) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_69EB = 0;
													while true do
														if (FlatIdent_69EB == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												break;
											end
											if (FlatIdent_61534 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_61534 = 6;
											end
											if (3 == FlatIdent_61534) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_61534 = 4;
											end
											if (FlatIdent_61534 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_61534 = 8;
											end
											if (FlatIdent_61534 == 0) then
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												FlatIdent_61534 = 1;
											end
											if (FlatIdent_61534 == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_61534 = 7;
											end
											if (FlatIdent_61534 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_61534 = 2;
											end
											if (4 == FlatIdent_61534) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_61534 = 5;
											end
											if (2 == FlatIdent_61534) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_61534 = 3;
											end
										end
									elseif (Enum == 248) then
										local A = Inst[2];
										local Results, Limit = _R(Stk[A]());
										Top = (Limit + A) - 1;
										local Edx = 0;
										for Idx = A, Top do
											local FlatIdent_3BE5E = 0;
											while true do
												if (FlatIdent_3BE5E == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
									else
										local FlatIdent_440D0 = 0;
										local A;
										while true do
											if (FlatIdent_440D0 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_440D0 = 2;
											end
											if (7 == FlatIdent_440D0) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_440D0 == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_440D0 = 5;
											end
											if (FlatIdent_440D0 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_440D0 = 4;
											end
											if (FlatIdent_440D0 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_440D0 = 7;
											end
											if (2 == FlatIdent_440D0) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_440D0 = 3;
											end
											if (FlatIdent_440D0 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_440D0 = 6;
											end
											if (FlatIdent_440D0 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_440D0 = 1;
											end
										end
									end
								elseif (Enum <= 250) then
									local FlatIdent_1CA53 = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (7 == FlatIdent_1CA53) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_1CA53 = 8;
										end
										if (FlatIdent_1CA53 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_1CA53 = 5;
										end
										if (FlatIdent_1CA53 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_1CA53 = 3;
										end
										if (FlatIdent_1CA53 == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_1CA53 = 7;
										end
										if (FlatIdent_1CA53 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_1CA53 = 4;
										end
										if (FlatIdent_1CA53 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_1CA53 = 6;
										end
										if (FlatIdent_1CA53 == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_1CA53 = 1;
										end
										if (FlatIdent_1CA53 == 1) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_1CA53 = 2;
										end
										if (FlatIdent_1CA53 == 8) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
									end
								elseif (Enum > 251) then
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								else
									do
										return;
									end
								end
							elseif (Enum <= 263) then
								if (Enum <= 257) then
									if (Enum <= 254) then
										if (Enum == 253) then
											local FlatIdent_62EB5 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_62EB5 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_62EB5 = 4;
												end
												if (FlatIdent_62EB5 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_62EB5 = 5;
												end
												if (FlatIdent_62EB5 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3] ~= 0;
													VIP = VIP + 1;
													FlatIdent_62EB5 = 7;
												end
												if (8 == FlatIdent_62EB5) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_62EB5 == 7) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_62EB5 = 8;
												end
												if (FlatIdent_62EB5 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_62EB5 = 2;
												end
												if (FlatIdent_62EB5 == 2) then
													Stk[A] = B[Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_62EB5 = 3;
												end
												if (FlatIdent_62EB5 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_62EB5 = 1;
												end
												if (FlatIdent_62EB5 == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_62EB5 = 6;
												end
											end
										else
											local FlatIdent_5854A = 0;
											local B;
											local A;
											while true do
												if (1 == FlatIdent_5854A) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_5854A = 2;
												end
												if (FlatIdent_5854A == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													FlatIdent_5854A = 7;
												end
												if (FlatIdent_5854A == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 10;
												end
												if (FlatIdent_5854A == 5) then
													Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_5854A = 6;
												end
												if (7 == FlatIdent_5854A) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_5854A = 8;
												end
												if (FlatIdent_5854A == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													FlatIdent_5854A = 1;
												end
												if (FlatIdent_5854A == 11) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 12;
												end
												if (18 == FlatIdent_5854A) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_5854A = 19;
												end
												if (FlatIdent_5854A == 16) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 17;
												end
												if (FlatIdent_5854A == 20) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_5854A = 21;
												end
												if (FlatIdent_5854A == 15) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 16;
												end
												if (FlatIdent_5854A == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 5;
												end
												if (FlatIdent_5854A == 3) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 4;
												end
												if (FlatIdent_5854A == 14) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_5854A = 15;
												end
												if (FlatIdent_5854A == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_5854A = 9;
												end
												if (13 == FlatIdent_5854A) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5854A = 14;
												end
												if (FlatIdent_5854A == 19) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_5854A = 20;
												end
												if (FlatIdent_5854A == 10) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 11;
												end
												if (FlatIdent_5854A == 22) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													break;
												end
												if (FlatIdent_5854A == 12) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 13;
												end
												if (FlatIdent_5854A == 21) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 22;
												end
												if (FlatIdent_5854A == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_5854A = 3;
												end
												if (FlatIdent_5854A == 17) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_5854A = 18;
												end
											end
										end
									elseif (Enum <= 255) then
										local FlatIdent_6EFC8 = 0;
										local A;
										while true do
											if (4 == FlatIdent_6EFC8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_6EFC8 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_6EFC8 = 1;
											end
											if (FlatIdent_6EFC8 == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_6EFC8 = 4;
											end
											if (FlatIdent_6EFC8 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_6EFC8 = 3;
											end
											if (FlatIdent_6EFC8 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_6EFC8 = 2;
											end
										end
									elseif (Enum == 256) then
										local FlatIdent_6EED2 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_6EED2 == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_6EED2 = 3;
											end
											if (FlatIdent_6EED2 == 0) then
												B = nil;
												A = nil;
												Upvalues[Inst[3]] = Stk[Inst[2]];
												VIP = VIP + 1;
												FlatIdent_6EED2 = 1;
											end
											if (FlatIdent_6EED2 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_6EED2 = 4;
											end
											if (FlatIdent_6EED2 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (1 == FlatIdent_6EED2) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_6EED2 = 2;
											end
										end
									else
										local FlatIdent_40724 = 0;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_40724 == 5) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_2CD81 = 0;
													while true do
														if (0 == FlatIdent_2CD81) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												break;
											end
											if (FlatIdent_40724 == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_40724 = 5;
											end
											if (FlatIdent_40724 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_40724 = 2;
											end
											if (FlatIdent_40724 == 0) then
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_40724 = 1;
											end
											if (FlatIdent_40724 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_40724 = 4;
											end
											if (FlatIdent_40724 == 2) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_40724 = 3;
											end
										end
									end
								elseif (Enum <= 260) then
									if (Enum <= 258) then
										local FlatIdent_A56B = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_A56B == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_A56B = 4;
											end
											if (FlatIdent_A56B == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
												FlatIdent_A56B = 8;
											end
											if (FlatIdent_A56B == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_A56B = 6;
											end
											if (FlatIdent_A56B == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_A56B = 10;
											end
											if (FlatIdent_A56B == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_A56B = 3;
											end
											if (FlatIdent_A56B == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_A56B = 9;
											end
											if (FlatIdent_A56B == 12) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_A56B = 13;
											end
											if (FlatIdent_A56B == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_A56B = 1;
											end
											if (FlatIdent_A56B == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_A56B = 2;
											end
											if (10 == FlatIdent_A56B) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_A56B = 11;
											end
											if (FlatIdent_A56B == 11) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_A56B = 12;
											end
											if (FlatIdent_A56B == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_A56B = 7;
											end
											if (FlatIdent_A56B == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_A56B = 5;
											end
											if (FlatIdent_A56B == 13) then
												Stk[Inst[2]][Stk[Inst[3]]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
										end
									elseif (Enum > 259) then
										local FlatIdent_20B6C = 0;
										local A;
										while true do
											if (FlatIdent_20B6C == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 8;
											end
											if (FlatIdent_20B6C == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 3;
											end
											if (FlatIdent_20B6C == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_20B6C = 5;
											end
											if (FlatIdent_20B6C == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_20B6C = 6;
											end
											if (FlatIdent_20B6C == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 7;
											end
											if (FlatIdent_20B6C == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 2;
											end
											if (FlatIdent_20B6C == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 9;
											end
											if (FlatIdent_20B6C == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_20B6C == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 4;
											end
											if (FlatIdent_20B6C == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_20B6C = 1;
											end
										end
									else
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
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
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
									end
								elseif (Enum <= 261) then
									local A = Inst[2];
									local B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
								elseif (Enum == 262) then
									local FlatIdent_C3E1 = 0;
									while true do
										if (3 == FlatIdent_C3E1) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C3E1 = 4;
										end
										if (FlatIdent_C3E1 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C3E1 = 2;
										end
										if (FlatIdent_C3E1 == 0) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C3E1 = 1;
										end
										if (FlatIdent_C3E1 == 5) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_C3E1 == 4) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C3E1 = 5;
										end
										if (FlatIdent_C3E1 == 2) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_C3E1 = 3;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]];
								end
							elseif (Enum <= 269) then
								if (Enum <= 266) then
									if (Enum <= 264) then
										local FlatIdent_95679 = 0;
										local A;
										while true do
											if (FlatIdent_95679 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												break;
											end
											if (FlatIdent_95679 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_95679 = 2;
											end
											if (FlatIdent_95679 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_95679 = 4;
											end
											if (FlatIdent_95679 == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_95679 = 1;
											end
											if (FlatIdent_95679 == 2) then
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_95679 = 3;
											end
										end
									elseif (Enum > 265) then
										local FlatIdent_50CE = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_50CE == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_50CE = 1;
											end
											if (FlatIdent_50CE == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_50CE = 3;
											end
											if (FlatIdent_50CE == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_50CE = 4;
											end
											if (7 == FlatIdent_50CE) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_50CE = 8;
											end
											if (5 == FlatIdent_50CE) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_50CE = 6;
											end
											if (8 == FlatIdent_50CE) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_50CE == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_50CE = 2;
											end
											if (FlatIdent_50CE == 6) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_351D2 = 0;
													while true do
														if (FlatIdent_351D2 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_50CE = 7;
											end
											if (4 == FlatIdent_50CE) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_50CE = 5;
											end
										end
									else
										local FlatIdent_6D3D2 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_6D3D2 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_6D3D2 = 6;
											end
											if (FlatIdent_6D3D2 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_6D3D2 = 3;
											end
											if (FlatIdent_6D3D2 == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_6D3D2 = 1;
											end
											if (FlatIdent_6D3D2 == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_6D3D2 = 2;
											end
											if (FlatIdent_6D3D2 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_6D3D2 = 5;
											end
											if (FlatIdent_6D3D2 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6D3D2 = 8;
											end
											if (FlatIdent_6D3D2 == 6) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_72798 = 0;
													while true do
														if (FlatIdent_72798 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_6D3D2 = 7;
											end
											if (FlatIdent_6D3D2 == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_6D3D2 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_6D3D2 = 4;
											end
										end
									end
								elseif (Enum <= 267) then
									local FlatIdent_3208B = 0;
									local A;
									while true do
										if (FlatIdent_3208B == 0) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Top));
											break;
										end
									end
								elseif (Enum > 268) then
									Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
								else
									local FlatIdent_3EBA7 = 0;
									while true do
										if (2 == FlatIdent_3EBA7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3EBA7 = 3;
										end
										if (0 == FlatIdent_3EBA7) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_3EBA7 = 1;
										end
										if (FlatIdent_3EBA7 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3EBA7 = 2;
										end
										if (FlatIdent_3EBA7 == 3) then
											if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								end
							elseif (Enum <= 272) then
								if (Enum <= 270) then
									local FlatIdent_4DF7D = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (FlatIdent_4DF7D == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											A = nil;
											FlatIdent_4DF7D = 1;
										end
										if (FlatIdent_4DF7D == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_4DF7D = 3;
										end
										if (FlatIdent_4DF7D == 5) then
											for Idx = A, Top do
												local FlatIdent_EC80 = 0;
												while true do
													if (FlatIdent_EC80 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_4DF7D = 6;
										end
										if (FlatIdent_4DF7D == 4) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_4DF7D = 5;
										end
										if (FlatIdent_4DF7D == 6) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_4DF7D == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4DF7D = 4;
										end
										if (FlatIdent_4DF7D == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_4DF7D = 2;
										end
									end
								elseif (Enum > 271) then
									local FlatIdent_24C04 = 0;
									local A;
									while true do
										if (FlatIdent_24C04 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A]();
											break;
										end
									end
								else
									local T;
									local Edx;
									local Results, Limit;
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
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									for Idx = A + 1, Top do
										Insert(T, Stk[Idx]);
									end
								end
							elseif (Enum <= 273) then
								local FlatIdent_47530 = 0;
								local A;
								while true do
									if (FlatIdent_47530 == 2) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										FlatIdent_47530 = 3;
									end
									if (FlatIdent_47530 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_47530 = 2;
									end
									if (FlatIdent_47530 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_47530 = 1;
									end
									if (4 == FlatIdent_47530) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_47530 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										FlatIdent_47530 = 4;
									end
								end
							elseif (Enum > 274) then
								Stk[Inst[2]] = #Stk[Inst[3]];
							else
								local FlatIdent_81AFC = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_81AFC == 16) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_81AFC = 17;
									end
									if (FlatIdent_81AFC == 13) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_81AFC = 14;
									end
									if (FlatIdent_81AFC == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										FlatIdent_81AFC = 4;
									end
									if (FlatIdent_81AFC == 10) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 11;
									end
									if (FlatIdent_81AFC == 30) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 31;
									end
									if (FlatIdent_81AFC == 19) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 20;
									end
									if (FlatIdent_81AFC == 17) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_81AFC = 18;
									end
									if (FlatIdent_81AFC == 31) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_81AFC = 32;
									end
									if (FlatIdent_81AFC == 9) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_81AFC = 10;
									end
									if (24 == FlatIdent_81AFC) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_81AFC = 25;
									end
									if (2 == FlatIdent_81AFC) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_4D759 = 0;
											while true do
												if (FlatIdent_4D759 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										FlatIdent_81AFC = 3;
									end
									if (FlatIdent_81AFC == 25) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_81AFC = 26;
									end
									if (FlatIdent_81AFC == 33) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_81AFC = 34;
									end
									if (FlatIdent_81AFC == 23) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 24;
									end
									if (FlatIdent_81AFC == 7) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 8;
									end
									if (FlatIdent_81AFC == 8) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_81AFC = 9;
									end
									if (14 == FlatIdent_81AFC) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_81AFC = 15;
									end
									if (FlatIdent_81AFC == 18) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_81AFC = 19;
									end
									if (FlatIdent_81AFC == 26) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_81AFC = 27;
									end
									if (FlatIdent_81AFC == 37) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (29 == FlatIdent_81AFC) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_81AFC = 30;
									end
									if (FlatIdent_81AFC == 22) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_81AFC = 23;
									end
									if (FlatIdent_81AFC == 20) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_81AFC = 21;
									end
									if (FlatIdent_81AFC == 35) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_81AFC = 36;
									end
									if (FlatIdent_81AFC == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 5;
									end
									if (FlatIdent_81AFC == 15) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_81AFC = 16;
									end
									if (FlatIdent_81AFC == 21) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 22;
									end
									if (FlatIdent_81AFC == 5) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_81AFC = 6;
									end
									if (FlatIdent_81AFC == 32) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 33;
									end
									if (28 == FlatIdent_81AFC) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_81AFC = 29;
									end
									if (FlatIdent_81AFC == 36) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_81AFC = 37;
									end
									if (FlatIdent_81AFC == 12) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 13;
									end
									if (FlatIdent_81AFC == 27) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_81AFC = 28;
									end
									if (1 == FlatIdent_81AFC) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 2;
									end
									if (FlatIdent_81AFC == 11) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_81AFC = 12;
									end
									if (FlatIdent_81AFC == 34) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 35;
									end
									if (FlatIdent_81AFC == 6) then
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_81AFC = 7;
									end
									if (FlatIdent_81AFC == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_81AFC = 1;
									end
								end
							end
						elseif (Enum <= 321) then
							if (Enum <= 298) then
								if (Enum <= 286) then
									if (Enum <= 280) then
										if (Enum <= 277) then
											if (Enum == 276) then
												local FlatIdent_80792 = 0;
												local T;
												local Edx;
												local Results;
												local Limit;
												local A;
												while true do
													if (FlatIdent_80792 == 4) then
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														FlatIdent_80792 = 5;
													end
													if (2 == FlatIdent_80792) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_80792 = 3;
													end
													if (FlatIdent_80792 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_80792 = 2;
													end
													if (FlatIdent_80792 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_80792 = 4;
													end
													if (FlatIdent_80792 == 5) then
														for Idx = A, Top do
															local FlatIdent_4B180 = 0;
															while true do
																if (FlatIdent_4B180 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_80792 = 6;
													end
													if (FlatIdent_80792 == 0) then
														T = nil;
														Edx = nil;
														Results, Limit = nil;
														A = nil;
														FlatIdent_80792 = 1;
													end
													if (FlatIdent_80792 == 6) then
														T = Stk[A];
														for Idx = A + 1, Top do
															Insert(T, Stk[Idx]);
														end
														break;
													end
												end
											else
												local A;
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
											end
										elseif (Enum <= 278) then
											local A;
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
										elseif (Enum == 279) then
											local FlatIdent_58975 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_58975 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_58975 = 2;
												end
												if (FlatIdent_58975 == 6) then
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_58975 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_58975 = 4;
												end
												if (FlatIdent_58975 == 2) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_58975 = 3;
												end
												if (FlatIdent_58975 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													FlatIdent_58975 = 1;
												end
												if (FlatIdent_58975 == 5) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_58975 = 6;
												end
												if (FlatIdent_58975 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_58975 = 5;
												end
											end
										else
											local FlatIdent_37AC5 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_37AC5 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_37AC5 = 3;
												end
												if (3 == FlatIdent_37AC5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_37AC5 = 4;
												end
												if (1 == FlatIdent_37AC5) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_37AC5 = 2;
												end
												if (FlatIdent_37AC5 == 5) then
													for Idx = A, Top do
														local FlatIdent_4F1B5 = 0;
														while true do
															if (FlatIdent_4F1B5 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_37AC5 = 6;
												end
												if (FlatIdent_37AC5 == 4) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_37AC5 = 5;
												end
												if (FlatIdent_37AC5 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													A = nil;
													FlatIdent_37AC5 = 1;
												end
												if (FlatIdent_37AC5 == 6) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
											end
										end
									elseif (Enum <= 283) then
										if (Enum <= 281) then
											local FlatIdent_91408 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_91408 == 7) then
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													FlatIdent_91408 = 8;
												end
												if (FlatIdent_91408 == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_91408 = 1;
												end
												if (FlatIdent_91408 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_91408 = 5;
												end
												if (FlatIdent_91408 == 6) then
													for Idx = A, Top do
														local FlatIdent_570DA = 0;
														while true do
															if (FlatIdent_570DA == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_91408 = 7;
												end
												if (FlatIdent_91408 == 8) then
													for Idx = A, Inst[4] do
														local FlatIdent_50079 = 0;
														while true do
															if (FlatIdent_50079 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_91408 = 9;
												end
												if (FlatIdent_91408 == 5) then
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_91408 = 6;
												end
												if (FlatIdent_91408 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_91408 = 3;
												end
												if (FlatIdent_91408 == 9) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_91408 == 1) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_91408 = 2;
												end
												if (FlatIdent_91408 == 3) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_91408 = 4;
												end
											end
										elseif (Enum > 282) then
											local FlatIdent_40F85 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_40F85 == 4) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Stk[Inst[4]]];
													break;
												end
												if (FlatIdent_40F85 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_40F85 = 1;
												end
												if (FlatIdent_40F85 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_40F85 = 3;
												end
												if (FlatIdent_40F85 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_40F85 = 2;
												end
												if (3 == FlatIdent_40F85) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_40F85 = 4;
												end
											end
										else
											local FlatIdent_2E5B5 = 0;
											local A;
											local Cls;
											while true do
												if (FlatIdent_2E5B5 == 1) then
													for Idx = 1, #Lupvals do
														local List = Lupvals[Idx];
														for Idz = 0, #List do
															local FlatIdent_2CB83 = 0;
															local Upv;
															local NStk;
															local DIP;
															while true do
																if (FlatIdent_2CB83 == 0) then
																	Upv = List[Idz];
																	NStk = Upv[1];
																	FlatIdent_2CB83 = 1;
																end
																if (FlatIdent_2CB83 == 1) then
																	DIP = Upv[2];
																	if ((NStk == Stk) and (DIP >= A)) then
																		local FlatIdent_63C9 = 0;
																		while true do
																			if (FlatIdent_63C9 == 0) then
																				Cls[DIP] = NStk[DIP];
																				Upv[1] = Cls;
																				break;
																			end
																		end
																	end
																	break;
																end
															end
														end
													end
													break;
												end
												if (FlatIdent_2E5B5 == 0) then
													A = Inst[2];
													Cls = {};
													FlatIdent_2E5B5 = 1;
												end
											end
										end
									elseif (Enum <= 284) then
										local FlatIdent_226A8 = 0;
										while true do
											if (FlatIdent_226A8 == 3) then
												if (Stk[Inst[2]] < Inst[4]) then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_226A8 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_226A8 = 3;
											end
											if (FlatIdent_226A8 == 0) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_226A8 = 1;
											end
											if (FlatIdent_226A8 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_226A8 = 2;
											end
										end
									elseif (Enum == 285) then
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
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_4F93 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_4F93 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_4F93 = 4;
											end
											if (FlatIdent_4F93 == 8) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4F93 = 9;
											end
											if (FlatIdent_4F93 == 9) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_4F93 = 10;
											end
											if (FlatIdent_4F93 == 10) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_4F93 = 11;
											end
											if (5 == FlatIdent_4F93) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_4F93 = 6;
											end
											if (FlatIdent_4F93 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_4F93 = 3;
											end
											if (1 == FlatIdent_4F93) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_4F93 = 2;
											end
											if (FlatIdent_4F93 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4F93 = 8;
											end
											if (FlatIdent_4F93 == 12) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4F93 = 13;
											end
											if (FlatIdent_4F93 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_4F93 = 5;
											end
											if (FlatIdent_4F93 == 14) then
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_4F93 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
												FlatIdent_4F93 = 1;
											end
											if (FlatIdent_4F93 == 13) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_4F93 = 14;
											end
											if (FlatIdent_4F93 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												FlatIdent_4F93 = 7;
											end
											if (FlatIdent_4F93 == 11) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												FlatIdent_4F93 = 12;
											end
										end
									end
								elseif (Enum <= 292) then
									if (Enum <= 289) then
										if (Enum <= 287) then
											local FlatIdent_2A0D7 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (FlatIdent_2A0D7 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_2A0D7 = 1;
												end
												if (5 == FlatIdent_2A0D7) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_2A0D7 = 6;
												end
												if (FlatIdent_2A0D7 == 8) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_2A0D7 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2A0D7 = 5;
												end
												if (FlatIdent_2A0D7 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_2A0D7 = 8;
												end
												if (FlatIdent_2A0D7 == 1) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_2A0D7 = 2;
												end
												if (FlatIdent_2A0D7 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2A0D7 = 4;
												end
												if (2 == FlatIdent_2A0D7) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2A0D7 = 3;
												end
												if (FlatIdent_2A0D7 == 6) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_209D4 = 0;
														while true do
															if (FlatIdent_209D4 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													FlatIdent_2A0D7 = 7;
												end
											end
										elseif (Enum == 288) then
											local FlatIdent_85A9A = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_85A9A == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_85A9A = 5;
												end
												if (FlatIdent_85A9A == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_85A9A = 4;
												end
												if (0 == FlatIdent_85A9A) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_85A9A = 1;
												end
												if (FlatIdent_85A9A == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_85A9A = 2;
												end
												if (FlatIdent_85A9A == 5) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_85A9A = 6;
												end
												if (FlatIdent_85A9A == 6) then
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_85A9A == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_85A9A = 3;
												end
											end
										else
											local FlatIdent_47EBC = 0;
											local A;
											while true do
												if (FlatIdent_47EBC == 0) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													break;
												end
											end
										end
									elseif (Enum <= 290) then
										local FlatIdent_81CAE = 0;
										local A;
										while true do
											if (FlatIdent_81CAE == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81CAE = 1;
											end
											if (FlatIdent_81CAE == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_81CAE = 3;
											end
											if (5 == FlatIdent_81CAE) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_81CAE == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_81CAE = 5;
											end
											if (FlatIdent_81CAE == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_81CAE = 4;
											end
											if (FlatIdent_81CAE == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_81CAE = 2;
											end
										end
									elseif (Enum == 291) then
										local FlatIdent_15AD6 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_15AD6 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15AD6 = 6;
											end
											if (FlatIdent_15AD6 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_15AD6 = 1;
											end
											if (FlatIdent_15AD6 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_15AD6 = 2;
											end
											if (FlatIdent_15AD6 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_15AD6 = 3;
											end
											if (FlatIdent_15AD6 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_15AD6 = 5;
											end
											if (FlatIdent_15AD6 == 3) then
												Stk[A] = B[Stk[Inst[4]]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_15AD6 = 4;
											end
											if (FlatIdent_15AD6 == 6) then
												Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
										end
									else
										Stk[Inst[2]]();
									end
								elseif (Enum <= 295) then
									if (Enum <= 293) then
										local FlatIdent_2D044 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_2D044 == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_2D044 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_2D044 = 8;
											end
											if (6 == FlatIdent_2D044) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_52A00 = 0;
													while true do
														if (0 == FlatIdent_52A00) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_2D044 = 7;
											end
											if (FlatIdent_2D044 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2D044 = 5;
											end
											if (FlatIdent_2D044 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2D044 = 4;
											end
											if (5 == FlatIdent_2D044) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_2D044 = 6;
											end
											if (FlatIdent_2D044 == 1) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_2D044 = 2;
											end
											if (0 == FlatIdent_2D044) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_2D044 = 1;
											end
											if (FlatIdent_2D044 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2D044 = 3;
											end
										end
									elseif (Enum == 294) then
										local FlatIdent_46148 = 0;
										local A;
										while true do
											if (FlatIdent_46148 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 1;
											end
											if (FlatIdent_46148 == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 9;
											end
											if (FlatIdent_46148 == 7) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 8;
											end
											if (FlatIdent_46148 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_46148 = 5;
											end
											if (FlatIdent_46148 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 4;
											end
											if (FlatIdent_46148 == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_46148 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_46148 = 6;
											end
											if (FlatIdent_46148 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 3;
											end
											if (1 == FlatIdent_46148) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 2;
											end
											if (FlatIdent_46148 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_46148 = 7;
											end
										end
									else
										local FlatIdent_2776F = 0;
										local A;
										while true do
											if (FlatIdent_2776F == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_2776F = 9;
											end
											if (FlatIdent_2776F == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2776F = 6;
											end
											if (FlatIdent_2776F == 6) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_2776F = 7;
											end
											if (FlatIdent_2776F == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2776F = 4;
											end
											if (FlatIdent_2776F == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_2776F = 2;
											end
											if (4 == FlatIdent_2776F) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2776F = 5;
											end
											if (7 == FlatIdent_2776F) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_2776F = 8;
											end
											if (FlatIdent_2776F == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_2776F == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_2776F = 1;
											end
											if (2 == FlatIdent_2776F) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_2776F = 3;
											end
										end
									end
								elseif (Enum <= 296) then
									local FlatIdent_7557A = 0;
									local A;
									while true do
										if (FlatIdent_7557A == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 8;
										end
										if (FlatIdent_7557A == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 1;
										end
										if (FlatIdent_7557A == 9) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (5 == FlatIdent_7557A) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_7557A = 6;
										end
										if (FlatIdent_7557A == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_7557A = 5;
										end
										if (FlatIdent_7557A == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 3;
										end
										if (FlatIdent_7557A == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 4;
										end
										if (FlatIdent_7557A == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 7;
										end
										if (FlatIdent_7557A == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 9;
										end
										if (FlatIdent_7557A == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7557A = 2;
										end
									end
								elseif (Enum > 297) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_7F9BE = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (5 == FlatIdent_7F9BE) then
											for Idx = A, Top do
												local FlatIdent_16CE2 = 0;
												while true do
													if (FlatIdent_16CE2 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_7F9BE = 6;
										end
										if (FlatIdent_7F9BE == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											A = nil;
											FlatIdent_7F9BE = 1;
										end
										if (FlatIdent_7F9BE == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7F9BE = 4;
										end
										if (2 == FlatIdent_7F9BE) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_7F9BE = 3;
										end
										if (FlatIdent_7F9BE == 6) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_7F9BE == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7F9BE = 2;
										end
										if (FlatIdent_7F9BE == 4) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_7F9BE = 5;
										end
									end
								end
							elseif (Enum <= 309) then
								if (Enum <= 303) then
									if (Enum <= 300) then
										if (Enum == 299) then
											local FlatIdent_57294 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_57294 == 3) then
													Stk[A] = Stk[A]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_57294 = 4;
												end
												if (FlatIdent_57294 == 5) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_57294 = 6;
												end
												if (FlatIdent_57294 == 6) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													FlatIdent_57294 = 7;
												end
												if (FlatIdent_57294 == 4) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_57294 = 5;
												end
												if (FlatIdent_57294 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_57294 = 3;
												end
												if (FlatIdent_57294 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_57294 = 2;
												end
												if (8 == FlatIdent_57294) then
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_555F7 = 0;
														while true do
															if (FlatIdent_555F7 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (0 == FlatIdent_57294) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													A = nil;
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_57294 = 1;
												end
												if (7 == FlatIdent_57294) then
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													FlatIdent_57294 = 8;
												end
											end
										else
											local FlatIdent_84103 = 0;
											local T;
											local Edx;
											local Results;
											local Limit;
											local A;
											while true do
												if (7 == FlatIdent_84103) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_84103 = 8;
												end
												if (FlatIdent_84103 == 0) then
													T = nil;
													Edx = nil;
													Results, Limit = nil;
													FlatIdent_84103 = 1;
												end
												if (FlatIdent_84103 == 6) then
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														local FlatIdent_82F73 = 0;
														while true do
															if (FlatIdent_82F73 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													FlatIdent_84103 = 7;
												end
												if (FlatIdent_84103 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_84103 = 5;
												end
												if (FlatIdent_84103 == 1) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_84103 = 2;
												end
												if (FlatIdent_84103 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_84103 = 6;
												end
												if (FlatIdent_84103 == 8) then
													T = Stk[A];
													for Idx = A + 1, Top do
														Insert(T, Stk[Idx]);
													end
													break;
												end
												if (FlatIdent_84103 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_84103 = 3;
												end
												if (FlatIdent_84103 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_84103 = 4;
												end
											end
										end
									elseif (Enum <= 301) then
										local FlatIdent_6D77C = 0;
										while true do
											if (FlatIdent_6D77C == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6D77C = 3;
											end
											if (FlatIdent_6D77C == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_6D77C == 0) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												FlatIdent_6D77C = 1;
											end
											if (FlatIdent_6D77C == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_6D77C = 2;
											end
										end
									elseif (Enum > 302) then
										local FlatIdent_5F9F3 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5F9F3 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5F9F3 = 1;
											end
											if (FlatIdent_5F9F3 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5F9F3 = 6;
											end
											if (FlatIdent_5F9F3 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5F9F3 = 3;
											end
											if (7 == FlatIdent_5F9F3) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_5F9F3 == 6) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5F9F3 = 7;
											end
											if (FlatIdent_5F9F3 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5F9F3 = 5;
											end
											if (FlatIdent_5F9F3 == 3) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_5F9F3 = 4;
											end
											if (1 == FlatIdent_5F9F3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5F9F3 = 2;
											end
										end
									else
										local FlatIdent_9273 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_9273 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_9273 = 1;
											end
											if (FlatIdent_9273 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_9273 = 2;
											end
											if (FlatIdent_9273 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_9273 = 3;
											end
											if (FlatIdent_9273 == 3) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_9273 = 4;
											end
											if (FlatIdent_9273 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_9273 = 5;
											end
											if (FlatIdent_9273 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									end
								elseif (Enum <= 306) then
									if (Enum <= 304) then
										local A;
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
									elseif (Enum > 305) then
										local FlatIdent_19D3F = 0;
										local A;
										while true do
											if (FlatIdent_19D3F == 2) then
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_19D3F = 3;
											end
											if (FlatIdent_19D3F == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												break;
											end
											if (FlatIdent_19D3F == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_19D3F = 2;
											end
											if (FlatIdent_19D3F == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_19D3F = 1;
											end
										end
									else
										local A;
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
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
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
									end
								elseif (Enum <= 307) then
									if (Inst[2] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 308) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								else
									local Results;
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3] ~= 0;
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
										local FlatIdent_93951 = 0;
										while true do
											if (FlatIdent_93951 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
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
								end
							elseif (Enum <= 315) then
								if (Enum <= 312) then
									if (Enum <= 310) then
										local FlatIdent_764D8 = 0;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_764D8 == 3) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_764D8 = 4;
											end
											if (FlatIdent_764D8 == 6) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_1B293 = 0;
													while true do
														if (FlatIdent_1B293 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												break;
											end
											if (FlatIdent_764D8 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_764D8 = 5;
											end
											if (FlatIdent_764D8 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_764D8 = 2;
											end
											if (2 == FlatIdent_764D8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_764D8 = 3;
											end
											if (FlatIdent_764D8 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_764D8 = 6;
											end
											if (FlatIdent_764D8 == 0) then
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_764D8 = 1;
											end
										end
									elseif (Enum > 311) then
										local FlatIdent_532E3 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_532E3 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (3 == FlatIdent_532E3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												do
													return Stk[A](Unpack(Stk, A + 1, Inst[3]));
												end
												FlatIdent_532E3 = 4;
											end
											if (FlatIdent_532E3 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_532E3 = 1;
											end
											if (FlatIdent_532E3 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												do
													return Unpack(Stk, A, Top);
												end
												FlatIdent_532E3 = 5;
											end
											if (FlatIdent_532E3 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_532E3 = 2;
											end
											if (FlatIdent_532E3 == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_532E3 = 3;
											end
										end
									else
										local FlatIdent_82175 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_82175 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_82175 = 3;
											end
											if (FlatIdent_82175 == 6) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_82175 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_82175 = 4;
											end
											if (FlatIdent_82175 == 5) then
												for Idx = A, Top do
													local FlatIdent_83DE9 = 0;
													while true do
														if (FlatIdent_83DE9 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_82175 = 6;
											end
											if (FlatIdent_82175 == 4) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_82175 = 5;
											end
											if (FlatIdent_82175 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_82175 = 2;
											end
											if (0 == FlatIdent_82175) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_82175 = 1;
											end
										end
									end
								elseif (Enum <= 313) then
									Stk[Inst[2]] = Inst[3] ~= 0;
								elseif (Enum > 314) then
									Stk[Inst[2]] = Env[Inst[3]];
								else
									local FlatIdent_90753 = 0;
									local A;
									while true do
										if (FlatIdent_90753 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 9;
										end
										if (FlatIdent_90753 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_90753 = 5;
										end
										if (FlatIdent_90753 == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 1;
										end
										if (FlatIdent_90753 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 2;
										end
										if (FlatIdent_90753 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 8;
										end
										if (FlatIdent_90753 == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_90753 = 6;
										end
										if (FlatIdent_90753 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 7;
										end
										if (FlatIdent_90753 == 9) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_90753 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 4;
										end
										if (2 == FlatIdent_90753) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_90753 = 3;
										end
									end
								end
							elseif (Enum <= 318) then
								if (Enum <= 316) then
									local FlatIdent_78E3C = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_78E3C == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											break;
										end
										if (FlatIdent_78E3C == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											FlatIdent_78E3C = 5;
										end
										if (FlatIdent_78E3C == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_78E3C = 1;
										end
										if (FlatIdent_78E3C == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_78E3C = 3;
										end
										if (FlatIdent_78E3C == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_78E3C = 2;
										end
										if (FlatIdent_78E3C == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_78E3C = 4;
										end
										if (FlatIdent_78E3C == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_78E3C = 6;
										end
									end
								elseif (Enum > 317) then
									local FlatIdent_322B = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_322B == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_322B = 2;
										end
										if (FlatIdent_322B == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_322B = 3;
										end
										if (FlatIdent_322B == 3) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Stk[Inst[4]]];
											VIP = VIP + 1;
											FlatIdent_322B = 4;
										end
										if (FlatIdent_322B == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_322B = 1;
										end
										if (FlatIdent_322B == 6) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											FlatIdent_322B = 7;
										end
										if (FlatIdent_322B == 5) then
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_322B = 6;
										end
										if (FlatIdent_322B == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_322B = 5;
										end
										if (FlatIdent_322B == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								else
									local FlatIdent_258D9 = 0;
									local B;
									while true do
										if (FlatIdent_258D9 == 0) then
											B = Stk[Inst[4]];
											if B then
												VIP = VIP + 1;
											else
												local FlatIdent_62804 = 0;
												while true do
													if (FlatIdent_62804 == 0) then
														Stk[Inst[2]] = B;
														VIP = Inst[3];
														break;
													end
												end
											end
											break;
										end
									end
								end
							elseif (Enum <= 319) then
								local FlatIdent_9959D = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_9959D == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_9959D == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_9959D = 1;
									end
									if (4 == FlatIdent_9959D) then
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_9959D = 5;
									end
									if (FlatIdent_9959D == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_9959D = 3;
									end
									if (FlatIdent_9959D == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_9959D = 4;
									end
									if (FlatIdent_9959D == 6) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_9959D = 7;
									end
									if (5 == FlatIdent_9959D) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_9959D = 6;
									end
									if (FlatIdent_9959D == 1) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_9959D = 2;
									end
								end
							elseif (Enum == 320) then
								local FlatIdent_572E4 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_572E4 == 4) then
										Inst = Instr[VIP];
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_572E4 = 5;
									end
									if (FlatIdent_572E4 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (3 == FlatIdent_572E4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_572E4 = 4;
									end
									if (FlatIdent_572E4 == 1) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_572E4 = 2;
									end
									if (FlatIdent_572E4 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_572E4 = 1;
									end
									if (FlatIdent_572E4 == 2) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_572E4 = 3;
									end
								end
							else
								local FlatIdent_230E1 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_230E1 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_230E1 = 2;
									end
									if (FlatIdent_230E1 == 5) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_230E1 = 6;
									end
									if (FlatIdent_230E1 == 6) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_230E1 = 7;
									end
									if (FlatIdent_230E1 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Inst[3];
										FlatIdent_230E1 = 1;
									end
									if (FlatIdent_230E1 == 7) then
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_230E1 == 3) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_230E1 = 4;
									end
									if (FlatIdent_230E1 == 4) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_230E1 = 5;
									end
									if (FlatIdent_230E1 == 2) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_230E1 = 3;
									end
								end
							end
						elseif (Enum <= 344) then
							if (Enum <= 332) then
								if (Enum <= 326) then
									if (Enum <= 323) then
										if (Enum > 322) then
											local FlatIdent_519B2 = 0;
											local A;
											while true do
												if (FlatIdent_519B2 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_519B2 = 6;
												end
												if (FlatIdent_519B2 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_519B2 = 7;
												end
												if (FlatIdent_519B2 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_519B2 = 3;
												end
												if (FlatIdent_519B2 == 7) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
												if (FlatIdent_519B2 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_519B2 = 4;
												end
												if (FlatIdent_519B2 == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_519B2 = 1;
												end
												if (4 == FlatIdent_519B2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_519B2 = 5;
												end
												if (1 == FlatIdent_519B2) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_519B2 = 2;
												end
											end
										else
											local FlatIdent_4C037 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_4C037 == 4) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4C037 = 5;
												end
												if (FlatIdent_4C037 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_4C037 = 3;
												end
												if (3 == FlatIdent_4C037) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4C037 = 4;
												end
												if (FlatIdent_4C037 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_4C037 = 2;
												end
												if (FlatIdent_4C037 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_4C037 = 1;
												end
												if (FlatIdent_4C037 == 5) then
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
											end
										end
									elseif (Enum <= 324) then
										local FlatIdent_1C6E6 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_1C6E6 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_1C6E6 = 1;
											end
											if (FlatIdent_1C6E6 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1C6E6 = 2;
											end
											if (FlatIdent_1C6E6 == 8) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_1C6E6 = 9;
											end
											if (FlatIdent_1C6E6 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1C6E6 = 6;
											end
											if (FlatIdent_1C6E6 == 4) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_1C6E6 = 5;
											end
											if (FlatIdent_1C6E6 == 9) then
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_1C6E6 == 3) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_1C6E6 = 4;
											end
											if (FlatIdent_1C6E6 == 2) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1C6E6 = 3;
											end
											if (FlatIdent_1C6E6 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_1C6E6 = 8;
											end
											if (FlatIdent_1C6E6 == 6) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_1C6E6 = 7;
											end
										end
									elseif (Enum == 325) then
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_7409 = 0;
										local A;
										while true do
											if (FlatIdent_7409 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7409 = 6;
											end
											if (FlatIdent_7409 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7409 = 1;
											end
											if (FlatIdent_7409 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_7409 = 3;
											end
											if (3 == FlatIdent_7409) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7409 = 4;
											end
											if (FlatIdent_7409 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_7409 = 2;
											end
											if (FlatIdent_7409 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_7409 = 7;
											end
											if (7 == FlatIdent_7409) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_7409 == 4) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_7409 = 5;
											end
										end
									end
								elseif (Enum <= 329) then
									if (Enum <= 327) then
										local FlatIdent_68906 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_68906 == 1) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_68906 = 2;
											end
											if (FlatIdent_68906 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												FlatIdent_68906 = 3;
											end
											if (FlatIdent_68906 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_68906 = 4;
											end
											if (4 == FlatIdent_68906) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_68906 = 5;
											end
											if (FlatIdent_68906 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_68906 = 7;
											end
											if (FlatIdent_68906 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												FlatIdent_68906 = 1;
											end
											if (FlatIdent_68906 == 7) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_68906 = 8;
											end
											if (FlatIdent_68906 == 8) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_68906 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_68906 = 6;
											end
										end
									elseif (Enum == 328) then
										local FlatIdent_3A183 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_3A183 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_3A183 = 4;
											end
											if (FlatIdent_3A183 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_3A183 = 3;
											end
											if (FlatIdent_3A183 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_3A183 = 2;
											end
											if (FlatIdent_3A183 == 5) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3A183 = 6;
											end
											if (FlatIdent_3A183 == 0) then
												B = nil;
												A = nil;
												Upvalues[Inst[3]] = Stk[Inst[2]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_3A183 = 1;
											end
											if (FlatIdent_3A183 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3A183 = 5;
											end
											if (FlatIdent_3A183 == 6) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									else
										local FlatIdent_269B = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_269B == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_269B = 1;
											end
											if (7 == FlatIdent_269B) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_269B = 8;
											end
											if (FlatIdent_269B == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_269B = 5;
											end
											if (FlatIdent_269B == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_269B = 4;
											end
											if (1 == FlatIdent_269B) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_269B = 2;
											end
											if (FlatIdent_269B == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												FlatIdent_269B = 6;
											end
											if (FlatIdent_269B == 8) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_269B == 6) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_31375 = 0;
													while true do
														if (FlatIdent_31375 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_269B = 7;
											end
											if (FlatIdent_269B == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_269B = 3;
											end
										end
									end
								elseif (Enum <= 330) then
									local A = Inst[2];
									local Step = Stk[A + 2];
									local Index = Stk[A] + Step;
									Stk[A] = Index;
									if (Step > 0) then
										if (Index <= Stk[A + 1]) then
											local FlatIdent_1953 = 0;
											while true do
												if (FlatIdent_1953 == 0) then
													VIP = Inst[3];
													Stk[A + 3] = Index;
													break;
												end
											end
										end
									elseif (Index >= Stk[A + 1]) then
										local FlatIdent_1E5D6 = 0;
										while true do
											if (0 == FlatIdent_1E5D6) then
												VIP = Inst[3];
												Stk[A + 3] = Index;
												break;
											end
										end
									end
								elseif (Enum == 331) then
									local FlatIdent_35204 = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (FlatIdent_35204 == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_1AD3 = 0;
												while true do
													if (FlatIdent_1AD3 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_35204 = 7;
										end
										if (FlatIdent_35204 == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_35204 = 1;
										end
										if (FlatIdent_35204 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_35204 = 3;
										end
										if (FlatIdent_35204 == 1) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_35204 = 2;
										end
										if (FlatIdent_35204 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_35204 = 5;
										end
										if (FlatIdent_35204 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_35204 = 6;
										end
										if (8 == FlatIdent_35204) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_35204 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_35204 = 8;
										end
										if (FlatIdent_35204 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_35204 = 4;
										end
									end
								else
									local FlatIdent_8F8DE = 0;
									local B;
									local A;
									while true do
										if (5 == FlatIdent_8F8DE) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8F8DE = 6;
										end
										if (FlatIdent_8F8DE == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8F8DE = 2;
										end
										if (FlatIdent_8F8DE == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_8F8DE = 1;
										end
										if (6 == FlatIdent_8F8DE) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_8F8DE == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8F8DE = 4;
										end
										if (FlatIdent_8F8DE == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8F8DE = 5;
										end
										if (FlatIdent_8F8DE == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_8F8DE = 3;
										end
									end
								end
							elseif (Enum <= 338) then
								if (Enum <= 335) then
									if (Enum <= 333) then
										Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									elseif (Enum > 334) then
										local B;
										local A;
										Upvalues[Inst[3]] = Stk[Inst[2]];
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
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local B;
										local A;
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Stk[Inst[4]]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 336) then
									local FlatIdent_A6E4 = 0;
									local A;
									while true do
										if (FlatIdent_A6E4 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											FlatIdent_A6E4 = 2;
										end
										if (0 == FlatIdent_A6E4) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_A6E4 = 1;
										end
										if (FlatIdent_A6E4 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_A6E4 = 3;
										end
										if (FlatIdent_A6E4 == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											do
												return Stk[A], Stk[A + 1];
											end
											break;
										end
									end
								elseif (Enum == 337) then
									local FlatIdent_21A16 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_21A16 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_21A16 = 1;
										end
										if (FlatIdent_21A16 == 8) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_21A16 == 7) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_21A16 = 8;
										end
										if (FlatIdent_21A16 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_21A16 = 4;
										end
										if (FlatIdent_21A16 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_21A16 = 2;
										end
										if (FlatIdent_21A16 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_21A16 = 7;
										end
										if (FlatIdent_21A16 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_21A16 = 3;
										end
										if (FlatIdent_21A16 == 4) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_21A16 = 5;
										end
										if (FlatIdent_21A16 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_21A16 = 6;
										end
									end
								else
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum <= 341) then
								if (Enum <= 339) then
									local B;
									local A;
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
								elseif (Enum > 340) then
									local FlatIdent_88620 = 0;
									local T;
									local Edx;
									local Results;
									local Limit;
									local A;
									while true do
										if (7 == FlatIdent_88620) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_88620 = 8;
										end
										if (FlatIdent_88620 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_88620 = 6;
										end
										if (FlatIdent_88620 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_88620 = 4;
										end
										if (FlatIdent_88620 == 8) then
											T = Stk[A];
											for Idx = A + 1, Top do
												Insert(T, Stk[Idx]);
											end
											break;
										end
										if (FlatIdent_88620 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_88620 = 5;
										end
										if (FlatIdent_88620 == 0) then
											T = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_88620 = 1;
										end
										if (FlatIdent_88620 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_88620 = 3;
										end
										if (FlatIdent_88620 == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_1108D = 0;
												while true do
													if (FlatIdent_1108D == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_88620 = 7;
										end
										if (FlatIdent_88620 == 1) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_88620 = 2;
										end
									end
								else
									local FlatIdent_7ED1E = 0;
									local B;
									local A;
									while true do
										if (2 == FlatIdent_7ED1E) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7ED1E = 3;
										end
										if (FlatIdent_7ED1E == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_7ED1E = 2;
										end
										if (FlatIdent_7ED1E == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_7ED1E == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_7ED1E = 1;
										end
										if (FlatIdent_7ED1E == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_7ED1E = 4;
										end
									end
								end
							elseif (Enum <= 342) then
								local FlatIdent_45A9E = 0;
								local A;
								while true do
									if (FlatIdent_45A9E == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 1;
									end
									if (FlatIdent_45A9E == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 4;
									end
									if (FlatIdent_45A9E == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_45A9E = 6;
									end
									if (FlatIdent_45A9E == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_45A9E = 5;
									end
									if (FlatIdent_45A9E == 8) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 9;
									end
									if (FlatIdent_45A9E == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 7;
									end
									if (1 == FlatIdent_45A9E) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 2;
									end
									if (FlatIdent_45A9E == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 8;
									end
									if (FlatIdent_45A9E == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_45A9E = 3;
									end
									if (FlatIdent_45A9E == 9) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							elseif (Enum > 343) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_2BEDF = 0;
								local A;
								while true do
									if (FlatIdent_2BEDF == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 7;
									end
									if (FlatIdent_2BEDF == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 4;
									end
									if (FlatIdent_2BEDF == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 1;
									end
									if (FlatIdent_2BEDF == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 8;
									end
									if (FlatIdent_2BEDF == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 6;
									end
									if (FlatIdent_2BEDF == 8) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 9;
									end
									if (FlatIdent_2BEDF == 9) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (2 == FlatIdent_2BEDF) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 3;
									end
									if (FlatIdent_2BEDF == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 2;
									end
									if (FlatIdent_2BEDF == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_2BEDF = 5;
									end
								end
							end
						elseif (Enum <= 356) then
							if (Enum <= 350) then
								if (Enum <= 347) then
									if (Enum <= 345) then
										local FlatIdent_58B34 = 0;
										local T;
										local Edx;
										local Results;
										local Limit;
										local A;
										while true do
											if (FlatIdent_58B34 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_58B34 = 3;
											end
											if (FlatIdent_58B34 == 6) then
												T = Stk[A];
												for Idx = A + 1, Top do
													Insert(T, Stk[Idx]);
												end
												break;
											end
											if (FlatIdent_58B34 == 5) then
												for Idx = A, Top do
													local FlatIdent_75B0 = 0;
													while true do
														if (0 == FlatIdent_75B0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_58B34 = 6;
											end
											if (FlatIdent_58B34 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_58B34 = 2;
											end
											if (FlatIdent_58B34 == 0) then
												T = nil;
												Edx = nil;
												Results, Limit = nil;
												A = nil;
												FlatIdent_58B34 = 1;
											end
											if (FlatIdent_58B34 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_58B34 = 4;
											end
											if (FlatIdent_58B34 == 4) then
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_58B34 = 5;
											end
										end
									elseif (Enum == 346) then
										local B;
										local A;
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
									else
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									end
								elseif (Enum <= 348) then
									local FlatIdent_5210D = 0;
									local A;
									while true do
										if (FlatIdent_5210D == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5210D = 5;
										end
										if (FlatIdent_5210D == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5210D = 7;
										end
										if (FlatIdent_5210D == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5210D = 3;
										end
										if (FlatIdent_5210D == 7) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_5210D == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5210D = 1;
										end
										if (FlatIdent_5210D == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5210D = 4;
										end
										if (5 == FlatIdent_5210D) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5210D = 6;
										end
										if (FlatIdent_5210D == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_5210D = 2;
										end
									end
								elseif (Enum > 349) then
									local FlatIdent_345BF = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_345BF == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_345BF = 3;
										end
										if (FlatIdent_345BF == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_345BF = 6;
										end
										if (FlatIdent_345BF == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_345BF = 1;
										end
										if (FlatIdent_345BF == 6) then
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_345BF == 4) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_345BF = 5;
										end
										if (FlatIdent_345BF == 1) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_345BF = 2;
										end
										if (FlatIdent_345BF == 3) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_345BF = 4;
										end
									end
								else
									local FlatIdent_3D3CB = 0;
									local A;
									while true do
										if (2 == FlatIdent_3D3CB) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_3D3CB = 3;
										end
										if (FlatIdent_3D3CB == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_3D3CB = 1;
										end
										if (1 == FlatIdent_3D3CB) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_3D3CB = 2;
										end
										if (FlatIdent_3D3CB == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								end
							elseif (Enum <= 353) then
								if (Enum <= 351) then
									local FlatIdent_2CB75 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_2CB75 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2CB75 = 2;
										end
										if (9 == FlatIdent_2CB75) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_2CB75 = 10;
										end
										if (FlatIdent_2CB75 == 8) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_2CB75 = 9;
										end
										if (FlatIdent_2CB75 == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2CB75 = 11;
										end
										if (FlatIdent_2CB75 == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											break;
										end
										if (FlatIdent_2CB75 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2CB75 = 1;
										end
										if (FlatIdent_2CB75 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_2CB75 = 6;
										end
										if (FlatIdent_2CB75 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2CB75 = 3;
										end
										if (FlatIdent_2CB75 == 7) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_2CB75 = 8;
										end
										if (FlatIdent_2CB75 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2CB75 = 4;
										end
										if (FlatIdent_2CB75 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_2CB75 = 7;
										end
										if (FlatIdent_2CB75 == 4) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2CB75 = 5;
										end
									end
								elseif (Enum == 352) then
									if (Inst[2] <= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								end
							elseif (Enum <= 354) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 355) then
								local B;
								local A;
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
								Stk[Inst[2]] = Inst[3];
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
							else
								local K;
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
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
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
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
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Upvalues[Inst[3]] = Stk[Inst[2]];
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
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							end
						elseif (Enum <= 362) then
							if (Enum <= 359) then
								if (Enum <= 357) then
									local FlatIdent_8C894 = 0;
									local A;
									while true do
										if (FlatIdent_8C894 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8C894 = 6;
										end
										if (FlatIdent_8C894 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8C894 = 2;
										end
										if (FlatIdent_8C894 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C894 = 7;
										end
										if (FlatIdent_8C894 == 7) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_8C894 == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_8C894 = 5;
										end
										if (FlatIdent_8C894 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C894 = 4;
										end
										if (FlatIdent_8C894 == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8C894 = 1;
										end
										if (FlatIdent_8C894 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_8C894 = 3;
										end
									end
								elseif (Enum > 358) then
									local FlatIdent_2FBD1 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_2FBD1 == 3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2FBD1 = 4;
										end
										if (FlatIdent_2FBD1 == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_2FBD1 = 6;
										end
										if (FlatIdent_2FBD1 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2FBD1 = 2;
										end
										if (FlatIdent_2FBD1 == 4) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2FBD1 = 5;
										end
										if (FlatIdent_2FBD1 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_2FBD1 = 1;
										end
										if (FlatIdent_2FBD1 == 2) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2FBD1 = 3;
										end
										if (FlatIdent_2FBD1 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											break;
										end
									end
								else
									local B;
									local A;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum <= 360) then
								local FlatIdent_7CB99 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_7CB99 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_7CB99 = 6;
									end
									if (FlatIdent_7CB99 == 1) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_7CB99 = 2;
									end
									if (FlatIdent_7CB99 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										FlatIdent_7CB99 = 1;
									end
									if (FlatIdent_7CB99 == 7) then
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (FlatIdent_7CB99 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_7CB99 = 5;
									end
									if (6 == FlatIdent_7CB99) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_7CB99 = 7;
									end
									if (FlatIdent_7CB99 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										FlatIdent_7CB99 = 3;
									end
									if (FlatIdent_7CB99 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_7CB99 = 4;
									end
								end
							elseif (Enum > 361) then
								local FlatIdent_85E0E = 0;
								local A;
								while true do
									if (FlatIdent_85E0E == 0) then
										A = Inst[2];
										do
											return Stk[A], Stk[A + 1];
										end
										break;
									end
								end
							else
								local A;
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
							end
						elseif (Enum <= 365) then
							if (Enum <= 363) then
								local FlatIdent_737E6 = 0;
								local T;
								local Edx;
								local Results;
								local Limit;
								local A;
								while true do
									if (FlatIdent_737E6 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_737E6 = 4;
									end
									if (FlatIdent_737E6 == 0) then
										T = nil;
										Edx = nil;
										Results, Limit = nil;
										A = nil;
										FlatIdent_737E6 = 1;
									end
									if (FlatIdent_737E6 == 4) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_737E6 = 5;
									end
									if (FlatIdent_737E6 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_737E6 = 2;
									end
									if (FlatIdent_737E6 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_737E6 = 3;
									end
									if (6 == FlatIdent_737E6) then
										T = Stk[A];
										for Idx = A + 1, Top do
											Insert(T, Stk[Idx]);
										end
										break;
									end
									if (FlatIdent_737E6 == 5) then
										for Idx = A, Top do
											local FlatIdent_3DE3D = 0;
											while true do
												if (FlatIdent_3DE3D == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_737E6 = 6;
									end
								end
							elseif (Enum > 364) then
								local FlatIdent_7618 = 0;
								while true do
									if (1 == FlatIdent_7618) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_7618 = 2;
									end
									if (FlatIdent_7618 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_7618 = 3;
									end
									if (FlatIdent_7618 == 3) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_7618 = 4;
									end
									if (4 == FlatIdent_7618) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_7618 == 0) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										FlatIdent_7618 = 1;
									end
								end
							else
								local FlatIdent_17A38 = 0;
								local A;
								while true do
									if (FlatIdent_17A38 == 0) then
										A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
										break;
									end
								end
							end
						elseif (Enum <= 366) then
							local FlatIdent_92FAC = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_92FAC == 2) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_92FAC = 3;
								end
								if (FlatIdent_92FAC == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_92FAC = 2;
								end
								if (FlatIdent_92FAC == 6) then
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_92FAC == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_92FAC = 4;
								end
								if (FlatIdent_92FAC == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									FlatIdent_92FAC = 1;
								end
								if (FlatIdent_92FAC == 5) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_92FAC = 6;
								end
								if (FlatIdent_92FAC == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_92FAC = 5;
								end
							end
						elseif (Enum > 367) then
							local FlatIdent_4BE3A = 0;
							local A;
							while true do
								if (FlatIdent_4BE3A == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 5;
								end
								if (FlatIdent_4BE3A == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 8;
								end
								if (FlatIdent_4BE3A == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 3;
								end
								if (8 == FlatIdent_4BE3A) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A]();
									FlatIdent_4BE3A = 9;
								end
								if (FlatIdent_4BE3A == 0) then
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_4BE3A = 1;
								end
								if (FlatIdent_4BE3A == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 6;
								end
								if (9 == FlatIdent_4BE3A) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									break;
								end
								if (6 == FlatIdent_4BE3A) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 7;
								end
								if (FlatIdent_4BE3A == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 4;
								end
								if (FlatIdent_4BE3A == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_4BE3A = 2;
								end
							end
						else
							local FlatIdent_5EC5A = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_5EC5A == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_5EC5A = 2;
								end
								if (FlatIdent_5EC5A == 6) then
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_5EC5A = 7;
								end
								if (0 == FlatIdent_5EC5A) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_5EC5A = 1;
								end
								if (FlatIdent_5EC5A == 5) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5EC5A = 6;
								end
								if (FlatIdent_5EC5A == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5EC5A = 4;
								end
								if (2 == FlatIdent_5EC5A) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_5EC5A = 3;
								end
								if (FlatIdent_5EC5A == 7) then
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_5EC5A == 4) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5EC5A = 5;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_24149 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_24149 = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!9F032Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q747047657403563Q00682Q7470733A2Q2F7261772E67697468756275736572636F6E74656E742E636F6D2F536C2Q65707943612Q74537461722F43612Q745374617254656D702F726566732F68656164732F6D61696E2F4D61696E2E6C756103623Q00682Q7470733A2Q2F7261772E67697468756275736572636F6E74656E742E636F6D2F536C2Q65707943612Q74537461722F43612Q745374617254656D702F726566732F68656164732F6D61696E2F496E746572666163654D616E616765722E6C7561030C3Q0043726561746557696E646F7703053Q005469746C6503143Q0043612Q7453746172204175746F4661726D20763303083Q005375625469746C6503123Q004661726D2C2052616964202620436F64657303083Q005461625769647468026Q00644003043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574025Q00208240025Q00C07C4003073Q00416372796C69632Q0103053Q005468656D6503043Q004461726B030B3Q004D696E696D697A654B657903043Q00456E756D03073Q004B6579436F6465030A3Q005269676874536869667403083Q004D61696E4661726D03063Q00412Q6454616203093Q004D61696E204661726D03043Q0049636F6E03063Q007363726F2Q6C03043Q004D61696E030A3Q004368657374204661726D03043Q00686F6D6503043Q00426F6E6503093Q00426F6E65204661726D03053Q00736B752Q6C03043Q005261696403093Q004175746F205261696403063Q0073776F72647303083Q0054656C65706F727403093Q0054656C65706F7274732Q033Q006D617003043Q004D697363030C3Q004D697363202620436F6465732Q033Q00626F7803083Q0053652Q74696E677303083Q0073652Q74696E677303073Q004F7074696F6E73030A3Q004765745365727669636503073Q00506C6179657273030B3Q004C6F63616C506C6179657203113Q005265706C69636174656453746F72616765030C3Q0054772Q656E5365727669636503093Q00576F726B737061636503083Q004C69676874696E6703073Q00506C6163654964030C3Q0057616974466F724368696C6403073Q004D6F64756C65732Q033Q004E657403113Q0052452F5265676973746572412Q7461636B030E3Q0052452F526567697374657248697403073Q0052656D6F74657303063Q005265642Q656D03063Q00436F2Q6D465F025Q00807140026Q00F03F03113Q00312E20537461727465722049736C616E6403073Q00566563746F72332Q033Q006E6577025Q00609040026Q003040025Q0034964003093Q00322E204A756E676C65025Q009C93C0026Q002840025Q0010744003113Q00332E205069726174652056692Q6C616765025Q00EC91C0026Q001040025Q00F0AD4003093Q00342E20446573657274025Q00808D40026Q001840025Q00E3B04003103Q00352E204D692Q646C652049736C616E64025Q00A079C0025Q0030994003113Q00362E2046726F7A656E2056692Q6C616765025Q00FC9140026Q003B40025Q00A094C003123Q00372E204D6172696E6520466F727472652Q73025Q00CEB2C0026Q003540025Q00C4B040030B3Q00382E20536B796C616E6473025Q0066B3C0025Q00688640025Q0084A4C003093Q00392E20507269736F6E025Q00FEB240026Q001440025Q00F88640030D3Q0031302E20436F6C6F2Q7365756D025Q00F497C0026Q001C40025Q0096A5C003113Q002Q312E204D61676D612056692Q6C616765025Q007DB4C0026Q002040025Q0089C04003133Q0031322E20556E64657277617465722043697479024Q0060DDED40026Q002440025Q006C984003113Q0031332E20466F756E7461696E2043697479025Q00F8B340025Q00804D40025Q0058AF40030E3Q00552Q70657220536B796C616E6473025Q00BDB6C0025Q00C49340025Q0094A1C0027Q004003123Q00312E204B696E67646F6D206F6620526F7365025Q00D07BC0026Q005240025Q00F0744003073Q00322E2043616665025Q00E077C0025Q00405240025Q00B0714003183Q00332E2052656D6F74652049736C616E64202855736F617029025Q0052A1C0026Q004540025Q00B888C0030D3Q00342E2047722Q656E205A6F6E65025Q004CA2C0025Q00C8A8C0030C3Q00352E20477261766579617264025Q0026B5C0025Q00A886C003103Q00362E20536E6F77204D6F756E7461696E025Q00C88140025Q00107940025Q00A5B4C0030F3Q00372E20486F7420616E6420436F6C64025Q004DB5C0026Q002E40025Q0087B4C0030E3Q00382E204375727365642053686970025Q0061B9C0025Q00C05440025Q00405FC0030D3Q00392E2049636520436173746C65025Q00F3B740026Q003D40025Q0066B9C003143Q0031302E20466F72676F2Q74656E2049736C616E64025Q00B4A7C0025Q00E06D40024Q0080D8C3C0030E3Q002Q312E204461726B204172656E61025Q0028AE40025Q0050ABC003073Q004D616E73696F6E025Q00807DC0025Q00C07440025Q00B88340026Q000840030C3Q00312E20506F727420546F776E025Q004075C0026Q003440025Q00A1B540030F3Q00322E2048796472612049736C616E64025Q00C7B440025Q00608F40025Q00A06F40030D3Q00332E2047726561742054722Q65025Q0080A040025Q0011BAC003123Q00342E20466C6F6174696E6720547572746C65025Q00DFC9C0025Q00F07A40025Q00BABDC003143Q00352E20436173746C65206F6E2074686520536561025Q0070B3C0025Q00A07340025Q009EA7C003113Q00362E204861756E74656420436173746C65025Q0096C2C0025Q00C06140025Q00A0B54003103Q00372E20536561206F6620547265617473025Q00649DC0026Q002A40024Q0080B5C6C0030F3Q00382E2054696B69204F7574706F7374025Q00B5CFC0026Q002640025Q00A07B40030E3Q004C494748544E494E474142555345030A3Q004B492Q545F524553455403153Q005355423247414D452Q524F424F545F524553455431030F3Q0053756232556E636C654B697A61727503093Q0066752Q6431305F763203063Q0066752Q64313003083Q004368616E646C657203073Q004269676E65777303133Q005355423247414D452Q524F424F545F45585031030A3Q00537562324665723Q39030C3Q0054616E74616947616D696E67030A3Q006B692Q7467616D696E67030B3Q00456E79755F69735F50726F030F3Q00537562324361707461696E4D61756903083Q004D6167696362757303123Q00537562324F2Q66696369616C4E2Q6F626965030B3Q00546865477265617441636503043Q004A43574B03063Q00426C752Q787903063Q004178696F7265030B3Q0053746172636F646568656F030D3Q0053747261774861744D61696E65030C3Q005375623244616967726F636B03113Q00537562324E2Q6F624D6173746572313233028Q00030C3Q0042616E64697451756573743103063Q0042616E64697403063Q00434672616D65025Q002Q9040025Q002C9840025Q00BC9240025Q00289840030B3Q004A756E676C65517565737403063Q004D6F6E6B6579025Q001099C0026Q004240025Q00406340025Q007497C0026Q005140025Q00C06DC003073Q00476F72692Q6C61025Q00D891C0026Q004440025Q001880C0026Q003E40030B3Q0042752Q677951756573743103063Q00506972617465025Q00D091C0025Q00E6AD40025Q000493C0025Q00804240025Q005AAB4003053Q004272757465025Q009C92C0026Q002Q40025Q00D0AD40026Q004E40030B3Q004465736572745175657374030D3Q004465736572742042616E646974026Q008C40025Q0026B140025Q00208D40025Q0071B140025Q00C05240030E3Q00446573657274204F2Q6669636572025Q008C9840025Q0001B140025Q0080564003093Q00536E6F775175657374030B3Q00536E6F772042616E646974025Q00A89540025Q00C05540025Q004894C0025Q00149540025Q004C95C0026Q00594003073Q00536E6F776D616E025Q00849240025Q00805A40025Q001C97C0026Q005E40030C3Q004D6172696E6551756573743203133Q0043686965662050652Q7479204F2Q6669636572025Q00ABB3C0026Q003C40025Q00E4B040025Q003CB3C0025Q00D8B040025Q00C0624003083Q00536B795175657374030A3Q00536B792042616E646974025Q00E9B2C0025Q007EA4C0025Q006AB3C0025Q00607240025Q0094A6C0025Q00E06540030B3Q004461726B204D6173746572025Q0067B4C0025Q00E07440025Q007EA2C0025Q00C06740030B3Q00507269736F6E517565737403083Q00507269736F6E6572025Q00BCB440025Q00A07D40025Q00BAB440025Q00406A4003123Q0044616E6765726F757320507269736F6E6572025Q00B8B540025Q00A07640025Q00206C40030E3Q00436F6C6F2Q7365756D5175657374030C3Q00546F67612057612Q72696F72025Q00A098C0025Q004EA7C0025Q00CC9BC0026Q004640025Q0060A5C0025Q0030714003093Q00476C61646961746F72025Q00B895C0025Q0074A8C0025Q00C07240030A3Q004D61676D61517565737403103Q004D696C697461727920536F6C64696572025Q00C4B4C0024Q0080A2C040025Q00F3B4C0025Q00804440025Q00B2C040025Q00507440030C3Q004D696C697461727920537079025Q00C5B6C0025Q003AC140025Q00707740030C3Q00466973686D616E5175657374030F3Q00466973686D616E2057612Q72696F72024Q0040D8ED40026Q003240025Q00809840025Q006C9C40026Q00794003103Q00466973686D616E20436F2Q6D616E646F024Q00603FEE40025Q007C9640025Q00207C40030E3Q00552Q706572536B79517565737431030B3Q00476F642773204775617264025Q0071B2C0025Q00688A40025Q00789EC0025Q0033B2C0025Q00808A40025Q00B49EC0025Q00B07D4003063Q005368616E6461025Q0004BEC0025Q00ADB540025Q00307FC0025Q00688040030E3Q00552Q706572536B79517565737432030B3Q00526F79616C205371756164025Q00B088C0025Q00C07F40025Q0074A1C0025Q00F082C0025Q00B07F40025Q00B0A2C0025Q00308140030D3Q00526F79616C20536F6C64696572025Q00888AC0025Q00D07A40025Q00DCA4C0025Q00888340030D3Q00466F756E7461696E5175657374030D3Q0047612Q6C657920506972617465025Q0086B440026Q004340025Q00A2AF40025Q00DBB540025Q00F2AE40025Q00508440030E3Q0047612Q6C6579204361707461696E025Q00E08540030A3Q004172656131517565737403063Q00526169646572025Q00B07AC0025Q00B09C40025Q00C077C0025Q00805340025Q005EA040025Q00A8864003093Q004D657263656E617279025Q00E080C0025Q00405740025Q00109D40025Q00388840030A3Q0041726561325175657374030B3Q005377616E20506972617465025Q00D88340025Q00B88C40025Q00E08940025Q00805E40025Q00289240026Q008940030D3Q00466163746F7279205374612Q66025Q00207740025Q00405340025Q00588B40030C3Q004D6172696E6551756573743303113Q004D6172696E65204C69657574656E616E74025Q0014A3C0025Q0026A9C0026Q005340025Q0036A8C0025Q00208C40030E3Q004D6172696E65204361707461696E025Q00C6A4C0025Q00C0A8C0025Q00B08D40030B3Q005A6F6D626965517565737403063Q005A6F6D626965025Q0074B5C0026Q004840025Q00D088C0025Q001BB6C0025Q00405140025Q000887C0025Q00788E4003073Q0056616D70697265025Q008FB6C0025Q00F078C0025Q00408F4003113Q00536E6F774D6F756E7461696E5175657374030C3Q00536E6F772054722Q6F706572025Q00F08240025Q006C91C0025Q00B08040025Q00607940025Q005490C0025Q00689040030E3Q0057696E7465722057612Q72696F72025Q001C9240025Q00E07A40025Q005092C0025Q00309140030C3Q00496365536964655175657374030F3Q004C6162205375626F7264696E617465025Q0055B8C0025Q00F3B2C0025Q003EB6C0026Q003740025Q00E9B3C0025Q00949140030E3Q00486F726E65642057612Q72696F72025Q0088B8C0025Q00ACB6C0025Q005C9240030D3Q0046697265536964655175657374030B3Q004D61676D61204E696E6A61025Q001BB5C0026Q003640025Q00FAB4C0025Q00A2B5C0026Q003840025Q0026B6C0025Q00C09240030B3Q004C61766120506972617465025Q00EBB3C0025Q00F3B3C0025Q00889340030A3Q0053686970517565737431030D3Q0053686970204465636B68616E64025Q00F08C40025Q00405F40024Q00A00AE040025Q00E49240025Q00C05F40024Q00E01FE040025Q00EC9340030D3Q005368697020456E67696E2Q6572025Q00D88C40024Q002001E040025Q00509440030A3Q0053686970517565737432030C3Q00536869702053746577617264025Q00808C40025Q00606440024Q00200CE040025Q00A08840025Q00406640024Q004018E040025Q00B49440030C3Q0053686970204F2Q6669636572025Q00108C40025Q00806640024Q00C09CDF40025Q00189540030A3Q0046726F73745175657374030E3Q004172637469632057612Q72696F72025Q0004B840025Q0052B9C0025Q00BDB740025Q004EB8C0025Q007C9540030B3Q00536E6F77204C75726B6572025Q00AABAC0025Q00449640030E3Q00466F72676F2Q74656E5175657374030B3Q0053656120536F6C64696572025Q00DCA7C0025Q00606D40024Q0080D0C3C0025Q000EAAC0025Q004FC4C0025Q00A89640030D3Q0057617465722046696768746572025Q000EA6C0024Q008048C4C0025Q00709740030F3Q00506972617465506F7274517565737403123Q00506972617465204D692Q6C696F6E61697265025Q00607CC0025Q00405940025Q003BB740025Q005077C0025Q008FB540025Q00D4974003123Q00506973746F6C2042692Q6C696F6E61697265025Q00907CC0025Q0052B740025Q009C9840030B3Q00416D617A6F6E517565737403133Q00447261676F6E20437265772057612Q72696F72025Q00CBB640026Q004A40025Q003C91C0025Q0002B940026Q004B40025Q002C90C0026Q00994003123Q00447261676F6E204372657720417263686572025Q00E9B940025Q00107840025Q00649940030C3Q00416D617A6F6E517565737432030F3Q0046656D616C652049736C616E646572025Q0043B540025Q00D08240025Q00788740025Q00E5B440025Q00608240025Q00A88240025Q00C89940030E3Q004769616E742049736C616E646572025Q0012B340025Q00B88240025Q002Q70C0025Q00909A4003103Q004D6172696E6554722Q6549736C616E6403103Q004D6172696E6520436F2Q6D6F646F7265025Q006EA340025Q00C05040025Q003ABBC0025Q0056A340025Q00405440025Q00DFBCC0025Q00F49A4003133Q004D6172696E6520526561722041646D6972616C025Q0010AB40026Q005F40025Q0001BCC0025Q00BC9B4003103Q00442Q6570466F7265737449736C616E64030E3Q00466973686D616E20526169646572025Q00ACC4C0025Q00B07440025Q001BC1C0025Q0070C4C0024Q0080A82QC0025Q00209C40030F3Q00466973686D616E204361707461696E025Q007AC5C0024Q008073C1C0025Q00849C4003113Q00442Q6570466F7265737449736C616E6432030D3Q00466F7265737420506972617465025Q002CC4C0024Q0080352QC0024Q00809EC4C0025Q00A07440024Q00800BC2C0025Q00E89C4003133Q004D7974686F6C6F676963616C20506972617465025Q0032C6C0025Q00307440025Q0093C1C0025Q00B09D4003113Q00442Q6570466F7265737449736C616E6433030D3Q004A756E676C6520506972617465025Q00C6C8C0025Q00607840025Q0057C3C0025Q007FC7C0024Q008097C4C0025Q00149E4003103Q004D75736B65742Q657220506972617465025Q00C1C9C0024Q008022C3C0025Q00DC9E40030C3Q004861756E7465645175657374030F3Q005265626F726E20536B656C65746F6E025Q0085C2C0025Q00BBB540025Q001CC1C0025Q00806140025Q0097B740025Q00409F40030D3Q004C6976696E67205A6F6D626965024Q0080CFC3C0025Q0028B740025Q00A49F40030D3Q004861756E746564517565737432030C3Q0044656D6F6E696320536F756C024Q008094C2C0025Q00806540025Q00BEB740025Q0091C2C0025Q00A06540025Q00EFB740025Q0004A040030F3Q00506F2Q73652Q736564204D752Q6D79024Q0080B3C2C0025Q0093B740025Q0036A040030B3Q005065616E75745175657374030C3Q005065616E75742053636F7574025Q0070A0C0025Q00E8C3C0025Q00A8A1C0025Q004EC4C0025Q0068A04003103Q005065616E757420507265736964656E74025Q0064A0C0025Q00D8C4C0025Q009AA040030D3Q00496365437265616D5175657374030E3Q0049636520437265616D2043686566025Q009089C0025Q00805040024Q008075CFC0025Q00A084C0025Q00405040024Q004035D0C0025Q00CCA04003133Q0049636520437265616D20436F2Q6D616E646572025Q002Q90C0024Q0080E3CFC0025Q0030A140030A3Q0043616B65517565737431030E3Q00432Q6F6B69652043726166746572025Q00909FC0024Q00807CC7C0025Q0032A2C0025Q00B1C7C0025Q0062A140030C3Q00432Q6F6B6965204775617264025Q00449BC0024Q00805AC8C0025Q0094A140030A3Q0043616B65517565737432030C3Q0042616B696E67205374612Q66025Q00189EC0025Q0019C9C0025Q001EA0C0025Q0047C9C0025Q00C6A140030A3Q00486561642042616B6572025Q00349CC0025Q004AC9C0025Q00F8A140030A3Q0043686F63517565737431030E3Q00436F636F6120477561726469616E025Q00E06C40025Q00D4C7C0026Q006A40024Q00802DC8C0025Q002AA240030D3Q00436F636F612057612Q72696F72026Q0031C0025Q007EC7C0025Q005CA240030A3Q0043686F63517565737432030B3Q0043616E647920526562656C025Q00E06240024Q0080F3C8C0024Q008083C9C0025Q008EA240030C3Q0043616E647920506972617465025Q00607A40024Q008068C9C0025Q00C0A24003093Q0054696B695175657374030B3Q0049736C65204F75746C6177024Q008026D0C0025Q00805F40025Q00F2A240030A3Q0049736C616E6420426F79024Q00804AD0C0025Q00C08B40025Q0024A340030A3Q0054696B6951756573743203123Q0053756E204B692Q7365642057612Q72696F72025Q0023D0C0025Q00C08A40030D3Q0049736C65204368616D70696F6E024Q00C030D0C0025Q00804340025Q00649240030C3Q00476F72692Q6C61204B696E67025Q00804B4003043Q0043686566025Q00405A4003043Q0059657469025Q00406040030C3Q00566963652041646D6972616C025Q00806B4003063Q0057617264656E025Q00C06C40030C3Q0043686965662057617264656E025Q00406F4003043Q005377616E025Q00E07540030D3Q004D61676D612041646D6972616C025Q00907A40030C3Q00466973686D616E204C6F7264025Q00407F4003063Q00577973706572025Q00F88140030B3Q005468756E64657220476F64025Q00708740030B3Q004379626F7267517565737403063Q004379626F726703073Q004469616D6F6E64025Q00908A4003063Q004A6572656D79025Q00E88C4003073Q004F726269747573025Q00F8914003093Q00466972655175657374030D3Q00536D6F6B652041646D6972616C025Q0034B5C0025Q00AFB4C0030E3Q00437572736564204361707461696E025Q00E0954003143Q004177616B656E6564204963652041646D6972616C025Q000C9740030B3Q0054696465204B2Q65706572025Q0038984003053Q0053746F6E65025Q001072C0025Q00804540025Q00C8B540025Q002C9A40030E3Q0049736C616E6420456D7072652Q73025Q00589B40030C3Q004B696C6F2041646D6972616C025Q0008A140025Q0051BAC0025Q004C9D4003103Q004361707461696E20456C657068616E74025Q00789E4003103Q0042656175746966756C20506972617465025Q00FEA040030A3Q0043616B652051752Q656E024Q008095C2C0025Q00806440025Q0094B640022Q00A053AD84E441022Q00701B7B8CF041022Q0030F152C0FB4103083Q00496E7374616E6365030C3Q00426F647956656C6F6369747903083Q004D6178466F726365024Q0080842E4103083Q0056656C6F6369747903043Q004E616D65030A3Q004661726D427970612Q7303133Q00426F6479416E67756C617256656C6F6369747903093Q004D6178546F72717565030F3Q00416E67756C617256656C6F6369747903103Q004661726D427970612Q73526F74617465030E3Q00436861726163746572412Q64656403073Q00436F2Q6E65637403093Q0043686172616374657203043Q007461736B03053Q00737061776E03133Q005669727475616C496E7075744D616E6167657203073Q0067657467656E76030B3Q00412Q7461636B52616E676503083Q004465626F756E6365030D3Q00436F6D626F4465626F756E636503073Q004D31436F6D626F03053Q007063612Q6C03063Q00412Q7461636B030C3Q00412Q6450617261677261706803093Q00426F2Q73204661726D03073Q00436F6E74656E7403373Q0054772Q656E7320746F2074686520626F2Q7320616E64206B692Q6C732069742028646570656E6473206F6E20796F7572206C6576656C2903093Q00412Q64546F2Q676C65030E3Q004175746F4661726D426F2Q736573030E3Q004175746F2D4661726D20426F2Q7303073Q0044656661756C7403093Q004F6E4368616E676564030A3Q005365727665722D486F7003273Q004966206E6F20626F2Q7365732061726520666F756E642C2069742073657276657220686F707321030A3Q0053657276657220486F70030A3Q004C6576656C204661726D03243Q0054616B65732071756573747320616E64206661726D206C6576656C7320666F7220796F7503093Q004175746F204661726D030F3Q004175746F204661726D204C6576656C030A3Q004175746F2D537461747303963Q0046756E6374696F6E206973207374692Q6C20626574612C20736F20697420646F65736E27742073746F7020636F6E73756D696E6720796F757220706F696E7473206F6E636520796F752073656C656374207768617420796F752077616E742074686520706F696E7473206F6E2C20736F20706C65617365207573652074686973206F6E6C7920617420796F7572206F776E207269736B030B3Q00412Q6444726F70646F776E030A3Q005374617454617267657403163Q0053656C656374205374617420746F205570677261646503063Q0056616C75657303053Q004D656C2Q6503073Q00446566656E736503053Q0053776F72642Q033Q0047756E030A3Q00426C6F7820467275697403053Q004D756C746903093Q004175746F537461747303113Q00456E61626C65204175746F205374617473030E3Q0053656C6563746564576561706F6E03113Q004175746F2D457175697020576561706F6E030B3Q004465736372697074696F6E031F3Q0053656C65637420776561706F6E20746F206571756970206F6E20737061776E03083Q0043612Q6C6261636B03093Q00412Q6442752Q746F6E03113Q005265667265736820542Q6F6C204C69737403223Q00557064617465206C69737420616674657220627579696E67206E6577206974656D73031E3Q00466C69657320746F20636865737473206175746F6D61746963612Q6C792E03093Q0043686573744661726D030F3Q004175746F204368657374204661726D03093Q00412Q64536C69646572030A3Q0054772Q656E53702Q6564030B3Q0054772Q656E2053702Q656403213Q00486967686572203D204661737465722028332Q30207265636F2Q6D656E646564292Q033Q004D696E2Q033Q004D617803083Q00526F756E64696E6703173Q004175746F205261696420284E6578742049736C616E6429032E3Q004B692Q6C7320612Q6C206D6F62732C207468656E206D6F76657320746F20746865206E6578742069736C616E642E03083Q00526169644661726D030F3Q005374617274204175746F2052616964031C3Q004861756E74656420436173746C6520285365612033204F6E6C79292E03083Q00426F6E654661726D030E3Q004175746F20426F6E65204661726D030A3Q00426F6E6520476163686103293Q004175746F206275792052616E646F6D2053757270726973652066726F6D204465617468204B696E672E03083Q00426F6E65526F2Q6C03203Q004175746F20526F2Q6C20426F6E6573202854656C65706F7274202B204275792903133Q00436F2Q6D756E69747920262053752Q706F7274032D3Q004A6F696E2074686520446973636F726420666F72207570646174657320616E6420627567207265706F7274732103133Q004A6F696E20446973636F726420536572766572031D3Q00682Q7470733A2Q2F646973636F72642E2Q672F6D556D4D453944464834030D3Q00436F6465205265642Q656D657203433Q005265642Q656D7320612Q6C2077696B6920636F646573206F6E65206279206F6E652E20436865636B206E6F74696669636174696F6E7320666F7220726573756C74732E03103Q005265642Q656D20412Q6C20436F64657303053Q00706169727303053Q007461626C6503063Q00696E7365727403043Q00736F7274030D3Q0043752Q72656E74205365613A20032F3Q0053656C65637420616E2069736C616E642062656C6F7720746F2074656C65706F727420692Q6D6564696174656C792E030C3Q0049736C616E6453656C656374030D3Q0053656C6563742049736C616E64030D3Q0053746F702054656C65706F727403093Q0046505320422Q6F7374031D3Q004C6F7765727320677261706869637320746F20726564756365206C6167030A3Q005365744C69627261727903093Q00536574466F6C64657203103Q0043612Q745374617253652Q74696E677303153Q004275696C64496E7465726661636553656374696F6E03093Q0053656C65637454616203063Q004E6F7469667903113Q0043612Q7453746172204175746F6661726D03173Q005363726970742068617320622Q656E206C6F616465642103083Q004475726174696F6E03093Q005363722Q656E477569030A3Q005465787442752Q746F6E030A3Q00496D6167654C6162656C03063Q004F70656E554903063Q00506172656E7403073Q00436F7265477569030E3Q005A496E6465784265686176696F7203073Q005369626C696E6703103Q004261636B67726F756E64436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742026Q003F40030F3Q00426F7264657253697A65506978656C03083Q00506F736974696F6E029A5Q99B93F026Q33C33F026Q00494003043Q0054657874034Q00030B3Q00416E63686F72506F696E7403073Q00566563746F7232026Q00E03F029A5Q99E93F03163Q004261636B67726F756E645472616E73706172656E637903053Q00496D616765031B3Q00726278612Q73657469643A2Q2F38343937313032383133342Q373903083Q005549436F726E6572030C3Q00436F726E657252616469757303043Q005544696D03113Q004D6F75736542752Q746F6E31436C69636B03103Q0055736572496E70757453657276696365026Q00D03F030A3Q00496E707574426567616E030C3Q00496E7075744368616E67656400F20B2Q002Q12012Q00013Q00122Q000100023Q00202Q00010001000300122Q000300046Q000100039Q0000026Q0001000200122Q000100013Q00122Q000200023Q00202Q00020002000300122Q000400056Q000200046Q00013Q00024Q00010001000200202Q00023Q00064Q00043Q000700302Q00040007000800302Q00040009000A00302Q0004000B000C00122Q0005000E3Q00202Q00050005000F00122Q000600103Q00122Q000700116Q00050007000200102Q0004000D000500302Q00040012001300302Q00040014001500122Q000500173Q00202Q00050005001800202Q00050005001900102Q0004001600054Q0002000400024Q00033Q000700202Q00040002001B4Q00063Q000200302Q00060007001C00302Q0006001D001E4Q00040006000200102Q0003001A000400202Q00040002001B4Q00063Q000200302Q00060007002000302Q0006001D00214Q00040006000200102Q0003001F000400202Q00040002001B4Q00063Q000200302Q00060007002300302Q0006001D00244Q00040006000200102Q00030022000400202Q00040002001B4Q00063Q000200302Q00060007002600302Q0006001D00274Q00040006000200102Q00030025000400202Q00040002001B4Q00063Q000200302Q00060007002900302Q0006001D002A4Q00040006000200102Q00030028000400202Q00040002001B4Q00063Q000200302Q00060007002C00302Q0006001D002D4Q00040006000200102Q0003002B000400202Q00040002001B4Q00063Q000200302Q00060007002E00302Q0006001D002F4Q00040006000200102Q0003002E000400202Q00043Q003000122Q000500023Q00202Q00050005003100122Q000700326Q0005000700020020350106000500330012E8000700023Q00202Q00070007003100122Q000900346Q00070009000200122Q000800023Q00202Q00080008003100122Q000A00356Q0008000A000200122Q000900023Q00202Q00090009003100122Q000B00366Q0009000B000200122Q000A00023Q00202Q000A000A003100122Q000C00376Q000A000C000200122Q000B00023Q00202Q000B000B003800202Q000C0007003900122Q000E003A6Q000C000E000200202Q000C000C003900122Q000E003B6Q000C000E000200202Q000D000C003900122Q000F003C6Q000D000F000200202Q000E000C003900122Q0010003D6Q000E0010000200202Q000F0007003900122Q0011003E6Q000F0011000200202Q000F000F003900122Q0011003F6Q000F0011000200202Q00100007003900122Q0012003E6Q00100012000200202Q00100010003900122Q001200406Q0010001200024Q00118Q001200123Q00122Q001300416Q00143Q00034Q00153Q000E00122Q001600443Q00202Q00160016004500122Q001700463Q00122Q001800473Q00122Q001900486Q00160019000200102Q00150043001600122Q001600443Q00202Q00160016004500122Q0017004A3Q00122Q0018004B3Q00122Q0019004C6Q00160019000200102Q00150049001600122Q001600443Q00202Q00160016004500122Q0017004E3Q00122Q0018004F3Q00122Q001900506Q00160019000200102Q0015004D001600122Q001600443Q00202Q00160016004500122Q001700523Q00122Q001800533Q00122Q001900546Q00160019000200102Q00150051001600122Q001600443Q00202Q00160016004500122Q001700563Q00122Q001800533Q00122Q001900574Q00CA00160019000200103101150055001600122Q001600443Q00202Q00160016004500122Q001700593Q00122Q0018005A3Q00122Q0019005B6Q00160019000200102Q00150058001600122Q001600443Q00202Q00160016004500122Q0017005D3Q00122Q0018005E3Q00122Q0019005F6Q00160019000200102Q0015005C001600122Q001600443Q00202Q00160016004500122Q001700613Q00122Q001800623Q00122Q001900636Q00160019000200102Q00150060001600122Q001600443Q00202Q00160016004500122Q001700653Q00122Q001800663Q00122Q001900676Q00160019000200102Q00150064001600122Q001600443Q00202Q00160016004500122Q001700693Q00122Q0018006A3Q00122Q0019006B6Q00160019000200102Q00150068001600122Q001600443Q00202Q00160016004500122Q0017006D3Q00122Q0018006E3Q00122Q0019006F6Q00160019000200102Q0015006C001600122Q001600443Q00202Q00160016004500122Q001700713Q00122Q001800723Q00122Q001900736Q00160019000200102Q00150070001600122Q001600443Q00202Q00160016004500122Q001700753Q00122Q001800763Q00122Q001900776Q00160019000200102Q00150074001600122Q001600443Q00202Q00160016004500122Q001700793Q00122Q0018007A3Q00122Q0019007B6Q00160019000200102Q00150078001600102Q0014004200154Q00153Q000C00122Q001600443Q00202Q00160016004500122Q0017007E3Q00122Q0018007F3Q00122Q001900806Q00160019000200102Q0015007D001600122Q001600443Q00202Q00160016004500122Q001700823Q00122Q001800833Q00122Q001900846Q00160019000200102Q00150081001600123B011600443Q00202C00160016004500122Q001700863Q00122Q001800873Q00122Q001900886Q00160019000200102Q00150085001600122Q001600443Q00202Q00160016004500122Q0017008A3Q00122Q0018007F3Q00122Q0019008B6Q00160019000200102Q00150089001600122Q001600443Q00202Q00160016004500122Q0017008D3Q00122Q001800533Q00122Q0019008E6Q00160019000200102Q0015008C001600122Q001600443Q00202Q00160016004500122Q001700903Q00122Q001800913Q00122Q001900926Q00160019000200102Q0015008F001600122Q001600443Q00202Q00160016004500122Q001700943Q00122Q001800953Q00122Q001900966Q00160019000200102Q00150093001600122Q001600443Q00202Q00160016004500122Q001700983Q00122Q001800993Q00122Q0019009A6Q00160019000200102Q00150097001600122Q001600443Q00202Q00160016004500122Q0017009C3Q00122Q0018009D3Q00122Q0019009E6Q00160019000200102Q0015009B001600122Q001600443Q00202Q00160016004500122Q001700A03Q00122Q001800A13Q00122Q001900A26Q00160019000200102Q0015009F001600122Q001600443Q00202Q00160016004500122Q001700A43Q00122Q001800953Q00122Q001900A56Q00160019000200102Q001500A3001600122Q001600443Q00202Q00160016004500122Q001700A73Q00122Q001800A83Q00122Q001900A96Q00160019000200102Q001500A6001600102Q0014007C00154Q00153Q000800122Q001600443Q00202Q00160016004500122Q001700AC3Q00122Q001800AD3Q00122Q001900AE6Q00160019000200102Q001500AB001600122Q001600443Q00202Q0016001600450012A8001700B03Q00120F001800B13Q00122Q001900B26Q00160019000200102Q001500AF001600122Q001600443Q00202Q00160016004500122Q001700B43Q00122Q0018005E3Q00122Q001900B56Q00160019000200102Q001500B3001600122Q001600443Q00202Q00160016004500122Q001700B73Q00122Q001800B83Q00122Q001900B96Q00160019000200102Q001500B6001600122Q001600443Q00202Q00160016004500122Q001700BB3Q00122Q001800BC3Q00122Q001900BD6Q00160019000200102Q001500BA001600122Q001600443Q00202Q00160016004500122Q001700BF3Q00122Q001800C03Q00122Q001900C16Q00160019000200102Q001500BE001600122Q001600443Q00202Q00160016004500122Q001700C33Q00122Q001800C43Q00122Q001900C56Q00160019000200102Q001500C2001600122Q001600443Q00202Q00160016004500122Q001700C73Q00122Q001800C83Q00122Q001900C96Q00160019000200102Q001500C6001600102Q001400AA00154Q001500143Q00122Q001600CA3Q00122Q001700CB3Q00122Q001800CC3Q00122Q001900CD3Q00122Q001A00CE3Q00122Q001B00CF3Q00122Q001C00D03Q00122Q001D00D13Q00122Q001E00D23Q00122Q001F00D33Q00122Q002000D43Q00122Q002100D53Q00122Q002200D63Q00122Q002300D73Q00122Q002400D83Q00122Q002500D93Q00122Q002600DA3Q00122Q002700DB3Q00122Q002800DC3Q00122Q002900DD3Q00122Q002A00DE3Q00122Q002B00DF3Q00122Q002C00E03Q00122Q002D00E16Q0015001800012Q00A9001600234Q00D7001700053Q00122Q001800E23Q00122Q001900E33Q00122Q001A00423Q00122Q001B00E43Q00122Q001C00E53Q00202Q001C001C004500122Q001D00E63Q00122Q001E00473Q00122Q001F00E74Q00CA001C001F0002001295001D00E53Q00202Q001D001D004500122Q001E00E83Q00122Q001F00473Q00122Q002000E96Q001D00206Q00173Q00012Q00A9001800053Q0012D5001900723Q00122Q001A00EA3Q00122Q001B00423Q00122Q001C00EB3Q00122Q001D00E53Q00202Q001D001D004500122Q001E00EC3Q00122Q001F00ED3Q00122Q002000EE6Q001D00200002001295001E00E53Q00202Q001E001E004500122Q001F00EF3Q00122Q002000F03Q00122Q002100F16Q001E00216Q00183Q00012Q00A9001900053Q0012D5001A00953Q00122Q001B00EA3Q00122Q001C007C3Q00122Q001D00F23Q00122Q001E00E53Q00202Q001E001E004500122Q001F00EC3Q00122Q002000ED3Q00122Q002100EE6Q001E00210002001295001F00E53Q00202Q001F001F004500122Q002000F33Q00122Q002100F43Q00122Q002200F56Q001F00226Q00193Q00012Q00A9001A00053Q0012D5001B00F63Q00122Q001C00F73Q00122Q001D00423Q00122Q001E00F83Q00122Q001F00E53Q00202Q001F001F004500122Q002000F93Q00122Q0021004F3Q00122Q002200FA6Q001F00220002001295002000E53Q00202Q00200020004500122Q002100FB3Q00122Q002200FC3Q00122Q002300FD6Q002000236Q001A3Q00012Q00A9001B00053Q0012D5001C00F43Q00122Q001D00F73Q00122Q001E007C3Q00122Q001F00FE3Q00122Q002000E53Q00202Q00200020004500122Q002100F93Q00122Q0022004F3Q00122Q002300FA6Q002000230002001295002100E53Q00202Q00210021004500122Q002200FF3Q00122Q00232Q00012Q00122Q0024002Q015Q002100246Q001B3Q00012Q00A9001C00053Q0012D5001D0002012Q00122Q001E0003012Q00122Q001F00423Q00122Q00200004012Q00122Q002100E53Q00202Q00210021004500122Q00220005012Q00122Q002300533Q00122Q00240006015Q002100240002001295002200E53Q00202Q00220022004500122Q00230007012Q00122Q002400F43Q00122Q00250008015Q002200256Q001C3Q00012Q00A9001D00053Q0012D5001E0009012Q00122Q001F0003012Q00122Q0020007C3Q00122Q0021000A012Q00122Q002200E53Q00202Q00220022004500122Q00230005012Q00122Q002400533Q00122Q00250006015Q002200250002001295002300E53Q00202Q00230023004500122Q0024000B012Q00122Q002500723Q00122Q0026000C015Q002300266Q001D3Q00012Q00A9001E00053Q0012D5001F000D012Q00122Q0020000E012Q00122Q002100423Q00122Q0022000F012Q00122Q002300E53Q00202Q00230023004500122Q00240010012Q00122Q00250011012Q00122Q00260012015Q002300260002001295002400E53Q00202Q00240024004500122Q00250013012Q00122Q002600EE3Q00122Q00270014015Q002400276Q001E3Q00012Q00A9001F00053Q0012D500200015012Q00122Q0021000E012Q00122Q0022007C3Q00122Q00230016012Q00122Q002400E53Q00202Q00240024004500122Q00250010012Q00122Q00260011012Q00122Q00270012015Q002400270002001295002500E53Q00202Q00250025004500122Q00260017012Q00122Q00270018012Q00122Q00280019015Q002500286Q001F3Q00012Q00A9002000053Q0012D50021001A012Q00122Q0022001B012Q00122Q002300423Q00122Q0024001C012Q00122Q002500E53Q00202Q00250025004500122Q0026001D012Q00122Q0027001E012Q00122Q0028001F015Q002500280002001295002600E53Q00202Q00260026004500122Q00270020012Q00122Q0028007F3Q00122Q00290021015Q002600296Q00203Q00012Q00A9002100053Q0012D500220022012Q00122Q00230023012Q00122Q002400423Q00122Q00250024012Q00122Q002600E53Q00202Q00260026004500122Q00270025012Q00122Q002800623Q00122Q00290026015Q002600290002001295002700E53Q00202Q00270027004500122Q00280027012Q00122Q00290028012Q00122Q002A0029015Q0027002A6Q00213Q00012Q00A9002200053Q0012D50023002A012Q00122Q00240023012Q00122Q0025007C3Q00122Q0026002B012Q00122Q002700E53Q00202Q00270027004500122Q00280025012Q00122Q002900623Q00122Q002A0026015Q0027002A0002001295002800E53Q00202Q00280028004500122Q0029002C012Q00122Q002A002D012Q00122Q002B002E015Q0028002B6Q00223Q00012Q00A9002300053Q0012D50024002F012Q00122Q00250030012Q00122Q002600423Q00122Q00270031012Q00122Q002800E53Q00202Q00280028004500122Q00290032012Q00122Q002A00423Q00122Q002B0033015Q0028002B0002001295002900E53Q00202Q00290029004500122Q002A0034012Q00122Q002B00423Q00122Q002C0033015Q0029002C6Q00233Q00012Q00A9002400053Q0012D500250035012Q00122Q00260030012Q00122Q0027007C3Q00122Q00280036012Q00122Q002900E53Q00202Q00290029004500122Q002A0032012Q00122Q002B00423Q00122Q002C0033015Q0029002C0002001295002A00E53Q00202Q002A002A004500122Q002B0037012Q00122Q002C00423Q00122Q002D0038015Q002A002D6Q00243Q00012Q00A9002500053Q0012D500260039012Q00122Q0027003A012Q00122Q002800423Q00122Q0029003B012Q00122Q002A00E53Q00202Q002A002A004500122Q002B003C012Q00122Q002C006A3Q00122Q002D003D015Q002A002D0002001295002B00E53Q00202Q002B002B004500122Q002C003E012Q00122Q002D003F012Q00122Q002E0040015Q002B002E6Q00253Q00012Q00A9002600053Q0012D500270041012Q00122Q0028003A012Q00122Q0029007C3Q00122Q002A0042012Q00122Q002B00E53Q00202Q002B002B004500122Q002C003C012Q00122Q002D006A3Q00122Q002E003D015Q002B002E0002001295002C00E53Q00202Q002C002C004500122Q002D0043012Q00122Q002E006A3Q00122Q002F0044015Q002C002F6Q00263Q00012Q00A9002700053Q0012D500280045012Q00122Q00290046012Q00122Q002A00423Q00122Q002B0047012Q00122Q002C00E53Q00202Q002C002C004500122Q002D0048012Q00122Q002E004B3Q00122Q002F0049015Q002C002F0002001295002D00E53Q00202Q002D002D004500122Q002E004A012Q00122Q002F004B012Q00122Q0030004C015Q002D00306Q00273Q00012Q00A9002800053Q0012D50029004D012Q00122Q002A0046012Q00122Q002B007C3Q00122Q002C004E012Q00122Q002D00E53Q00202Q002D002D004500122Q002E0048012Q00122Q002F004B3Q00122Q00300049015Q002D00300002001295002E00E53Q00202Q002E002E004500122Q002F004F012Q00122Q003000993Q00122Q00310050015Q002E00316Q00283Q00012Q00A9002900053Q0012D5002A0051012Q00122Q002B0052012Q00122Q002C00423Q00122Q002D0053012Q00122Q002E00E53Q00202Q002E002E004500122Q002F0054012Q00122Q00300055012Q00122Q00310056015Q002E00310002001295002F00E53Q00202Q002F002F004500122Q003000713Q00122Q003100663Q00122Q00320057015Q002F00326Q00293Q00012Q00A9002A00053Q0012D5002B0058012Q00122Q002C0052012Q00122Q002D007C3Q00122Q002E0059012Q00122Q002F00E53Q00202Q002F002F004500122Q00300054012Q00122Q00310055012Q00122Q00320056015Q002F00320002001295003000E53Q00202Q00300030004500122Q0031005A012Q00122Q003200663Q00122Q0033005B015Q003000336Q002A3Q00012Q00A9002B00053Q0012D5002C005C012Q00122Q002D005D012Q00122Q002E00423Q00122Q002F005E012Q00122Q003000E53Q00202Q00300030004500122Q0031005F012Q00122Q00320060012Q00122Q00330061015Q003000330002001295003100E53Q00202Q00310031004500122Q00320062012Q00122Q00330063012Q00122Q00340064015Q003100346Q002B3Q00012Q00A9002C00053Q0012D5002D0065012Q00122Q002E005D012Q00122Q002F007C3Q00122Q00300066012Q00122Q003100E53Q00202Q00310031004500122Q0032005F012Q00122Q00330060012Q00122Q00340061015Q003100340002001295003200E53Q00202Q00320032004500122Q00330067012Q00122Q00340068012Q00122Q00350069015Q003200356Q002C3Q00012Q00A9002D00053Q0012D5002E006A012Q00122Q002F006B012Q00122Q003000423Q00122Q0031006C012Q00122Q003200E53Q00202Q00320032004500122Q0033006D012Q00122Q0034006E012Q00122Q0035006F015Q003200350002001295003300E53Q00202Q00330033004500122Q00340070012Q00122Q00350071012Q00122Q00360072015Q003300366Q002D3Q00012Q00A9002E00053Q0012D5002F0073012Q00122Q0030006B012Q00122Q0031007C3Q00122Q00320074012Q00122Q003300E53Q00202Q00330033004500122Q0034006D012Q00122Q0035006E012Q00122Q0036006F015Q003300360002001295003400E53Q00202Q00340034004500122Q00350075012Q00122Q00360076012Q00122Q00370077015Q003400376Q002E3Q00012Q00A9002F00053Q0012D500300078012Q00122Q00310079012Q00122Q003200423Q00122Q0033007A012Q00122Q003400E53Q00202Q00340034004500122Q0035007B012Q00122Q0036007C012Q00122Q0037007D015Q003400370002001295003500E53Q00202Q00350035004500122Q0036007E012Q00122Q0037004B012Q00122Q0038007F015Q003500386Q002F3Q00012Q00A9003000053Q0012D500310080012Q00122Q00320079012Q00122Q0033007C3Q00122Q00340081012Q00122Q003500E53Q00202Q00350035004500122Q0036007B012Q00122Q0037007C012Q00122Q0038007D015Q003500380002001295003600E53Q00202Q00360036004500122Q0037007E012Q00122Q0038004B012Q00122Q0039007F015Q003600396Q00303Q00012Q00A9003100053Q0012D500320082012Q00122Q00330083012Q00122Q003400423Q00122Q00350084012Q00122Q003600E53Q00202Q00360036004500122Q00370085012Q00122Q003800833Q00122Q00390086015Q003600390002001295003700E53Q00202Q00370037004500122Q00380087012Q00122Q00390088012Q00122Q003A0089015Q0037003A6Q00313Q00012Q00A9003200053Q0012D50033008A012Q00122Q00340083012Q00122Q0035007C3Q00122Q0036008B012Q00122Q003700E53Q00202Q00370037004500122Q00380085012Q00122Q003900833Q00122Q003A0086015Q0037003A0002001295003800E53Q00202Q00380038004500122Q0039008C012Q00122Q003A008D012Q00122Q003B008E015Q0038003B6Q00323Q00012Q00A9003300053Q0012D50034008F012Q00122Q00350090012Q00122Q003600423Q00122Q00370091012Q00122Q003800E53Q00202Q00380038004500122Q00390092012Q00122Q003A00833Q00122Q003B0093015Q0038003B0002001295003900E53Q00202Q00390039004500122Q003A0094012Q00122Q003B0095012Q00122Q003C0096015Q0039003C6Q00333Q00012Q00A9003400053Q0012D500350097012Q00122Q00360090012Q00122Q0037007C3Q00122Q00380098012Q00122Q003900E53Q00202Q00390039004500122Q003A0092012Q00122Q003B00833Q00122Q003C0093015Q0039003C0002001295003A00E53Q00202Q003A003A004500122Q003B0099012Q00122Q003C009A012Q00122Q003D00F06Q003A003D6Q00343Q00012Q00A9003500053Q0012D50036009B012Q00122Q0037009C012Q00122Q003800423Q00122Q0039009D012Q00122Q003A00E53Q00202Q003A003A004500122Q003B009E012Q00122Q003C00833Q00122Q003D009F015Q003A003D0002001295003B00E53Q00202Q003B003B004500122Q003C008A3Q00122Q003D00A0012Q00122Q003E00A1015Q003B003E6Q00353Q00012Q00A9003600053Q0012D5003700A2012Q00122Q0038009C012Q00122Q0039007C3Q00122Q003A00A3012Q00122Q003B00E53Q00202Q003B003B004500122Q003C009E012Q00122Q003D00833Q00122Q003E009F015Q003B003E0002001295003C00E53Q00202Q003C003C004500122Q003D00A4012Q00122Q003E00A0012Q00122Q003F00A5015Q003C003F6Q00363Q00012Q00A9003700053Q0012D5003800A6012Q00122Q003900A7012Q00122Q003A00423Q00122Q003B00A8012Q00122Q003C00E53Q00202Q003C003C004500122Q003D00A9012Q00122Q003E00AA012Q00122Q003F00AB015Q003C003F0002001295003D00E53Q00202Q003D003D004500122Q003E00AC012Q00122Q003F00AD012Q00122Q004000AE015Q003D00406Q00373Q00012Q00A9003800053Q0012D5003900AF012Q00122Q003A00A7012Q00122Q003B007C3Q00122Q003C00B0012Q00122Q003D00E53Q00202Q003D003D004500122Q003E00A9012Q00122Q003F00AA012Q00122Q004000AB015Q003D00400002001295003E00E53Q00202Q003E003E004500122Q003F00B1012Q00122Q004000663Q00122Q004100B2015Q003E00416Q00383Q00012Q00A9003900053Q0012D5003A00B3012Q00122Q003B00B4012Q00122Q003C00423Q00122Q003D00B5012Q00122Q003E00E53Q00202Q003E003E004500122Q003F00B6012Q00122Q004000913Q00122Q004100B7015Q003E00410002001295003F00E53Q00202Q003F003F004500122Q004000B8012Q00122Q004100B9012Q00122Q004200BA015Q003F00426Q00393Q00012Q00A9003A00053Q0012D5003B00BB012Q00122Q003C00B4012Q00122Q003D007C3Q00122Q003E00BC012Q00122Q003F00E53Q00202Q003F003F004500122Q004000B6012Q00122Q004100913Q00122Q004200B7015Q003F00420002001295004000E53Q00202Q00400040004500122Q004100BD012Q00122Q004200BE012Q00122Q004300BF015Q004000436Q003A3Q00012Q00A9003B00053Q0012D5003C00C0012Q00122Q003D00C1012Q00122Q003E00423Q00122Q003F00C2012Q00122Q004000E53Q00202Q00400040004500122Q004100C3012Q00122Q004200833Q00122Q004300C4015Q004000430002001295004100E53Q00202Q00410041004500122Q004200C5012Q00122Q004300C6012Q00122Q004400C7015Q004100446Q003B3Q00012Q00A9003C00053Q0012D5003D00C8012Q00122Q003E00C1012Q00122Q003F007C3Q00122Q004000C9012Q00122Q004100E53Q00202Q00410041004500122Q004200C3012Q00122Q004300833Q00122Q004400C4015Q004100440002001295004200E53Q00202Q00420042004500122Q004300CA012Q00122Q0044009D3Q00122Q004500CB015Q004200456Q003C3Q00012Q00A9003D00053Q0012D5003E00CC012Q00122Q003F00CD012Q00122Q004000423Q00122Q004100CE012Q00122Q004200E53Q00202Q00420042004500122Q004300CF012Q00122Q004400D0012Q00122Q004500D1015Q004200450002001295004300E53Q00202Q00430043004500122Q004400D2012Q00122Q004500D3012Q00122Q004600D4015Q004300466Q003D3Q00012Q00A9003E00053Q0012D5003F00D5012Q00122Q004000CD012Q00122Q0041007C3Q00122Q004200D6012Q00122Q004300E53Q00202Q00430043004500122Q004400CF012Q00122Q004500D0012Q00122Q004600D1015Q004300460002001295004400E53Q00202Q00440044004500122Q004500D7012Q00122Q004600D3012Q00122Q004700D8015Q004400476Q003E3Q00012Q00A9003F00053Q0012D5004000D9012Q00122Q004100DA012Q00122Q004200423Q00122Q004300DB012Q00122Q004400E53Q00202Q00440044004500122Q004500DC012Q00122Q004600DD012Q00122Q004700DE015Q004400470002001295004500E53Q00202Q00450045004500122Q004600DF012Q00122Q004700E0012Q00122Q004800E1015Q004500486Q003F3Q00012Q00A9004000053Q0012D5004100E2012Q00122Q004200DA012Q00122Q0043007C3Q00122Q004400E3012Q00122Q004500E53Q00202Q00450045004500122Q004600DC012Q00122Q004700DD012Q00122Q004800DE015Q004500480002001295004600E53Q00202Q00460046004500122Q004700E4012Q00122Q004800EE3Q00122Q004900E5015Q004600496Q00403Q00012Q00A9004100053Q0012D5004200E6012Q00122Q004300E7012Q00122Q004400423Q00122Q004500E8012Q00122Q004600E53Q00202Q00460046004500122Q004700E9012Q00122Q004800EA012Q00122Q004900EB015Q004600490002001295004700E53Q00202Q00470047004500122Q004800EC012Q00122Q004900ED012Q00122Q004A00EE015Q0047004A6Q00413Q00012Q00A9004200053Q0012D5004300EF012Q00122Q004400E7012Q00122Q0045007C3Q00122Q004600F0012Q00122Q004700E53Q00202Q00470047004500122Q004800E9012Q00122Q004900EA012Q00122Q004A00EB015Q0047004A0002001295004800E53Q00202Q00480048004500122Q004900F1012Q00122Q004A00F2012Q00122Q004B00F3015Q0048004B6Q00423Q00012Q00A9004300053Q0012D5004400F4012Q00122Q004500F5012Q00122Q004600423Q00122Q004700F6012Q00122Q004800E53Q00202Q00480048004500122Q004900F7012Q00122Q004A009D3Q00122Q004B00F8015Q0048004B0002001295004900E53Q00202Q00490049004500122Q004A00F9012Q00122Q004B009D3Q00122Q004C00FA015Q0049004C6Q00433Q00012Q00A9004400053Q0012D5004500FB012Q00122Q004600F5012Q00122Q0047007C3Q00122Q004800FC012Q00122Q004900E53Q00202Q00490049004500122Q004A00F7012Q00122Q004B009D3Q00122Q004C00F8015Q0049004C0002001295004A00E53Q00202Q004A004A004500122Q004B0037012Q00122Q004C00873Q00122Q004D00FD015Q004A004D6Q00443Q00012Q00A9004500053Q0012D5004600FE012Q00122Q004700FF012Q00122Q004800423Q00122Q00492Q00022Q00122Q004A00E53Q00202Q004A004A004500122Q004B0001022Q00122Q004C002Q022Q00122Q004D0003025Q004A004D0002001295004B00E53Q00202Q004B004B004500122Q004C0004022Q00122Q004D00A13Q00122Q004E0005025Q004B004E6Q00453Q00012Q00A9004600053Q0012D500470006022Q00122Q004800FF012Q00122Q0049007C3Q00122Q004A0007022Q00122Q004B00E53Q00202Q004B004B004500122Q004C0001022Q00122Q004D002Q022Q00122Q004E0003025Q004B004E0002001295004C00E53Q00202Q004C004C004500122Q004D0008022Q00122Q004E00A13Q00122Q004F0009025Q004C004F6Q00463Q00012Q00A9004700053Q0012D50048000A022Q00122Q0049000B022Q00122Q004A00423Q00122Q004B000C022Q00122Q004C00E53Q00202Q004C004C004500122Q004D000D022Q00122Q004E000E022Q00122Q004F000F025Q004C004F0002001295004D00E53Q00202Q004D004D004500122Q004E0010022Q00122Q004F003F012Q00122Q00500011025Q004D00506Q00473Q00012Q00A9004800053Q0012D500490012022Q00122Q004A000B022Q00122Q004B007C3Q00122Q004C0013022Q00122Q004D00E53Q00202Q004D004D004500122Q004E000D022Q00122Q004F000E022Q00122Q0050000F025Q004D00500002001295004E00E53Q00202Q004E004E004500122Q004F0014022Q00122Q00500002012Q00122Q00510015025Q004E00516Q00483Q00012Q00710016003200012Q00A9001700053Q0012D500180016022Q00122Q00190017022Q00122Q001A00423Q00122Q001B0018022Q00122Q001C00E53Q00202Q001C001C004500122Q001D0019022Q00122Q001E001A022Q00122Q001F001B025Q001C001F0002001295001D00E53Q00202Q001D001D004500122Q001E001C022Q00122Q001F001D022Q00122Q0020001E025Q001D00206Q00173Q00012Q00A9001800053Q0012D50019001F022Q00122Q001A0017022Q00122Q001B007C3Q00122Q001C0020022Q00122Q001D00E53Q00202Q001D001D004500122Q001E0019022Q00122Q001F001A022Q00122Q0020001B025Q001D00200002001295001E00E53Q00202Q001E001E004500122Q001F0021022Q00122Q00200022022Q00122Q002100EA015Q001E00216Q00183Q00012Q00A9001900053Q0012D5001A0023022Q00122Q001B0024022Q00122Q001C00423Q00122Q001D0025022Q00122Q001E00E53Q00202Q001E001E004500122Q001F0026022Q00122Q00200027022Q00122Q00210028025Q001E00210002001295001F00E53Q00202Q001F001F004500122Q00200029022Q00122Q0021002A022Q00122Q0022002B025Q001F00226Q00193Q00012Q00A9001A00053Q0012D5001B002C022Q00122Q001C0024022Q00122Q001D007C3Q00122Q001E002D022Q00122Q001F00E53Q00202Q001F001F004500122Q00200026022Q00122Q00210027022Q00122Q00220028025Q001F00220002001295002000E53Q00202Q00200020004500122Q0021002E022Q00122Q0022002F022Q00122Q00230030025Q002000236Q001A3Q00012Q00A9001B00053Q0012D5001C0031022Q00122Q001D0032022Q00122Q001E00423Q00122Q001F0033022Q00122Q002000E53Q00202Q00200020004500122Q00210034022Q00122Q00220035022Q00122Q00230036025Q002000230002001295002100E53Q00202Q00210021004500122Q00220037022Q00122Q00230038022Q00122Q00240039025Q002100246Q001B3Q00012Q00A9001C00053Q0012D5001D003A022Q00122Q001E0032022Q00122Q001F007C3Q00122Q0020003B022Q00122Q002100E53Q00202Q00210021004500122Q00220034022Q00122Q00230035022Q00122Q00240036025Q002100240002001295002200E53Q00202Q00220022004500122Q0023003C022Q00122Q0024003D022Q00122Q0025003E025Q002200256Q001C3Q00012Q00A9001D00053Q0012D5001E003F022Q00122Q001F0040022Q00122Q002000423Q00122Q00210041022Q00122Q002200E53Q00202Q00220022004500122Q00230042022Q00122Q00240043022Q00122Q00250044025Q002200250002001295002300E53Q00202Q00230023004500122Q00240045022Q00122Q00250043022Q00122Q00260046025Q002300266Q001D3Q00012Q00A9001E00053Q0012D5001F0047022Q00122Q00200040022Q00122Q0021007C3Q00122Q00220048022Q00122Q002300E53Q00202Q00230023004500122Q00240042022Q00122Q00250043022Q00122Q00260044025Q002300260002001295002400E53Q00202Q00240024004500122Q00250049022Q00122Q00260043022Q00122Q0027004A025Q002400276Q001E3Q00012Q00A9001F00053Q0012D50020004B022Q00122Q0021004C022Q00122Q002200423Q00122Q0023004D022Q00122Q002400E53Q00202Q00240024004500122Q0025004E022Q00122Q00260043022Q00122Q0027004F025Q002400270002001295002500E53Q00202Q00250025004500122Q00260050022Q00122Q00270051022Q00122Q00280052025Q002500286Q001F3Q00012Q00A9002000053Q0012D500210053022Q00122Q0022004C022Q00122Q0023007C3Q00122Q00240054022Q00122Q002500E53Q00202Q00250025004500122Q0026004E022Q00122Q00270043022Q00122Q0028004F025Q002500280002001295002600E53Q00202Q00260026004500122Q00270055022Q00122Q00280056022Q00122Q00290057025Q002600296Q00203Q00012Q00A9002100053Q0012D500220058022Q00122Q00230059022Q00122Q002400423Q00122Q0025005A022Q00122Q002600E53Q00202Q00260026004500122Q0027005B022Q00122Q0028005C022Q00122Q0029005D025Q002600290002001295002700E53Q00202Q00270027004500122Q0028005E022Q00122Q002900A83Q00122Q002A005F025Q0027002A6Q00213Q00012Q00A9002200053Q0012D500230060022Q00122Q00240059022Q00122Q0025007C3Q00122Q00260061022Q00122Q002700E53Q00202Q00270027004500122Q0028005B022Q00122Q0029005C022Q00122Q002A005D025Q0027002A0002001295002800E53Q00202Q00280028004500122Q00290062022Q00122Q002A00B9012Q00122Q002B0063025Q0028002B6Q00223Q00012Q00A9002300053Q0012D500240064022Q00122Q00250065022Q00122Q002600423Q00122Q00270066022Q00122Q002800E53Q00202Q00280028004500122Q00290067022Q00122Q002A00C03Q00122Q002B0068025Q0028002B0002001295002900E53Q00202Q00290029004500122Q002A0069022Q00122Q002B006A022Q00122Q002C006B025Q0029002C6Q00233Q00012Q00A9002400053Q0012D50025006C022Q00122Q00260065022Q00122Q0027007C3Q00122Q0028006D022Q00122Q002900E53Q00202Q00290029004500122Q002A0067022Q00122Q002B00C03Q00122Q002C0068025Q0029002C0002001295002A00E53Q00202Q002A002A004500122Q002B006E022Q00122Q002C006A022Q00122Q002D006F025Q002A002D6Q00243Q00012Q00A9002500053Q0012D500260070022Q00122Q00270071022Q00122Q002800423Q00122Q00290072022Q00122Q002A00E53Q00202Q002A002A004500122Q002B0073022Q00122Q002C0074022Q00122Q002D0075025Q002A002D0002001295002B00E53Q00202Q002B002B004500122Q002C0076022Q00122Q002D0077022Q00122Q002E0078025Q002B002E6Q00253Q00012Q00A9002600053Q0012D500270079022Q00122Q00280071022Q00122Q0029007C3Q00122Q002A007A022Q00122Q002B00E53Q00202Q002B002B004500122Q002C0073022Q00122Q002D0074022Q00122Q002E0075025Q002B002E0002001295002C00E53Q00202Q002C002C004500122Q002D007B022Q00122Q002E00AA3Q00122Q002F007C025Q002C002F6Q00263Q00012Q00A9002700053Q0012D50028007D022Q00122Q0029007E022Q00122Q002A00423Q00122Q002B007F022Q00122Q002C00E53Q00202Q002C002C004500122Q002D0080022Q00122Q002E007C012Q00122Q002F0081025Q002C002F0002001295002D00E53Q00202Q002D002D004500122Q002E0082022Q00122Q002F00FC3Q00122Q00300083025Q002D00306Q00273Q00012Q00A9002800053Q0012D500290084022Q00122Q002A007E022Q00122Q002B007C3Q00122Q002C0085022Q00122Q002D00E53Q00202Q002D002D004500122Q002E0080022Q00122Q002F007C012Q00122Q00300081025Q002D00300002001295002E00E53Q00202Q002E002E004500122Q002F0086022Q00122Q0030007C012Q00122Q00310087025Q002E00316Q00283Q00012Q00A9002900053Q0012D5002A0088022Q00122Q002B0089022Q00122Q002C00423Q00122Q002D008A022Q00122Q002E00E53Q00202Q002E002E004500122Q002F008B022Q00122Q0030008C022Q00122Q0031008D025Q002E00310002001295002F00E53Q00202Q002F002F004500122Q0030008E022Q00122Q0031008F022Q00122Q00320090025Q002F00326Q00293Q00012Q00A9002A00053Q0012D5002B0091022Q00122Q002C0089022Q00122Q002D007C3Q00122Q002E0092022Q00122Q002F00E53Q00202Q002F002F004500122Q0030008B022Q00122Q0031008C022Q00122Q0032008D025Q002F00320002001295003000E53Q00202Q00300030004500122Q00310093022Q00122Q0032008C022Q00122Q00330094025Q003000336Q002A3Q00012Q00A9002B00053Q0012D5002C0095022Q00122Q002D0096022Q00122Q002E00423Q00122Q002F0097022Q00122Q003000E53Q00202Q00300030004500122Q00310098022Q00122Q003200FC3Q00122Q00330099025Q003000330002001295003100E53Q00202Q00310031004500122Q0032009A022Q00122Q003300FC3Q00122Q0034009B025Q003100346Q002B3Q00012Q00A9002C00053Q0012D5002D009C022Q00122Q002E0096022Q00122Q002F007C3Q00122Q0030009D022Q00122Q003100E53Q00202Q00310031004500122Q00320098022Q00122Q003300FC3Q00122Q00340099025Q003100340002001295003200E53Q00202Q00320032004500122Q0033009E022Q00122Q003400FC3Q00122Q0035009F025Q003200356Q002C3Q00012Q00A9002D00053Q0012D5002E00A0022Q00122Q002F00A1022Q00122Q003000423Q00122Q003100A2022Q00122Q003200E53Q00202Q00320032004500122Q003300A3022Q00122Q003400FC3Q00122Q003500A4025Q003200350002001295003300E53Q00202Q00330033004500122Q003400A5022Q00122Q0035007C012Q00122Q003600A6025Q003300366Q002D3Q00012Q00A9002E00053Q0012D5002F00A7022Q00122Q003000A1022Q00122Q0031007C3Q00122Q003200A8022Q00122Q003300E53Q00202Q00330033004500122Q003400A3022Q00122Q003500FC3Q00122Q003600A4025Q003300360002001295003400E53Q00202Q00340034004500122Q003500A9022Q00122Q0036007C012Q00122Q003700AA025Q003400376Q002E3Q00012Q00A9002F00053Q0012D5003000AB022Q00122Q003100AC022Q00122Q003200423Q00122Q003300AD022Q00122Q003400E53Q00202Q00340034004500122Q003500AE022Q00122Q003600C6012Q00122Q003700AF025Q003400370002001295003500E53Q00202Q00350035004500122Q003600B0022Q00122Q003700C6012Q00122Q003800B1025Q003500386Q002F3Q00012Q00A9003000053Q0012D5003100B2022Q00122Q003200AC022Q00122Q0033007C3Q00122Q003400B3022Q00122Q003500E53Q00202Q00350035004500122Q003600AE022Q00122Q003700C6012Q00122Q003800AF025Q003500380002001295003600E53Q00202Q00360036004500122Q003700B4022Q00122Q003800C6012Q00122Q003900B5025Q003600396Q00303Q00012Q00A9003100053Q0012D5003200B6022Q00122Q003300B7022Q00122Q003400423Q00122Q003500B8022Q00122Q003600E53Q00202Q00360036004500122Q003700B9022Q00122Q003800C6012Q00122Q003900BA025Q003600390002001295003700E53Q00202Q00370037004500122Q00380011012Q00122Q003900C6012Q00122Q003A00BB025Q0037003A6Q00313Q00012Q00A9003200053Q0012D5003300BC022Q00122Q003400B7022Q00122Q0035007C3Q00122Q003600BD022Q00122Q003700E53Q00202Q00370037004500122Q003800B9022Q00122Q003900C6012Q00122Q003A00BA025Q0037003A0002001295003800E53Q00202Q00380038004500122Q003900BE022Q00122Q003A00C6012Q00122Q003B00BF025Q0038003B6Q00323Q00012Q00A9003300053Q0012D5003400C0022Q00122Q003500C1022Q00122Q003600423Q00122Q003700C2022Q00122Q003800E53Q00202Q00380038004500122Q003900C73Q00122Q003A00C83Q00122Q003B00C96Q0038003B0002001295003900E53Q00202Q00390039004500122Q003A00C3022Q00122Q003B004B3Q00122Q003C00C4025Q0039003C6Q00333Q00012Q00A9003400053Q0012D5003500C5022Q00122Q003600C1022Q00122Q0037007C3Q00122Q003800C6022Q00122Q003900E53Q00202Q00390039004500122Q003A00C73Q00122Q003B00C83Q00122Q003C00C96Q0039003C0002001295003A00E53Q00202Q003A003A004500122Q003B00C7022Q00122Q003C00C83Q00122Q003D00C8025Q003A003D6Q00343Q00012Q00A9003500053Q0012D5003600C9022Q00122Q003700CA022Q00122Q003800423Q00122Q003900CB022Q00122Q003A00E53Q00202Q003A003A004500122Q003B00CC022Q00122Q003C001A022Q00122Q003D0022025Q003A003D0002001295003B00E53Q00202Q003B003B004500122Q003C0094022Q00122Q003D005A3Q00122Q003E00CD025Q003B003E6Q00353Q00012Q00A9003600053Q0012D500370037022Q00122Q003800CA022Q00122Q0039007C3Q00122Q003A00CE022Q00122Q003B00E53Q00202Q003B003B004500122Q003C00CC022Q00122Q003D001A022Q00122Q003E0022025Q003B003E0002001295003C00E53Q00202Q003C003C004500122Q003D00CF022Q00122Q003E00D0022Q00122Q003F00D1025Q003C003F6Q00363Q00012Q00AC0016003600022Q00A9001700154Q00D7001800043Q00122Q001900723Q00122Q001A00EA3Q00122Q001B00AA3Q00122Q001C00D2022Q00122Q001D00E53Q00202Q001D001D004500122Q001E00EC3Q00122Q001F00ED3Q00122Q002000EE4Q001B001D00204Q000900183Q00012Q00A9001900043Q001236011A00D3022Q00122Q001B00F73Q00122Q001C00AA3Q00122Q001D00D4022Q00122Q001E00E53Q00202Q001E001E004500122Q001F00F93Q00122Q0020004F3Q00122Q002100FA6Q001E00214Q000900193Q00012Q00A9001A00043Q001236011B00D5022Q00122Q001C000E012Q00122Q001D00AA3Q00122Q001E00D6022Q00122Q001F00E53Q00202Q001F001F004500122Q00200010012Q00122Q00210011012Q00122Q00220012015Q001F00224Q0009001A3Q00012Q00A9001B00043Q001236011C00D7022Q00122Q001D001B012Q00122Q001E007C3Q00122Q001F00D8022Q00122Q002000E53Q00202Q00200020004500122Q0021001D012Q00122Q0022001E012Q00122Q0023001F015Q002000234Q0009001B3Q00012Q00A9001C00043Q001236011D00D9022Q00122Q001E0030012Q00122Q001F007C3Q00122Q002000DA022Q00122Q002100E53Q00202Q00210021004500122Q00220032012Q00122Q002300423Q00122Q00240033015Q002100244Q0009001C3Q00012Q00A9001D00043Q001236011E00DB022Q00122Q001F0030012Q00122Q002000AA3Q00122Q002100DC022Q00122Q002200E53Q00202Q00220022004500122Q00230032012Q00122Q002400423Q00122Q00250033015Q002200254Q0009001D3Q00012Q00A9001E00043Q001236011F00DD022Q00122Q00200030012Q00122Q0021004F3Q00122Q002200DE022Q00122Q002300E53Q00202Q00230023004500122Q00240032012Q00122Q002500423Q00122Q00260033015Q002300264Q0009001E3Q00012Q00A9001F00043Q001236012000DF022Q00122Q00210046012Q00122Q0022007C3Q00122Q002300E0022Q00122Q002400E53Q00202Q00240024004500122Q00250048012Q00122Q0026004B3Q00122Q00270049015Q002400274Q0009001F3Q00012Q00A9002000043Q001236012100E1022Q00122Q00220052012Q00122Q002300AA3Q00122Q002400E2022Q00122Q002500E53Q00202Q00250025004500122Q00260054012Q00122Q00270055012Q00122Q00280056015Q002500284Q000900203Q00012Q00A9002100043Q001236012200E3022Q00122Q0023005D012Q00122Q0024007C3Q00122Q002500E4022Q00122Q002600E53Q00202Q00260026004500122Q0027005F012Q00122Q00280060012Q00122Q00290061015Q002600294Q000900213Q00012Q00A9002200043Q001236012300E5022Q00122Q0024006B012Q00122Q0025007C3Q00122Q002600E6022Q00122Q002700E53Q00202Q00270027004500122Q0028006D012Q00122Q0029006E012Q00122Q002A006F015Q0027002A4Q000900223Q00012Q00A9002300043Q001236012400E7022Q00122Q002500E8022Q00122Q002600423Q00122Q002700E9022Q00122Q002800E53Q00202Q00280028004500122Q0029007B012Q00122Q002A007C012Q00122Q002B007D015Q0028002B4Q000900233Q00012Q00A9002400043Q001236012500E7022Q00122Q00260083012Q00122Q002700AA3Q00122Q002800EA022Q00122Q002900E53Q00202Q00290029004500122Q002A0085012Q00122Q002B00833Q00122Q002C0086015Q0029002C4Q000900243Q00012Q00A9002500043Q001236012600EB022Q00122Q00270090012Q00122Q002800AA3Q00122Q002900EC022Q00122Q002A00E53Q00202Q002A002A004500122Q002B0092012Q00122Q002C00833Q00122Q002D0093015Q002A002D4Q000900253Q00012Q00A9002600043Q001236012700ED022Q00122Q0028009C012Q00122Q002900AA3Q00122Q002A00EE022Q00122Q002B00E53Q00202Q002B002B004500122Q002C009E012Q00122Q002D00833Q00122Q002E009F015Q002B002E4Q000900263Q00012Q00A9002700043Q001236012800EF022Q00122Q002900F0022Q00122Q002A00AA3Q00122Q002B00F1022Q00122Q002C00E53Q00202Q002C002C004500122Q002D00F2022Q00122Q002E00473Q00122Q002F00F3025Q002C002F4Q000900273Q00012Q00A9002800043Q001236012900EF012Q00122Q002A00DA012Q00122Q002B007C3Q00122Q002C00F4022Q00122Q002D00E53Q00202Q002D002D004500122Q002E00DC012Q00122Q002F00DD012Q00122Q003000DE015Q002D00304Q000900283Q00012Q00A9002900043Q001236012A00F5022Q00122Q002B00C1012Q00122Q002C007C3Q00122Q002D00F6022Q00122Q002E00E53Q00202Q002E002E004500122Q002F00F7012Q00122Q0030009D3Q00122Q003100F8015Q002E00314Q000900293Q00012Q00A9002A00043Q001236012B00F7022Q00122Q002C00FF012Q00122Q002D007C3Q00122Q002E00F8022Q00122Q002F00E53Q00202Q002F002F004500122Q00300001022Q00122Q0031002Q022Q00122Q00320003025Q002F00324Q0009002A3Q00012Q00A9002B00043Q001236012C00F9022Q00122Q002D000B022Q00122Q002E00AA3Q00122Q002F00FA022Q00122Q003000E53Q00202Q00300030004500122Q003100FB022Q00122Q003200FC022Q00122Q003300FD025Q003000334Q0009002B3Q00012Q00A9002C00043Q001236012D00FE022Q00122Q002E0017022Q00122Q002F00AA3Q00122Q003000FF022Q00122Q003100E53Q00202Q00310031004500122Q00320019022Q00122Q0033001A022Q00122Q0034001B025Q003100344Q0009002C3Q00012Q00A9002D00043Q001236012E2Q00032Q00122Q002F0032022Q00122Q003000AA3Q00122Q00310001032Q00122Q003200E53Q00202Q00320032004500122Q00330002032Q00122Q0034001E012Q00122Q0035002Q035Q003200354Q0009002D3Q00012Q00A9002E00043Q001236012F0004032Q00122Q00300040022Q00122Q003100AA3Q00122Q00320005032Q00122Q003300E53Q00202Q00330033004500122Q00340042022Q00122Q00350043022Q00122Q00360044025Q003300364Q0009002E3Q00012Q00A9002F00043Q00123601300006032Q00122Q00310059022Q00122Q003200AA3Q00122Q00330007032Q00122Q003400E53Q00202Q00340034004500122Q0035005B022Q00122Q0036005C022Q00122Q0037005D025Q003400374Q0009002F3Q00012Q00A9003000043Q00123601310008032Q00122Q0032007E022Q00122Q003300AA3Q00122Q00340009032Q00122Q003500E53Q00202Q00350035004500122Q00360080022Q00122Q0037007C012Q00122Q00380081025Q003500384Q000900303Q00012Q00710017001900012Q003901185Q001234001900E53Q00202Q00190019004500122Q001A000A032Q00122Q001B000B032Q00122Q001C000C035Q0019001C00024Q001A001A6Q001B5Q00122Q001C000D032Q00122Q001D000E032Q0012A8001E000F032Q001203011F0010032Q00202Q001F001F004500122Q00200011035Q001F0002000200122Q00200012032Q00122Q002100443Q00202Q00210021004500122Q00220013032Q00122Q00230013032Q00122Q00240013033Q00CA0021002400022Q00D8001F0020002100122Q00200014032Q00122Q002100443Q00202Q00210021004500122Q002200E23Q00122Q002300E23Q00122Q002400E26Q0021002400024Q001F0020002100122Q00200015032Q0012A800210016033Q0027001F0020002100122Q00200010032Q00202Q00200020004500122Q00210017035Q00200002000200122Q00210018032Q00122Q002200443Q00202Q00220022004500122Q00230013032Q00122Q00240013032Q0012A800250013033Q00CA0022002500022Q00D800200021002200122Q00210019032Q00122Q002200443Q00202Q00220022004500122Q002300E23Q00122Q002400E23Q00122Q002500E26Q0022002500024Q00200021002200122Q00210015032Q0012A80022001A033Q00BC00200021002200062400213Q000100052Q0007012Q000B4Q0007012Q001C4Q0007012Q001D4Q0007012Q001E4Q0007012Q00093Q00062400220001000100022Q0007012Q00064Q0007016Q00062400230002000100012Q0007012Q00063Q00020D012400033Q00062400250004000100012Q0007012Q00063Q00062400260005000100012Q0007012Q00063Q00062400270006000100012Q0007012Q00063Q00123E0128001B035Q00280006002800122Q002A001C035Q00280028002A4Q002A00276Q0028002A000100122Q0028001D035Q00280006002800062Q002800DD08013Q0004533Q00DD080100123B0128001E032Q0012A80029001F033Q00610128002800292Q0007012900274Q003B00280002000100062400280007000100042Q0007012Q00234Q0007012Q00064Q0007012Q00084Q0007012Q00103Q00062400290008000100022Q0007012Q00064Q0007012Q00173Q00123B012A00023Q002005012A002A00310012A8002C0020033Q00CA002A002C0002000624002B0009000100012Q0007012Q00103Q000624002C000A000100032Q0007012Q00044Q0007012Q00064Q0007016Q000624002D000B000100022Q0007012Q00064Q0007012Q00103Q000624002E000C000100012Q0007012Q00063Q000624002F000D000100012Q0007012Q00063Q0006240030000E000100062Q0007012Q002E4Q0007012Q00064Q0007017Q0007012Q00134Q0007012Q00084Q0007012Q00103Q00020D0131000F3Q00062400320010000100022Q0007012Q00064Q0007012Q001A3Q00062400330011000100032Q0007012Q001F4Q0007012Q00204Q0007012Q00063Q00062400340012000100022Q0007012Q00064Q0007012Q001B3Q00062400350013000100022Q0007012Q00094Q0007012Q000A3Q00126400360021035Q0036000100024Q00373Q000100122Q00380022032Q00122Q00390002015Q00370038003900102Q0036002E00374Q00363Q000300122Q00370023032Q00122Q003800E24Q00BC0036003700380012A800370024032Q0012A8003800E24Q00BC0036003700380012A800370025032Q0012A8003800E24Q00BC00360037003800123B01370026032Q00062400380014000100022Q0007012Q00064Q0007012Q00364Q003B0037000200010012A800370027032Q00062400380015000100042Q0007012Q00064Q0007012Q00094Q0007012Q000D4Q0007012Q000E4Q004100360037003800202Q00370003001A00122Q00390028035Q0037003700394Q00393Q000200122Q003A0029032Q00102Q00390007003A00122Q003A002A032Q00122Q003B002B035Q0039003A003B2Q006E00370039000100203500370003001A00122Q0039002C035Q00370037003900122Q0039002D035Q003A3Q000200122Q003B002E032Q00102Q003A0007003B00122Q003B002F035Q003C8Q003A003B003C2Q00CA0037003A00020012A8003A0030033Q007500380037003A000624003A0016000100042Q0007012Q00044Q0007012Q00064Q0007012Q00334Q0007012Q00324Q006D0038003A000100202Q00380003001A00122Q003A0028035Q00380038003A4Q003A3Q000200122Q003B0031032Q00102Q003A0007003B00122Q003B002A032Q00122Q003C0032035Q003A003B003C4Q0038003A000100202Q00380003001A00122Q003A002C035Q00380038003A00122Q003A0033035Q003B3Q000200122Q003C0033032Q00102Q003B0007003C00122Q003C002F035Q003D8Q003B003C003D4Q0038003B000200202Q00390003001A00122Q003B0028035Q00390039003B4Q003B3Q000200122Q003C0034032Q00102Q003B0007003C00122Q003C002A032Q00122Q003D0035035Q003B003C003D4Q0039003B000100202Q00390003001A00122Q003B002C035Q00390039003B00122Q003B0036035Q003C3Q000200122Q003D0037032Q00102Q003C0007003D00122Q003D002F035Q003E8Q003C003D003E4Q0039003C000200202Q003A0003001A00122Q003C0028035Q003A003A003C4Q003C3Q000200122Q003D0038032Q00102Q003C0007003D00122Q003D002A032Q00122Q003E0039035Q003C003D003E4Q003A003C000100202Q003A0003001A00122Q003C003A035Q003A003A003C00122Q003C003B035Q003D3Q000400122Q003E003C032Q00102Q003D0007003E00122Q003E003D035Q003F00053Q00122Q0040003E032Q00122Q0041003F032Q00122Q00420040032Q00122Q00430041032Q00122Q00440042035Q003F000500012Q00BC003D003E003F00122D003E0043035Q003F8Q003D003E003F00122Q003E002F032Q00122Q003F003E035Q003D003E003F4Q003A003D000200202Q003B0003001A00122Q003D002C035Q003B003B003D0012A8003D0044033Q00A9003E3Q00020012A8003F0045032Q00105B013E0007003F0012A8003F002F033Q003901406Q00BC003E003F00402Q00CA003B003E0002002035013C0003001A0012A8003E003A033Q0075003C003C003E0012A8003E0046033Q0070013F3Q000500122Q00400047032Q00102Q003F0007004000122Q00400048032Q00122Q00410049035Q003F0040004100122Q0040003D035Q004100266Q0041000100024Q003F004000410012A80040002F033Q00FC004100414Q00BC003F004000410012A80040004A032Q00020D014100174Q0014003F004000414Q003C003F000200202Q003D0003001A00122Q003F004B035Q003D003D003F4Q003F3Q000300122Q0040004C032Q00102Q003F0007004000122Q00400048032Q00122Q0041004D033Q00BC003F004000410012A80040004A032Q00062400410018000100022Q0007012Q003C4Q0007012Q00264Q00BC003F004000412Q006E003D003F00010012A8003F0030033Q0075003D003B003F000624003F0019000100022Q0007017Q0007012Q00044Q006E003D003F000100123B013D001E032Q0012A8003E001F033Q0061013D003D003E000624003E001A000100012Q0007012Q002C4Q003B003D000200010012A8003F0030033Q0075003D0039003F000624003F001B000100052Q0007012Q00114Q0007012Q00124Q0007012Q00044Q0007017Q0007012Q00324Q0023013D003F000100202Q003D0003001F00122Q003F0028035Q003D003D003F4Q003F3Q000200302Q003F0007002000122Q0040002A032Q00122Q0041004E035Q003F004000414Q003D003F0001002035003D0003001F00122Q003F002C035Q003D003D003F00122Q003F004F035Q00403Q000200122Q00410050032Q00102Q00400007004100122Q0041002F035Q00428Q0040004100422Q00CA003D004000020012A800400030033Q0075003E003D00400006240040001C000100032Q0007012Q00044Q0007012Q00314Q0007012Q00324Q00C5003E0040000100202Q003E0003001F00122Q00400051035Q003E003E004000122Q00400052035Q00413Q000700122Q00420053032Q00102Q00410007004200122Q00420048032Q00122Q00430054033Q00BC0041004200430012A80042002F032Q0012A800430045013Q00BC0041004200430012A800420055032Q0012A800430015013Q00BC0041004200430012A800420056032Q0012A8004300B3013Q00BC0041004200430012A800420057032Q0012A8004300E24Q00BC0041004200430012A80042004A032Q00020D0143001D4Q004E0141004200434Q003E0041000100202Q003E0003002500122Q00400028035Q003E003E00404Q00403Q000200122Q00410058032Q00102Q00400007004100122Q0041002A032Q00122Q00420059033Q00BC0040004100422Q006E003E00400001002035003E0003002500122Q0040002C035Q003E003E004000122Q0040005A035Q00413Q000200122Q0042005B032Q00102Q00410007004200122Q0042002F035Q00438Q0041004200432Q00CA003E004100020012A800410030033Q0075003F003E00410006240041001E000100062Q0007012Q00044Q0007012Q001B4Q0007012Q00314Q0007012Q00064Q0007012Q00334Q0007012Q00324Q0023013F0041000100202Q003F0003002200122Q00410028035Q003F003F00414Q00413Q000200302Q00410007002300122Q0042002A032Q00122Q0043005C035Q0041004200434Q003F00410001002035003F0003002200122Q0041002C035Q003F003F004100122Q0041005D035Q00423Q000200122Q0043005E032Q00102Q00420007004300122Q0043002F035Q00448Q0042004300442Q00CA003F004200020012A800420030033Q00750040003F00420006240042001F000100072Q0007012Q00044Q0007012Q00214Q0007017Q0007012Q00314Q0007012Q00064Q0007012Q00334Q0007012Q00324Q007400400042000100202Q00400003002200122Q00420028035Q0040004000424Q00423Q000200122Q0043005F032Q00102Q00420007004300122Q0043002A032Q00122Q00440060035Q0042004300442Q006E00400042000100203500400003002200122Q0042002C035Q00400040004200122Q00420061035Q00433Q000200122Q00440062032Q00102Q00430007004400122Q0044002F035Q00458Q0043004400452Q00CA0040004300020012A800430030033Q007500410040004300062400430020000100052Q0007012Q00044Q0007012Q00214Q0007017Q0007012Q00314Q0007012Q00324Q007400410043000100202Q00410003002B00122Q00430028035Q0041004100434Q00433Q000200122Q00440063032Q00102Q00430007004400122Q0044002A032Q00122Q00450064035Q0043004400452Q007400410043000100202Q00410003002B00122Q0043004B035Q0041004100434Q00433Q000300122Q00440065032Q00102Q00430007004400122Q00440048032Q00122Q00450066035Q0043004400450012A80044004A032Q00062400450021000100012Q0007017Q004E0143004400454Q00410043000100202Q00410003002B00122Q00430028035Q0041004100434Q00433Q000200122Q00440067032Q00102Q00430007004400122Q0044002A032Q00122Q00450068033Q00BC0043004400452Q006E00410043000100203501410003002B0012A80043004B033Q00750041004100432Q00A900433Q00020012A800440069032Q00105B0143000700440012A80044004A032Q00062400450022000100032Q0007017Q0007012Q00154Q0007012Q000F4Q00A30043004400454Q0041004300014Q004100216Q0041000100024Q00420014004100062Q0042009B0A0100010004533Q009B0A010012A8004200424Q00610142001400422Q00A900435Q00123B0144006A033Q0007014500424Q00160044000200460004533Q00A60A0100123B0149006B032Q0012A8004A006C033Q006101490049004A2Q0007014A00434Q0007014B00474Q006E0049004B0001000697004400A00A0100020004533Q00A00A0100123B0144006B032Q00123C0145006D035Q0044004400454Q004500436Q00440002000100202Q00440003002800122Q00460028035Q0044004400464Q00463Q000200122Q0047006E035Q004800414Q00C400470047004800105B0146000700470012A80047002A032Q0012A80048006F033Q00BC0046004700482Q006E0044004600010020350144000300280012A80046003A033Q00750044004400460012A800460070033Q00A900473Q00050012A800480071032Q00108100470007004800122Q0048003D035Q00470048004300122Q00480043035Q00498Q00470048004900122Q0048002F035Q004900496Q00470048004900122Q0048004A032Q00062400490023000100072Q0007012Q00424Q0007012Q001A4Q0007012Q00064Q0007012Q00044Q0007012Q00334Q0007012Q00084Q0007017Q00BC0047004800492Q006E0044004700010020350144000300280012A80046004B033Q00750044004400462Q00A900463Q00020012A800470072032Q00105B0146000700470012A80047004A032Q00062400480024000100022Q0007012Q00324Q0007017Q004E0146004700484Q00440046000100202Q00440003002E00122Q0046004B035Q0044004400464Q00463Q000300122Q00470073032Q00102Q00460007004700122Q00470048032Q00122Q00480074033Q00BC0046004700480012A80047004A032Q00062400480025000100022Q0007012Q00354Q0007017Q00AE0046004700484Q00440046000100122Q0044001E032Q00122Q0045001F035Q00440044004500062400450026000100062Q0007012Q00044Q0007012Q00064Q0007012Q00334Q0007012Q00184Q0007012Q00084Q0007017Q003B0044000200012Q003901445Q00123B0145001E032Q0012A80046001F033Q006101450045004600062400460027000100062Q0007012Q00044Q0007012Q00064Q0007012Q00294Q0007012Q00444Q0007012Q00364Q0007017Q003B00450002000100123B0145001E032Q0012A80046001F033Q0061014500450046000624004600280001000F2Q0007012Q00044Q0007012Q00064Q0007012Q00294Q0007012Q00444Q0007012Q002D4Q0007012Q00134Q0007012Q00334Q0007012Q00084Q0007012Q00324Q0007012Q00364Q0007017Q0007012Q00224Q0007012Q00114Q0007012Q00164Q0007012Q00104Q003B00450002000100123B0145001E032Q0012A80046001F033Q006101450045004600062400460029000100022Q0007012Q00064Q0007012Q002B4Q003B00450002000100123B0145001E032Q0012A80046001F033Q00610145004500460006240046002A000100072Q0007012Q00044Q0007012Q00064Q0007017Q0007012Q00334Q0007012Q00084Q0007012Q00324Q0007012Q00104Q003B00450002000100123B0145001E032Q0012A80046001F033Q00610145004500460006240046002B000100082Q0007012Q00044Q0007012Q00064Q0007012Q00334Q0007012Q00084Q0007012Q00364Q0007012Q001B4Q0007012Q00344Q0007017Q003B00450002000100123B0145001E032Q0012A80046001F033Q00610145004500460006240046002C000100072Q0007012Q00044Q0007012Q00064Q0007012Q00334Q0007012Q00194Q0007017Q0007012Q00084Q0007012Q00364Q00B000450002000100122Q00470075035Q0045000100474Q00478Q00450047000100122Q00470076035Q00450001004700122Q00470077035Q00450047000100122Q00470078035Q00450001004700202Q00470003002E4Q00450047000100122Q00470079035Q00450002004700122Q004700426Q00450047000100122Q0047007A035Q00453Q00474Q00473Q000300122Q0048007B032Q00102Q00470007004800122Q0048002A032Q00122Q0049007C035Q00470048004900122Q0048007D032Q00122Q004900666Q0047004800494Q00450047000100122Q00450010032Q00202Q00450045004500122Q0046007E035Q00450002000200122Q00460010032Q00202Q00460046004500122Q0047007F035Q00460002000200122Q00470010032Q00202Q00470047004500122Q00480080035Q00470002000200122Q00480015032Q00122Q00490081035Q00450048004900122Q00480082032Q00122Q004900023Q00202Q00490049003100122Q004B0083035Q0049004B00024Q00450048004900122Q00480084032Q00122Q004900173Q00122Q004A0084035Q00490049004A00122Q004A0085035Q00490049004A4Q00450048004900122Q00480082035Q00460048004500122Q00480086032Q00122Q00490087032Q00122Q004A0088035Q00490049004A00122Q004A0089032Q00122Q004B0089032Q00122Q004C0089035Q0049004C00024Q00460048004900122Q0048008A032Q00122Q004900E26Q00460048004900122Q0048008B032Q00122Q0049000E3Q00202Q00490049004500122Q004A008C032Q00122Q004B00E23Q00122Q004C008D032Q00122Q004D00E26Q0049004D00024Q0046004800490012270148000E3Q00202Q00480048004500122Q004900E23Q00122Q004A008E032Q00122Q004B00E23Q00122Q004C008E035Q0048004C000200102Q0046000D004800122Q0048008F032Q00122Q00490090033Q00BC00460048004900123600480082035Q00470048004600122Q00480091032Q00122Q00490092032Q00202Q00490049004500122Q004A0093032Q00122Q004B0093035Q0049004B00024Q00470048004900122Q0048008B032Q00123B0149000E3Q0020F200490049004500122Q004A0093032Q00122Q004B00E23Q00122Q004C0093032Q00122Q004D00E26Q0049004D00024Q00470048004900122Q0048000E3Q00202Q00480048004500122Q00490094032Q0012A8004A00E23Q001203004B0094032Q00122Q004C00E26Q0048004C000200102Q0047000D004800122Q00480095032Q00122Q004900426Q00470048004900122Q00480096032Q00122Q00490097035Q00470048004900123B01480010032Q0020A400480048004500122Q00490098035Q00480002000200122Q00490099032Q00122Q004A009A032Q00202Q004A004A004500122Q004B00E23Q00122Q004C00726Q004A004C00024Q00480049004A0012A800490082033Q00BC0048004900460012A80049009B033Q00610149004600490012A8004B001C033Q007500490049004B000624004B002D000100012Q0007012Q00024Q00660149004B000100122Q004900023Q00202Q00490049003100122Q004B009C035Q0049004B00024Q004A004A3Q00122Q004B009D035Q004C004D3Q000624004E002E000100042Q0007012Q004C4Q0007012Q004D4Q0007012Q00464Q0007012Q004B3Q0012A8004F009E033Q0061014F0046004F0012A80051001C033Q0075004F004F00510006240051002F000100042Q0007012Q004A4Q0007012Q004C4Q0007012Q004D4Q0007012Q00464Q001B014F0051000100122Q004F009F035Q004F0049004F00122Q0051001C035Q004F004F005100062400510030000100022Q0007012Q004A4Q0007012Q004E4Q006E004F005100012Q00FB3Q00013Q00313Q000E3Q00026Q00F03F027Q0040026Q000840030E3Q0046696E6446697273744368696C642Q033Q004D617003073Q00456E656D696573030A3Q004D6172696E65466F726403063Q004A756E676C6503063Q004D6F6E6B657903073Q00476F72692Q6C6103093Q004472652Q73726F736103093Q0047722Q656E5A6F6E65030B3Q005377616E20506972617465030D3Q00466163746F7279205374612Q6600554Q001A8Q001A000100013Q000645012Q0006000100010004533Q000600010012A83Q00014Q00C63Q00024Q001A8Q001A000100023Q000645012Q000C000100010004533Q000C00010012A83Q00024Q00C63Q00024Q001A8Q001A000100033Q000645012Q0012000100010004533Q001200010012A83Q00034Q00C63Q00024Q001A3Q00043Q00205E014Q000400122Q000200058Q000200024Q000100043Q00202Q00010001000400122Q000300066Q00010003000200064Q002800013Q0004533Q0028000100200501023Q00040012A8000400074Q00CA0002000400020006BB00020026000100010004533Q0026000100200501023Q00040012A8000400084Q00CA00020004000200062A0102002800013Q0004533Q002800010012A8000200014Q00C6000200023Q00062A2Q01003600013Q0004533Q003600010020050102000100040012A8000400094Q00CA0002000400020006BB00020034000100010004533Q003400010020050102000100040012A80004000A4Q00CA00020004000200062A0102003600013Q0004533Q003600010012A8000200014Q00C6000200023Q00062A012Q004400013Q0004533Q0044000100200501023Q00040012A80004000B4Q00CA0002000400020006BB00020042000100010004533Q0042000100200501023Q00040012A80004000C4Q00CA00020004000200062A0102004400013Q0004533Q004400010012A8000200024Q00C6000200023Q00062A2Q01005200013Q0004533Q005200010020050102000100040012A80004000D4Q00CA0002000400020006BB00020050000100010004533Q005000010020050102000100040012A80004000E4Q00CA00020004000200062A0102005200013Q0004533Q005200010012A8000200024Q00C6000200023Q0012A8000200034Q00C6000200024Q00FB3Q00017Q001E3Q0003043Q0067616D65030A3Q0047657453657276696365030B3Q00482Q747053657276696365030F3Q0054656C65706F72745365727669636503073Q00506C616365496403223Q00682Q7470733A2Q2F67616D65732E726F626C6F782E636F6D2F76312F67616D65732F03273Q002F736572766572732F5075626C69633F736F72744F726465723D417363266C696D69743D312Q3003053Q007063612Q6C03043Q006461746103053Q00706169727303073Q00706C6179696E67030A3Q006D6178506C617965727303023Q00696403053Q004A6F62496403053Q007461626C6503063Q00696E73657274028Q0003043Q006D61746803063Q0072616E646F6D026Q00F03F03173Q0054656C65706F7274546F506C616365496E7374616E636503063Q004E6F7469667903053Q005469746C65030A3Q0053657276657220486F7003073Q00436F6E74656E74032F3Q004E6F2062652Q746572207365727665727320666F756E642E2054727920616761696E20696E2061206D6F6D656E742E03083Q004475726174696F6E026Q00084003053Q00452Q726F72031C3Q004661696C656420746F20666574636820736572766572206C6973742E004E3Q0012CC3Q00013Q00206Q000200122Q000200038Q0002000200122Q000100013Q00202Q00010001000200122Q000300046Q00010003000200122Q000200013Q00202Q00020002000500122Q000300066Q000400023Q00122Q000500076Q00030003000500122Q000400083Q00062400053Q000100022Q0007012Q00034Q0007017Q001600040002000500062A0104004600013Q0004533Q0046000100062A0105004600013Q0004533Q0046000100203501060005000900062A0106004600013Q0004533Q004600012Q00A900065Q00123B0107000A3Q0020350108000500092Q00160007000200090004533Q002D0001002035010C000B000B002035010D000B000C00064A000C002D0001000D0004533Q002D0001002035010C000B000D00123B010D00013Q002035010D000D000E00067D000C002D0001000D0004533Q002D000100123B010C000F3Q002035010C000C00102Q0007010D00063Q002035010E000B000D2Q006E000C000E00010006970007001F000100020004533Q001F00012Q0013010700063Q000E330111003E000100070004533Q003E000100123B010700123Q0020D000070007001300122Q000800146Q000900066Q0007000900024Q00070006000700202Q0008000100154Q000A00026Q000B00076Q000C8Q0008000C000100044Q004D00012Q001A000700013Q0020130007000700164Q00093Q000300302Q00090017001800302Q00090019001A00302Q0009001B001C4Q0007000900010004533Q004D00012Q001A000600013Q0020130006000600164Q00083Q000300302Q00080017001D00302Q00080019001E00302Q0008001B001C4Q0006000800012Q00FB3Q00013Q00013Q00033Q0003043Q0067616D6503073Q00482Q7470476574030A3Q004A534F4E4465636F6465000A3Q0012113Q00013Q00206Q00024Q00029Q00000200024Q000100013Q00202Q0001000100034Q00038Q000100036Q00019Q0000017Q00053Q00030E3Q0046696E6446697273744368696C6403093Q00506C6179657247756903043Q004D61696E03053Q00517565737403073Q0056697369626C6500174Q0017016Q00206Q000100122Q000200028Q0002000200064Q0008000100010004533Q000800012Q00392Q016Q00C6000100023Q0020052Q013Q00010012A8000300034Q00CA0001000300020006BB0001000F000100010004533Q000F00012Q003901026Q00C6000200023Q0020050102000100010012A8000400044Q00CA00020004000200063D01030015000100020004533Q001500010020350103000200052Q00C6000300024Q00FB3Q00017Q000A3Q0003043Q0066696E6403043Q005368697003083Q00456E67696E2Q657203073Q005374657761726403073Q004F2Q666963657203063Q00434672616D652Q033Q006E6577025Q0061B9C0025Q00C05440025Q00405FC0021D3Q00200501023Q00010012A8000400024Q00CA0002000400020006BB00020014000100010004533Q0014000100200501023Q00010012A8000400034Q00CA0002000400020006BB00020014000100010004533Q0014000100200501023Q00010012A8000400044Q00CA0002000400020006BB00020014000100010004533Q0014000100200501023Q00010012A8000400054Q00CA00020004000200062A0102001B00013Q0004533Q001B000100123B010200063Q0020B800020002000700122Q000300083Q00122Q000400093Q00122Q0005000A6Q000200056Q00026Q00C6000100024Q00FB3Q00017Q00113Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403043Q006D61746803043Q006875676503093Q00776F726B737061636503073Q00456E656D69657303053Q007061697273030B3Q004765744368696C6472656E03043Q004E616D6503083Q0048756D616E6F696403063Q004865616C7468028Q0003163Q0046696E6446697273744368696C64576869636849734103083Q00426173655061727403083Q00506F736974696F6E03093Q004D61676E6974756465013E4Q001A00015Q0020352Q010001000100062A2Q01000900013Q0004533Q000900010020050102000100020012A8000400034Q00CA0002000400020006BB0002000B000100010004533Q000B00012Q00FC000200024Q00C6000200023Q0020350102000100032Q005B000300033Q00122Q000400043Q00202Q00040004000500122Q000500063Q00202Q00050005000200122Q000700076Q00050007000200062Q00050017000100010004533Q001700012Q00FC000600064Q00C6000600023Q00123B010600083Q0020050107000500092Q0044000700084Q004600063Q00080004533Q003A0001002035010B000A000A000645010B003A00013Q0004533Q003A0001002005010B000A00020012A8000D000B4Q00CA000B000D000200062A010B003A00013Q0004533Q003A0001002035010B000A000B002035010B000B000C000E33010D003A0001000B0004533Q003A0001002005010B000A00020012A8000D00034Q00CA000B000D00020006BB000B0030000100010004533Q00300001002005010B000A000E0012A8000D000F4Q00CA000B000D000200062A010B003A00013Q0004533Q003A0001002035010C000B0010002035010D000200102Q000B000C000C000D002035010C000C001100064A000C003A000100040004533Q003A00012Q00070104000C4Q00070103000A3Q0006970006001C000100020004533Q001C00012Q00C6000300024Q00FB3Q00017Q000A3Q0003053Q00706169727303083Q004261636B7061636B030B3Q004765744368696C6472656E2Q033Q0049734103043Q00542Q6F6C03053Q007461626C6503043Q0066696E6403043Q004E616D6503063Q00696E7365727403093Q00436861726163746572003B4Q000D7Q00122Q000100016Q00025Q00202Q00020002000200202Q0002000200034Q000200036Q00013Q000300044Q001900010020050106000500040012A8000800054Q00CA00060008000200062A0106001900013Q0004533Q0019000100123B010600063Q00205D0106000600074Q00075Q00202Q0008000500084Q00060008000200062Q00060019000100010004533Q0019000100123B010600063Q0020350106000600092Q000701075Q0020350108000500082Q006E00060008000100069700010008000100020004533Q000800012Q001A00015Q0020352Q010001000A00062A2Q01003900013Q0004533Q0039000100123B2Q0100014Q008200025Q00202Q00020002000A00202Q0002000200034Q000200036Q00013Q000300044Q003700010020050106000500040012A8000800054Q00CA00060008000200062A0106003700013Q0004533Q0037000100123B010600063Q00205D0106000600074Q00075Q00202Q0008000500084Q00060008000200062Q00060037000100010004533Q0037000100123B010600063Q0020350106000600092Q000701075Q0020350108000500082Q006E00060008000100069700010026000100020004533Q002600012Q00C63Q00024Q00FB3Q00017Q000D3Q0003073Q0067657467656E76030F3Q004175746F4571756970576561706F6E03093Q00436861726163746572030E3Q00436861726163746572412Q64656403043Q0057616974030C3Q0057616974466F724368696C6403083Q0048756D616E6F696403043Q007461736B03043Q0077616974026Q00F83F03083Q004261636B7061636B030E3Q0046696E6446697273744368696C6403093Q004571756970542Q6F6C001F3Q00123B012Q00014Q0010012Q00010002002035014Q000200062A012Q001E00013Q0004533Q001E00012Q001A00015Q0020352Q01000100030006BB0001000D000100010004533Q000D00012Q001A00015Q0020352Q01000100040020052Q01000100052Q001C000100020002002005010200010006001228000400076Q00020004000200122Q000300083Q00202Q00030003000900122Q0004000A6Q0003000200014Q00035Q00202Q00030003000B00202Q00030003000C4Q00058Q00030005000200062Q0003001E00013Q0004533Q001E000100200501040002000D2Q0007010600034Q006E0004000600012Q00FB3Q00017Q001D3Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F7450617274030C3Q00412Q706C795068797369637303083Q00506F736974696F6E03093Q004D61676E697475646503093Q0054772Q656E496E666F2Q033Q006E657703043Q006D61746803053Q00636C616D70025Q00807140029A5Q99E93F026Q00104003043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D65028Q00026Q00204003043Q00506C617903093Q00436F6D706C6574656403043Q005761697403043Q007461736B03043Q0077616974029A5Q99D93F030C3Q00496E766F6B65536572766572030A3Q0053746172745175657374026Q33E33F03454Q001A00036Q001001030001000200062A0103000500013Q0004533Q000500012Q00FB3Q00014Q001A000300013Q00203501030003000100062A0103000E00013Q0004533Q000E00010020050104000300020012A8000600034Q00CA0004000600020006BB0004000F000100010004533Q000F00012Q00FB3Q00013Q0020350104000300030012EB000500046Q000600046Q00050002000100202Q00050004000500202Q0006000200054Q00050005000600202Q00050005000600122Q000600073Q00202Q00060006000800122Q000700093Q00202Q00070007000A00202Q00080005000B00122Q0009000C3Q00122Q000A000D6Q0007000A000200122Q0008000E3Q00202Q00080008000F00202Q0008000800104Q0006000800024Q000700023Q00202Q0007000700114Q000900046Q000A00066Q000B3Q000100122Q000C00123Q00202Q000C000C000800122Q000D00133Q00122Q000E00143Q00122Q000F00136Q000C000F00024Q000C0002000C00102Q000B0012000C4Q0007000B000200202Q0008000700154Q00080002000100202Q00080007001600202Q0008000800174Q00080002000100122Q000800183Q00202Q00080008001900122Q0009001A6Q0008000200014Q000800033Q00202Q00080008001B00122Q000A001C6Q000B8Q000C00016Q0008000C000100122Q000800183Q00202Q00080008001900122Q0009001D6Q0008000200016Q00017Q00093Q0003043Q004461746103053Q004C6576656C03053Q0056616C7565026Q00F03F026Q00F0BF03093Q00776F726B7370616365030E3Q0046696E6446697273744368696C6403073Q00456E656D696573026Q00104000284Q007B7Q00206Q000100206Q000200206Q00034Q000100016Q000200016Q000200023Q00122Q000300043Q00122Q000400053Q00042Q0002001D00012Q001A000600014Q006101060006000500203501070006000400068A0007001C00013Q0004533Q001C000100123B010700063Q0020050107000700070012A8000900084Q00CA00070009000200062A0107001C00013Q0004533Q001C0001002005010800070007002035010A000600092Q00CA0008000A000200062A0108001C00013Q0004533Q001C00012Q00072Q0100063Q0004533Q001D000100044A0102000A000100062A2Q01002500013Q0004533Q0025000100123B010200063Q00205001020002000800202Q0003000100094Q0002000200034Q000300016Q000200034Q00FC000200024Q00C6000200024Q00FB3Q00017Q00043Q0003043Q007461736B03043Q0077616974027Q004003053Q007063612Q6C00093Q00127E3Q00013Q00206Q000200122Q000100038Q0002000100124Q00043Q00062400013Q000100012Q001A8Q00163Q000200012Q00FB3Q00013Q00013Q00023Q00030C3Q00496E766F6B6553657276657203043Q004275736F00054Q00507Q00206Q000100122Q000200028Q000200016Q00017Q00173Q0003093Q004175746F537461747303053Q0056616C7565030E3Q0046696E6446697273744368696C6403043Q004461746103063Q00506F696E7473028Q00030A3Q0053746174546172676574030A3Q00426C6F7820467275697403093Q00426C6F784672756974026Q00F03F03053Q007063612Q6C03043Q007461736B03043Q0077616974026Q00E03F026Q00144003063Q004E6F7469667903053Q005469746C65030A3Q004175746F20537461747303073Q00436F6E74656E7403113Q0020706F696E7473207370656E74206F6E2003013Q002103083Q004475726174696F6E027Q0040003D4Q001A7Q002035014Q0001002035014Q00020006BB3Q0006000100010004533Q000600012Q00FB3Q00014Q001A000100013Q0020052Q01000100030012A8000300044Q00CA0001000300020006BB0001000D000100010004533Q000D00012Q00FB3Q00013Q0020050102000100030012A8000400054Q00CA0002000400020006BB00020013000100010004533Q001300012Q00FB3Q00013Q00203501030002000200266500030017000100060004533Q001700012Q00FB3Q00014Q001A00045Q0020350104000400070020350104000400022Q0007010500043Q0026D30004001E000100080004533Q001E00010012A8000500093Q0012A8000600063Q0012A80007000A4Q0007010800033Q0012A80009000A3Q00044C0007003C000100123B010B000B3Q000624000C3Q000100012Q0007012Q00054Q00F0000B0002000100202Q00060006000A00122Q000B000C3Q00202Q000B000B000D00122Q000C000E6Q000B0002000100202Q000B0006000F00262Q000B003B000100060004533Q003B00012Q001A000B00023Q0020E3000B000B00104Q000D3Q000300302Q000D001100124Q000E00063Q00122Q000F00146Q001000043Q00122Q001100156Q000E000E001100102Q000D0013000E00302Q000D001600174Q000B000D000100044A0107002300012Q00FB3Q00013Q00013Q00083Q0003043Q0067616D65030A3Q004765745365727669636503113Q005265706C69636174656453746F7261676503073Q0052656D6F74657303063Q00436F2Q6D465F030C3Q00496E766F6B6553657276657203083Q00412Q64506F696E74026Q00F03F000C3Q0012843Q00013Q00206Q000200122Q000200038Q0002000200206Q000400206Q000500206Q000600122Q000200076Q00035Q00122Q000400088Q000400016Q00017Q00123Q00027Q0040026Q000840026Q00144003093Q00506C6179657247756903043Q004D61696E030E3Q0046696E6446697273744368696C6403053Q00517565737403073Q0056697369626C6503093Q0043686172616374657203103Q0048756D616E6F6964522Q6F745061727403063Q00434672616D652Q033Q006E6577028Q0003043Q007461736B03043Q0077616974026Q00E03F030C3Q00496E766F6B65536572766572030A3Q005374617274517565737401323Q00206600013Q000100202Q00023Q000200202Q00033Q00034Q00045Q00202Q00040004000400202Q00040004000500202Q00040004000600122Q000600076Q00040006000200062Q0004001200013Q0004533Q001200012Q001A00045Q00207C00040004000400202Q00040004000500202Q00040004000700202Q00040004000800062Q00040031000100010004533Q003100012Q001A00045Q00203501040004000900063D01050019000100040004533Q001900010020050105000400060012A80007000A4Q00CA00050007000200062A0105003100013Q0004533Q0031000100123B0106000B3Q00205F01060006000C00122Q0007000D3Q00122Q000800033Q00122Q0009000D6Q0006000900024Q00060003000600102Q0005000B000600122Q0006000E3Q00202Q00060006000F00122Q000700106Q0006000200014Q000600013Q00202Q00060006001100122Q000800126Q000900016Q000A00026Q0006000A000100122Q0006000E3Q00202Q00060006000F00122Q000700106Q0006000200012Q00FB3Q00017Q00053Q00030E3Q0046696E6446697273744368696C6403093Q00506C6179657247756903043Q004D61696E03053Q00517565737403073Q0056697369626C6500174Q0017016Q00206Q000100122Q000200028Q0002000200064Q0008000100010004533Q000800012Q00392Q016Q00C6000100023Q0020052Q013Q00010012A8000300034Q00CA0001000300020006BB0001000F000100010004533Q000F00012Q003901026Q00C6000200023Q0020050102000100010012A8000400044Q00CA00020004000200063D01030015000100020004533Q001500010020350103000200052Q00C6000300024Q00FB3Q00017Q000F3Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403093Q00776F726B737061636503073Q00456E656D69657303043Q006D61746803043Q006875676503053Q007061697273030B3Q004765744368696C6472656E03043Q004E616D6503083Q0048756D616E6F696403063Q004865616C7468028Q0003083Q00506F736974696F6E03093Q004D61676E6974756465013A4Q001A00015Q0020352Q010001000100062A2Q01000900013Q0004533Q000900010020050102000100020012A8000400034Q00CA0002000400020006BB0002000B000100010004533Q000B00012Q00FC000200024Q00C6000200023Q002035010200010003001226000300043Q00202Q00030003000200122Q000500056Q00030005000200062Q00030014000100010004533Q001400012Q00FC000400044Q00C6000400024Q00FC000400043Q00129F000500063Q00202Q00050005000700122Q000600083Q00202Q0007000300094Q000700086Q00063Q000800044Q00360001002035010B000A000A000645010B003600013Q0004533Q00360001002005010B000A00020012A8000D000B4Q00CA000B000D000200062A010B003600013Q0004533Q00360001002035010B000A000B002035010B000B000C000E33010D00360001000B0004533Q00360001002005010B000A00020012A8000D00034Q00CA000B000D000200062A010B003600013Q0004533Q00360001002035010B000A0003002058010B000B000E00202Q000C0002000E4Q000B000B000C00202Q000B000B000F00062Q000B0036000100050004533Q003600012Q00070105000B4Q00070104000A3Q0006970006001C000100020004533Q001C00012Q00C6000400024Q00FB3Q00017Q00283Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F7450617274027Q0040026Q000840026Q00144003063Q004E6F7469667903053Q005469746C6503093Q004175746F204661726D03073Q00436F6E74656E74031A3Q0054772Q656E696E6720746F2071756573742067697665723Q2E03083Q004475726174696F6E030C3Q00412Q706C795068797369637303083Q00506F736974696F6E03093Q004D61676E697475646503043Q006D6174682Q033Q006D6178026Q33F33F03093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D65028Q00026Q001C4003043Q00506C617903093Q00436F6D706C6574656403043Q005761697403043Q007461736B03043Q0077616974029A5Q99E93F030C3Q00496E766F6B65536572766572030A3Q0053746172745175657374026Q00F03F030E3Q00436C65616E75705068797369637303183Q00517565737420612Q636570746564212048756E74696E6720026Q0010402Q033Q003Q2E01614Q001A00016Q00102Q010001000200062A2Q01000600013Q0004533Q000600012Q00392Q0100014Q00C6000100024Q001A000100013Q0020352Q010001000100062A2Q01000F00013Q0004533Q000F00010020050102000100020012A8000400034Q00CA0002000400020006BB00020011000100010004533Q001100012Q003901026Q00C6000200023Q00203501020001000300209E00033Q000400202Q00043Q000500202Q00053Q00064Q000600023Q00202Q0006000600074Q00083Q000300302Q00080008000900302Q0008000A000B00302Q0008000C00044Q00060008000100122Q0006000D6Q000700026Q00060002000100202Q00060002000E00202Q00070005000E4Q00060006000700202Q00060006000F00122Q000700103Q00202Q0007000700114Q000800036Q00080006000800122Q000900126Q00070009000200122Q000800133Q00202Q0008000800144Q000900073Q00122Q000A00153Q00202Q000A000A001600202Q000A000A00174Q0008000A00024Q000900043Q00202Q0009000900184Q000B00026Q000C00086Q000D3Q000100122Q000E00193Q00202Q000E000E001400122Q000F001A3Q00122Q0010001B3Q00122Q001100066Q000E001100024Q000E0005000E00102Q000D0019000E4Q0009000D000200202Q000A0009001C4Q000A0002000100202Q000A0009001D00202Q000A000A001E4Q000A0002000100122Q000A001F3Q00202Q000A000A002000122Q000B00216Q000A000200014Q000A00053Q00202Q000A000A002200122Q000C00236Q000D00036Q000E00046Q000A000E000100122Q000A001F3Q00202Q000A000A002000122Q000B00246Q000A0002000100122Q000A00256Q000A000100014Q000A00023Q00202Q000A000A00074Q000C3Q000300302Q000C0008000900122Q000D00263Q00202Q000E3Q002700122Q000F00286Q000D000D000F00102Q000C000A000D00302Q000C000C00054Q000A000C00014Q000A00016Q000A00028Q00017Q00063Q0003093Q00776F726B737061636503153Q0046696E6446697273744368696C644F66436C612Q7303073Q0054652Q7261696E030D3Q0057617465725761766553697A65028Q0003103Q0057617465725265666C656374616E6365000D3Q0012993Q00013Q00206Q000200122Q000200038Q0002000200064Q000C00013Q0004533Q000C000100123B012Q00013Q0020085Q000300304Q0004000500124Q00013Q00206Q000300304Q000600052Q00FB3Q00017Q00103Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F7450617274030A3Q004661726D427970612Q7303073Q0044657374726F7903103Q004661726D427970612Q73526F7461746503083Q0048756D616E6F6964030D3Q00506C6174666F726D5374616E64010003053Q007061697273030B3Q004765744368696C6472656E2Q033Q0049734103083Q004261736550617274030A3Q0043616E436F2Q6C6964652Q0103063Q0043616E63656C00334Q001A7Q002035014Q000100062A012Q002C00013Q0004533Q002C00010020052Q013Q00020012A8000300034Q00CA00010003000200062A2Q01001900013Q0004533Q001900010020050102000100020012A8000400044Q00CA00020004000200062A0102001100013Q0004533Q001100010020350102000100040020050102000200052Q003B0002000200010020050102000100020012A8000400064Q00CA00020004000200062A0102001900013Q0004533Q001900010020350102000100060020050102000200052Q003B00020002000100200501023Q00020012A8000400074Q00CA00020004000200062A0102001F00013Q0004533Q001F000100305201020008000900123B0103000A3Q00200501043Q000B2Q0044000400054Q004600033Q00050004533Q002A000100200501080007000C0012A8000A000D4Q00CA0008000A000200062A0108002A00013Q0004533Q002A00010030520107000E000F00069700030024000100020004533Q002400012Q001A000100013Q00062A2Q01003200013Q0004533Q003200012Q001A000100013Q0020052Q01000100102Q003B0001000200012Q00FB3Q00017Q000F3Q00030E3Q0046696E6446697273744368696C64030A3Q004661726D427970612Q7303053Q00436C6F6E6503063Q00506172656E7403103Q004661726D427970612Q73526F7461746503093Q0043686172616374657203083Q0048756D616E6F6964030D3Q00506C6174666F726D5374616E642Q0103053Q007061697273030B3Q004765744368696C6472656E2Q033Q0049734103083Q004261736550617274030A3Q0043616E436F2Q6C6964650100012A3Q0020052Q013Q00010012A8000300024Q00CA0001000300020006BB00010009000100010004533Q000900012Q001A00015Q0020052Q01000100032Q001C00010002000200105B2Q0100043Q0020052Q013Q00010012A8000300054Q00CA0001000300020006BB00010012000100010004533Q001200012Q001A000100013Q0020052Q01000100032Q001C00010002000200105B2Q0100044Q001A000100023Q00205D00010001000600202Q00010001000100122Q000300076Q00010003000200062Q0001001A00013Q0004533Q001A00010030522Q010008000900123B0102000A4Q0082000300023Q00202Q00030003000600202Q00030003000B4Q000300046Q00023Q000400044Q0027000100200501070006000C0012A80009000D4Q00CA00070009000200062A0107002700013Q0004533Q002700010030520106000E000F00069700020021000100020004533Q002100012Q00FB3Q00017Q00123Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403093Q00776F726B7370616365030C3Q005F576F726C644F726967696E03093Q004C6F636174696F6E73026Q007940025Q0088B34003053Q007061697273030B3Q004765744368696C6472656E2Q033Q0049734103083Q00426173655061727403083Q00506F736974696F6E03093Q004D61676E697475646503053Q004D6F64656C030E3Q004765744D6F64656C434672616D6503013Q0070025Q0040AF4000544Q00E67Q00206Q000100206Q000200122Q000200038Q0002000200064Q0009000100010004533Q000900012Q00FC000100014Q00C6000100023Q00123B2Q0100043Q0020052Q01000100020012A8000300054Q00CA00010003000200062A2Q01001400013Q0004533Q0014000100123B2Q0100043Q0020352Q01000100050020052Q01000100020012A8000300064Q00CA0001000300022Q00FC000200023Q0012A8000300073Q0012A8000400083Q00062A2Q01003300013Q0004533Q0033000100123B010500093Q00200501060001000A2Q0044000600074Q004600053Q00070004533Q00310001002005010A0009000B0012A8000C000C4Q00CA000A000C000200062A010A003100013Q0004533Q003100012Q001A000A00014Q0061010A000A00090006BB000A0031000100010004533Q00310001002035010A0009000D002035010B3Q000D2Q000B000A000A000B002035010A000A000E00064A000300310001000A0004533Q0031000100064A000A0031000100040004533Q003100012Q0007010200094Q00070104000A3Q0006970005001E000100020004533Q001E00010006BB00020052000100010004533Q0052000100123B010500093Q001219010600043Q00202Q00060006000A4Q000600076Q00053Q000700044Q00500001002005010A0009000B0012A8000C000F4Q00CA000A000C000200062A010A005000013Q0004533Q005000012Q001A000A00014Q0061010A000A00090006BB000A0050000100010004533Q00500001002005010A000900102Q00E0000A0002000200202Q000A000A001100202Q000B3Q000D4Q000B000A000B00202Q000B000B000E00062Q000300500001000B0004533Q00500001002652000B0050000100120004533Q005000012Q0007010200093Q0004533Q005200010006970005003B000100020004533Q003B00012Q00C6000200024Q00FB3Q00017Q00223Q0003153Q0046696E6446697273744368696C644F66436C612Q7303073Q0054652Q7261696E030D3Q0057617465725761766553697A65028Q0003103Q0057617465725265666C656374616E636503113Q0057617465725472616E73706172656E6379030D3Q00476C6F62616C536861646F7773010003063Q00466F67456E64023Q00C088C3004203083Q0073652Q74696E677303093Q0052656E646572696E67030C3Q005175616C6974794C6576656C026Q00F03F03053Q00706169727303043Q0067616D65030E3Q0047657444657363656E64616E74732Q033Q0049734103043Q0050617274030E3Q00556E696F6E4F7065726174696F6E03083Q004D6573685061727403083Q004D6174657269616C03043Q00456E756D030D3Q00536D2Q6F7468506C6173746963030B3Q005265666C656374616E6365030A3Q0043617374536861646F7703053Q00446563616C03073Q0054657874757265030C3Q005472616E73706172656E6379030F3Q005061727469636C65456D692Q74657203053Q00547261696C03083Q004C69666574696D65030B3Q004E756D62657252616E67652Q033Q006E6577004B4Q001D016Q00206Q000100122Q000200028Q0002000200064Q000900013Q0004533Q00090001003052012Q00030004003052012Q00050004003052012Q000600042Q001A000100013Q00302B2Q01000700084Q000100013Q00302Q00010009000A00122Q0001000B6Q00010001000200202Q00010001000C00302Q0001000D000E00122Q0001000F3Q00122Q000200103Q00202Q0002000200114Q000200036Q00013Q000300044Q004800010020050106000500120012A8000800134Q00CA0006000800020006BB00060026000100010004533Q002600010020050106000500120012A8000800144Q00CA0006000800020006BB00060026000100010004533Q002600010020050106000500120012A8000800154Q00CA00060008000200062A0106002D00013Q0004533Q002D000100123B010600173Q00200601060006001600202Q00060006001800102Q00050016000600302Q00050019000400302Q0005001A000800044Q004800010020050106000500120012A80008001B4Q00CA0006000800020006BB00060037000100010004533Q003700010020050106000500120012A80008001C4Q00CA00060008000200062A0106003900013Q0004533Q003900010030520105001D000E0004533Q004800010020050106000500120012A80008001E4Q00CA0006000800020006BB00060043000100010004533Q004300010020050106000500120012A80008001F4Q00CA00060008000200062A0106004800013Q0004533Q0048000100123B010600213Q0020350106000600220012A8000700044Q001C00060002000200105B01050020000600069700010017000100020004533Q001700012Q00FB3Q00017Q00083Q00030C3Q0057616974466F724368696C64030D3Q00506C617965725363726970747303153Q0046696E6446697273744368696C644F66436C612Q73030B3Q004C6F63616C53637269707403073Q0067657473656E76030B3Q0048697446756E6374696F6E03023Q005F4703103Q0053656E6448697473546F53657276657200144Q004D7Q00206Q000100122Q000200028Q0002000200206Q000300122Q000200048Q0002000200064Q001300013Q0004533Q0013000100123B2Q0100053Q00062A2Q01001300013Q0004533Q001300012Q001A000100013Q001208010200056Q00038Q00020002000200202Q00020002000700202Q00020002000800102Q0001000600022Q00FB3Q00017Q001C3Q0003043Q007469636B03083Q004465626F756E636502FCA9F1D24D62503F03093Q00436861726163746572030E3Q0046696E6446697273744368696C6403083Q0048756D616E6F696403063Q004865616C7468028Q0003153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03053Q007461626C6503043Q0066696E6403053Q004D656C2Q65030A3Q00426C6F7820467275697403053Q0053776F726403073Q00542Q6F6C546970030D3Q00436F6D626F4465626F756E636503073Q004D31436F6D626F027Q0040026Q00F03F029A5Q99A93F03073Q00456E656D696573030F3Q004C656674436C69636B52656D6F7465030A3Q004669726553657276657203083Q00506F736974696F6E030B3Q005072696D6172795061727403043Q00556E6974030B3Q0048697446756E6374696F6E01753Q0012E2000100016Q00010001000200202Q00023Q00024Q00010001000200262Q00010007000100030004533Q000700012Q00FB3Q00014Q001A00015Q0020352Q010001000400062A2Q01001400013Q0004533Q001400010020050102000100050012A8000400064Q00CA00020004000200062A0102001400013Q0004533Q0014000100203501020001000600203501020002000700266500020015000100080004533Q001500012Q00FB3Q00013Q0020050102000100090012A80004000A4Q00CA00020004000200062A0102002500013Q0004533Q0025000100123B0103000B3Q00205500030003000C4Q000400033Q00122Q0005000D3Q00122Q0006000E3Q00122Q0007000F6Q0004000300010020350105000200102Q00CA0003000500020006BB00030026000100010004533Q002600012Q00FB3Q00013Q00123B010300014Q001001030001000200203501043Q00112Q000B0003000300040026650003002F000100030004533Q002F000100203501033Q00120006BB00030030000100010004533Q003000010012A8000300083Q000E6001130035000100030004533Q003500010012A8000400143Q00067700030036000100040004533Q0036000100205100030003001400123B010400014Q001001040001000200105B012Q0011000400105B012Q00120003000E6001130041000100030004533Q0041000100123B010400014Q00100104000100020020510004000400150006BB00040043000100010004533Q0043000100123B010400014Q001001040001000200105B012Q000200042Q00A900045Q00062400053Q000100022Q0007012Q00014Q0007012Q00044Q0031000600056Q000700013Q00202Q00070007000500122Q000900166Q000700096Q00063Q00014Q000600043Q000E2Q00080074000100060004533Q007400010020050106000200050012A8000800174Q00CA00060008000200062A0106006100013Q0004533Q0061000100203501060002001700206800060006001800202Q00080004001400202Q00080008001300202Q00080008001900202Q00090001001A00202Q0009000900194Q00080008000900202Q00080008001B4Q000900036Q0006000900012Q001A000600023Q00200700060006001800122Q000800086Q00060008000100202Q00063Q001C00062Q0006006E00013Q0004533Q006E000100203501063Q001C0020FF00070004001400202Q0007000700134Q000800046Q00060008000100044Q007400012Q001A000600033Q00207000060006001800202Q00080004001400202Q0008000800134Q000900046Q0006000900012Q00FB3Q00013Q00013Q000F3Q0003053Q007061697273030B3Q004765744368696C6472656E030E3Q0046696E6446697273744368696C6403083Q0048756D616E6F696403063Q004865616C7468028Q0003103Q0048756D616E6F6964522Q6F745061727403083Q00506F736974696F6E030B3Q005072696D6172795061727403093Q004D61676E697475646503073Q0067657467656E7603083Q0053652Q74696E6773030B3Q00412Q7461636B52616E676503053Q007461626C6503063Q00696E7365727401303Q0006BB3Q0003000100010004533Q000300012Q00FB3Q00013Q00123B2Q0100013Q00200501023Q00022Q0044000200034Q004600013Q00030004533Q002D00012Q001A00065Q00067D0005002D000100060004533Q002D00010020050106000500030012A8000800044Q00CA00060008000200062A0106002D00013Q0004533Q002D0001002035010600050004002035010600060005000E330106002D000100060004533Q002D00010020050106000500030012A8000800074Q00CA00060008000200062A0106002D00013Q0004533Q002D00010020350107000600082Q00B300085Q00202Q00080008000900202Q0008000800084Q00070007000800202Q00070007000A00122Q0008000B6Q00080001000200202Q00080008000C00202Q00080008000D00062Q0007002D000100080004533Q002D000100123B0107000E3Q0020DE00070007000F4Q000800016Q000900026Q000A00056Q000B00066Q0009000200012Q006E00070009000100069700010008000100020004533Q000800012Q00FB3Q00017Q000C3Q00030E3Q004175746F4661726D426F2Q73657303053Q0056616C756503093Q0043686573744661726D03083Q0053657456616C756503083Q00426F6E654661726D03083Q00526169644661726D03093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403053Q007072696E7403323Q00426F2Q73204661726D20537461727465643A20536561726368696E6720666F7220737061776E656420626F2Q7365733Q2E03113Q00426F2Q73204661726D2053746F2Q706564003A4Q001A7Q002035014Q0001002035014Q000200062A012Q003400013Q0004533Q003400012Q001A7Q002035014Q000300062A012Q000E00013Q0004533Q000E00012Q001A7Q002035014Q0003002005014Q00042Q003901026Q006E3Q000200012Q001A7Q002035014Q000500062A012Q001700013Q0004533Q001700012Q001A7Q002035014Q0005002005014Q00042Q003901026Q006E3Q000200012Q001A7Q002035014Q000600062A012Q002000013Q0004533Q002000012Q001A7Q002035014Q0006002005014Q00042Q003901026Q006E3Q000200012Q001A3Q00013Q002035014Q000700062A012Q003000013Q0004533Q003000012Q001A3Q00013Q00205D5Q000700206Q000800122Q000200098Q0002000200064Q003000013Q0004533Q003000012Q001A3Q00024Q001A000100013Q0020352Q01000100070020352Q01000100092Q003B3Q0002000100123B012Q000A3Q0012A80001000B4Q003B3Q000200010004533Q003900012Q001A3Q00034Q0024012Q0001000100123B012Q000A3Q0012A80001000C4Q003B3Q000200012Q00FB3Q00017Q00023Q0003073Q0067657467656E76030F3Q004175746F4571756970576561706F6E01043Q00123B2Q0100014Q00102Q010001000200105B2Q0100024Q00FB3Q00017Q00013Q0003093Q0053657456616C75657300064Q00597Q00206Q00014Q000200016Q000200019Q0000016Q00017Q000A3Q0003063Q004E6F7469667903053Q005469746C65030A3Q004175746F20537461747303073Q00436F6E74656E7403093Q004175746F537461747303053Q0056616C756503083Q00456E61626C65642103083Q0044697361626C656403083Q004475726174696F6E027Q004000114Q00F17Q00206Q00014Q00023Q000300302Q0002000200034Q000300013Q00202Q00030003000500202Q00030003000600062Q0003000C00013Q0004533Q000C00010012A8000300073Q0006BB0003000D000100010004533Q000D00010012A8000300083Q00105B01020004000300305201020009000A2Q006E3Q000200012Q00FB3Q00017Q00033Q0003043Q007461736B03043Q0077616974026Q33C33F00083Q00123B012Q00013Q002011014Q000200122Q000100038Q000200019Q006Q0001000100046Q00012Q00FB3Q00017Q000F3Q0003093Q0043686573744661726D03083Q0053657456616C756503083Q00426F6E654661726D03083Q00526169644661726D030E3Q004175746F4661726D426F2Q73657303063Q004E6F7469667903053Q005469746C65030F3Q004175746F204661726D204C6576656C03073Q00436F6E74656E74031E3Q0053746172746564212046696E64696E6720626573742071756573743Q2E03083Q004475726174696F6E026Q00104003093Q004175746F204661726D03083Q0053746F2Q7065642E027Q0040013B4Q00258Q00FC000100014Q0025000100013Q00062A012Q003100013Q0004533Q003100012Q001A000100023Q0020352Q010001000100062A2Q01000E00013Q0004533Q000E00012Q001A000100023Q0020352Q01000100010020052Q01000100022Q003901036Q006E0001000300012Q001A000100023Q0020352Q010001000300062A2Q01001700013Q0004533Q001700012Q001A000100023Q0020352Q01000100030020052Q01000100022Q003901036Q006E0001000300012Q001A000100023Q0020352Q010001000400062A2Q01002000013Q0004533Q002000012Q001A000100023Q0020352Q01000100040020052Q01000100022Q003901036Q006E0001000300012Q001A000100023Q0020352Q010001000500062A2Q01002900013Q0004533Q002900012Q001A000100023Q0020352Q01000100050020052Q01000100022Q003901036Q006E0001000300012Q001A000100033Q0020130001000100064Q00033Q000300302Q00030007000800302Q00030009000A00302Q0003000B000C4Q0001000300010004533Q003A00012Q001A000100044Q00DD0001000100014Q000100033Q00202Q0001000100064Q00033Q000300302Q00030007000D00302Q00030009000E00302Q0003000B000F4Q0001000300012Q00FB3Q00017Q00053Q0003093Q0043686573744661726D03053Q0056616C756503083Q00426F6E654661726D03083Q0053657456616C756503083Q00526169644661726D001F4Q001A7Q002035014Q0001002035014Q000200062A012Q001C00013Q0004533Q001C00012Q001A7Q002035014Q0003002035014Q000200062A012Q000F00013Q0004533Q000F00012Q001A7Q002035014Q0003002005014Q00042Q003901026Q006E3Q000200012Q001A7Q002035014Q0005002035014Q000200062A012Q001900013Q0004533Q001900012Q001A7Q002035014Q0005002005014Q00042Q003901026Q006E3Q000200012Q001A3Q00014Q0024012Q000100010004533Q001E00012Q001A3Q00024Q0024012Q000100012Q00FB3Q00019Q002Q002Q014Q00FB3Q00017Q00073Q0003083Q00526169644661726D03053Q0056616C756503093Q0043686573744661726D03083Q0053657456616C756503083Q00426F6E654661726D03043Q007461736B03053Q00737061776E00274Q001A7Q002035014Q0001002035014Q000200062A012Q002400013Q0004533Q002400012Q00A98Q002E3Q00019Q003Q00206Q000300206Q000200064Q001100013Q0004533Q001100012Q001A7Q002035014Q0003002005014Q00042Q003901026Q006E3Q000200012Q001A7Q002035014Q0005002035014Q000200062A012Q001B00013Q0004533Q001B00012Q001A7Q002035014Q0005002005014Q00042Q003901026Q006E3Q000200012Q001A3Q00024Q0024012Q0001000100123B012Q00063Q002035014Q000700062400013Q000100022Q001A3Q00034Q001A3Q00044Q003B3Q000200010004533Q002600012Q001A3Q00054Q0024012Q000100012Q00FB3Q00013Q00013Q00033Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727400114Q001A7Q002035014Q000100062A012Q001000013Q0004533Q001000012Q001A7Q00205D5Q000100206Q000200122Q000200038Q0002000200064Q001000013Q0004533Q001000012Q001A3Q00014Q001A00015Q0020352Q01000100010020352Q01000100032Q003B3Q000200012Q00FB3Q00017Q00103Q0003083Q00426F6E654661726D03053Q0056616C7565026Q00084003063Q004E6F7469667903053Q005469746C6503133Q0057726F6E67205365612044657465637465642103073Q00436F6E74656E74030F3Q00596F752061726520696E205365612003203Q002E20426F6E65204661726D206F6E6C7920776F726B7320696E2053656120332E03083Q004475726174696F6E026Q00144003083Q0053657456616C756503093Q0043686573744661726D03083Q00526169644661726D03043Q007461736B03053Q00737061776E003A4Q001A7Q002035014Q0001002035014Q000200062A012Q003700013Q0004533Q003700012Q001A3Q00014Q0010012Q000100020026543Q001A000100030004533Q001A00012Q001A000100023Q0020580001000100044Q00033Q000300302Q00030005000600122Q000400086Q00055Q00122Q000600096Q00040004000600102Q00030007000400302Q0003000A000B4Q0001000300014Q00015Q00202Q00010001000100202Q00010001000C4Q00038Q0001000300016Q00014Q001A00015Q0020352Q010001000D0020352Q010001000200062A2Q01002400013Q0004533Q002400012Q001A00015Q0020352Q010001000D0020052Q010001000C2Q003901036Q006E0001000300012Q001A00015Q0020352Q010001000E0020352Q010001000200062A2Q01002E00013Q0004533Q002E00012Q001A00015Q0020352Q010001000E0020052Q010001000C2Q003901036Q006E0001000300012Q001A000100034Q00242Q010001000100123B2Q01000F3Q0020352Q010001001000062400023Q000100022Q001A3Q00044Q001A3Q00054Q003B0001000200010004533Q003900012Q001A3Q00064Q0024012Q000100012Q00FB3Q00013Q00013Q00033Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727400114Q001A7Q002035014Q000100062A012Q001000013Q0004533Q001000012Q001A7Q00205D5Q000100206Q000200122Q000200038Q0002000200064Q001000013Q0004533Q001000012Q001A3Q00014Q001A00015Q0020352Q01000100010020352Q01000100032Q003B3Q000200012Q00FB3Q00017Q000B3Q0003083Q00426F6E65526F2Q6C03053Q0056616C7565026Q00084003063Q004E6F7469667903053Q005469746C65030A3Q0057726F6E67205365612103073Q00436F6E74656E7403373Q00426F6E65204761636861206973206F6E6C7920617661696C61626C6520696E20536561203320284861756E74656420436173746C65292E03083Q004475726174696F6E026Q00144003083Q0053657456616C7565001C4Q001A7Q002035014Q0001002035014Q000200062A012Q001900013Q0004533Q001900012Q001A3Q00014Q0010012Q000100020026543Q0016000100030004533Q001600012Q001A000100023Q0020130001000100044Q00033Q000300302Q00030005000600302Q00030007000800302Q00030009000A4Q0001000300012Q00F500015Q00202Q00010001000100202Q00010001000B4Q00038Q0001000300016Q00014Q001A000100034Q00242Q01000100010004533Q001B00012Q001A3Q00044Q0024012Q000100012Q00FB3Q00017Q00093Q00030C3Q00736574636C6970626F617264031D3Q00682Q7470733A2Q2F646973636F72642E2Q672F6D556D4D45394446483403063Q004E6F7469667903053Q005469746C6503073Q00446973636F726403073Q00436F6E74656E7403193Q004C696E6B20636F7069656420746F20636C6970626F6172642103083Q004475726174696F6E026Q000840000B3Q001244012Q00013Q00122Q000100028Q000200019Q0000206Q00034Q00023Q000300302Q00020004000500302Q00020006000700302Q0002000800096Q000200016Q00017Q00093Q0003063Q004E6F7469667903053Q005469746C6503053Q00436F64657303073Q00436F6E74656E74031E3Q005374617274696E6720726564656D7074696F6E2070726F63652Q733Q2E03083Q004475726174696F6E027Q004003043Q007461736B03053Q00737061776E000F4Q000E7Q00206Q00014Q00023Q000300302Q00020002000300302Q00020004000500302Q0002000600076Q0002000100124Q00083Q00206Q000900062400013Q000100032Q001A3Q00014Q001A3Q00024Q001A8Q003B3Q000200012Q00FB3Q00013Q00013Q000F3Q0003063Q0069706169727303053Q007063612Q6C03063Q004E6F7469667903053Q005469746C6503073Q00436F6E74656E7403083Q00746F737472696E6703083Q004475726174696F6E027Q004003163Q004661696C656420746F2073656E64207265717565737403043Q007461736B03043Q0077616974026Q00E03F03053Q00436F64657303143Q00412Q6C20636F6465732070726F63652Q73656421026Q000840002C3Q00123B012Q00014Q001A00016Q00163Q000200020004533Q0022000100123B010500023Q00062400063Q000100022Q001A3Q00014Q0007012Q00044Q001600050002000600062A0105001600013Q0004533Q001600012Q001A000700023Q0020420107000700034Q00093Q000300102Q00090004000400122Q000A00066Q000B00066Q000A0002000200102Q00090005000A00302Q0009000700084Q00070009000100044Q001D00012Q001A000700023Q0020680107000700034Q00093Q000300102Q00090004000400302Q00090005000900302Q0009000700084Q00070009000100123B0107000A3Q00203501070007000B0012A80008000C4Q003B0007000200012Q001A01035Q0006973Q0004000100020004533Q000400012Q001A3Q00023Q0020135Q00034Q00023Q000300302Q00020004000D00302Q00020005000E00302Q00020007000F6Q000200012Q00FB3Q00013Q00013Q00013Q00030C3Q00496E766F6B6553657276657200064Q0038016Q00206Q00014Q000200018Q00029Q008Q00017Q001E3Q0003063Q0043616E63656C03093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q00506F736974696F6E03093Q004D61676E6974756465030A3Q0054772Q656E53702Q656403053Q0056616C7565025Q00C0724003093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D6503073Q00566563746F7233028Q00026Q00494003043Q00506C617903063Q004E6F7469667903053Q005469746C65030B3Q0054656C65706F7274696E6703073Q00436F6E74656E74030D3Q0054726176656C696E6720746F202Q033Q003Q2E03083Q004475726174696F6E026Q00084003093Q00436F6D706C6574656403073Q00436F2Q6E65637401514Q001A00016Q00612Q0100013Q00062A2Q01005000013Q0004533Q005000012Q001A000200013Q00062A0102000A00013Q0004533Q000A00012Q001A000200013Q0020050102000200012Q003B0002000200012Q001A000200023Q00203501020002000200062A0102001300013Q0004533Q001300010020050103000200030012A8000500044Q00CA0003000500020006BB00030014000100010004533Q001400012Q00FB3Q00013Q00203501030002000400206D0104000300054Q00040004000100202Q0004000400064Q000500033Q00202Q00050005000700202Q00050005000800062Q0005001E000100010004533Q001E00010012A8000500094Q001A000600044Q0064010700036Q00060002000100122Q0006000A3Q00202Q00060006000B4Q00070004000500122Q0008000C3Q00202Q00080008000D00202Q00080008000E4Q0006000800024Q000700053Q00202Q00070007000F4Q000900036Q000A00066Q000B3Q000100122Q000C00103Q00202Q000C000C000B00122Q000D00113Q00202Q000D000D000B00122Q000E00123Q00122Q000F00133Q00122Q001000126Q000D001000024Q000D0001000D4Q000C0002000200102Q000B0010000C4Q0007000B00024Q000700016Q000700013Q00202Q0007000700144Q0007000200014Q000700063Q00202Q0007000700154Q00093Q000300302Q00090016001700122Q000A00196Q000B5Q00122Q000C001A6Q000A000A000C00102Q00090018000A00302Q0009001B001C4Q0007000900014Q000700013Q00202Q00070007001D00202Q00070007001E00062400093Q000100022Q0007012Q00034Q0007012Q00024Q006E0007000900012Q001A01026Q00FB3Q00013Q00013Q00113Q00030E3Q0046696E6446697273744368696C64030A3Q004661726D427970612Q7303073Q0044657374726F7903103Q004661726D427970612Q73526F7461746503083Q0056656C6F6369747903073Q00566563746F72332Q033Q006E6577028Q0003053Q007061697273030B3Q004765744368696C6472656E2Q033Q0049734103083Q004261736550617274030A3Q0043616E436F2Q6C6964652Q0103083Q0048756D616E6F6964030D3Q00506C6174666F726D5374616E64012Q00324Q001D016Q00206Q000100122Q000200028Q0002000200064Q000A00013Q0004533Q000A00012Q001A7Q002035014Q0002002005014Q00032Q003B3Q000200012Q001A7Q002005014Q00010012A8000200044Q00CA3Q0002000200062A012Q001400013Q0004533Q001400012Q001A7Q002035014Q0004002005014Q00032Q003B3Q000200012Q001A7Q0012C8000100063Q00202Q00010001000700122Q000200083Q00122Q000300083Q00122Q000400086Q00010004000200104Q0005000100124Q00096Q000100013Q00202Q00010001000A4Q000100029Q00000200044Q0028000100200501050004000B0012A80007000C4Q00CA00050007000200062A0105002800013Q0004533Q002800010030520104000D000E0006973Q0022000100020004533Q002200012Q001A3Q00013Q002005014Q00010012A80002000F4Q00CA3Q0002000200062A012Q003100013Q0004533Q00310001003052012Q001000112Q00FB3Q00017Q00073Q0003063Q004E6F7469667903053Q005469746C6503073Q0053746F2Q70656403073Q00436F6E74656E7403133Q0054656C65706F72742063616E63652Q6C65642E03083Q004475726174696F6E027Q0040000A4Q003E9Q003Q000100016Q00013Q00206Q00014Q00023Q000300302Q00020002000300302Q00020004000500302Q0002000600076Q000200016Q00017Q00073Q0003063Q004E6F7469667903053Q005469746C6503093Q0046505320422Q6F737403073Q00436F6E74656E7403133Q004772617068696373206F7074696D697A65642103083Q004475726174696F6E026Q000840000A4Q003E9Q003Q000100016Q00013Q00206Q00014Q00023Q000300302Q00020002000300302Q00020004000500302Q0002000600076Q000200016Q00017Q002B3Q0003043Q007461736B03043Q0077616974026Q00E03F03093Q0043686573744661726D03053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q00026Q00F03F03053Q00706169727303093Q00776F726B7370616365030E3Q0047657444657363656E64616E74732Q033Q0049734103083Q00426173655061727403043Q004E616D6503043Q0066696E6403053Q004368657374030A3Q0054772Q656E53702Q656403083Q00506F736974696F6E03093Q004D61676E697475646503093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D6503043Q00506C6179030D3Q00506C61796261636B537461746503073Q00506C6179696E6703063Q0043616E63656C026Q33D33F03063Q004E6F7469667903053Q005469746C65030A3Q004368657374204661726D03073Q00436F6E74656E7403123Q004E6F2043686573747320466F756E643Q2E03083Q004475726174696F6E026Q000840027Q004000A73Q00123B012Q00013Q002035014Q00020012A8000100034Q001C3Q0002000200062A012Q00A600013Q0004533Q00A600012Q001A7Q002035014Q0004002035014Q000500062A014Q00013Q0004535Q00012Q001A3Q00013Q002035014Q00060006BB3Q0010000100010004533Q001000010004535Q00010020052Q013Q000700122E010300086Q00010003000200202Q00023Q000700122Q000400096Q00020004000200062Q0001001D00013Q0004533Q001D000100062A0102001D00013Q0004533Q001D000100203501030002000A002665000300220001000B0004533Q0022000100123B010300013Q0020350103000300020012A80004000C4Q003B0003000200010004535Q00012Q001A000300024Q0034010400016Q0003000200014Q00035Q00122Q0004000D3Q00122Q0005000E3Q00202Q00050005000F4Q000500066Q00043Q000600044Q009100012Q001A00095Q0020350109000900040020350109000900050006BB00090032000100010004533Q003200010004533Q009300012Q001A000900013Q00203501090009000600062A0109009300013Q0004533Q009300012Q001A000900013Q00205D00090009000600202Q00090009000700122Q000B00086Q0009000B000200062Q0009009300013Q0004533Q009300012Q001A000900013Q00203501090009000600203501090009000900203501090009000A002665000900440001000B0004533Q004400010004533Q009300012Q001A000900013Q00202F01090009000600202Q00010009000800202Q00090008001000122Q000B00116Q0009000B000200062Q0009009100013Q0004533Q009100010020350109000800120020050109000900130012A8000B00144Q00CA0009000B000200062A0109009100013Q0004533Q009100012Q0039010300014Q00D600098Q000900036Q00095Q00202Q00090009001500202Q00090009000500202Q000A0008001600202Q000B000100164Q000A000A000B00202Q000A000A001700122Q000B00183Q00202Q000B000B00194Q000C000A000900122Q000D001A3Q00202Q000D000D001B00202Q000D000D001C4Q000B000D00024Q000C00043Q00202Q000C000C001D4Q000E00016Q000F000B6Q00103Q000100202Q00110008001E00102Q0010001E00114Q000C0010000200202Q000D000C001F4Q000D0002000100202Q000D000C002000123B010E001A3Q002035010E000E0020002035010E000E0021000645010D008D0001000E0004533Q008D000100123B010E00013Q002049000E000E00024Q000E0001000100202Q000D000C00204Q000E00013Q00202Q000E000E000600062Q000E008100013Q0004533Q008100012Q001A000E00013Q002035010E000E0006002035010E000E0009002035010E000E000A002665000E00840001000B0004533Q00840001002005010E000C00222Q003B000E000200010004533Q008D00012Q001A000E5Q002035010E000E0004002035010E000E00050006BB000E006E000100010004533Q006E0001002005010E000C00222Q003B000E000200010004533Q008D00010004533Q006E000100123B010E00013Q002035010E000E00020012A8000F00234Q003B000E000200010006970004002C000100020004533Q002C00010006BB00033Q000100010004535Q00012Q001A000400033Q0006BB00043Q000100010004535Q00012Q001A000400053Q0020130004000400244Q00063Q000300302Q00060025002600302Q00060027002800302Q00060029002A4Q0004000600012Q0039010400014Q0025000400033Q00123B010400013Q0020350104000400020012A80005002B4Q003B0004000200010004535Q00012Q00FB3Q00017Q001C3Q0003043Q007461736B03043Q0077616974026Q00E03F030E3Q004175746F4661726D426F2Q73657303053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q0003063Q00434672616D652Q033Q006E6577026Q00344003153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03083Q004261636B7061636B03063Q00506172656E7403093Q004571756970542Q6F6C03063Q00412Q7461636B03063Q004E6F7469667903053Q005469746C6503093Q00426F2Q73204661726D03073Q00436F6E74656E74032F3Q004E6F20626F2Q73657320666F7220796F7572206C6576656C206172652063752Q72656E746C7920737061776E65642E03083Q004475726174696F6E026Q001440027Q004000663Q00123B012Q00013Q002035014Q00020012A8000100034Q001C3Q0002000200062A012Q006500013Q0004533Q006500012Q001A7Q002035014Q0004002035014Q000500062A012Q006200013Q0004533Q006200012Q001A3Q00013Q002035014Q000600063D2Q01001200013Q0004533Q001200010020052Q013Q00070012A8000300084Q00CA00010003000200063D0102001700013Q0004533Q0017000100200501023Q00070012A8000400094Q00CA00020004000200062A2Q013Q00013Q0004535Q000100062A01023Q00013Q0004535Q000100203501030002000A000E33010B3Q000100030004535Q00012Q001A000300024Q00E500030001000400062A0103005100013Q0004533Q005100010020050105000300070012A8000700094Q00CA00050007000200062A0105005100013Q0004533Q0051000100203501050003000900203501050005000A000E33010B0051000100050004533Q005100012Q003901056Q004F010500033Q00202Q00050003000700122Q000700086Q00050007000200062Q00053Q00013Q0004535Q000100203501060005000C0012DB0007000C3Q00202Q00070007000D00122Q0008000B3Q00122Q0009000E3Q00122Q000A000B6Q0007000A00024Q00060006000700102Q0001000C000600202Q00063Q000F00122Q000800106Q00060008000200062Q00060045000100010004533Q004500012Q001A000600013Q00203501060006001100200501060006000F0012A8000800104Q00CA00060008000200062A0106004D00013Q0004533Q004D000100203501070006001200067D0007004D00013Q0004533Q004D00010020050107000200132Q0007010900064Q006E0007000900012Q001A000700043Q0020050107000700142Q003B0007000200010004535Q00012Q001A000500033Q0006BB0005005D000100010004533Q005D00012Q001A000500053Q0020130005000500154Q00073Q000300302Q00070016001700302Q00070018001900302Q0007001A001B4Q0005000700012Q0039010500014Q0025000500033Q00123B010500013Q0020350105000500020012A80006001C4Q003B0005000200010004535Q00012Q0039017Q00253Q00033Q0004535Q00012Q00FB3Q00017Q005F3Q0003043Q007461736B03043Q0077616974026Q33C33F030E3Q004175746F4661726D426F2Q73657303053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q0003083Q00506F736974696F6E03093Q004D61676E697475646503043Q006D6174682Q033Q006D6178029A5Q99E93F03093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D65026Q00344003043Q00506C617903093Q00436F6D706C6574656403043Q005761697403053Q00737061776E03063Q004E6F7469667903053Q005469746C6503093Q00426F2Q73204661726D03073Q00436F6E74656E7403103Q004E6F20626F2Q73657320666F756E642E03083Q004475726174696F6E026Q000840030A3Q0053657276657220486F70026Q00F03F026Q00F83F03043Q004461746103053Q004C6576656C026Q00F0BF03093Q004175746F204661726D03123Q004D6178206C6576656C207265616368656421026Q001440026Q001040027Q0040026Q00184003093Q00506C6179657247756903043Q004D61696E03053Q00517565737403073Q0056697369626C6503093Q00436F6E7461696E6572030A3Q0051756573745469746C6503043Q005465787403063Q00737472696E6703043Q0066696E6403213Q004C6576656C20557021204162616E646F6E696E67206F6C642071756573743Q2E030C3Q00496E766F6B65536572766572030C3Q004162616E646F6E5175657374026Q00E03F03123Q00476F696E6720666F722071756573743Q2E026Q33F33F026Q001C40026Q33E33F030A3Q005374617274517565737403043Q006875676503093Q00776F726B737061636503073Q00456E656D69657303053Q007061697273030B3Q004765744368696C6472656E03043Q004E616D65026Q00394003083Q0048756E74696E67202Q033Q003Q2E026Q66E63F026Q00304003063Q00506172656E7403153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03083Q004261636B7061636B03093Q004571756970542Q6F6C02B81E85EB51B8BE3F03063Q00412Q7461636B027B14AE47E17AB43F03043Q005368697003083Q00456E67696E2Q657203073Q005374657761726403073Q004F2Q6669636572025Q0061B9C0025Q00C05440025Q00405FC0026Q00544003143Q0054726176656C696E6720746F20417265613Q2E026Q002E40026Q002440002F022Q00123B012Q00013Q00202F5Q000200122Q000100038Q000200019Q0000206Q000400206Q000500064Q008600013Q0004533Q008600012Q001A3Q00013Q002035014Q000600063D2Q01001000013Q0004533Q001000010020052Q013Q00070012A8000300084Q00CA00010003000200063D0102001500013Q0004533Q0015000100200501023Q00070012A8000400094Q00CA00020004000200062A2Q01008500013Q0004533Q0085000100062A0102008500013Q0004533Q0085000100203501030002000A000E33010B0085000100030004533Q008500012Q001A000300024Q00E500030001000400062A0103006600013Q0004533Q006600010020050105000300070012A8000700094Q00CA00050007000200062A0105006600013Q0004533Q0066000100203501050003000900203501050005000A000E33010B0066000100050004533Q006600012Q003901056Q004F010500033Q00202Q00050003000700122Q000700086Q00050007000200062Q0005008500013Q0004533Q008500012Q001A000600044Q0073000700046Q00060002000100202Q00060005000C00202Q00070001000C4Q00060006000700202Q00060006000D00122Q0007000E3Q00202Q00070007000F4Q000800056Q00080006000800122Q000900106Q00070009000200122Q000800113Q00202Q0008000800124Q000900073Q00122Q000A00133Q00202Q000A000A001400202Q000A000A00154Q0008000A00024Q000900066Q000A00016Q0009000200014Q000900073Q00202Q0009000900164Q000B00016Q000C00086Q000D3Q000100202Q000E0005001700122Q000F00173Q00202Q000F000F001200122Q0010000B3Q00122Q001100183Q00122Q0012000B6Q000F001200024Q000E000E000F00102Q000D0017000E4Q0009000D000200202Q000A000900194Q000A0002000100202Q000A0009001A00202Q000A000A001B4Q000A000200014Q000A00086Q000A0001000100122Q000A00013Q00202Q000A000A001C000624000B3Q000100042Q0007017Q001A3Q00014Q0007012Q00024Q001A3Q00094Q003B000A000200010004533Q008500012Q001A000500033Q0006BB00050081000100010004533Q008100012Q0039010500014Q0048010500036Q0005000A3Q00202Q00050005001D4Q00073Q000300302Q0007001E001F00302Q00070020002100302Q0007002200234Q0005000700014Q00055Q00202Q00050005002400062Q0005008100013Q0004533Q008100012Q001A00055Q00203501050005002400203501050005000500062A0105008100013Q0004533Q0081000100123B010500013Q00203201050005000200122Q000600256Q0005000200014Q0005000B6Q00050001000100123B010500013Q0020350105000500020012A8000600254Q003B0005000200012Q001A017Q001A3Q000C3Q00062A014Q00013Q0004535Q00012Q001A3Q00013Q002035014Q00060006BB3Q008E000100010004533Q008E00010004535Q00010020052Q013Q000700122E010300086Q00010003000200202Q00023Q000700122Q000400096Q00020004000200062Q0001009B00013Q0004533Q009B000100062A0102009B00013Q0004533Q009B000100203501030002000A002665000300A00001000B0004533Q00A0000100123B010300013Q0020350103000300020012A8000400264Q003B0003000200010004535Q00012Q001A000300013Q00209800030003002700202Q00030003002800202Q0003000300054Q000400046Q0005000D6Q000500053Q00122Q000600253Q00122Q000700293Q00042Q000500B200012Q001A0009000D4Q0061010900090008002035010A0009002500068A000A00B1000100030004533Q00B100012Q0007010400093Q0004533Q00B2000100044A010500AA00010006BB000400C0000100010004533Q00C000012Q001A0005000A3Q00201300050005001D4Q00073Q000300302Q0007001E002A00302Q00070020002B00302Q00070022002C4Q00050007000100123B010500013Q0020350105000500020012A80006002D4Q003B0005000200010004535Q000100203501050004002E00202B00060004002300202Q00070004002D00202Q00080004002C00202Q00090004002F4Q000A00013Q00202Q000A000A003000202Q000A000A003100202Q000A000A000700122Q000C00326Q000A000C000200062Q000B00CE0001000A0004533Q00CE0001002035010B000A003300062A010B00EB00013Q0004533Q00EB0001002035010C000A00340020F6000C000C003500202Q000C000C001E00202Q000C000C003600122Q000D00373Q00202Q000D000D00384Q000E000C6Q000F00076Q000D000F000200062Q000D00EB000100010004533Q00EB00012Q001A000D000A3Q002013000D000D001D4Q000F3Q000300302Q000F001E002A00302Q000F0020003900302Q000F0022002E4Q000D000F00012Q001A000D000E3Q002005010D000D003A0012A8000F003B4Q006E000D000F000100123B010D00013Q002035010D000D00020012A8000E003C4Q003B000D000200012Q0039010B5Q0006BB000B00292Q0100010004533Q00292Q012Q001A000C000A3Q002013000C000C001D4Q000E3Q000300302Q000E001E002A00302Q000E0020003D00302Q000E0022002E4Q000C000E0001002035010C0008000C002035010D0001000C2Q000B000C000C000D002035010C000C000D00123B010D000E3Q002035010D000D000F2Q001A000E00054Q004D010E000C000E0012A8000F003E4Q00CA000D000F00022Q001A000E00064Q0007010F00014Q003B000E0002000100123B010E00113Q002035010E000E00122Q0007010F000D3Q00123B011000133Q0020350110001000140020350110001000152Q00CA000E001000022Q00C2000F00073Q00202Q000F000F00164Q001100016Q0012000E6Q00133Q000100122Q001400173Q00202Q00140014001200122Q0015000B3Q00122Q0016003F3Q00122Q0017002C4Q00CA0014001700022Q009B00140008001400105B0113001700142Q00CA000F001300020020050110000F00192Q003B0010000200010020350110000F001A00204000100010001B4Q00100002000100122Q001000013Q00202Q00100010000200122Q001100406Q0010000200012Q001A0010000E3Q00200501100010003A0012A8001200414Q0007011300054Q006A001400066Q00100014000100122Q001000013Q00202Q00100010000200122Q001100106Q0010000200012Q00FC000C000C3Q001251010D000E3Q00202Q000D000D004200122Q000E00433Q00202Q000E000E000700122Q001000446Q000E0010000200062Q000E00532Q013Q0004533Q00532Q0100123B010F00453Q0020050110000E00462Q0044001000114Q0046000F3Q00110004533Q00512Q01002035011400130047000645011400512Q0100070004533Q00512Q010020050114001300070012A8001600094Q00CA00140016000200062A011400512Q013Q0004533Q00512Q0100203501140013000900203501140014000A000E33010B00512Q0100140004533Q00512Q010020050114001300070012A8001600084Q00CA00140016000200062A011400512Q013Q0004533Q00512Q0100203501140013000800205801140014000C00202Q00150001000C4Q00140014001500202Q00140014000D00062Q001400512Q01000D0004533Q00512Q012Q0007010D00144Q0007010C00133Q000697000F00372Q0100020004533Q00372Q0100062A010C00BF2Q013Q0004533Q00BF2Q01002035010F000C000800206B0010000F000C00202Q00110001000C4Q00100010001100202Q00100010000D000E2Q0048008B2Q0100100004533Q008B2Q012Q001A0011000A3Q00205F00110011001D4Q00133Q000300302Q0013001E002A00122Q001400496Q001500073Q00122Q0016004A6Q00140014001600102Q00130020001400302Q0013002200264Q0011001300014Q001100066Q001200016Q00110002000100122Q0011000E3Q00202Q00110011000F4Q001200056Q00120010001200122Q0013004B6Q00110013000200122Q001200113Q00202Q0012001200124Q001300113Q00122Q001400133Q00202Q00140014001400202Q0014001400154Q0012001400024Q001300073Q00202Q0013001300164Q001500016Q001600126Q00173Q000100202Q0018000F001700122Q001900173Q00202Q00190019001200122Q001A000B3Q00122Q001B004C3Q00122Q001C000B6Q0019001C00024Q00180018001900102Q0017001700184Q00130017000200202Q0014001300194Q00140002000100202Q00140013001A00202Q00140014001B4Q0014000200010012A8001100253Q0012A80012002D3Q0012A8001300253Q00044C001100BE2Q010020350115000C004D00062A01153Q00013Q0004535Q00010020350115000C000900203501150015000A002665001500972Q01000B0004533Q00972Q010004535Q00010020350115000F00170012DB001600173Q00202Q00160016001200122Q0017000B3Q00122Q0018004C3Q00122Q0019000B6Q0016001900024Q00150015001600102Q00010017001500202Q00153Q004E00122Q0017004F6Q00150017000200062Q001500AA2Q0100010004533Q00AA2Q012Q001A001500013Q00203501150015005000200501150015004E0012A80017004F4Q00CA00150017000200062A011500B62Q013Q0004533Q00B62Q0100203501160015004D00067D001600B62Q013Q0004533Q00B62Q010020050116000200512Q006A001800156Q00160018000100122Q001600013Q00202Q00160016000200122Q001700526Q0016000200012Q001A001600093Q0020400016001600534Q00160002000100122Q001600013Q00202Q00160016000200122Q001700546Q00160002000100044A0111008F2Q010004535Q00012Q0007010F00093Q0020050110000700380012A8001200554Q00CA0010001200020006BB001000D42Q0100010004533Q00D42Q010020050110000700380012A8001200564Q00CA0010001200020006BB001000D42Q0100010004533Q00D42Q010020050110000700380012A8001200574Q00CA0010001200020006BB001000D42Q0100010004533Q00D42Q010020050110000700380012A8001200584Q00CA00100012000200062A011000DB2Q013Q0004533Q00DB2Q0100123B011000173Q0020EA00100010001200122Q001100593Q00122Q0012005A3Q00122Q0013005B6Q0010001300024Q000F00103Q0020350110000F000C00203501110001000C2Q000B00100010001100203501100010000D000E33015C0029020100100004533Q002902012Q001A0011000A3Q00201300110011001D4Q00133Q000300302Q0013001E002A00302Q00130020005D00302Q00130022002E4Q0011001300012Q001A001100064Q0007011200014Q003B00110002000100123B011100113Q0020350111001100122Q001A001200054Q004D01120010001200123B011300133Q0020350113001300140020350113001300152Q00CA0011001300022Q00C2001200073Q00202Q0012001200164Q001400016Q001500116Q00163Q000100122Q001700173Q00202Q00170017001200122Q0018000B3Q00122Q0019005E3Q00122Q001A000B4Q00CA0017001A00022Q00290017000F001700102Q0016001700174Q00120016000200202Q0013001200194Q00130002000100202Q00130012001A00202Q00130013001B4Q00130002000100202Q00130007003800122Q001500554Q00CA0013001500020006BB00130015020100010004533Q001502010020050113000700380012A8001500564Q00CA0013001500020006BB00130015020100010004533Q001502010020050113000700380012A8001500574Q00CA00130015000200062A0113002702013Q0004533Q002702012Q001A001300084Q008600130001000100122Q001300013Q00202Q00130013000200122Q0014003C6Q00130002000100122Q001300173Q00202Q00130013001200122Q0014000B3Q00122Q0015000B3Q00122Q0016005F6Q0013001600024Q0013000F001300102Q00010017001300122Q001300013Q00202Q00130013000200122Q001400266Q0013000200012Q001A001300084Q002401130001000100123B011100013Q0020350111001100020012A80012002E4Q003B0011000200010004535Q00012Q00FB3Q00013Q00013Q00093Q0003153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03083Q004261636B7061636B03063Q00506172656E7403093Q004571756970542Q6F6C03043Q007461736B03043Q0077616974026Q33C33F03063Q00412Q7461636B001D4Q0017016Q00206Q000100122Q000200028Q0002000200064Q000B000100010004533Q000B00012Q001A3Q00013Q002035014Q0003002005014Q00010012A8000200024Q00CA3Q0002000200062A012Q001900013Q0004533Q001900010020352Q013Q00042Q001A00025Q00067D00010019000100020004533Q001900012Q001A000100023Q00204F0001000100054Q00038Q00010003000100122Q000100063Q00202Q00010001000700122Q000200086Q0001000200012Q001A000100033Q0020052Q01000100092Q003B0001000200012Q00FB3Q00017Q00053Q0003093Q0043686172616374657203043Q007461736B03053Q00737061776E030E3Q00436861726163746572412Q64656403073Q00436F2Q6E656374000F4Q001A7Q002035014Q000100062A012Q000800013Q0004533Q0008000100123B012Q00023Q002035014Q00032Q001A000100014Q003B3Q000200012Q001A7Q002035014Q0004002005014Q000500062400023Q000100012Q001A3Q00014Q006E3Q000200012Q00FB3Q00013Q00018Q00034Q001A8Q0024012Q000100012Q00FB3Q00017Q002B3Q0003043Q007461736B03043Q007761697403083Q00426F6E65526F2Q6C03053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403073Q00566563746F72332Q033Q006E6577025Q008DC2C0025Q00C06140025Q00A7B54003093Q00776F726B737061636503043Q004E50437303053Q007061697273030B3Q004765744368696C6472656E03043Q004E616D65030A3Q004465617468204B696E6703083Q00506F736974696F6E2Q033Q004D617003093Q004D61676E6974756465026Q002E4003063Q004E6F7469667903053Q005469746C6503093Q00426F6E6520526F2Q6C03073Q00436F6E74656E7403173Q004D6F76696E6720746F204465617468204B696E673Q2E03083Q004475726174696F6E026Q00F03F03093Q0054772Q656E496E666F025Q00C0724003043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D65028Q00026Q00144003043Q00506C617903093Q00436F6D706C6574656403043Q005761697403053Q007063612Q6C026Q00044000953Q00123B012Q00013Q002035014Q00022Q0010012Q0001000200062A012Q009400013Q0004533Q009400012Q001A7Q002035014Q0003002035014Q000400062A012Q008F00013Q0004533Q008F00012Q001A3Q00013Q002035014Q00050006BB3Q000F000100010004533Q000F00010004535Q00010020052Q013Q00060012A8000300074Q00CA0001000300020006BB00010015000100010004533Q001500010004535Q000100123B010200083Q00207F00020002000900122Q0003000A3Q00122Q0004000B3Q00122Q0005000C6Q00020005000200122Q0003000D3Q00202Q00030003000600122Q0005000E6Q00030005000200062Q0003003500013Q0004533Q0035000100123B0103000F3Q0012C90004000D3Q00202Q00040004000E00202Q0004000400104Q000400056Q00033Q000500044Q003300010020350108000700110026D300080033000100120004533Q003300010020050108000700060012A8000A00074Q00CA0008000A000200062A0108003300013Q0004533Q003300010020350108000700070020350102000800130004533Q0035000100069700030028000100020004533Q0028000100123B0103000D3Q0020050103000300060012A8000500144Q00CA00030005000200062A0103005700013Q0004533Q0057000100123B0103000D3Q00205D00030003001400202Q00030003000600122Q0005000E6Q00030005000200062Q0003005700013Q0004533Q0057000100123B0103000F3Q0012AB0004000D3Q00202Q00040004001400202Q00040004000E00202Q0004000400104Q000400056Q00033Q000500044Q005500010020350108000700110026D300080055000100120004533Q005500010020050108000700060012A8000A00074Q00CA0008000A000200062A0108005500013Q0004533Q005500010020350108000700070020350102000800130004533Q005700010006970003004A000100020004533Q004A00010020350103000100132Q000B000300030002002035010300030015000E3301160086000100030004533Q008600012Q001A000400023Q0020130004000400174Q00063Q000300302Q00060018001900302Q0006001A001B00302Q0006001C001D4Q0004000600012Q00CF000400036Q000500016Q00040002000100122Q0004001E3Q00202Q00040004000900202Q00050003001F00122Q000600203Q00202Q00060006002100202Q0006000600224Q0004000600022Q001A000500043Q00208D0005000500234Q000700016Q000800046Q00093Q000100122Q000A00243Q00202Q000A000A000900122Q000B00083Q00202Q000B000B000900122Q000C00253Q00122Q000D00263Q0012A8000E00254Q00CA000B000E00022Q00E4000B0002000B2Q001C000A0002000200105B01090024000A2Q00CA0005000900020020050106000500272Q003B0006000200010020350106000500280020050106000600292Q003B0006000200012Q001A000600054Q00240106000100010004535Q000100123B0104002A3Q00062400053Q000100012Q001A3Q00064Q00C000040002000500122Q000600013Q00202Q00060006000200122Q0007002B6Q00060002000100046Q000100123B012Q00013Q002035014Q00020012A80001001D4Q003B3Q000200010004535Q00012Q00FB3Q00013Q00013Q00043Q00030C3Q00496E766F6B6553657276657203053Q00426F6E65732Q033Q00427579026Q00F03F00084Q00377Q00206Q000100122Q000200023Q00122Q000300033Q00122Q000400043Q00122Q000500048Q000500016Q00017Q003F3Q0003043Q007461736B03043Q0077616974029A5Q99B93F03083Q00526169644661726D03053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q0003093Q00776F726B737061636503073Q00456E656D69657303043Q006D61746803043Q006875676503053Q007061697273030B3Q004765744368696C6472656E03083Q00506F736974696F6E03093Q004D61676E6974756465025Q0070A740026Q004E40030A3Q0054772Q656E53702Q6564025Q00C0724003093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D65026Q002E4003043Q00506C617903043Q007469636B026Q00F03F03063Q00506172656E7403063Q0043616E63656C03153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03083Q004261636B7061636B03093Q004571756970542Q6F6C03063Q00412Q7461636B027Q0040030C3Q005F576F726C644F726967696E03093Q004C6F636174696F6E73026Q0079402Q0103063Q004E6F7469667903053Q005469746C6503093Q004175746F205261696403073Q00436F6E74656E74031F3Q0049736C616E6420436C65617221204D6F76696E6720746F206E6578743Q2E03083Q004475726174696F6E026Q0008402Q033Q0049734103053Q004D6F64656C030E3Q004765744D6F64656C434672616D6503013Q0070026Q00544003093Q00436F6D706C6574656403043Q0057616974031A3Q00526169642046696E6973686564212053746F2Q70696E673Q2E026Q00144003083Q0053657456616C75650035012Q00123B012Q00013Q002035014Q00020012A8000100034Q001C3Q0002000200062A012Q00342Q013Q0004533Q00342Q012Q001A7Q002035014Q0004002035014Q000500062A014Q00013Q0004535Q00012Q001A3Q00013Q002035014Q000600063D2Q01001200013Q0004533Q001200010020052Q013Q00070012A8000300084Q00CA00010003000200063D0102001700013Q0004533Q0017000100200501023Q00070012A8000400094Q00CA00020004000200062A2Q013Q00013Q0004535Q000100062A01023Q00013Q0004535Q000100203501030002000A0026650003001F0001000B0004533Q001F00010004535Q00012Q001A000300024Q0040010400016Q00030002000100122Q0003000C3Q00202Q00030003000700122Q0005000D6Q0003000500024Q000400043Q00122Q0005000E3Q00202Q00050005000F00062Q0003004900013Q0004533Q0049000100123B010600103Q0020050107000300112Q0044000700084Q004600063Q00080004533Q00470001002005010B000A000700122E010D00086Q000B000D000200202Q000C000A000700122Q000E00096Q000C000E000200062Q000B004700013Q0004533Q0047000100062A010C004700013Q0004533Q00470001002035010D000C000A000E33010B00470001000D0004533Q00470001002035010D000B0012002035010E000100122Q000B000D000D000E002035010D000D0013002652000D0047000100140004533Q0047000100064A000D0047000100050004533Q004700012Q00070105000D4Q00070104000B3Q00069700060030000100020004533Q0030000100062A010400AD00013Q0004533Q00AD00010020350106000400120020350107000100122Q000B000600060007002035010600060013000E330115008E000100060004533Q008E00012Q001A00075Q0020350107000700160020350107000700050006BB00070057000100010004533Q005700010012A8000700173Q00123B010800183Q00201D0008000800194Q00090006000700122Q000A001A3Q00202Q000A000A001B00202Q000A000A001C4Q0008000A00024Q000900033Q00202Q00090009001D4Q000B00016Q000C00086Q000D3Q000100202Q000E0004001E00122Q000F001E3Q00202Q000F000F001900122Q0010000B3Q00122Q0011001F3Q00122Q0012000B6Q000F001200024Q000E000E000F00102Q000D001E000E4Q0009000D000200202Q000A000900204Q000A0002000100122Q000A00216Q000A00010002002035010B00040012002035010C000100122Q000B000B000B000C002035010B000B0013000E330115008B0001000B0004533Q008B000100123B010B00214Q0010010B000100022Q000B000B000B000A002652000B008B000100220004533Q008B000100123B010B00013Q00202D010B000B00024Q000B000100014Q000B5Q00202Q000B000B000400202Q000B000B000500062Q000B008700013Q0004533Q00870001002035010B000400230006BB000B0071000100010004533Q00710001002005010B000900242Q003B000B000200010004533Q008B00010004533Q00710001002005010B000900242Q003B000B000200010004535Q000100203501070004001E0012DB0008001E3Q00202Q00080008001900122Q0009000B3Q00122Q000A001F3Q00122Q000B000B6Q0008000B00024Q00070007000800102Q0001001E000700202Q00073Q002500122Q000900266Q00070009000200062Q000700A1000100010004533Q00A100012Q001A000700013Q0020350107000700270020050107000700250012A8000900264Q00CA00070009000200062A010700A900013Q0004533Q00A9000100203501080007002300067D000800A900013Q0004533Q00A900010020050108000200282Q0007010A00074Q006E0008000A00012Q001A000800043Q0020050108000800292Q003B0008000200010004535Q000100123B010600013Q0020B200060006000200122Q0007002A6Q0006000200014Q00065Q00062Q000300C900013Q0004533Q00C9000100123B010700103Q0020050108000300112Q0044000800094Q004600073Q00090004533Q00C70001002005010C000B00070012A8000E00084Q00CA000C000E000200062A010C00C700013Q0004533Q00C70001002035010C000B000800201C010C000C001200202Q000D000100124Q000C000C000D00202Q000C000C001300262Q000C00C7000100140004533Q00C700012Q0039010600013Q0004533Q00C90001000697000700B9000100020004533Q00B900010006BB00063Q000100010004535Q00012Q001A00075Q00203501070007000400203501070007000500062A01073Q00013Q0004535Q000100123B0107000C3Q0020050107000700070012A80009002B4Q00CA00070009000200062A010700DB00013Q0004533Q00DB000100123B0107000C3Q00203501070007002B0020050107000700070012A80009002C4Q00CA00070009000200062A010700EC00013Q0004533Q00EC000100123B010800103Q0020050109000700112Q00440009000A4Q004600083Q000A0004533Q00EA0001002035010D000C0012002035010E000100122Q000B000D000D000E002035010D000D0013002652000D00EA0001002D0004533Q00EA00012Q001A000D00053Q00208C000D000C002E000697000800E2000100020004533Q00E200012Q001A000800064Q001001080001000200062A010800272Q013Q0004533Q00272Q012Q001A000900073Q00201300090009002F4Q000B3Q000300302Q000B0030003100302Q000B0032003300302Q000B003400354Q0009000B00010020050109000800360012A8000B00374Q00CA0009000B000200062A01092Q002Q013Q0004534Q002Q010020050109000800382Q001C0009000200020006BB0009003Q0100010004533Q003Q0100203501090008001E002035010A0001001200206D010B000900394Q000A000A000B00202Q000A000A00134Q000B5Q00202Q000B000B001600202Q000B000B000500062Q000B000B2Q0100010004533Q000B2Q010012A8000B00174Q001A000C00033Q002002010C000C001D4Q000E00013Q00122Q000F00183Q00202Q000F000F00194Q0010000A000B00122Q0011001A3Q00202Q00110011001B00202Q00110011001C4Q000F001100024Q00103Q000100122Q0011001E3Q00202Q00110011001900122Q0012000B3Q00122Q0013003A3Q00122Q0014000B6Q0011001400024Q00110009001100102Q0010001E00114Q000C0010000200202Q000D000C00204Q000D0002000100202Q000D000C003B00202Q000D000D003C4Q000D000200014Q000D00053Q00202Q000D0008002E00046Q00012Q001A000900073Q00201300090009002F4Q000B3Q000300302Q000B0030003100302Q000B0032003D00302Q000B0034003E4Q0009000B00012Q001A00095Q00203501090009000400200501090009003F2Q0039010B6Q006E0009000B00010004535Q00012Q00FB3Q00017Q003A3Q0003043Q007461736B03043Q007761697403083Q00426F6E654661726D03053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q00026Q00F03F03083Q00506F736974696F6E03093Q004D61676E6974756465025Q00409F4003063Q004E6F7469667903053Q005469746C6503093Q00426F6E65204661726D03073Q00436F6E74656E74031E3Q0054726176656C696E6720746F204861756E74656420436173746C653Q2E03083Q004475726174696F6E026Q00084003093Q0054772Q656E496E666F2Q033Q006E6577025Q00C0724003043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D6503043Q00506C617903093Q00436F6D706C6574656403043Q0057616974026Q00E03F030F3Q005265626F726E20536B656C65746F6E030D3Q004C6976696E67205A6F6D626965030C3Q0044656D6F6E696320536F756C030F3Q00506F2Q73652Q736564204D752Q6D7903043Q006D61746803043Q006875676503053Q00706169727303093Q00776F726B737061636503073Q00456E656D696573030B3Q004765744368696C6472656E03053Q007461626C6503043Q0066696E6403043Q004E616D6503063Q00506172656E7403073Q00566563746F7233026Q00104003153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03083Q004261636B7061636B03093Q004571756970542Q6F6C03063Q00412Q7461636B025Q00407F40024Q008095C2C0025Q00406540025Q0094B64000DB3Q00123B012Q00013Q002035014Q00022Q0010012Q0001000200062A012Q00DA00013Q0004533Q00DA00012Q001A7Q002035014Q0003002035014Q000400062A014Q00013Q0004535Q00012Q001A3Q00013Q002035014Q00050006BB3Q000F000100010004533Q000F00010004535Q00010020052Q013Q000600122E010300076Q00010003000200202Q00023Q000600122Q000400086Q00020004000200062Q0001001C00013Q0004533Q001C000100062A0102001C00013Q0004533Q001C0001002035010300020009002665000300210001000A0004533Q0021000100123B010300013Q0020350103000300020012A80004000B4Q003B0003000200010004535Q00012Q001A000300024Q00AF000400016Q0003000200014Q000300033Q00202Q00030003000C00202Q00040001000C4Q00030003000400202Q00030003000D000E2Q000E004A000100030004533Q004A00012Q001A000400043Q00201300040004000F4Q00063Q000300302Q00060010001100302Q00060012001300302Q0006001400154Q00040006000100123B010400163Q00203501040004001700200200050003001800123B010600193Q00203501060006001A00203501060006001B2Q00CA0004000600022Q001A000500053Q00200501050005001C2Q0007010700014Q0007010800044Q006701093Q00014Q000A00033Q00102Q0009001D000A4Q00050009000200202Q00060005001E4Q00060002000100202Q00060005001F0020400006000600204Q00060002000100122Q000600013Q00202Q00060006000200122Q000700216Q0006000200012Q00A9000400043Q00129D000500223Q00122Q000600233Q00122Q000700243Q00122Q000800256Q0004000400012Q00FC000500053Q0012BD000600263Q00202Q00060006002700122Q000700283Q00122Q000800293Q00202Q00080008002A00202Q00080008002B4Q000800096Q00073Q000900044Q0073000100123B010C002C3Q0020BE000C000C002D4Q000D00043Q00202Q000E000B002E4Q000C000E000200062Q000C007300013Q0004533Q00730001002005010C000B00060012A8000E00074Q00CA000C000E000200062A010C007300013Q0004533Q00730001002035010C000B0008002035010C000C0009000E33010A00730001000C0004533Q00730001002035010C000B0007002058010C000C000C00202Q000D0001000C4Q000C000C000D00202Q000C000C000D00062Q000C0073000100060004533Q007300012Q00070106000C4Q00070105000B3Q0006970007005A000100020004533Q005A000100062A010500CB00013Q0004533Q00CB00012Q001A00075Q0020350107000700030020350107000700040006BB0007007D000100010004533Q007D00010004535Q000100062A01053Q00013Q0004535Q000100203501070005002F00062A01073Q00013Q0004535Q00010020050107000500060012A8000900084Q00CA00070009000200062A01073Q00013Q0004535Q00010020350107000500080020350107000700090026650007008C0001000A0004533Q008C00010004535Q00012Q001A000700013Q00203501070007000500062A01073Q00013Q0004535Q00012Q001A000700013Q002035010700070005002035010700070008002035010700070009002665000700970001000A0004533Q009700010004535Q00012Q001A000700013Q00201700070007000500202Q0001000700074Q000700026Q000800016Q00070002000100202Q00070005000700202Q00070007000C00122Q0008001D3Q00202Q00080008001700122Q000900303Q00202Q00090009001700122Q000A000A3Q00122Q000B00313Q00122Q000C000A6Q0009000C00024Q0009000700094Q000A00076Q0008000A000200102Q0001001D000800202Q00083Q003200122Q000A00336Q0008000A000200062Q000800B5000100010004533Q00B500012Q001A000800013Q0020350108000800340020050108000800320012A8000A00334Q00CA0008000A000200062A010800BD00013Q0004533Q00BD000100203501090008002F00067D000900BD00013Q0004533Q00BD00010020050109000200352Q0007010B00084Q006E0009000B00012Q001A000900063Q0020060009000900364Q00090002000100122Q000900013Q00202Q0009000900024Q00090001000100202Q00090005000800202Q00090009000900262Q00093Q0001000A0004535Q000100203501090005002F0006BB00090077000100010004533Q007700010004535Q00012Q001A000700033Q00206B00070007000C00202Q00080001000C4Q00070007000800202Q00070007000D000E2Q00373Q000100070004535Q000100123B0108001D3Q00202201080008001700122Q000900383Q00122Q000A00393Q00122Q000B003A6Q0008000B000200102Q0001001D000800046Q00012Q00FB3Q00017Q00013Q0003083Q004D696E696D697A6500044Q001A7Q002005014Q00012Q003B3Q000200012Q00FB3Q00017Q000D3Q0003083Q00506F736974696F6E03053Q005544696D322Q033Q006E657703013Q005803053Q005363616C6503063Q004F2Q6673657403013Q005903043Q0067616D65030A3Q0047657453657276696365030C3Q0054772Q656E5365727669636503063Q0043726561746503093Q0054772Q656E496E666F03043Q00506C617901263Q00201E2Q013Q00014Q00028Q00010001000200122Q000200023Q00202Q0002000200034Q000300013Q00202Q00030003000400202Q0003000300054Q000400013Q00202Q00040004000400202Q00040004000600202Q0005000100044Q0004000400054Q000500013Q00202Q00050005000700202Q0005000500054Q000600013Q00202Q00060006000700202Q00060006000600202Q0007000100074Q0006000600074Q00020006000200122Q000300083Q00202Q00030003000900122Q0005000A6Q00030005000200202Q00030003000B4Q000500023Q00122Q0006000C3Q00202Q0006000600034Q000700036Q0006000200024Q00073Q000100102Q0007000100024Q00030007000200202Q00030003000D4Q0003000200016Q00017Q00073Q00030D3Q0055736572496E7075745479706503043Q00456E756D030C3Q004D6F75736542752Q746F6E3103053Q00546F75636803083Q00506F736974696F6E03073Q004368616E67656403073Q00436F2Q6E656374011A3Q00200C2Q013Q000100122Q000200023Q00202Q00020002000100202Q00020002000300062Q0001000C000100020004533Q000C00010020352Q013Q000100123B010200023Q0020350102000200010020350102000200040006452Q010019000100020004533Q001900012Q00392Q0100014Q00532Q015Q00202Q00013Q00054Q000100016Q000100033Q00202Q0001000100054Q000100023Q00202Q00013Q000600202Q00010001000700062400033Q000100022Q0007017Q001A8Q006E0001000300012Q00FB3Q00013Q00013Q00033Q00030E3Q0055736572496E707574537461746503043Q00456E756D2Q033Q00456E64000A4Q00577Q00206Q000100122Q000100023Q00202Q00010001000100202Q00010001000300064Q0009000100010004533Q000900012Q0039017Q00253Q00014Q00FB3Q00017Q00043Q00030D3Q0055736572496E7075745479706503043Q00456E756D030D3Q004D6F7573654D6F76656D656E7403053Q00546F75636801133Q00200C2Q013Q000100122Q000200023Q00202Q00020002000100202Q00020002000300062Q0001000C000100020004533Q000C00010020352Q013Q000100123B010200023Q0020350102000200010020350102000200040006452Q010012000100020004533Q001200012Q001A00015Q00062A2Q01001200013Q0004533Q001200012Q001A000100014Q000701026Q003B0001000200012Q00FB3Q00017Q00", GetFEnv(), ...);
