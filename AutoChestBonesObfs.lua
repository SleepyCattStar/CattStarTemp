-- To be released soon

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
			local FlatIdent_76979 = 0;
			while true do
				if (FlatIdent_76979 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local FlatIdent_69270 = 0;
			local a;
			while true do
				if (FlatIdent_69270 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_6D4CB = 0;
						local b;
						while true do
							if (FlatIdent_6D4CB == 1) then
								return b;
							end
							if (FlatIdent_6D4CB == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_6D4CB = 1;
							end
						end
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
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local FlatIdent_12703 = 0;
			local Plc;
			while true do
				if (FlatIdent_12703 == 0) then
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
		local FlatIdent_2BD95 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_2BD95 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_2BD95 = 3;
			end
			if (3 == FlatIdent_2BD95) then
				return Concat(FStr);
			end
			if (FlatIdent_2BD95 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_2BD95 = 2;
			end
			if (FlatIdent_2BD95 == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_2BD95 = 1;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_7DD24 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (2 == FlatIdent_7DD24) then
				for Idx = 1, gBits32() do
					local FlatIdent_104D4 = 0;
					local Descriptor;
					while true do
						if (FlatIdent_104D4 == 0) then
							Descriptor = gBits8();
							if (gBit(Descriptor, 1, 1) == 0) then
								local Type = gBit(Descriptor, 2, 3);
								local Mask = gBit(Descriptor, 4, 6);
								local Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									local FlatIdent_940A0 = 0;
									while true do
										if (FlatIdent_940A0 == 0) then
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
							break;
						end
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_7DD24 == 1) then
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
				FlatIdent_7DD24 = 2;
			end
			if (FlatIdent_7DD24 == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_7DD24 = 1;
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
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 48) then
					if (Enum <= 23) then
						if (Enum <= 11) then
							if (Enum <= 5) then
								if (Enum <= 2) then
									if (Enum <= 0) then
										local FlatIdent_946F = 0;
										local A;
										while true do
											if (FlatIdent_946F == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_946F = 5;
											end
											if (FlatIdent_946F == 7) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												break;
											end
											if (FlatIdent_946F == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_946F = 4;
											end
											if (FlatIdent_946F == 5) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_946F = 6;
											end
											if (FlatIdent_946F == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_946F = 2;
											end
											if (0 == FlatIdent_946F) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_946F = 1;
											end
											if (FlatIdent_946F == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_946F = 3;
											end
											if (FlatIdent_946F == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_946F = 7;
											end
										end
									elseif (Enum == 1) then
										local FlatIdent_380E8 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_380E8 == 10) then
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
											if (FlatIdent_380E8 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_380E8 = 2;
											end
											if (FlatIdent_380E8 == 8) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_380E8 = 9;
											end
											if (FlatIdent_380E8 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_380E8 = 6;
											end
											if (FlatIdent_380E8 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_380E8 = 1;
											end
											if (4 == FlatIdent_380E8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_380E8 = 5;
											end
											if (6 == FlatIdent_380E8) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_380E8 = 7;
											end
											if (FlatIdent_380E8 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_380E8 = 4;
											end
											if (FlatIdent_380E8 == 9) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_380E8 = 10;
											end
											if (FlatIdent_380E8 == 2) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_380E8 = 3;
											end
											if (FlatIdent_380E8 == 7) then
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_380E8 = 8;
											end
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
								elseif (Enum <= 3) then
									local FlatIdent_6DC53 = 0;
									local A;
									while true do
										if (FlatIdent_6DC53 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_6DC53 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6DC53 = 2;
										end
										if (0 == FlatIdent_6DC53) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_6DC53 = 1;
										end
										if (FlatIdent_6DC53 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_6DC53 = 4;
										end
										if (FlatIdent_6DC53 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_6DC53 = 3;
										end
									end
								elseif (Enum == 4) then
									local FlatIdent_98388 = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (1 == FlatIdent_98388) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_98388 = 2;
										end
										if (FlatIdent_98388 == 5) then
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_882F4 = 0;
												while true do
													if (FlatIdent_882F4 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_98388 = 6;
										end
										if (FlatIdent_98388 == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_98388 = 1;
										end
										if (FlatIdent_98388 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_98388 = 3;
										end
										if (3 == FlatIdent_98388) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											FlatIdent_98388 = 4;
										end
										if (FlatIdent_98388 == 4) then
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_98388 = 5;
										end
										if (FlatIdent_98388 == 6) then
											VIP = Inst[3];
											break;
										end
									end
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum <= 8) then
								if (Enum <= 6) then
									local A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
								elseif (Enum > 7) then
									local FlatIdent_3CF01 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_3CF01 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_3CF01 = 1;
										end
										if (FlatIdent_3CF01 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_3CF01 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_3CF01 = 4;
										end
										if (FlatIdent_3CF01 == 2) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_3CF01 = 3;
										end
										if (FlatIdent_3CF01 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_3CF01 = 2;
										end
									end
								else
									local B = Stk[Inst[4]];
									if not B then
										VIP = VIP + 1;
									else
										Stk[Inst[2]] = B;
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 9) then
								Stk[Inst[2]] = Stk[Inst[3]];
							elseif (Enum == 10) then
								Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
							else
								local FlatIdent_4508F = 0;
								local B;
								local A;
								while true do
									if (3 == FlatIdent_4508F) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_4508F = 4;
									end
									if (FlatIdent_4508F == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4508F = 2;
									end
									if (FlatIdent_4508F == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_4508F = 1;
									end
									if (FlatIdent_4508F == 6) then
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_4508F == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4508F = 5;
									end
									if (FlatIdent_4508F == 5) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4508F = 6;
									end
									if (FlatIdent_4508F == 2) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_4508F = 3;
									end
								end
							end
						elseif (Enum <= 17) then
							if (Enum <= 14) then
								if (Enum <= 12) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
								elseif (Enum > 13) then
									local FlatIdent_4223E = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_4223E == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_4223E == 2) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_4223E = 3;
										end
										if (FlatIdent_4223E == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4223E = 1;
										end
										if (FlatIdent_4223E == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_4223E = 4;
										end
										if (FlatIdent_4223E == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_4223E = 2;
										end
									end
								else
									local FlatIdent_276C2 = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_276C2 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											FlatIdent_276C2 = 6;
										end
										if (FlatIdent_276C2 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_276C2 = 3;
										end
										if (FlatIdent_276C2 == 8) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_276C2 == 7) then
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_276C2 = 8;
										end
										if (4 == FlatIdent_276C2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_276C2 = 5;
										end
										if (FlatIdent_276C2 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											FlatIdent_276C2 = 2;
										end
										if (FlatIdent_276C2 == 3) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_276C2 = 4;
										end
										if (FlatIdent_276C2 == 6) then
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_276C2 = 7;
										end
										if (FlatIdent_276C2 == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_276C2 = 1;
										end
									end
								end
							elseif (Enum <= 15) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum > 16) then
								Upvalues[Inst[3]] = Stk[Inst[2]];
							elseif (Stk[Inst[2]] ~= Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 20) then
							if (Enum <= 18) then
								local A = Inst[2];
								local B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							elseif (Enum > 19) then
								do
									return;
								end
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 21) then
							Stk[Inst[2]]();
						elseif (Enum > 22) then
							Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
						else
							Stk[Inst[2]] = {};
						end
					elseif (Enum <= 35) then
						if (Enum <= 29) then
							if (Enum <= 26) then
								if (Enum <= 24) then
									local FlatIdent_44100 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_44100 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_44100 = 2;
										end
										if (FlatIdent_44100 == 6) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (2 == FlatIdent_44100) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44100 = 3;
										end
										if (FlatIdent_44100 == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_44100 = 6;
										end
										if (FlatIdent_44100 == 3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_44100 = 4;
										end
										if (FlatIdent_44100 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_44100 = 5;
										end
										if (FlatIdent_44100 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_44100 = 1;
										end
									end
								elseif (Enum == 25) then
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
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
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
									Stk[Inst[2]] = {};
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
									Stk[Inst[2]] = {};
								end
							elseif (Enum <= 27) then
								local FlatIdent_89562 = 0;
								local A;
								while true do
									if (FlatIdent_89562 == 2) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_89562 = 3;
									end
									if (FlatIdent_89562 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_89562 = 2;
									end
									if (FlatIdent_89562 == 0) then
										A = nil;
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										FlatIdent_89562 = 1;
									end
									if (FlatIdent_89562 == 5) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_89562 = 6;
									end
									if (FlatIdent_89562 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (4 == FlatIdent_89562) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_89562 = 5;
									end
									if (FlatIdent_89562 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_89562 = 4;
									end
								end
							elseif (Enum == 28) then
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
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Upvalues[Inst[3]] = Stk[Inst[2]];
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
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
							end
						elseif (Enum <= 32) then
							if (Enum <= 30) then
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
							elseif (Enum == 31) then
								Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 33) then
							local FlatIdent_65194 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_65194 == 2) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_65194 = 3;
								end
								if (FlatIdent_65194 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_65194 = 2;
								end
								if (3 == FlatIdent_65194) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_65194 = 4;
								end
								if (4 == FlatIdent_65194) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									break;
								end
								if (FlatIdent_65194 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									FlatIdent_65194 = 1;
								end
							end
						elseif (Enum > 34) then
							local B = Inst[3];
							local K = Stk[B];
							for Idx = B + 1, Inst[4] do
								K = K .. Stk[Idx];
							end
							Stk[Inst[2]] = K;
						elseif not Stk[Inst[2]] then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 41) then
						if (Enum <= 38) then
							if (Enum <= 36) then
								local A = Inst[2];
								do
									return Unpack(Stk, A, A + Inst[3]);
								end
							elseif (Enum == 37) then
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
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
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
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 39) then
							local A = Inst[2];
							local T = Stk[A];
							for Idx = A + 1, Inst[3] do
								Insert(T, Stk[Idx]);
							end
						elseif (Enum > 40) then
							local FlatIdent_71E8F = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_71E8F == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_71E8F == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_71E8F = 3;
								end
								if (FlatIdent_71E8F == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_71E8F = 2;
								end
								if (FlatIdent_71E8F == 3) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_71E8F = 4;
								end
								if (FlatIdent_71E8F == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_71E8F = 5;
								end
								if (FlatIdent_71E8F == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_71E8F = 1;
								end
							end
						else
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
						end
					elseif (Enum <= 44) then
						if (Enum <= 42) then
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
						elseif (Enum > 43) then
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Top));
						else
							local FlatIdent_98327 = 0;
							local A;
							local Results;
							local Edx;
							while true do
								if (FlatIdent_98327 == 0) then
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									FlatIdent_98327 = 1;
								end
								if (FlatIdent_98327 == 1) then
									Edx = 0;
									for Idx = A, Inst[4] do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									break;
								end
							end
						end
					elseif (Enum <= 46) then
						if (Enum > 45) then
							local FlatIdent_35AC5 = 0;
							local A;
							while true do
								if (1 == FlatIdent_35AC5) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_35AC5 = 2;
								end
								if (2 == FlatIdent_35AC5) then
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_35AC5 = 3;
								end
								if (FlatIdent_35AC5 == 5) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Inst[2] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_35AC5 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_35AC5 = 4;
								end
								if (FlatIdent_35AC5 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_35AC5 = 5;
								end
								if (FlatIdent_35AC5 == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_35AC5 = 1;
								end
							end
						elseif (Stk[Inst[2]] > Inst[4]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum > 47) then
						local FlatIdent_38BFA = 0;
						while true do
							if (FlatIdent_38BFA == 0) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								FlatIdent_38BFA = 1;
							end
							if (FlatIdent_38BFA == 3) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
								break;
							end
							if (FlatIdent_38BFA == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_38BFA = 3;
							end
							if (FlatIdent_38BFA == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_38BFA = 2;
							end
						end
					else
						local FlatIdent_8239F = 0;
						local B;
						local T;
						local A;
						while true do
							if (FlatIdent_8239F == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								FlatIdent_8239F = 2;
							end
							if (FlatIdent_8239F == 0) then
								B = nil;
								T = nil;
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								FlatIdent_8239F = 1;
							end
							if (FlatIdent_8239F == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								T = Stk[A];
								FlatIdent_8239F = 5;
							end
							if (FlatIdent_8239F == 3) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_8239F = 4;
							end
							if (FlatIdent_8239F == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_8239F = 3;
							end
							if (FlatIdent_8239F == 5) then
								B = Inst[3];
								for Idx = 1, B do
									T[Idx] = Stk[A + Idx];
								end
								break;
							end
						end
					end
				elseif (Enum <= 73) then
					if (Enum <= 60) then
						if (Enum <= 54) then
							if (Enum <= 51) then
								if (Enum <= 49) then
									Stk[Inst[2]] = #Stk[Inst[3]];
								elseif (Enum > 50) then
									local Results;
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
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_679D2 = 0;
										while true do
											if (FlatIdent_679D2 == 0) then
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
									local FlatIdent_523B3 = 0;
									local A;
									while true do
										if (FlatIdent_523B3 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_523B3 = 3;
										end
										if (FlatIdent_523B3 == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_523B3 = 1;
										end
										if (FlatIdent_523B3 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											FlatIdent_523B3 = 4;
										end
										if (FlatIdent_523B3 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											FlatIdent_523B3 = 2;
										end
										if (FlatIdent_523B3 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] < Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								end
							elseif (Enum <= 52) then
								local FlatIdent_79729 = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_79729 == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_79729 = 6;
									end
									if (FlatIdent_79729 == 6) then
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
									if (FlatIdent_79729 == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_79729 = 1;
									end
									if (FlatIdent_79729 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_79729 = 4;
									end
									if (FlatIdent_79729 == 2) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_79729 = 3;
									end
									if (FlatIdent_79729 == 4) then
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_77CC3 = 0;
											while true do
												if (FlatIdent_77CC3 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										FlatIdent_79729 = 5;
									end
									if (1 == FlatIdent_79729) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_79729 = 2;
									end
								end
							elseif (Enum == 53) then
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
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local FlatIdent_3416F = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_3416F == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (3 == FlatIdent_3416F) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3416F = 4;
									end
									if (FlatIdent_3416F == 4) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_3416F = 5;
									end
									if (FlatIdent_3416F == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_3416F = 1;
									end
									if (2 == FlatIdent_3416F) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_3416F = 3;
									end
									if (FlatIdent_3416F == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_3416F = 6;
									end
									if (FlatIdent_3416F == 1) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_3416F = 2;
									end
								end
							end
						elseif (Enum <= 57) then
							if (Enum <= 55) then
								Stk[Inst[2]] = Inst[3];
							elseif (Enum == 56) then
								local K;
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
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
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
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
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
								Stk[Inst[2]][Inst[3]] = Inst[4];
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
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
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
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
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
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
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
								Stk[Inst[2]] = Env[Inst[3]];
							else
								local FlatIdent_61AEE = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_61AEE == 1) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_61AEE = 2;
									end
									if (FlatIdent_61AEE == 2) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_61AEE = 3;
									end
									if (3 == FlatIdent_61AEE) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_61AEE = 4;
									end
									if (FlatIdent_61AEE == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_61AEE = 1;
									end
									if (4 == FlatIdent_61AEE) then
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
						elseif (Enum <= 58) then
							local FlatIdent_7FF2C = 0;
							local A;
							local Results;
							local Limit;
							local Edx;
							while true do
								if (FlatIdent_7FF2C == 1) then
									Top = (Limit + A) - 1;
									Edx = 0;
									FlatIdent_7FF2C = 2;
								end
								if (0 == FlatIdent_7FF2C) then
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									FlatIdent_7FF2C = 1;
								end
								if (FlatIdent_7FF2C == 2) then
									for Idx = A, Top do
										local FlatIdent_80652 = 0;
										while true do
											if (FlatIdent_80652 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									break;
								end
							end
						elseif (Enum > 59) then
							local FlatIdent_2A1A = 0;
							local A;
							while true do
								if (FlatIdent_2A1A == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2A1A = 3;
								end
								if (FlatIdent_2A1A == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2A1A = 4;
								end
								if (FlatIdent_2A1A == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_2A1A = 5;
								end
								if (FlatIdent_2A1A == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (1 == FlatIdent_2A1A) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_2A1A = 2;
								end
								if (FlatIdent_2A1A == 0) then
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_2A1A = 1;
								end
								if (5 == FlatIdent_2A1A) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_2A1A = 6;
								end
							end
						else
							local NewProto = Proto[Inst[3]];
							local NewUvals;
							local Indexes = {};
							NewUvals = Setmetatable({}, {__index=function(_, Key)
								local Val = Indexes[Key];
								return Val[1][Val[2]];
							end,__newindex=function(_, Key, Value)
								local Val = Indexes[Key];
								Val[1][Val[2]] = Value;
							end});
							for Idx = 1, Inst[4] do
								local FlatIdent_33F65 = 0;
								local Mvm;
								while true do
									if (FlatIdent_33F65 == 0) then
										VIP = VIP + 1;
										Mvm = Instr[VIP];
										FlatIdent_33F65 = 1;
									end
									if (FlatIdent_33F65 == 1) then
										if (Mvm[1] == 9) then
											Indexes[Idx - 1] = {Stk,Mvm[3]};
										else
											Indexes[Idx - 1] = {Upvalues,Mvm[3]};
										end
										Lupvals[#Lupvals + 1] = Indexes;
										break;
									end
								end
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						end
					elseif (Enum <= 66) then
						if (Enum <= 63) then
							if (Enum <= 61) then
								local B;
								local A;
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
							elseif (Enum == 62) then
								if (Stk[Inst[2]] < Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								Stk[A] = Stk[A]();
							end
						elseif (Enum <= 64) then
							local FlatIdent_69486 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_69486 == 10) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_69486 = 11;
								end
								if (FlatIdent_69486 == 9) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_69486 = 10;
								end
								if (FlatIdent_69486 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_69486 = 3;
								end
								if (FlatIdent_69486 == 14) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									break;
								end
								if (FlatIdent_69486 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									FlatIdent_69486 = 6;
								end
								if (FlatIdent_69486 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									FlatIdent_69486 = 4;
								end
								if (FlatIdent_69486 == 8) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_69486 = 9;
								end
								if (FlatIdent_69486 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_69486 = 2;
								end
								if (FlatIdent_69486 == 13) then
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_69486 = 14;
								end
								if (FlatIdent_69486 == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_69486 = 7;
								end
								if (FlatIdent_69486 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Upvalues[Inst[3]] = Stk[Inst[2]];
									FlatIdent_69486 = 1;
								end
								if (FlatIdent_69486 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_69486 = 8;
								end
								if (FlatIdent_69486 == 12) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_69486 = 13;
								end
								if (FlatIdent_69486 == 11) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_69486 = 12;
								end
								if (FlatIdent_69486 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_69486 = 5;
								end
							end
						elseif (Enum == 65) then
							local FlatIdent_1C534 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_1C534 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_1C534 = 5;
								end
								if (FlatIdent_1C534 == 3) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_1C534 = 4;
								end
								if (FlatIdent_1C534 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1C534 = 1;
								end
								if (FlatIdent_1C534 == 6) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_1C534 = 7;
								end
								if (FlatIdent_1C534 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_1C534 = 2;
								end
								if (FlatIdent_1C534 == 7) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (2 == FlatIdent_1C534) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_1C534 = 3;
								end
								if (FlatIdent_1C534 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_1C534 = 6;
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
								Stk[CB] = R;
								VIP = Inst[3];
							else
								VIP = VIP + 1;
							end
						end
					elseif (Enum <= 69) then
						if (Enum <= 67) then
							if (Inst[2] < Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum == 68) then
							if (Stk[Inst[2]] <= Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local B;
							local T;
							local A;
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Upvalues[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							T = Stk[A];
							B = Inst[3];
							for Idx = 1, B do
								T[Idx] = Stk[A + Idx];
							end
						end
					elseif (Enum <= 71) then
						if (Enum > 70) then
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
						else
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						end
					elseif (Enum > 72) then
						local B;
						local A;
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
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
						Stk[Inst[2]] = {};
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
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					else
						Stk[Inst[2]] = Upvalues[Inst[3]];
					end
				elseif (Enum <= 85) then
					if (Enum <= 79) then
						if (Enum <= 76) then
							if (Enum <= 74) then
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
							elseif (Enum == 75) then
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									local FlatIdent_D895 = 0;
									while true do
										if (FlatIdent_D895 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							end
						elseif (Enum <= 77) then
							local FlatIdent_60344 = 0;
							local A;
							while true do
								if (FlatIdent_60344 == 0) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
							end
						elseif (Enum > 78) then
							if (Stk[Inst[2]] <= Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							do
								return Stk[Inst[2]];
							end
						end
					elseif (Enum <= 82) then
						if (Enum <= 80) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						elseif (Enum == 81) then
							local FlatIdent_7268B = 0;
							local A;
							while true do
								if (FlatIdent_7268B == 0) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									break;
								end
							end
						else
							local FlatIdent_2F8E7 = 0;
							local A;
							while true do
								if (FlatIdent_2F8E7 == 0) then
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									break;
								end
							end
						end
					elseif (Enum <= 83) then
						local FlatIdent_35F25 = 0;
						local A;
						while true do
							if (0 == FlatIdent_35F25) then
								A = nil;
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_35F25 = 1;
							end
							if (FlatIdent_35F25 == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_35F25 = 4;
							end
							if (6 == FlatIdent_35F25) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								break;
							end
							if (FlatIdent_35F25 == 5) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_35F25 = 6;
							end
							if (FlatIdent_35F25 == 1) then
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_35F25 = 2;
							end
							if (FlatIdent_35F25 == 2) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_35F25 = 3;
							end
							if (FlatIdent_35F25 == 4) then
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								FlatIdent_35F25 = 5;
							end
						end
					elseif (Enum == 84) then
						local FlatIdent_6CF78 = 0;
						local K;
						local B;
						local A;
						while true do
							if (FlatIdent_6CF78 == 8) then
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								FlatIdent_6CF78 = 9;
							end
							if (FlatIdent_6CF78 == 5) then
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6CF78 = 6;
							end
							if (FlatIdent_6CF78 == 1) then
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								FlatIdent_6CF78 = 2;
							end
							if (FlatIdent_6CF78 == 6) then
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								FlatIdent_6CF78 = 7;
							end
							if (FlatIdent_6CF78 == 7) then
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6CF78 = 8;
							end
							if (2 == FlatIdent_6CF78) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6CF78 = 3;
							end
							if (FlatIdent_6CF78 == 4) then
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								FlatIdent_6CF78 = 5;
							end
							if (10 == FlatIdent_6CF78) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3] ~= 0;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_6CF78 = 11;
							end
							if (FlatIdent_6CF78 == 0) then
								K = nil;
								B = nil;
								A = nil;
								A = Inst[2];
								B = Stk[Inst[3]];
								FlatIdent_6CF78 = 1;
							end
							if (FlatIdent_6CF78 == 9) then
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_6CF78 = 10;
							end
							if (FlatIdent_6CF78 == 3) then
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								FlatIdent_6CF78 = 4;
							end
							if (11 == FlatIdent_6CF78) then
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
						Stk[Inst[2]] = Stk[Inst[3]] / Inst[4];
					end
				elseif (Enum <= 91) then
					if (Enum <= 88) then
						if (Enum <= 86) then
							local FlatIdent_6873F = 0;
							local A;
							while true do
								if (FlatIdent_6873F == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_6873F = 3;
								end
								if (FlatIdent_6873F == 4) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_6873F = 5;
								end
								if (FlatIdent_6873F == 0) then
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6873F = 1;
								end
								if (FlatIdent_6873F == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6873F = 4;
								end
								if (1 == FlatIdent_6873F) then
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_6873F = 2;
								end
								if (5 == FlatIdent_6873F) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_6873F = 6;
								end
								if (FlatIdent_6873F == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									break;
								end
								if (FlatIdent_6873F == 6) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_6873F = 7;
								end
							end
						elseif (Enum == 87) then
							local B;
							local A;
							A = Inst[2];
							Stk[A](Stk[A + 1]);
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
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local FlatIdent_101B7 = 0;
							local A;
							while true do
								if (FlatIdent_101B7 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_101B7 = 2;
								end
								if (0 == FlatIdent_101B7) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_101B7 = 1;
								end
								if (3 == FlatIdent_101B7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_101B7 = 4;
								end
								if (FlatIdent_101B7 == 2) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									FlatIdent_101B7 = 3;
								end
								if (FlatIdent_101B7 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_101B7 = 5;
								end
								if (FlatIdent_101B7 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									break;
								end
							end
						end
					elseif (Enum <= 89) then
						if (Stk[Inst[2]] == Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum == 90) then
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					else
						Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
					end
				elseif (Enum <= 94) then
					if (Enum <= 92) then
						local FlatIdent_53D9 = 0;
						local B;
						local A;
						while true do
							if (FlatIdent_53D9 == 5) then
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_53D9 = 6;
							end
							if (FlatIdent_53D9 == 6) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
								break;
							end
							if (FlatIdent_53D9 == 3) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								FlatIdent_53D9 = 4;
							end
							if (FlatIdent_53D9 == 1) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_53D9 = 2;
							end
							if (FlatIdent_53D9 == 0) then
								B = nil;
								A = nil;
								Stk[Inst[2]] = Env[Inst[3]];
								FlatIdent_53D9 = 1;
							end
							if (FlatIdent_53D9 == 2) then
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								FlatIdent_53D9 = 3;
							end
							if (FlatIdent_53D9 == 4) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								FlatIdent_53D9 = 5;
							end
						end
					elseif (Enum > 93) then
						local A = Inst[2];
						local T = Stk[A];
						local B = Inst[3];
						for Idx = 1, B do
							T[Idx] = Stk[A + Idx];
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
					end
				elseif (Enum <= 96) then
					if (Enum == 95) then
						if (Inst[2] <= Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						local FlatIdent_18FAB = 0;
						local A;
						while true do
							if (FlatIdent_18FAB == 0) then
								A = nil;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								FlatIdent_18FAB = 1;
							end
							if (1 == FlatIdent_18FAB) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								FlatIdent_18FAB = 2;
							end
							if (3 == FlatIdent_18FAB) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
								break;
							end
							if (FlatIdent_18FAB == 2) then
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								FlatIdent_18FAB = 3;
							end
						end
					end
				elseif (Enum > 97) then
					Stk[Inst[2]] = Inst[3] ~= 0;
				else
					local FlatIdent_41401 = 0;
					local A;
					while true do
						if (0 == FlatIdent_41401) then
							A = nil;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_41401 = 1;
						end
						if (FlatIdent_41401 == 4) then
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_41401 = 5;
						end
						if (1 == FlatIdent_41401) then
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							FlatIdent_41401 = 2;
						end
						if (FlatIdent_41401 == 7) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							break;
						end
						if (3 == FlatIdent_41401) then
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							FlatIdent_41401 = 4;
						end
						if (FlatIdent_41401 == 6) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							FlatIdent_41401 = 7;
						end
						if (FlatIdent_41401 == 2) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							FlatIdent_41401 = 3;
						end
						if (FlatIdent_41401 == 5) then
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							FlatIdent_41401 = 6;
						end
					end
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!773Q00030A3Q006C6F6164737472696E6703043Q0067616D6503073Q00482Q747047657403493Q00682Q7470733A2Q2F6769746875622E636F6D2F64617769642D736372697074732F466C75656E742F72656C65617365732F6C61746573742F646F776E6C6F61642F6D61696E2E6C7561030C3Q0043726561746557696E646F7703053Q005469746C6503143Q0043612Q7453746172204175746F4661726D20763103073Q0056657273696F6E03083Q005375625469746C65030E3Q0058656E6F2053752Q706F7274656403083Q005461625769647468026Q00644003043Q0053697A6503053Q005544696D32030A3Q0066726F6D4F2Q66736574025Q00308140025Q00C0774003073Q00416372796C69632Q0103053Q005468656D6503043Q004461726B030B3Q004D696E696D697A654B657903043Q00456E756D03073Q004B6579436F6465030B3Q004C656674436F6E74726F6C03043Q004D61696E03063Q00412Q64546162030A3Q004368657374204661726D03043Q0049636F6E03043Q00686F6D6503043Q00426F6E6503093Q00426F6E65204661726D03053Q00736B752Q6C03083Q0053652Q74696E677303083Q0073652Q74696E677303073Q004F7074696F6E73030A3Q004765745365727669636503073Q00506C6179657273030B3Q004C6F63616C506C6179657203113Q005265706C69636174656453746F72616765030C3Q0054772Q656E5365727669636503093Q00576F726B737061636503073Q00506C6163654964030C3Q0057616974466F724368696C6403073Q004D6F64756C65732Q033Q004E657403113Q0052452F5265676973746572412Q7461636B030E3Q0052452F526567697374657248697403073Q0067657467656E76030B3Q00412Q7461636B52616E6765026Q004E4003083Q004465626F756E6365028Q00030D3Q00436F6D626F4465626F756E636503073Q004D31436F6D626F03053Q007063612Q6C03063Q00412Q7461636B03063Q00434672616D652Q033Q006E6577024Q008095C2C0025Q00806440025Q0094B640022Q00A053AD84E441022Q00701B7B8CF041022Q0030F152C0FB4103083Q00496E7374616E6365030C3Q00426F647956656C6F6369747903083Q004D6178466F72636503073Q00566563746F7233024Q0080842E4103083Q0056656C6F6369747903043Q004E616D65030A3Q004661726D427970612Q7303133Q00426F6479416E67756C617256656C6F6369747903093Q004D6178546F72717565030F3Q00416E67756C617256656C6F6369747903103Q004661726D427970612Q73526F74617465030C3Q00412Q6450617261677261706803073Q00436F6E74656E74031E3Q00466C69657320746F20636865737473206175746F6D61746963612Q6C792E03093Q00412Q64546F2Q676C6503093Q0043686573744661726D030F3Q004175746F204368657374204661726D03073Q0044656661756C74010003093Q004F6E4368616E67656403093Q00412Q64536C69646572030A3Q0054772Q656E53702Q6564030B3Q0054772Q656E2053702Q6564030B3Q004465736372697074696F6E03213Q00486967686572203D204661737465722028332Q30207265636F2Q6D656E64656429025Q00C072402Q033Q004D696E026Q0059402Q033Q004D6178025Q00408F4003083Q00526F756E64696E6703083Q0043612Q6C6261636B031C3Q004861756E74656420436173746C6520285365612033204F6E6C79292E03083Q00426F6E654661726D030E3Q004175746F20426F6E65204661726D030B3Q00412Q6444726F70646F776E030B3Q005468656D6553656C656374030C3Q0053656C656374205468656D6503063Q0056616C75657303053Q004C6967687403063Q004461726B657203043Q004171756103083Q00416D65746879737403043Q00526F736503043Q007461736B03053Q00737061776E03093Q0053656C656374546162026Q00F03F03063Q004E6F7469667903113Q0043612Q7453746172204175746F6661726D03163Q005363726970742068617320622Q656E206C6F6164656403083Q004475726174696F6E026Q0014400009012Q0012383Q00013Q00122Q000100023Q00202Q00010001000300122Q000300046Q000100039Q0000026Q0001000200202Q00013Q00054Q00033Q000700122Q000400073Q00202Q00053Q00084Q00040004000500102Q00030006000400302Q00030009000A00302Q0003000B000C00122Q0004000E3Q00202Q00040004000F00122Q000500103Q00122Q000600116Q00040006000200102Q0003000D000400302Q00030012001300302Q00030014001500122Q000400173Q00202Q00040004001800202Q00040004001900102Q0003001600044Q0001000300024Q00023Q000300202Q00030001001B4Q00053Q000200302Q00050006001C00302Q0005001D001E4Q00030005000200102Q0002001A000300202Q00030001001B4Q00053Q000200302Q00050006002000302Q0005001D00214Q00030005000200102Q0002001F000300202Q00030001001B4Q00053Q000200302Q00050006002200302Q0005001D00234Q00030005000200102Q00020022000300202Q00033Q002400122Q000400023Q00202Q00040004002500122Q000600266Q00040006000200202Q00050004002700122Q000600023Q00202Q00060006002500122Q000800286Q00060008000200122Q000700023Q00202Q00070007002500122Q000900296Q00070009000200122Q000800023Q00202Q00080008002500122Q000A002A6Q0008000A000200122Q000900023Q00202Q00090009002B00202Q000A0006002C00122Q000C002D6Q000A000C000200202Q000A000A002C00122Q000C002E6Q000A000C000200202Q000B000A002C00122Q000D002F6Q000B000D000200202Q000C000A002C00122Q000E00306Q000C000E000200122Q000D00314Q001B000D000100024Q000E3Q000100302Q000E0032003300102Q000D0022000E4Q000D3Q000300302Q000D0034003500302Q000D0036003500302Q000D0037003500122Q000E00383Q00063B000F3Q000100022Q00093Q00054Q00093Q000D4Q004D000E0002000100063B000E0001000100042Q00093Q00054Q00093Q00084Q00093Q000B4Q00093Q000C3Q001056000D0039000E4Q000E5Q00122Q000F003A3Q00202Q000F000F003B00122Q0010003C3Q00122Q0011003D3Q00122Q0012003E6Q000F0012000200122Q0010003F3Q00122Q001100403Q001237001200413Q00122Q001300423Q00202Q00130013003B00122Q001400436Q00130002000200122Q001400453Q00202Q00140014003B00122Q001500463Q00122Q001600463Q00122Q001700466Q001400170002001050001300440014001261001400453Q00202Q00140014003B00122Q001500353Q00122Q001600353Q00122Q001700356Q00140017000200102Q00130047001400302Q00130048004900122Q001400423Q00202Q00140014003B0012370015004A4Q005300140002000200122Q001500453Q00202Q00150015003B00122Q001600463Q00122Q001700463Q00122Q001800466Q00150018000200102Q0014004B001500122Q001500453Q00202Q00150015003B001237001600353Q001203001700353Q00122Q001800356Q00150018000200102Q0014004C001500302Q00140048004D00063B00150002000100052Q00093Q00094Q00093Q00104Q00093Q00114Q00093Q00124Q00093Q00083Q00025B001600033Q00063B00170004000100012Q00093Q00053Q00063B00180005000100032Q00093Q00134Q00093Q00144Q00093Q00053Q00201A00190002001A00202Q00190019004E4Q001B3Q000200302Q001B0006001C00302Q001B004F00504Q0019001B000100202Q00190002001A00202Q00190019005100122Q001B00526Q001C3Q000200300C001C0006005300300C001C005400552Q005A0019001C0002002012001A0019005600063B001C0006000100032Q00093Q00034Q00093Q00164Q00093Q00174Q0018001A001C000100202Q001A0002001A00202Q001A001A005700122Q001C00586Q001D3Q000700302Q001D0006005900302Q001D005A005B00302Q001D0054005C00302Q001D005D005E00302Q001D005F006000300C001D0061003500025B001E00073Q001049001D0062001E4Q001A001D000100202Q001A0002001F00202Q001A001A004E4Q001C3Q000200302Q001C0006002000302Q001C004F00634Q001A001C000100202Q001A0002001F00202Q001A001A0051001237001C00644Q0021001D3Q000200302Q001D0006006500302Q001D005400554Q001A001D000200202Q001B001A005600063B001D0008000100072Q00093Q00034Q00093Q00154Q00098Q00093Q00164Q00093Q00054Q00093Q00184Q00093Q00174Q003D001B001D000100202Q001B0002002200202Q001B001B006600122Q001D00676Q001E3Q000400302Q001E000600684Q001F00063Q00122Q002000153Q00122Q0021006A3Q0012470022006B3Q00122Q0023006C3Q00122Q0024006D3Q00122Q0025006E6Q001F00060001001050001E0069001F00300C001E0054001500063B001F0009000100012Q00097Q001050001E0062001F2Q0052001B001E0001001205001B006F3Q002046001B001B007000063B001C000A000100062Q00093Q00034Q00093Q00054Q00093Q00184Q00093Q000E4Q00093Q00074Q00098Q004D001B00020001001205001B006F3Q002046001B001B007000063B001C000B000100072Q00093Q00034Q00093Q00054Q00093Q00184Q00093Q000F4Q00098Q00093Q00074Q00093Q000D4Q0057001B0002000100202Q001B0001007100122Q001D00726Q001B001D000100202Q001B3Q00734Q001D3Q000300302Q001D0006007400302Q001D004F007500302Q001D007600774Q001B001D00012Q00143Q00013Q000C3Q00083Q00030C3Q0057616974466F724368696C64030D3Q00506C617965725363726970747303153Q0046696E6446697273744368696C644F66436C612Q73030B3Q004C6F63616C53637269707403073Q0067657473656E76030B3Q0048697446756E6374696F6E03023Q005F4703103Q0053656E6448697473546F53657276657200144Q001E7Q00206Q000100122Q000200028Q0002000200206Q000300122Q000200048Q0002000200064Q001300013Q0004133Q00130001001205000100053Q00060F0001001300013Q0004133Q001300012Q0048000100013Q001258000200056Q00038Q00020002000200202Q00020002000700202Q00020002000800102Q0001000600022Q00143Q00017Q001C3Q0003043Q007469636B03083Q004465626F756E636502FCA9F1D24D62503F03093Q00436861726163746572030E3Q0046696E6446697273744368696C6403083Q0048756D616E6F696403063Q004865616C7468028Q0003153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03053Q007461626C6503043Q0066696E6403053Q004D656C2Q65030A3Q00426C6F7820467275697403053Q0053776F726403073Q00542Q6F6C546970030D3Q00436F6D626F4465626F756E636503073Q004D31436F6D626F027Q0040026Q00F03F029A5Q99A93F03073Q00456E656D696573030F3Q004C656674436C69636B52656D6F7465030A3Q004669726553657276657203083Q00506F736974696F6E030B3Q005072696D6172795061727403043Q00556E6974030B3Q0048697446756E6374696F6E01753Q001232000100016Q00010001000200202Q00023Q00024Q00010001000200262Q00010007000100030004133Q000700012Q00143Q00014Q004800015Q00204600010001000400060F0001001400013Q0004133Q00140001002012000200010005001237000400064Q005A00020004000200060F0002001400013Q0004133Q0014000100204600020001000600204600020002000700264400020015000100080004133Q001500012Q00143Q00013Q0020120002000100090012370004000A4Q005A00020004000200060F0002002500013Q0004133Q002500010012050003000B3Q00202F00030003000C4Q000400033Q00122Q0005000D3Q00122Q0006000E3Q00122Q0007000F6Q0004000300010020460005000200102Q005A00030005000200062200030026000100010004133Q002600012Q00143Q00013Q001205000300014Q003F00030001000200204600043Q00112Q00170003000300040026440003002F000100030004133Q002F000100204600033Q001200062200030030000100010004133Q00300001001237000300083Q000E5F00130035000100030004133Q00350001001237000400143Q00060700030036000100040004133Q0036000100200A000300030014001205000400014Q003F0004000100020010503Q001100040010503Q00120003000E5F00130041000100030004133Q00410001001205000400014Q003F00040001000200200A00040004001500062200040043000100010004133Q00430001001205000400014Q003F0004000100020010503Q000200042Q001600045Q00063B00053Q000100022Q00093Q00014Q00093Q00044Q0034000600056Q000700013Q00202Q00070007000500122Q000900166Q000700096Q00063Q00014Q000600043Q000E2Q00080074000100060004133Q00740001002012000600020005001237000800174Q005A00060008000200060F0006006100013Q0004133Q0061000100204600060002001700203600060006001800202Q00080004001400202Q00080008001300202Q00080008001900202Q00090001001A00202Q0009000900194Q00080008000900202Q00080008001B4Q000900036Q0006000900012Q0048000600023Q00203500060006001800122Q000800086Q00060008000100202Q00063Q001C00062Q0006006E00013Q0004133Q006E000100204600063Q001C00206000070004001400202Q0007000700134Q000800046Q00060008000100044Q007400012Q0048000600033Q00202500060006001800202Q00080004001400202Q0008000800134Q000900046Q0006000900012Q00143Q00013Q00013Q000F3Q0003053Q007061697273030B3Q004765744368696C6472656E030E3Q0046696E6446697273744368696C6403083Q0048756D616E6F696403063Q004865616C7468028Q0003103Q0048756D616E6F6964522Q6F745061727403083Q00506F736974696F6E030B3Q005072696D6172795061727403093Q004D61676E697475646503073Q0067657467656E7603083Q0053652Q74696E6773030B3Q00412Q7461636B52616E676503053Q007461626C6503063Q00696E7365727401303Q0006223Q0003000100010004133Q000300012Q00143Q00013Q001205000100013Q00201200023Q00022Q004C000200034Q002B00013Q00030004133Q002D00012Q004800065Q00064B0005002D000100060004133Q002D0001002012000600050003001237000800044Q005A00060008000200060F0006002D00013Q0004133Q002D0001002046000600050004002046000600060005000E430006002D000100060004133Q002D0001002012000600050003001237000800074Q005A00060008000200060F0006002D00013Q0004133Q002D00010020460007000600082Q000200085Q00202Q00080008000900202Q0008000800084Q00070007000800202Q00070007000A00122Q0008000B6Q00080001000200202Q00080008000C00202Q00080008000D00062Q0007002D000100080004133Q002D00010012050007000E3Q00204500070007000F4Q000800016Q000900026Q000A00056Q000B00066Q0009000200012Q005200070009000100064200010008000100020004133Q000800012Q00143Q00017Q000E3Q00026Q00F03F027Q0040026Q000840030E3Q0046696E6446697273744368696C642Q033Q004D617003073Q00456E656D696573030A3Q004D6172696E65466F726403063Q004A756E676C6503063Q004D6F6E6B657903073Q00476F72692Q6C6103093Q004472652Q73726F736103093Q0047722Q656E5A6F6E65030B3Q005377616E20506972617465030D3Q00466163746F7279205374612Q6600554Q00488Q0048000100013Q0006593Q0006000100010004133Q000600010012373Q00014Q004E3Q00024Q00488Q0048000100023Q0006593Q000C000100010004133Q000C00010012373Q00024Q004E3Q00024Q00488Q0048000100033Q0006593Q0012000100010004133Q001200010012373Q00034Q004E3Q00024Q00483Q00043Q00202A5Q000400122Q000200058Q000200024Q000100043Q00202Q00010001000400122Q000300066Q00010003000200064Q002800013Q0004133Q0028000100201200023Q0004001237000400074Q005A00020004000200062200020026000100010004133Q0026000100201200023Q0004001237000400084Q005A00020004000200060F0002002800013Q0004133Q00280001001237000200014Q004E000200023Q00060F0001003600013Q0004133Q00360001002012000200010004001237000400094Q005A00020004000200062200020034000100010004133Q003400010020120002000100040012370004000A4Q005A00020004000200060F0002003600013Q0004133Q00360001001237000200014Q004E000200023Q00060F3Q004400013Q0004133Q0044000100201200023Q00040012370004000B4Q005A00020004000200062200020042000100010004133Q0042000100201200023Q00040012370004000C4Q005A00020004000200060F0002004400013Q0004133Q00440001001237000200024Q004E000200023Q00060F0001005200013Q0004133Q005200010020120002000100040012370004000D4Q005A00020004000200062200020050000100010004133Q005000010020120002000100040012370004000E4Q005A00020004000200060F0002005200013Q0004133Q00520001001237000200024Q004E000200023Q001237000200034Q004E000200024Q00143Q00017Q00063Q0003093Q00776F726B737061636503153Q0046696E6446697273744368696C644F66436C612Q7303073Q0054652Q7261696E030D3Q0057617465725761766553697A65028Q0003103Q0057617465725265666C656374616E6365000D3Q00125C3Q00013Q00206Q000200122Q000200038Q0002000200064Q000C00013Q0004133Q000C00010012053Q00013Q0020305Q000300304Q0004000500124Q00013Q00206Q000300304Q000600052Q00143Q00017Q000F3Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F7450617274030A3Q004661726D427970612Q7303073Q0044657374726F7903103Q004661726D427970612Q73526F7461746503083Q0048756D616E6F6964030D3Q00506C6174666F726D5374616E64010003053Q007061697273030B3Q004765744368696C6472656E2Q033Q0049734103083Q004261736550617274030A3Q0043616E436F2Q6C6964652Q01002D4Q00487Q0020465Q000100060F3Q002C00013Q0004133Q002C000100201200013Q0002001237000300034Q005A00010003000200060F0001001900013Q0004133Q00190001002012000200010002001237000400044Q005A00020004000200060F0002001100013Q0004133Q001100010020460002000100040020120002000200052Q004D000200020001002012000200010002001237000400064Q005A00020004000200060F0002001900013Q0004133Q001900010020460002000100060020120002000200052Q004D00020002000100201200023Q0002001237000400074Q005A00020004000200060F0002001F00013Q0004133Q001F000100300C0002000800090012050003000A3Q00201200043Q000B2Q004C000400054Q002B00033Q00050004133Q002A000100201200080007000C001237000A000D4Q005A0008000A000200060F0008002A00013Q0004133Q002A000100300C0007000E000F00064200030024000100020004133Q002400012Q00143Q00017Q000F3Q00030E3Q0046696E6446697273744368696C64030A3Q004661726D427970612Q7303053Q00436C6F6E6503063Q00506172656E7403103Q004661726D427970612Q73526F7461746503093Q0043686172616374657203083Q0048756D616E6F6964030D3Q00506C6174666F726D5374616E642Q0103053Q007061697273030B3Q004765744368696C6472656E2Q033Q0049734103083Q004261736550617274030A3Q0043616E436F2Q6C6964650100012A3Q00201200013Q0001001237000300024Q005A00010003000200062200010009000100010004133Q000900012Q004800015Q0020120001000100032Q0006000100020002001050000100043Q00201200013Q0001001237000300054Q005A00010003000200062200010012000100010004133Q001200012Q0048000100013Q0020120001000100032Q0006000100020002001050000100044Q0048000100023Q00200800010001000600202Q00010001000100122Q000300076Q00010003000200062Q0001001A00013Q0004133Q001A000100300C0001000800090012050002000A4Q0004000300023Q00202Q00030003000600202Q00030003000B4Q000300046Q00023Q000400044Q0027000100201200070006000C0012370009000D4Q005A00070009000200060F0007002700013Q0004133Q0027000100300C0006000E000F00064200020021000100020004133Q002100012Q00143Q00017Q00043Q0003093Q0043686573744661726D03053Q0056616C756503083Q00426F6E654661726D03083Q0053657456616C756500154Q00487Q0020465Q00010020465Q000200060F3Q001200013Q0004133Q001200012Q00487Q0020465Q00030020465Q000200060F3Q000F00013Q0004133Q000F00012Q00487Q0020465Q00030020125Q00042Q006200026Q00523Q000200012Q00483Q00014Q00153Q000100010004133Q001400012Q00483Q00024Q00153Q000100012Q00143Q00019Q002Q002Q014Q00143Q00017Q000F3Q0003083Q00426F6E654661726D03053Q0056616C7565026Q00084003063Q004E6F7469667903053Q005469746C6503133Q0057726F6E67205365612044657465637465642103073Q00436F6E74656E74030F3Q00596F752061726520696E205365612003203Q002E20426F6E65204661726D206F6E6C7920776F726B7320696E2053656120332E03083Q004475726174696F6E026Q00144003083Q0053657456616C756503093Q0043686573744661726D03043Q007461736B03053Q00737061776E00304Q00487Q0020465Q00010020465Q000200060F3Q002D00013Q0004133Q002D00012Q00483Q00014Q003F3Q000100020026103Q001A000100030004133Q001A00012Q0048000100023Q0020540001000100044Q00033Q000300302Q00030005000600122Q000400086Q00055Q00122Q000600096Q00040004000600102Q00030007000400302Q0003000A000B4Q0001000300014Q00015Q00202Q00010001000100202Q00010001000C4Q00038Q0001000300016Q00014Q004800015Q00204600010001000D00204600010001000200060F0001002400013Q0004133Q002400012Q004800015Q00204600010001000D00201200010001000C2Q006200036Q00520001000300012Q0048000100034Q00150001000100010012050001000E3Q00204600010001000F00063B00023Q000100022Q00483Q00044Q00483Q00054Q004D0001000200010004133Q002F00012Q00483Q00064Q00153Q000100012Q00143Q00013Q00013Q00033Q0003093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727400114Q00487Q0020465Q000100060F3Q001000013Q0004133Q001000012Q00487Q0020085Q000100206Q000200122Q000200038Q0002000200064Q001000013Q0004133Q001000012Q00483Q00014Q004800015Q0020460001000100010020460001000100032Q004D3Q000200012Q00143Q00017Q00013Q0003083Q005365745468656D6501054Q000E00015Q00202Q0001000100014Q00038Q0001000300016Q00017Q002B3Q0003043Q007461736B03043Q0077616974026Q00E03F03093Q0043686573744661726D03053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q00026Q00F03F03053Q00706169727303093Q00776F726B7370616365030E3Q0047657444657363656E64616E74732Q033Q0049734103083Q00426173655061727403043Q004E616D6503043Q0066696E6403053Q004368657374030A3Q0054772Q656E53702Q656403083Q00506F736974696F6E03093Q004D61676E697475646503093Q0054772Q656E496E666F2Q033Q006E657703043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D6503043Q00506C6179030D3Q00506C61796261636B537461746503073Q00506C6179696E6703063Q0043616E63656C026Q33D33F03063Q004E6F7469667903053Q005469746C65030A3Q004368657374204661726D03073Q00436F6E74656E7403123Q004E6F2043686573747320466F756E643Q2E03083Q004475726174696F6E026Q000840027Q004000A73Q0012053Q00013Q0020465Q0002001237000100034Q00063Q0002000200060F3Q00A600013Q0004133Q00A600012Q00487Q0020465Q00040020465Q000500060F5Q00013Q0004135Q00012Q00483Q00013Q0020465Q00060006223Q0010000100010004133Q001000010004135Q000100201200013Q0007001229000300086Q00010003000200202Q00023Q000700122Q000400096Q00020004000200062Q0001001D00013Q0004133Q001D000100060F0002001D00013Q0004133Q001D000100204600030002000A002644000300220001000B0004133Q00220001001205000300013Q0020460003000300020012370004000C4Q004D0003000200010004135Q00012Q0048000300024Q000D000400016Q0003000200014Q00035Q00122Q0004000D3Q00122Q0005000E3Q00202Q00050005000F4Q000500066Q00043Q000600044Q009100012Q004800095Q00204600090009000400204600090009000500062200090032000100010004133Q003200010004133Q009300012Q0048000900013Q00204600090009000600060F0009009300013Q0004133Q009300012Q0048000900013Q00200800090009000600202Q00090009000700122Q000B00086Q0009000B000200062Q0009009300013Q0004133Q009300012Q0048000900013Q00204600090009000600204600090009000900204600090009000A002644000900440001000B0004133Q004400010004133Q009300012Q0048000900013Q00204100090009000600202Q00010009000800202Q00090008001000122Q000B00116Q0009000B000200062Q0009009100013Q0004133Q00910001002046000900080012002012000900090013001237000B00144Q005A0009000B000200060F0009009100013Q0004133Q009100012Q0062000300014Q004000098Q000900036Q00095Q00202Q00090009001500202Q00090009000500202Q000A0008001600202Q000B000100164Q000A000A000B00202Q000A000A001700122Q000B00183Q00202Q000B000B00194Q000C000A000900122Q000D001A3Q00202Q000D000D001B00202Q000D000D001C4Q000B000D00024Q000C00043Q00202Q000C000C001D4Q000E00016Q000F000B6Q00103Q000100202Q00110008001E00102Q0010001E00114Q000C0010000200202Q000D000C001F4Q000D0002000100202Q000D000C0020001205000E001A3Q002046000E000E0020002046000E000E0021000659000D008D0001000E0004133Q008D0001001205000E00013Q002026000E000E00024Q000E0001000100202Q000D000C00204Q000E00013Q00202Q000E000E000600062Q000E008100013Q0004133Q008100012Q0048000E00013Q002046000E000E0006002046000E000E0009002046000E000E000A002644000E00840001000B0004133Q00840001002012000E000C00222Q004D000E000200010004133Q008D00012Q0048000E5Q002046000E000E0004002046000E000E0005000622000E006E000100010004133Q006E0001002012000E000C00222Q004D000E000200010004133Q008D00010004133Q006E0001001205000E00013Q002046000E000E0002001237000F00234Q004D000E000200010006420004002C000100020004133Q002C000100062200033Q000100010004135Q00012Q0048000400033Q00062200043Q000100010004135Q00012Q0048000400053Q00201C0004000400244Q00063Q000300302Q00060025002600302Q00060027002800302Q00060029002A4Q0004000600014Q000400016Q000400033Q00122Q000400013Q00202Q00040004000200122Q0005002B6Q00040002000100046Q00012Q00143Q00017Q00373Q0003043Q007461736B03043Q007761697403083Q00426F6E654661726D03053Q0056616C756503093Q00436861726163746572030E3Q0046696E6446697273744368696C6403103Q0048756D616E6F6964522Q6F745061727403083Q0048756D616E6F696403063Q004865616C7468028Q00026Q00F03F03083Q00506F736974696F6E03093Q004D61676E6974756465025Q00E0754003063Q004E6F7469667903053Q005469746C6503093Q00426F6E65204661726D03073Q00436F6E74656E74031E3Q0054726176656C696E6720746F204861756E74656420436173746C653Q2E03083Q004475726174696F6E026Q00084003093Q0054772Q656E496E666F2Q033Q006E6577025Q00C0724003043Q00456E756D030B3Q00456173696E675374796C6503063Q004C696E65617203063Q0043726561746503063Q00434672616D6503043Q00506C617903093Q00436F6D706C6574656403043Q0057616974026Q00E03F030F3Q005265626F726E20536B656C65746F6E030D3Q004C6976696E67205A6F6D626965030C3Q0044656D6F6E696320536F756C030F3Q00506F2Q73652Q736564204D752Q6D7903053Q00706169727303093Q00776F726B737061636503073Q00456E656D696573030B3Q004765744368696C6472656E03053Q007461626C6503043Q0066696E6403043Q004E616D6503063Q00506172656E7403073Q00566563746F7233026Q00104003153Q0046696E6446697273744368696C644F66436C612Q7303043Q00542Q6F6C03083Q004261636B7061636B03093Q004571756970542Q6F6C03063Q00412Q7461636B024Q008095C2C0025Q00406540025Q0094B64000CB3Q0012053Q00013Q0020465Q00022Q003F3Q0001000200060F3Q00CA00013Q0004133Q00CA00012Q00487Q0020465Q00030020465Q000400060F5Q00013Q0004135Q00012Q00483Q00013Q0020465Q00050006223Q000F000100010004133Q000F00010004135Q000100201200013Q0006001229000300076Q00010003000200202Q00023Q000600122Q000400086Q00020004000200062Q0001001C00013Q0004133Q001C000100060F0002001C00013Q0004133Q001C0001002046000300020009002644000300210001000A0004133Q00210001001205000300013Q0020460003000300020012370004000B4Q004D0003000200010004135Q00012Q0048000300024Q002E000400016Q0003000200014Q000300033Q00202Q00030003000C00202Q00040001000C4Q00030003000400202Q00030003000D000E2Q000E004A000100030004133Q004A00012Q0048000400043Q00205D00040004000F4Q00063Q000300302Q00060010001100302Q00060012001300302Q0006001400154Q00040006000100122Q000400163Q00202Q00040004001700202Q00050003001800122Q000600193Q00202Q00060006001A00202Q00060006001B4Q0004000600024Q000500053Q00202Q00050005001C4Q000700016Q000800046Q00093Q00014Q000A00033Q00102Q0009001D000A4Q00050009000200202Q00060005001E4Q00060002000100202Q00060005001F00202Q0006000600204Q00060002000100122Q000600013Q00202Q00060006000200122Q000700216Q0006000200012Q0016000400043Q001247000500223Q00122Q000600233Q00122Q000700243Q00122Q000800256Q0004000400012Q0020000500053Q001233000600263Q00122Q000700273Q00202Q00070007002800202Q0007000700294Q000700086Q00063Q000800044Q006A0001001205000B002A3Q002019000B000B002B4Q000C00043Q00202Q000D000A002C4Q000B000D000200062Q000B006A00013Q0004133Q006A0001002012000B000A0006001237000D00074Q005A000B000D000200060F000B006A00013Q0004133Q006A0001002046000B000A0008002046000B000B0009000E43000A006A0001000B0004133Q006A00012Q00090005000A3Q0004133Q006C000100064200060058000100020004133Q0058000100060F000500C200013Q0004133Q00C200012Q004800065Q00204600060006000300204600060006000400062200060074000100010004133Q007400010004135Q000100060F00053Q00013Q0004135Q000100204600060005002D00060F00063Q00013Q0004135Q0001002012000600050006001237000800084Q005A00060008000200060F00063Q00013Q0004135Q0001002046000600050008002046000600060009002644000600830001000A0004133Q008300010004135Q00012Q0048000600013Q00204600060006000500060F00063Q00013Q0004135Q00012Q0048000600013Q0020460006000600050020460006000600080020460006000600090026440006008E0001000A0004133Q008E00010004135Q00012Q0048000600013Q00200100060006000500202Q0001000600074Q000600026Q000700016Q00060002000100202Q00060005000700202Q00060006000C00122Q0007001D3Q00202Q00070007001700122Q0008002E3Q00202Q00080008001700122Q0009000A3Q00122Q000A002F3Q00122Q000B000A6Q0008000B00024Q0008000600084Q000900066Q00070009000200102Q0001001D000700202Q00073Q003000122Q000900316Q00070009000200062Q000700AC000100010004133Q00AC00012Q0048000700013Q002046000700070032002012000700070030001237000900314Q005A00070009000200060F000700B400013Q0004133Q00B4000100204600080007002D00064B000800B400013Q0004133Q00B400010020120008000200332Q0009000A00074Q00520008000A00012Q0048000800063Q00204A0008000800344Q00080002000100122Q000800013Q00202Q0008000800024Q00080001000100202Q00080005000800202Q00080008000900262Q00083Q0001000A0004135Q000100204600080005002D0006220008006E000100010004133Q006E00010004135Q00010012050006001D3Q00203C00060006001700122Q000700353Q00122Q000800363Q00122Q000900376Q00060009000200102Q0001001D000600046Q00012Q00143Q00017Q00", GetFEnv(), ...);