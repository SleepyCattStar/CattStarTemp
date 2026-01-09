
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
				local FlatIdent_12703 = 0;
				local b;
				while true do
					if (FlatIdent_12703 == 0) then
						b = Rep(a, repeatNext);
						repeatNext = nil;
						FlatIdent_12703 = 1;
					end
					if (FlatIdent_12703 == 1) then
						return b;
					end
				end
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_475BC = 0;
			local Res;
			while true do
				if (FlatIdent_475BC == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_1F33B = 0;
			local Plc;
			while true do
				if (FlatIdent_1F33B == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_60EA1 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_60EA1 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_60EA1 = 2;
			end
			if (FlatIdent_60EA1 == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_1BC4A = 0;
						while true do
							if (FlatIdent_1BC4A == 0) then
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
			if (FlatIdent_60EA1 == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_60EA1 = 3;
			end
			if (FlatIdent_60EA1 == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_60EA1 = 1;
			end
		end
	end
	local function gString(Len)
		local FlatIdent_C460 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_C460 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_C460 = 2;
			end
			if (FlatIdent_C460 == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_C460 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_C460 = 3;
			end
			if (FlatIdent_C460 == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_27957 = 0;
					while true do
						if (0 == FlatIdent_27957) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_C460 = 1;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_397D1 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (FlatIdent_397D1 == 2) then
				for Idx = 1, gBits32() do
					local Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_77C29 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_77C29 == 1) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									local FlatIdent_7A75F = 0;
									while true do
										if (FlatIdent_7A75F == 0) then
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
									local FlatIdent_1B1BA = 0;
									while true do
										if (FlatIdent_1B1BA == 0) then
											Inst[3] = gBits32() - (2 ^ 16);
											Inst[4] = gBits16();
											break;
										end
									end
								end
								FlatIdent_77C29 = 2;
							end
							if (FlatIdent_77C29 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_77C29 = 1;
							end
							if (FlatIdent_77C29 == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
							if (FlatIdent_77C29 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_77C29 = 3;
							end
						end
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_397D1 == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_397D1 = 1;
			end
			if (1 == FlatIdent_397D1) then
				ConstCount = gBits32();
				Consts = {};
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
				FlatIdent_397D1 = 2;
			end
		end
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
				local FlatIdent_2B407 = 0;
				while true do
					if (FlatIdent_2B407 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_2B407 = 1;
					end
					if (FlatIdent_2B407 == 1) then
						if (Enum <= 33) then
							if (Enum <= 16) then
								if (Enum <= 7) then
									if (Enum <= 3) then
										if (Enum <= 1) then
											if (Enum == 0) then
												local FlatIdent_66799 = 0;
												local B;
												local A;
												while true do
													if (2 == FlatIdent_66799) then
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_66799 = 3;
													end
													if (4 == FlatIdent_66799) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														break;
													end
													if (FlatIdent_66799 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_66799 = 1;
													end
													if (FlatIdent_66799 == 1) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_66799 = 2;
													end
													if (FlatIdent_66799 == 3) then
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_66799 = 4;
													end
												end
											else
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											end
										elseif (Enum == 2) then
											do
												return;
											end
										else
											local FlatIdent_1E39B = 0;
											local A;
											while true do
												if (FlatIdent_1E39B == 0) then
													A = Inst[2];
													do
														return Stk[A](Unpack(Stk, A + 1, Top));
													end
													break;
												end
											end
										end
									elseif (Enum <= 5) then
										if (Enum > 4) then
											local FlatIdent_189F0 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_189F0 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_189F0 = 3;
												end
												if (7 == FlatIdent_189F0) then
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_189F0 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													FlatIdent_189F0 = 2;
												end
												if (FlatIdent_189F0 == 6) then
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_189F0 = 7;
												end
												if (3 == FlatIdent_189F0) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_189F0 = 4;
												end
												if (FlatIdent_189F0 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_189F0 = 6;
												end
												if (4 == FlatIdent_189F0) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_189F0 = 5;
												end
												if (FlatIdent_189F0 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_189F0 = 1;
												end
											end
										else
											local FlatIdent_49280 = 0;
											local A;
											while true do
												if (FlatIdent_49280 == 0) then
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													break;
												end
											end
										end
									elseif (Enum == 6) then
										local FlatIdent_7F121 = 0;
										local A;
										while true do
											if (FlatIdent_7F121 == 0) then
												A = Inst[2];
												do
													return Unpack(Stk, A, Top);
												end
												break;
											end
										end
									elseif not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 11) then
									if (Enum <= 9) then
										if (Enum > 8) then
											local FlatIdent_8A1DB = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_8A1DB == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_8A1DB = 1;
												end
												if (FlatIdent_8A1DB == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_8A1DB == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_8A1DB = 4;
												end
												if (FlatIdent_8A1DB == 2) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_8A1DB = 3;
												end
												if (FlatIdent_8A1DB == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_8A1DB = 2;
												end
											end
										else
											local FlatIdent_86ECC = 0;
											local A;
											while true do
												if (FlatIdent_86ECC == 0) then
													A = Inst[2];
													Stk[A] = Stk[A]();
													break;
												end
											end
										end
									elseif (Enum > 10) then
										local FlatIdent_206F8 = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_206F8 == 6) then
												for Idx = A, Inst[4] do
													local FlatIdent_6D9D2 = 0;
													while true do
														if (FlatIdent_6D9D2 == 0) then
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
											if (FlatIdent_206F8 == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												FlatIdent_206F8 = 1;
											end
											if (FlatIdent_206F8 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_206F8 = 3;
											end
											if (FlatIdent_206F8 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_206F8 = 4;
											end
											if (5 == FlatIdent_206F8) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_206F8 = 6;
											end
											if (FlatIdent_206F8 == 1) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_206F8 = 2;
											end
											if (4 == FlatIdent_206F8) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_15C34 = 0;
													while true do
														if (FlatIdent_15C34 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												FlatIdent_206F8 = 5;
											end
										end
									elseif (Stk[Inst[2]] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 13) then
									if (Enum == 12) then
										local FlatIdent_6225E = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_6225E == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_6225E = 4;
											end
											if (FlatIdent_6225E == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_6225E = 1;
											end
											if (FlatIdent_6225E == 1) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6225E = 2;
											end
											if (FlatIdent_6225E == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
											if (FlatIdent_6225E == 2) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_6225E = 3;
											end
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									end
								elseif (Enum <= 14) then
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
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
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								elseif (Enum > 15) then
									Stk[Inst[2]] = {};
								else
									local FlatIdent_2C2F3 = 0;
									local A;
									while true do
										if (FlatIdent_2C2F3 == 0) then
											A = Inst[2];
											do
												return Stk[A], Stk[A + 1];
											end
											break;
										end
									end
								end
							elseif (Enum <= 24) then
								if (Enum <= 20) then
									if (Enum <= 18) then
										if (Enum == 17) then
											local A = Inst[2];
											local Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											local Edx = 0;
											for Idx = A, Top do
												local FlatIdent_630B0 = 0;
												while true do
													if (FlatIdent_630B0 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
										else
											local FlatIdent_3B7E2 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_3B7E2 == 2) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3B7E2 = 3;
												end
												if (FlatIdent_3B7E2 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_3B7E2 = 6;
												end
												if (FlatIdent_3B7E2 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_3B7E2 = 1;
												end
												if (FlatIdent_3B7E2 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_3B7E2 = 10;
												end
												if (FlatIdent_3B7E2 == 1) then
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_3B7E2 = 2;
												end
												if (FlatIdent_3B7E2 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_3B7E2 = 9;
												end
												if (FlatIdent_3B7E2 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_3B7E2 = 5;
												end
												if (FlatIdent_3B7E2 == 10) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if (Stk[Inst[2]] ~= Inst[4]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_3B7E2 == 3) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_3B7E2 = 4;
												end
												if (FlatIdent_3B7E2 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_3B7E2 = 7;
												end
												if (FlatIdent_3B7E2 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_3B7E2 = 8;
												end
											end
										end
									elseif (Enum > 19) then
										local FlatIdent_15A17 = 0;
										local B;
										local K;
										while true do
											if (FlatIdent_15A17 == 1) then
												for Idx = B + 1, Inst[4] do
													K = K .. Stk[Idx];
												end
												Stk[Inst[2]] = K;
												break;
											end
											if (FlatIdent_15A17 == 0) then
												B = Inst[3];
												K = Stk[B];
												FlatIdent_15A17 = 1;
											end
										end
									elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 22) then
									if (Enum > 21) then
										Stk[Inst[2]] = Inst[3];
									elseif (Stk[Inst[2]] ~= Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 23) then
									if (Stk[Inst[2]] < Inst[4]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_44603 = 0;
									local K;
									local B;
									local A;
									while true do
										if (FlatIdent_44603 == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44603 = 4;
										end
										if (4 == FlatIdent_44603) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44603 = 5;
										end
										if (2 == FlatIdent_44603) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44603 = 3;
										end
										if (FlatIdent_44603 == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											break;
										end
										if (FlatIdent_44603 == 0) then
											K = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44603 = 1;
										end
										if (FlatIdent_44603 == 5) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_44603 = 6;
										end
										if (6 == FlatIdent_44603) then
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											FlatIdent_44603 = 7;
										end
										if (1 == FlatIdent_44603) then
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44603 = 2;
										end
									end
								end
							elseif (Enum <= 28) then
								if (Enum <= 26) then
									if (Enum > 25) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
									else
										VIP = Inst[3];
									end
								elseif (Enum > 27) then
									local FlatIdent_94AF7 = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_94AF7 == 0) then
											A = Inst[2];
											Results = {Stk[A]()};
											FlatIdent_94AF7 = 1;
										end
										if (FlatIdent_94AF7 == 1) then
											Limit = Inst[4];
											Edx = 0;
											FlatIdent_94AF7 = 2;
										end
										if (2 == FlatIdent_94AF7) then
											for Idx = A, Limit do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
									end
								else
									local FlatIdent_3B868 = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_3B868 == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_3B868 = 1;
										end
										if (1 == FlatIdent_3B868) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
									end
								end
							elseif (Enum <= 30) then
								if (Enum == 29) then
									local FlatIdent_829F9 = 0;
									local A;
									while true do
										if (FlatIdent_829F9 == 12) then
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
											FlatIdent_829F9 = 13;
										end
										if (FlatIdent_829F9 == 8) then
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
											FlatIdent_829F9 = 9;
										end
										if (6 == FlatIdent_829F9) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_829F9 = 7;
										end
										if (FlatIdent_829F9 == 10) then
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
											FlatIdent_829F9 = 11;
										end
										if (FlatIdent_829F9 == 13) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_829F9 == 7) then
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
											FlatIdent_829F9 = 8;
										end
										if (FlatIdent_829F9 == 3) then
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
											FlatIdent_829F9 = 4;
										end
										if (FlatIdent_829F9 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_829F9 = 1;
										end
										if (FlatIdent_829F9 == 1) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_829F9 = 2;
										end
										if (FlatIdent_829F9 == 5) then
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
											FlatIdent_829F9 = 6;
										end
										if (FlatIdent_829F9 == 4) then
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
											FlatIdent_829F9 = 5;
										end
										if (FlatIdent_829F9 == 2) then
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
											FlatIdent_829F9 = 3;
										end
										if (FlatIdent_829F9 == 11) then
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
											FlatIdent_829F9 = 12;
										end
										if (FlatIdent_829F9 == 9) then
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
											FlatIdent_829F9 = 10;
										end
									end
								else
									local FlatIdent_81F6A = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_81F6A == 7) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_81F6A = 8;
										end
										if (8 == FlatIdent_81F6A) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_81F6A = 9;
										end
										if (5 == FlatIdent_81F6A) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_81F6A = 6;
										end
										if (FlatIdent_81F6A == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_81F6A = 5;
										end
										if (FlatIdent_81F6A == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_81F6A == 6) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_81F6A = 7;
										end
										if (FlatIdent_81F6A == 3) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_81F6A = 4;
										end
										if (FlatIdent_81F6A == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_81F6A = 1;
										end
										if (2 == FlatIdent_81F6A) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_81F6A = 3;
										end
										if (1 == FlatIdent_81F6A) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_81F6A = 2;
										end
									end
								end
							elseif (Enum <= 31) then
								local FlatIdent_6C277 = 0;
								local A;
								while true do
									if (FlatIdent_6C277 == 8) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6C277 = 9;
									end
									if (FlatIdent_6C277 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_6C277 = 3;
									end
									if (FlatIdent_6C277 == 7) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6C277 = 8;
									end
									if (FlatIdent_6C277 == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										FlatIdent_6C277 = 2;
									end
									if (FlatIdent_6C277 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6C277 = 4;
									end
									if (FlatIdent_6C277 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6C277 = 6;
									end
									if (9 == FlatIdent_6C277) then
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_6C277 == 6) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6C277 = 7;
									end
									if (FlatIdent_6C277 == 0) then
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_6C277 = 1;
									end
									if (FlatIdent_6C277 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_6C277 = 5;
									end
								end
							elseif (Enum > 32) then
								local A = Inst[2];
								local Results = {Stk[A](Stk[A + 1])};
								local Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_71E8F = 0;
									while true do
										if (FlatIdent_71E8F == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							else
								local FlatIdent_51C44 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_51C44 == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_51C44 = 5;
									end
									if (8 == FlatIdent_51C44) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_51C44 = 9;
									end
									if (FlatIdent_51C44 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_51C44 = 2;
									end
									if (FlatIdent_51C44 == 5) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_51C44 = 6;
									end
									if (FlatIdent_51C44 == 2) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_51C44 = 3;
									end
									if (FlatIdent_51C44 == 9) then
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_51C44 == 7) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_51C44 = 8;
									end
									if (FlatIdent_51C44 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_51C44 = 7;
									end
									if (FlatIdent_51C44 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_51C44 = 4;
									end
									if (FlatIdent_51C44 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_51C44 = 1;
									end
								end
							end
						elseif (Enum <= 50) then
							if (Enum <= 41) then
								if (Enum <= 37) then
									if (Enum <= 35) then
										if (Enum == 34) then
											local FlatIdent_186F = 0;
											local A;
											local K;
											local B;
											while true do
												if (FlatIdent_186F == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_186F = 9;
												end
												if (5 == FlatIdent_186F) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_186F = 6;
												end
												if (FlatIdent_186F == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_186F = 5;
												end
												if (FlatIdent_186F == 0) then
													A = nil;
													K = nil;
													B = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_186F = 1;
												end
												if (FlatIdent_186F == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_186F = 10;
												end
												if (FlatIdent_186F == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													B = Inst[3];
													FlatIdent_186F = 2;
												end
												if (FlatIdent_186F == 2) then
													K = Stk[B];
													for Idx = B + 1, Inst[4] do
														K = K .. Stk[Idx];
													end
													Stk[Inst[2]] = K;
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_186F = 3;
												end
												if (FlatIdent_186F == 7) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_186F = 8;
												end
												if (FlatIdent_186F == 3) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_186F = 4;
												end
												if (FlatIdent_186F == 6) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_186F = 7;
												end
												if (FlatIdent_186F == 10) then
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
											end
										else
											local FlatIdent_71493 = 0;
											local A;
											local Results;
											local Limit;
											local Edx;
											while true do
												if (FlatIdent_71493 == 1) then
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_71493 = 2;
												end
												if (FlatIdent_71493 == 0) then
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													FlatIdent_71493 = 1;
												end
												if (FlatIdent_71493 == 2) then
													for Idx = A, Top do
														local FlatIdent_13AEB = 0;
														while true do
															if (FlatIdent_13AEB == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													break;
												end
											end
										end
									elseif (Enum == 36) then
										local FlatIdent_1D2CD = 0;
										local NewProto;
										local NewUvals;
										local Indexes;
										while true do
											if (1 == FlatIdent_1D2CD) then
												Indexes = {};
												NewUvals = Setmetatable({}, {__index=function(_, Key)
													local FlatIdent_571C2 = 0;
													local Val;
													while true do
														if (FlatIdent_571C2 == 0) then
															Val = Indexes[Key];
															return Val[1][Val[2]];
														end
													end
												end,__newindex=function(_, Key, Value)
													local FlatIdent_3831 = 0;
													local Val;
													while true do
														if (FlatIdent_3831 == 0) then
															Val = Indexes[Key];
															Val[1][Val[2]] = Value;
															break;
														end
													end
												end});
												FlatIdent_1D2CD = 2;
											end
											if (FlatIdent_1D2CD == 0) then
												NewProto = Proto[Inst[3]];
												NewUvals = nil;
												FlatIdent_1D2CD = 1;
											end
											if (FlatIdent_1D2CD == 2) then
												for Idx = 1, Inst[4] do
													local FlatIdent_21E03 = 0;
													local Mvm;
													while true do
														if (FlatIdent_21E03 == 1) then
															if (Mvm[1] == 42) then
																Indexes[Idx - 1] = {Stk,Mvm[3]};
															else
																Indexes[Idx - 1] = {Upvalues,Mvm[3]};
															end
															Lupvals[#Lupvals + 1] = Indexes;
															break;
														end
														if (FlatIdent_21E03 == 0) then
															VIP = VIP + 1;
															Mvm = Instr[VIP];
															FlatIdent_21E03 = 1;
														end
													end
												end
												Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
												break;
											end
										end
									else
										local FlatIdent_2C7C4 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_2C7C4 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_2C7C4 = 1;
											end
											if (FlatIdent_2C7C4 == 6) then
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
											if (FlatIdent_2C7C4 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_2C7C4 = 6;
											end
											if (FlatIdent_2C7C4 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_2C7C4 = 3;
											end
											if (FlatIdent_2C7C4 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_2C7C4 = 5;
											end
											if (FlatIdent_2C7C4 == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_2C7C4 = 4;
											end
											if (FlatIdent_2C7C4 == 1) then
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_2C7C4 = 2;
											end
										end
									end
								elseif (Enum <= 39) then
									if (Enum > 38) then
										Stk[Inst[2]] = Env[Inst[3]];
									else
										local B;
										local A;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
									end
								elseif (Enum > 40) then
									local A = Inst[2];
									Stk[A](Stk[A + 1]);
								else
									local FlatIdent_6B9E2 = 0;
									local A;
									while true do
										if (FlatIdent_6B9E2 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								end
							elseif (Enum <= 45) then
								if (Enum <= 43) then
									if (Enum == 42) then
										Stk[Inst[2]] = Stk[Inst[3]];
									else
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									end
								elseif (Enum == 44) then
									local B;
									local A;
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
									local A = Inst[2];
									do
										return Unpack(Stk, A, A + Inst[3]);
									end
								end
							elseif (Enum <= 47) then
								if (Enum > 46) then
									local FlatIdent_6426D = 0;
									local K;
									local B;
									local A;
									while true do
										if (FlatIdent_6426D == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6426D = 7;
										end
										if (FlatIdent_6426D == 3) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_6426D = 4;
										end
										if (FlatIdent_6426D == 7) then
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											FlatIdent_6426D = 8;
										end
										if (4 == FlatIdent_6426D) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6426D = 5;
										end
										if (FlatIdent_6426D == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_6426D = 6;
										end
										if (8 == FlatIdent_6426D) then
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											FlatIdent_6426D = 9;
										end
										if (FlatIdent_6426D == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6426D = 3;
										end
										if (FlatIdent_6426D == 9) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											break;
										end
										if (FlatIdent_6426D == 0) then
											K = nil;
											B = nil;
											A = nil;
											FlatIdent_6426D = 1;
										end
										if (FlatIdent_6426D == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_6426D = 2;
										end
									end
								else
									local FlatIdent_70003 = 0;
									local A;
									local Results;
									local Edx;
									while true do
										if (FlatIdent_70003 == 0) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											FlatIdent_70003 = 1;
										end
										if (FlatIdent_70003 == 1) then
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_45CCF = 0;
												while true do
													if (FlatIdent_45CCF == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											break;
										end
									end
								end
							elseif (Enum <= 48) then
								local A = Inst[2];
								local C = Inst[4];
								local CB = A + 2;
								local Result = {Stk[A](Stk[A + 1], Stk[CB])};
								for Idx = 1, C do
									Stk[CB + Idx] = Result[Idx];
								end
								local R = Result[1];
								if R then
									local FlatIdent_2DF14 = 0;
									while true do
										if (0 == FlatIdent_2DF14) then
											Stk[CB] = R;
											VIP = Inst[3];
											break;
										end
									end
								else
									VIP = VIP + 1;
								end
							elseif (Enum > 49) then
								local Results;
								local Edx;
								local Results, Limit;
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
									local FlatIdent_79739 = 0;
									while true do
										if (FlatIdent_79739 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
							end
						elseif (Enum <= 59) then
							if (Enum <= 54) then
								if (Enum <= 52) then
									if (Enum > 51) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
									else
										local FlatIdent_559FF = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_559FF == 6) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_559FF == 5) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_559FF = 6;
											end
											if (FlatIdent_559FF == 2) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_559FF = 3;
											end
											if (1 == FlatIdent_559FF) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_559FF = 2;
											end
											if (FlatIdent_559FF == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_559FF = 5;
											end
											if (FlatIdent_559FF == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_559FF = 1;
											end
											if (FlatIdent_559FF == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_559FF = 4;
											end
										end
									end
								elseif (Enum > 53) then
									local FlatIdent_2B986 = 0;
									local K;
									local B;
									local A;
									while true do
										if (FlatIdent_2B986 == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2B986 = 3;
										end
										if (FlatIdent_2B986 == 4) then
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											FlatIdent_2B986 = 5;
										end
										if (FlatIdent_2B986 == 1) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2B986 = 2;
										end
										if (FlatIdent_2B986 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_2B986 = 4;
										end
										if (FlatIdent_2B986 == 0) then
											K = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2B986 = 1;
										end
										if (FlatIdent_2B986 == 5) then
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
									end
								else
									local FlatIdent_92569 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_92569 == 5) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_92569 = 6;
										end
										if (FlatIdent_92569 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_92569 = 1;
										end
										if (FlatIdent_92569 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_92569 = 7;
										end
										if (2 == FlatIdent_92569) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_92569 = 3;
										end
										if (FlatIdent_92569 == 4) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92569 = 5;
										end
										if (FlatIdent_92569 == 7) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_92569 = 8;
										end
										if (FlatIdent_92569 == 3) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92569 = 4;
										end
										if (9 == FlatIdent_92569) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_92569 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_92569 = 2;
										end
										if (8 == FlatIdent_92569) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_92569 = 9;
										end
									end
								end
							elseif (Enum <= 56) then
								if (Enum == 55) then
									Stk[Inst[2]] = not Stk[Inst[3]];
								else
									local FlatIdent_14BE1 = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_14BE1 == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_14BE1 = 1;
										end
										if (6 == FlatIdent_14BE1) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_14BE1 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_14BE1 = 3;
										end
										if (FlatIdent_14BE1 == 5) then
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_14BE1 = 6;
										end
										if (FlatIdent_14BE1 == 4) then
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_31791 = 0;
												while true do
													if (FlatIdent_31791 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_14BE1 = 5;
										end
										if (FlatIdent_14BE1 == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_14BE1 = 2;
										end
										if (3 == FlatIdent_14BE1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											FlatIdent_14BE1 = 4;
										end
									end
								end
							elseif (Enum <= 57) then
								local Edx;
								local Results, Limit;
								local B;
								local A;
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
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_82AB4 = 0;
									while true do
										if (FlatIdent_82AB4 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
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
							elseif (Enum == 58) then
								if (Stk[Inst[2]] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_97E60 = 0;
								local A;
								while true do
									if (0 == FlatIdent_97E60) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							end
						elseif (Enum <= 63) then
							if (Enum <= 61) then
								if (Enum == 60) then
									local Edx;
									local Results, Limit;
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
									do
										return Stk[A](Unpack(Stk, A + 1, Top));
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
								else
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum > 62) then
								local FlatIdent_93FA5 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_93FA5 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_93FA5 = 1;
									end
									if (FlatIdent_93FA5 == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_93FA5 = 6;
									end
									if (FlatIdent_93FA5 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_93FA5 = 4;
									end
									if (4 == FlatIdent_93FA5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_93FA5 = 5;
									end
									if (FlatIdent_93FA5 == 6) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_93FA5 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_93FA5 = 3;
									end
									if (1 == FlatIdent_93FA5) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_93FA5 = 2;
									end
								end
							elseif (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 65) then
							if (Enum == 64) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								Stk[Inst[2]]();
							end
						elseif (Enum <= 66) then
							local FlatIdent_82A94 = 0;
							local A;
							while true do
								if (0 == FlatIdent_82A94) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									break;
								end
							end
						elseif (Enum == 67) then
							Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
						else
							local FlatIdent_9876 = 0;
							local A;
							local K;
							local B;
							while true do
								if (FlatIdent_9876 == 9) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_9876 = 10;
								end
								if (FlatIdent_9876 == 0) then
									A = nil;
									K = nil;
									B = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_9876 = 1;
								end
								if (FlatIdent_9876 == 6) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_9876 = 7;
								end
								if (FlatIdent_9876 == 10) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_9876 = 11;
								end
								if (FlatIdent_9876 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_9876 = 9;
								end
								if (FlatIdent_9876 == 12) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
								if (FlatIdent_9876 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_9876 = 4;
								end
								if (7 == FlatIdent_9876) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_9876 = 8;
								end
								if (FlatIdent_9876 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									FlatIdent_9876 = 2;
								end
								if (FlatIdent_9876 == 4) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_9876 = 5;
								end
								if (FlatIdent_9876 == 5) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_9876 = 6;
								end
								if (FlatIdent_9876 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_9876 = 3;
								end
								if (FlatIdent_9876 == 11) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_9876 = 12;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!363Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q7470476574031C3Q00682Q7470733A2Q2F7369726975732E6D656E752F7261796669656C64030C3Q0043726561746557696E646F7703043Q004E616D65030F3Q00467275697420536E69706572207631030C3Q004C6F6164696E675469746C6503173Q00412Q6C206578656375746F7220636F6D70617469626C65030F3Q004C6F6164696E675375627469746C6503083Q0043612Q745374617203133Q00436F6E66696775726174696F6E536176696E6703073Q00456E61626C65642Q01030A3Q00466F6C6465724E616D6503133Q004672756974536E697065725F436F6E6669677303083Q0046696C654E616D65030D3Q0043612Q74537461725F4D61696E03093Q004B657953797374656D0100030A3Q004765745365727669636503073Q00506C6179657273030B3Q004C6F63616C506C61796572030C3Q0054772Q656E53657276696365030B3Q00482Q747053657276696365025Q00406F40022Q00A053AD84E44103023Q005F4703093Q004175746F467275697403083Q00467275697445535003093Q0043726561746554616203093Q004175746F204661726D022Q00A0E9AAB3F04103073Q0056697375616C73030B3Q004372656174654C6162656C030C3Q005374617475733A2049444C45030C3Q00437265617465546F2Q676C6503143Q004175746F20436F2Q6C65637420262053746F7265030C3Q0043752Q72656E7456616C756503043Q00466C6167030F3Q004175746F4672756974546F2Q676C6503083Q0043612Q6C6261636B030C3Q00546F2Q676C654755493A204B03093Q00467275697420455350030E3Q004672756974455350546F2Q676C6503043Q00456E756D03073Q004B6579436F646503013Q004B03103Q0055736572496E70757453657276696365030A3Q00496E707574426567616E03073Q00436F2Q6E65637403043Q007461736B03053Q00737061776E03113Q004C6F6164436F6E66696775726174696F6E006B3Q0012393Q00013Q00122Q000100023Q00202Q00010001000300122Q000300046Q000100039Q0000026Q0001000200202Q00013Q00054Q00033Q000500302Q00030006000700303400030008000900303F0003000A000B4Q00043Q000300302Q0004000D000E00302Q0004000F001000302Q00040011001200102Q0003000C000400302Q0003001300144Q00010003000200122Q000200023Q00202Q000200020015001216000400164Q002600020004000200202Q00020002001700122Q000300023Q00202Q00030003001500122Q000500186Q00030005000200122Q000400023Q00202Q00040004001500122Q000600196Q0004000600020012160005001A3Q0012200006001B3Q00122Q0007001C3Q00302Q0007001D001400122Q0007001C3Q00302Q0007001E001400202Q00070001001F00122Q000900203Q00122Q000A00216Q0007000A000200202Q00080001001F001216000A00223Q00122Q000B00216Q0008000B000200202Q00090007002300122Q000B00246Q0009000B0002000624000A3Q000100012Q002A3Q00093Q000624000B0001000100042Q002A3Q000A4Q002A3Q00064Q002A3Q00044Q002A3Q00023Q000231000C00023Q00200C000D000700254Q000F3Q000400302Q000F0006002600302Q000F0027001400302Q000F0028002900062400100003000100012Q002A3Q000A3Q00101E000F002A00104Q000D000F000100202Q000D0007002300122Q000F002B6Q000D000F000100202Q000D000800254Q000F3Q000400302Q000F0006002C00302Q000F0027001400302Q000F0028002D000231001000043Q00100E000F002A00104Q000D000F000100122Q000D002E3Q00202Q000D000D002F00202Q000D000D003000122Q000E00023Q00202Q000E000E001500122Q001000316Q000E0010000200202Q000F000E003200201B000F000F003300062400110005000100012Q002A3Q000D4Q0004000F00110001001227000F00343Q00202B000F000F003500062400100006000100062Q002A3Q000C4Q002A3Q00024Q002A3Q000A4Q002A3Q00034Q002A3Q00054Q002A3Q000B4Q0029000F00020001001227000F00343Q00202B000F000F003500062400100007000100012Q002A3Q00024Q0029000F0002000100201B000F3Q00362Q0029000F000200012Q00023Q00013Q00083Q00033Q002Q033Q0053657403083Q005374617475733A2003083Q00746F737472696E6701094Q003600015Q00202Q00010001000100122Q000300023Q00122Q000400036Q00058Q0004000200024Q0003000300044Q0001000300016Q00017Q00113Q00031B3Q00536561726368696E6720666F72204E6577205365727665723Q2E03223Q00682Q7470733A2Q2F67616D65732E726F626C6F782E636F6D2F76312F67616D65732F03283Q002F736572766572732F5075626C69633F736F72744F726465723D44657363266C696D69743D312Q3003053Q007063612Q6C03043Q006461746103053Q00706169727303023Q00696403043Q0067616D6503053Q004A6F62496403073Q00706C6179696E67030A3Q006D6178506C617965727303193Q00436F2Q6E656374696E6720746F205365727665722049443A20030A3Q0047657453657276696365030F3Q0054656C65706F72745365727669636503173Q0054656C65706F7274546F506C616365496E7374616E6365031C3Q0041504920452Q726F722E20466F7263696E672052656A6F696E3Q2E03083Q0054656C65706F7274003B4Q002F7Q00122Q000100018Q0002000100124Q00026Q000100013Q00122Q000200039Q00000200122Q000100043Q00062400023Q000100022Q001A3Q00024Q002A8Q00210001000200020006400001002F00013Q0004193Q002F000100202B0003000200050006400003002F00013Q0004193Q002F0001001227000300063Q00202B0004000200052Q00210003000200050004193Q002D000100202B000800070007001227000900083Q00202B0009000900090006130008002D000100090004193Q002D000100202B00080007000A00202B00090007000B00063A0008002D000100090004193Q002D00012Q001A00085Q0012220009000C3Q00202Q000A000700074Q00090009000A4Q00080002000100122Q000800083Q00202Q00080008000D00122Q000A000E6Q0008000A000200202Q00080008000F4Q000A00013Q00202Q000B000700074Q000C00036Q0008000C00016Q00013Q00063000030015000100020004193Q001500012Q001A00035Q001225000400106Q00030002000100122Q000300083Q00202Q00030003000D00122Q0005000E6Q00030005000200202Q0003000300114Q000500016Q000600036Q0003000600016Q00013Q00013Q00033Q00030A3Q004A534F4E4465636F646503043Q0067616D6503073Q00482Q747047657400094Q003C7Q00206Q000100122Q000200023Q00202Q0002000200034Q000400016Q000200049Q009Q008Q00017Q000D3Q0003053Q00706169727303093Q00776F726B7370616365030B3Q004765744368696C6472656E2Q033Q0049734103043Q00542Q6F6C03053Q004D6F64656C03043Q004E616D6503043Q0066696E6403053Q004672756974030E3Q0046696E6446697273744368696C6403063Q0048616E646C6503153Q0046696E6446697273744368696C644F66436C612Q7303043Q005061727400283Q0012383Q00013Q00122Q000100023Q00202Q0001000100034Q000100029Q00000200044Q0023000100201B000500040004001216000700054Q003B00050007000200060700050016000100010004193Q0016000100201B000500040004001216000700064Q003B0005000700020006400005002300013Q0004193Q0023000100202B00050004000700201B000500050008001216000700094Q003B0005000700020006400005002300013Q0004193Q0023000100201B00050004000A0012160007000B4Q003B0005000700020006070005001E000100010004193Q001E000100201B00050004000C0012160007000D4Q003B0005000700020006400005002300013Q0004193Q002300012Q002A000600044Q002A000700054Q000F000600033Q0006303Q0006000100020004193Q000600012Q003D3Q00014Q000F3Q00034Q00023Q00017Q00033Q0003023Q005F4703093Q004175746F467275697403043Q0049444C4501083Q001227000100013Q001001000100023Q0006073Q0007000100010004193Q000700012Q001A00015Q001216000200034Q00290001000200012Q00023Q00017Q00073Q0003023Q005F4703083Q00467275697445535003053Q00706169727303093Q00776F726B7370616365030B3Q004765744368696C6472656E030E3Q0046696E6446697273744368696C6403073Q0044657374726F7901153Q001227000100013Q001001000100023Q0006073Q0014000100010004193Q00140001001227000100033Q001232000200043Q00202Q0002000200054Q000200036Q00013Q000300044Q0012000100201B000600050006001216000800024Q003B0006000800020006400006001200013Q0004193Q0012000100202B00060005000200201B0006000600072Q00290006000200010006300001000A000100020004193Q000A00012Q00023Q00017Q00073Q0003073Q004B6579436F646503043Q0067616D65030A3Q004765745365727669636503073Q00436F7265477569030E3Q0046696E6446697273744368696C6403183Q005261796669656C6420496E7465726661636520537569746503073Q00456E61626C656402143Q0006400001000300013Q0004193Q000300012Q00023Q00013Q00202B00023Q00012Q001A00035Q00060A00020013000100030004193Q00130001001227000200023Q00202C00020002000300122Q000400046Q00020004000200202Q00020002000500122Q000400066Q00020004000200062Q0002001300013Q0004193Q0013000100202B0003000200072Q0037000300033Q0010010002000700032Q00023Q00017Q00263Q0003043Q007461736B03043Q0077616974026Q00E03F03023Q005F4703093Q004175746F467275697403093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q005461726765743A2003043Q004E616D6503083Q00506F736974696F6E03093Q004D61676E697475646503063Q0043726561746503093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q00434672616D6503043Q00506C617903063Q00506172656E74026Q00204003133Q00436F2Q6C656374696E672046727569743Q2E03043Q0067616D65030A3Q004765745365727669636503113Q005265706C69636174656453746F7261676503073Q0052656D6F74657303063Q00436F2Q6D465F030C3Q00496E766F6B65536572766572030A3Q0053746F7265467275697403043Q0046752Q6C010003193Q0053746F726167652046752Q6C212044726F2Q70696E673Q2E03083Q004261636B7061636B03093Q0044726F704672756974031A3Q0046727569742053746F7265642053752Q63652Q7366752Q6C7921031C3Q004E6F20467275697420466F756E642E2052656A6F696E696E673Q2E026Q00084000883Q0012273Q00013Q00202B5Q0002001216000100034Q00283Q000200020006403Q008700013Q0004193Q008700010012273Q00043Q00202B5Q00050006405Q00013Q0004195Q00012Q001A8Q001C3Q000100010006403Q007900013Q0004193Q007900010006400001007900013Q0004193Q007900012Q001A000200013Q00200900020002000600202Q00020002000700122Q000400086Q00020004000200062Q00023Q00013Q0004195Q00012Q001A000300023Q001244000400093Q00202Q00053Q000A4Q0004000400054Q00030002000100202Q00030002000B00202Q00040001000B4Q00030003000400202Q00030003000C4Q000400033Q00202Q00040004000D4Q000600023Q00122Q0007000E3Q00202Q00070007000F4Q000800046Q00080003000800122Q000900103Q00202Q00090009001100202Q0009000900124Q0007000900024Q00083Q000100202Q00090001001300102Q0008001300094Q00040008000200202Q0005000400144Q000500020001001227000500013Q00202B0005000500022Q004100050001000100202B00053Q00150006400005003D00013Q0004193Q003D000100202B00050002000B00202B00060001000B2Q004300050005000600202B00050005000C00261800050031000100160004193Q003100012Q001A000500023Q002Q12000600176Q00050002000100122Q000500013Q00202Q00050005000200122Q000600036Q00050002000100122Q000500183Q00202Q00050005001900122Q0007001A6Q00050007000200202Q00050005001B00202Q00050005001C00202Q00050005001D00122Q0007001E3Q00202Q00083Q000A4Q00098Q00050009000200262Q000500530001001F0004193Q0053000100263E00050075000100200004193Q007500012Q001A000600023Q001205000700216Q0006000200014Q000600013Q00202Q00060006002200202Q00060006000700202Q00083Q000A4Q00060008000200062Q00060062000100010004193Q006200012Q001A000600013Q00202B00060006000600201B00060006000700202B00083Q000A2Q003B00060008000200064000063Q00013Q0004195Q00012Q001A000700013Q00203500070007000600102Q00060015000700122Q000700013Q00202Q00070007000200122Q000800036Q00070002000100122Q000700183Q00202Q00070007001900122Q0009001A6Q00070009000200202Q00070007001B00202Q00070007001C00202Q00070007001D00122Q000900236Q00070009000100046Q00012Q001A000600023Q001216000700244Q00290006000200010004195Q00012Q001A000200023Q00121F000300256Q00020002000100122Q000200013Q00202Q00020002000200122Q000300266Q00020002000100122Q000200043Q00202Q00020002000500062Q00023Q00013Q0004195Q00012Q001A000200054Q00410002000100010004195Q00012Q00023Q00017Q00323Q0003043Q007461736B03043Q0077616974029A5Q99C93F03023Q005F4703083Q00467275697445535003053Q00706169727303093Q00776F726B7370616365030B3Q004765744368696C6472656E2Q033Q0049734103043Q00542Q6F6C03043Q004E616D6503043Q0066696E6403053Q004672756974030E3Q0046696E6446697273744368696C6403063Q0048616E646C6503153Q0046696E6446697273744368696C644F66436C612Q7303043Q005061727403083Q00496E7374616E63652Q033Q006E6577030C3Q0042692Q6C626F617264477569030B3Q00416C776179734F6E546F702Q0103043Q0053697A6503053Q005544696D32028Q00025Q00C06240025Q0080514003093Q00546578744C6162656C03053Q004C6162656C026Q00F03F03163Q004261636B67726F756E645472616E73706172656E6379030A3Q0054657874436F6C6F723303063Q00436F6C6F723303073Q0066726F6D524742025Q00E06F4003163Q00546578745374726F6B655472616E73706172656E637903043Q00466F6E7403043Q00456E756D030A3Q00476F7468616D426F6C6403083Q005465787453697A65026Q002C4003093Q0043686172616374657203103Q0048756D616E6F6964522Q6F745061727403083Q00506F736974696F6E03093Q004D61676E697475646503043Q005465787403023Q000A5B03043Q006D61746803053Q00666C2Q6F7203073Q002053747564735D00743Q0012273Q00013Q00202B5Q0002001216000100034Q00283Q000200020006403Q007300013Q0004193Q007300010012273Q00043Q00202B5Q00050006405Q00013Q0004195Q00010012273Q00063Q001232000100073Q00202Q0001000100084Q000100029Q00000200044Q0070000100201B0005000400090012160007000A4Q003B0005000700020006070005001B000100010004193Q001B000100202B00050004000B00201B00050005000C0012160007000D4Q003B0005000700020006400005007000013Q0004193Q0070000100201B00050004000E0012160007000F4Q003B00050007000200060700050023000100010004193Q0023000100201B000500040010001216000700114Q003B0005000700020006400005007000013Q0004193Q0070000100201B00060004000E001216000800054Q003B00060008000200060700060056000100010004193Q00560001001227000700123Q00201D00070007001300122Q000800146Q000900046Q0007000900024Q000600073Q00302Q0006000B000500302Q00060015001600122Q000700183Q00202Q00070007001300122Q000800193Q00122Q0009001A3Q00122Q000A00193Q00122Q000B001B6Q0007000B000200102Q00060017000700122Q000700123Q00202Q00070007001300122Q0008001C6Q000900066Q00070009000200302Q0007000B001D00122Q000800183Q00202Q00080008001300122Q0009001E3Q00122Q000A00193Q00122Q000B001E3Q00122Q000C00196Q0008000C000200102Q00070017000800302Q0007001F001E00122Q000800213Q00202Q00080008002200122Q000900233Q00122Q000A00233Q00122Q000B00236Q0008000B000200102Q00070020000800302Q00070024001900122Q000800263Q00202Q00080008002500202Q00080008002700102Q00070025000800302Q0007002800292Q001A00075Q00200900070007002A00202Q00070007000E00122Q0009002B6Q00070009000200062Q0007007000013Q0004193Q0070000100201B00080006000E001216000A001D4Q003B0008000A00020006400008007000013Q0004193Q0070000100202B00080007002C00201700090005002C4Q00080008000900202Q00080008002D00202Q00090006001D00202Q000A0004000B00122Q000B002F3Q00122Q000C00303Q00202Q000C000C00314Q000D00086Q000C0002000200122Q000D00326Q000A000A000D00102Q0009002E000A0006303Q0010000100020004193Q001000010004195Q00012Q00023Q00017Q00", GetFEnv(), ...);