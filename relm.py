from __future__ import annotations
from typing import Iterable, Any
import inspect
from pathlib import Path
import itertools
import ctypes


class Statement:
    def render(self, codes: list[Code]) -> list[Code]:
        raise SyntaxError("broken statement")

    def terminal(self) -> bool:
        return False


class ErrorStatement(Statement):
    def terminal(self) -> bool:
        raise SyntaxError("broken statement")


class Code(Statement):
    def __init__(
        self,
        op: str,
        operand: Code | tuple[Code] | int | str | float = 0,
        debug: str | bool = True,
        offset: int = 0,
    ):
        self.op = op
        self.offset = offset
        if isinstance(operand, Code):
            self.operand = operand.operand
            self.ref = [operand]
        elif isinstance(operand, tuple):
            self.operand = operand[0].operand
            self.ref = list(operand)
        else:
            self.operand = operand
            self.ref = []
        if not debug:
            self.debug = False
        elif ReLM.on_render:
            self.debug = "    " + ReLM.on_render.__name__
        else:
            if not isinstance(debug, str):
                debug = ""
            d = inspect.stack()[-1]
            lineno = f"{d.lineno}:"
            lineno += " " * (8 - len(lineno))
            self.debug = f"{lineno}{debug}{d.code_context[0][:-1].strip()}"

    def render(self, codes: list[Code]) -> list[Code]:
        codes.append(self)
        return codes

    def deploy(self, memory: list[Code], ncpu: int) -> bool:
        address = len(memory)
        for c in self.ref:
            c.operand = address + c.offset
        memory.append(self)
        return True


class BinaryOp(Statement):
    def __init__(self, unsigned: bool = False):
        self.unsigned = unsigned

    def __add__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.binary(rhs, "ADD")

    def __radd__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rbinary(lhs, "ADD")

    def __sub__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.binary(rhs, "SUB", "RSUB")

    def __rsub__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rbinary(lhs, "SUB", "RSUB")

    def __mul__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.binary(rhs, "MUL")

    def __rmul__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rbinary(lhs, "MUL")

    def __floordiv__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.div(rhs, False)

    def __rfloordiv__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rdiv(lhs, False)

    def __mod__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.div(rhs, True)

    def __rmod__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rdiv(lhs, True)

    def __and__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.binary(rhs, "AND")

    def __rand__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rbinary(lhs, "AND")

    def __xor__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.binary(rhs, "XOR")

    def __rxor__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rbinary(lhs, "XOR")

    def __or__(lhs, rhs: int | str | BinaryOp) -> ExprB:
        return lhs.binary(rhs, "OR")

    def __ror__(rhs, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rbinary(lhs, "OR")

    def __pos__(self) -> ExprB:
        return self

    def __neg__(self) -> ExprB:
        return 0 - self

    def __invert__(self) -> ExprB:
        return self ^ -1

    def __lt__(lhs, rhs: int | str | BinaryOp) -> Bool:
        if lhs.unsigned:
            return Bool(lhs.binary(rhs, "ULT", "UGT"))
        else:
            return Bool(lhs.binary(rhs, "ILT", "IGT"))

    def __ge__(lhs, rhs: int | str | BinaryOp) -> Bool:
        if lhs.unsigned:
            return Bool(lhs.binary(rhs, "ULT", "UGT"), True)
        else:
            return Bool(lhs.binary(rhs, "ILT", "IGT"), True)

    def __gt__(lhs, rhs: int | str | BinaryOp) -> Bool:
        if lhs.unsigned:
            return Bool(lhs.binary(rhs, "UGT", "ULT"))
        else:
            return Bool(lhs.binary(rhs, "IGT", "ILT"))

    def __le__(lhs, rhs: int | str | BinaryOp) -> Bool:
        if lhs.unsigned:
            return Bool(lhs.binary(rhs, "UGT", "ULT"), True)
        else:
            return Bool(lhs.binary(rhs, "IGT", "ILT"), True)

    def __ne__(lhs, rhs: int | str | BinaryOp) -> Bool:
        if isinstance(rhs, int) and rhs == 0:
            return Bool(+lhs)
        else:
            return Bool(lhs ^ rhs)

    def __eq__(lhs, rhs: int | str | BinaryOp) -> Bool:
        if isinstance(rhs, int) and rhs == 0:
            return Bool(+lhs, True)
        else:
            return Bool(lhs ^ rhs, True)

    useB = {"BLOAD", "BSLOAD", "BLOADX", "BSLOADX", "DIV", "DIVLOOP"}

    def getitem(self, items: Any, codes: list[Code | list[Code]]) -> type:
        t = Expr
        if not isinstance(items, tuple):
            items = (items,)
        for code in items:
            match code:
                case ExprB():
                    codes.extend(code.codes)
                    if not isinstance(code, Expr):
                        t = ExprB
                    continue
                case list():
                    codes.append(code)
                    continue
                case slice():
                    if isinstance(code.start, str):
                        code = [Code(code.start, code.stop)]
                    else:
                        rhs, op = code.start, code.stop
                        rhs = rhs.bload(op)
                        codes.extend(rhs.codes)
                        t = ExprB
                        continue
                case Statement():
                    code = code.render([])
                case _:
                    raise TypeError(f"{type(code)} is not supported")
            codes.extend(code)
            for c in code:
                if c.op in self.useB or c.operand in self.useB:
                    t = ExprB
        return t

    def __getitem__(self, items: Any) -> ExprB:
        codes = []
        return self.getitem(items, codes)(*codes, unsigned=self.unsigned)


class ExprB(BinaryOp):
    def __init__(self, *codes: Code | list[Code], unsigned: bool = False):
        super().__init__(unsigned)
        self.codes = codes

    def render(self, codes: list[Code]) -> list[Code]:
        for c in self.codes:
            if isinstance(c, list):
                codes.extend(c)
            else:
                codes.append(c)
        return codes

    def binary(lhs: ExprB, rhs: int | str | BinaryOp, *op: str) -> ExprB:
        match rhs:
            case int() | str():
                return lhs[lhs, op[0] : rhs]
            case Int():
                return lhs[lhs, op[0] : rhs.put()]
            case Expr():
                return lhs[RegB(lhs, rhs).opb(op[-1])]
            case ExprB():
                return lhs[l := Int(lhs), rhs, op[-1] : l.put()]
            case RegBType():
                return lhs[r := Int(rhs), lhs, op[0] : r.put()]
            case _:
                return NotImplemented

    def rbinary(rhs: ExprB, lhs: int | str | BinaryOp, *op: str) -> ExprB:
        match lhs:
            case int() | str():
                return rhs[rhs, op[-1] : lhs]
            case Int():
                return lhs[rhs, op[-1] : lhs.put()]
            case Expr():
                return lhs[RegB(rhs, lhs).opb(op[0])]
            case ExprB() | RegBType():
                return lhs[l := Int(lhs), rhs, op[-1] : l.put()]
            case _:
                return NotImplemented

    @staticmethod
    def udiv(mod: bool) -> Block:
        b = Block()
        for _ in range(11):
            b[AccU.opb("DIVLOOP")]
        if mod:
            b[+RegBU]
        return b

    def div(lhs: ExprB, rhs: int | BinaryOp, mod: bool) -> ExprB:
        match rhs:
            case int():
                return lhs[lhs, "DIV":rhs, lhs.udiv(mod)]
            case Int():
                return lhs[lhs, "DIV" : rhs.put(), lhs.udiv(mod)]
            case Expr():
                return lhs[
                    RegB(lhs, rhs).swapAB().opb("DIV"),
                    lhs.udiv(mod),
                ]
            case ExprB() | RegBType():
                return lhs[r := Int(rhs), lhs, "DIV" : r.put(), lhs.udiv(mod)]
            case _:
                return NotImplemented

    def rdiv(rhs: ExprB, lhs: int | BinaryOp, mod: bool) -> ExprB:
        match lhs:
            case int():
                return rhs[RegB(rhs, lhs).opb("DIV"), rhs.udiv(mod)]
            case Int() | Expr():
                return lhs[RegB(rhs, lhs).opb("DIV"), rhs.udiv(mod)]
            case ExprB():
                return lhs[r := Int(rhs), lhs, "DIV" : r.put(), rhs.udiv(mod)]
            case RegBType():
                return lhs[
                    l := Int(lhs),
                    RegB(rhs, l).opb("DIV"),
                    rhs.udiv(mod),
                ]
            case _:
                return NotImplemented

    def shift(lhs: ExprB, rhs: int | BinaryOp, op: str) -> ExprB:
        match rhs:
            case int():
                return lhs[lhs, op : 1 << (rhs & 31)]
            case Int():
                return lhs[lhs, op : rhs.puts()]
            case Expr():
                return lhs[RegB(lhs, rhs).swapAB("BSLOAD").opb(op)]
            case ExprB():
                return lhs[r := Int(rhs), lhs, op : r.puts()]
            case _:
                return NotImplemented

    def __lshift__(lhs: ExprB, rhs: int | BinaryOp) -> ExprB:
        return lhs.shift(rhs, "MUL")

    def __rshift__(lhs: ExprB, rhs: int | BinaryOp) -> ExprB:
        return lhs.shift(rhs, "SHR" if lhs.unsigned else "SAR")

    def rshift(rhs: ExprB, lhs: int | str | BinaryOp, op: str) -> ExprB:
        match lhs:
            case Expr():
                return lhs[RegB(rhs, lhs, "BSLOAD").opb(op)]
            case ExprB():
                return lhs[r := Int(rhs), lhs, op : r.puts()]
            case _:
                return NotImplemented

    def __rlshift__(rhs: ExprB, lhs: int | str | BinaryOp) -> ExprB:
        match lhs:
            case int() | str():
                if lhs == 1:
                    return rhs[rhs.opb("SHIFT")]
                else:
                    return rhs[rhs.opb("SHIFT") * lhs]
            case Int():
                return lhs[rhs.opb("SHIFT") * lhs]
            case _:
                return rhs.rshift(lhs, "MUL")

    def __rrshift__(rhs: ExprB, lhs: int | str | BinaryOp) -> ExprB:
        unsigned = rhs.unsigned if isinstance(lhs, int) else lhs.unsigned
        op = "SHR" if unsigned else "SAR"
        match lhs:
            case int() | str():
                return rhs[RegB(rhs, lhs, "BSLOAD").opb(op)]
            case Int():
                return lhs[RegB(rhs, lhs, "BSLOAD").opb(op)]
            case _:
                return rhs.rshift(lhs, op)

    def opb(self, op: str) -> ExprB:
        return self[self, "OPB":op]

    def swapAB(self, op: str = "BLOAD") -> ExprB:
        return self.opb(op)

    def bit_count(self) -> ExprB:
        return self[
            self,
            (AccU.opb("BLOADX") >> 1) & 0x55555555,
            (((RegBU - AccU).opb("BLOADX") >> 2) & 0x33333333) * 3,
            (RegBU - AccU).opb("BLOADX") >> 4,
            (((RegBU + AccU) & 0xF0F0F0F) * 0x1010101) >> 24,
        ]


class Expr(ExprB):
    def bload(self, op: str = "BLOAD") -> ExprB:
        for c in self.codes:
            if isinstance(c, (Label, list)):
                continue
            elif c.op == "LOAD":
                c.op = op
                return self[self.codes]
            else:
                break
        return self[op:0, self]

    def binary(lhs: Expr, rhs: int | str | BinaryOp, *op: str) -> ExprB:
        match rhs:
            case Expr():
                return super().binary(rhs, *op)
            case ExprB():
                return lhs[RegB(rhs, lhs).opb(op[0])]
            case RegBType():
                return lhs[lhs.opb(op[0])]
            case _:
                return super().binary(rhs, *op)

    def rbinary(rhs: Expr, lhs: int | str | BinaryOp, *op: str) -> ExprB:
        match lhs:
            case ExprB():
                return lhs[RegB(lhs, rhs).opb(op[-1])]
            case RegBType():
                return lhs[rhs.opb(op[-1])]
            case _:
                return super().rbinary(lhs, *op)

    def div(lhs: Expr, rhs: int | BinaryOp, mod: bool) -> ExprB:
        match rhs:
            case ExprB():
                return lhs[RegBU(rhs, lhs).opb("DIV"), lhs.udiv(mod)]
            case RegBType():
                return lhs[lhs, Acc.opb("DIV"), lhs.udiv(mod)]
            case _:
                return super().div(rhs, mod)

    def rdiv(rhs: Expr, lhs: int | BinaryOp, mod: bool) -> ExprB:
        match lhs:
            case ExprB():
                return lhs.div(rhs, mod)
            case RegBType():
                return lhs[rhs.swapAB().opb("DIV"), rhs.udiv(mod)]
            case _:
                return super().rdiv(lhs, mod)

    def shift(lhs: Expr, rhs: int | BinaryOp, op: str) -> ExprB:
        match rhs:
            case ExprB():
                return lhs[RegB(rhs, lhs, "BSLOAD").opb(op)]
            case _:
                return super().shift(rhs, op)

    def rshift(rhs: Expr, lhs: int | str | BinaryOp, op: str) -> ExprB:
        match lhs:
            case ExprB():
                return lhs[RegB(lhs, rhs).swapAB("BSLOAD").opb(op)]
            case _:
                return NotImplemented


class AccExpr(Expr):
    def __init__(self, unsigned: bool = False):
        super().__init__(unsigned=unsigned)

    def __call__(self, value: int | str | BinaryOp) -> Expr:
        match value:
            case int() | str():
                return self["LOAD":value]
            case BinaryOp():
                return +value
            case _:
                raise TypeError(f"{type(value)} is not supported")


Acc = AccExpr()
AccU = AccExpr(True)


class Int(BinaryOp):
    def __init__(
        self, value: int | str | BinaryOp | None = None, unsigned: bool = False
    ):
        super().__init__(unsigned)
        match value:
            case int() | str():
                self.expr = self["LOAD":value]
            case BinaryOp():
                self.expr = +value
            case None:
                self.expr = None
            case _:
                raise TypeError(f"{type(value)} is not supported")
        self.ref = []

    def __pos__(self) -> Expr:
        return self["LOAD" : self.put()]

    def render(self, codes: list[Code]) -> list[Code]:
        if self.expr is not None:
            self.expr.render(codes)
            codes.extend(self.ref)
            self.expr = None
        return codes

    def __call__(self, value: int | str | BinaryOp) -> ExprB:
        expr = Int(value, self.unsigned).expr
        return self[expr, self.ref]

    def put(self) -> Code:
        self.ref.append(code := Code("PUT", debug="->      "))
        return code

    def puts(self) -> Code:
        self.ref.append(code := Code("PUTS", debug="->      "), offset=0x80000000)
        return code

    def binary(lhs: Int, rhs: int | str | BinaryOp, *op: str) -> ExprB:
        match rhs:
            case int() | str():
                return lhs[+lhs, op[0] : rhs]
            case Int():
                return lhs[+lhs, op[0] : rhs.put()]
            case ExprB():
                return lhs[rhs, op[-1] : lhs.put()]
            case RegBType():
                return lhs[+lhs, "OPB" : op[0]]
            case _:
                return NotImplemented

    def rbinary(rhs: Int, lhs: int | str | BinaryOp, *op: str) -> ExprB:
        match lhs:
            case int() | str():
                return rhs["LOAD":lhs, op[0] : rhs.put()]
            case Int():
                return lhs[+lhs, op[0] : rhs.put()]
            case ExprB():
                return lhs[lhs, op[0] : rhs.put()]
            case RegBType():
                return lhs[+lhs, op[0] : rhs.put()]
            case _:
                return NotImplemented

    def div(lhs: Int, rhs: int | BinaryOp, mod: bool) -> ExprB:
        match rhs:
            case int() | Int() | RegBType():
                return (+lhs).div(rhs, mod)
            case ExprB():
                return lhs[RegBU(rhs, lhs).opb("DIV"), Acc.udiv(mod)]
            case _:
                return NotImplemented

    def rdiv(rhs: Int, lhs: int | BinaryOp, mod: bool) -> ExprB:
        match lhs:
            case int():
                return rhs["LOAD":lhs, "DIV" : rhs.put(), Acc.udiv(mod)]
            case Int() | ExprB():
                return lhs[+lhs, "DIV" : rhs.put(), Acc.udiv(mod)]
            case RegBType():
                return lhs[(+rhs).swapAB().opb("DIV"), Acc.udiv(mod)]
            case _:
                return NotImplemented

    def shift(lhs: Int, rhs: int | BinaryOp, op: str) -> ExprB:
        match rhs:
            case int():
                return lhs[+lhs, op : 1 << (rhs & 31)]
            case Int():
                return lhs[+lhs, op : rhs.puts()]
            case ExprB():
                if op == "MUL":
                    return lhs[rhs, "OPB":"SHIFT", op : lhs.put()]
                else:
                    return lhs[rhs, "BSLOAD" : lhs.put(), "OPB":op]
            case _:
                return NotImplemented

    def __lshift__(lhs: Int, rhs: int | BinaryOp) -> ExprB:
        return lhs.shift(rhs, "MUL")

    def __rshift__(lhs: Int, rhs: int | BinaryOp) -> ExprB:
        return lhs.shift(rhs, "SHR" if lhs.unsigned else "SAR")

    def rshift(rhs: Int, lhs: int | str | BinaryOp, op: str) -> ExprB:
        match lhs:
            case int() | str():
                if op == "MUL" and lhs == 1:
                    return rhs["LOAD" : rhs.puts()]
                else:
                    return rhs["LOAD":lhs, op : rhs.puts()]
            case Int():
                return lhs[+lhs, op : rhs.puts()]
            case ExprB():
                return lhs[lhs, op : rhs.puts()]
            case _:
                return NotImplemented

    def __rlshift__(rhs: Int, lhs: int | str | BinaryOp) -> ExprB:
        return rhs.rshift(lhs, "MUL")

    def __rrshift__(rhs: Int, lhs: int | str | BinaryOp) -> ExprB:
        unsigned = rhs.unsigned if isinstance(lhs, int) else lhs.unsigned
        return rhs.rshift(lhs, "SHR" if unsigned else "SAR")


def UInt(value: int | str | BinaryOp | None = None):
    return Int(value, True)


class RegBType(BinaryOp):
    def __init__(self, unsigned: bool = False):
        super().__init__(unsigned)

    def __pos__(self) -> Expr:
        return self["OPB":"LOAD"]

    def render(self, codes: list[Code]) -> list[Code]:
        codes.append(Code("OPB", "LOAD"))
        return codes

    def binary(lhs: RegBType, rhs: int | str | BinaryOp, *op: str) -> Expr:
        match rhs:
            case int() | str():
                return lhs[+lhs, op[0] : rhs]
            case Int():
                return lhs[+lhs, op[0] : rhs.put()]
            case Expr():
                return lhs[rhs, "OPB" : op[-1]]
            case ExprB():
                return lhs[+lhs, put := Code("PUT"), rhs, op[-1] : put]
            case _:
                return NotImplemented

    def rbinary(rhs: RegBType, lhs: int | str | BinaryOp, *op: str) -> Expr:
        match lhs:
            case int() | str():
                return rhs["LOAD":lhs, "OPB" : op[0]]
            case Int():
                return lhs[+lhs, "OPB" : op[0]]
            case Expr():
                return lhs[lhs, "OPB" : op[0]]
            case ExprB():
                return lhs[+rhs, put := Code("PUT"), lhs, op[0] : put]
            case _:
                return NotImplemented

    def div(lhs: RegBType, rhs: int | BinaryOp, mod: bool) -> ExprB:
        match rhs:
            case int():
                return lhs[+lhs, "DIV":rhs, Acc.udiv(mod)]
            case _:
                return rhs.rdiv(lhs, mod)

    def rdiv(rhs: RegBType, lhs: int | BinaryOp, mod: bool) -> ExprB:
        match lhs:
            case int():
                return rhs["LOAD":lhs, "OPB":"DIV", Acc.udiv(mod)]
            case _:
                return lhs.div(rhs, mod)

    def shift(lhs: RegBType, rhs: int | BinaryOp, op: str) -> ExprB:
        match rhs:
            case int():
                return lhs[+lhs, op : 1 << (rhs & 31)]
            case Int():
                return lhs[+lhs, op : rhs.puts()]
            case Expr():
                return lhs[rhs, "OPB":"BSLOAD", "OPB":op]
            case ExprB():
                return lhs[+lhs, put := Code("PUT"), rhs, "BSLOAD":put, "OPB":op]
            case _:
                return NotImplemented

    def __lshift__(lhs: RegBType, rhs: int | BinaryOp) -> ExprB:
        return lhs.shift(rhs, "MUL")

    def __rshift__(lhs: RegBType, rhs: int | BinaryOp) -> ExprB:
        return lhs.shift(rhs, "SHR" if lhs.unsigned else "SAR")

    def rshift(rhs: RegBType, lhs: int | str | BinaryOp, op: str) -> ExprB:
        match lhs:
            case Expr():
                return lhs[+rhs, lhs:"BSLOAD", "OPB":op]
            case ExprB():
                return lhs[r := Int(rhs), lhs, op : r.puts()]
            case _:
                return NotImplemented

    def __rlshift__(rhs: RegBType, lhs: int | str | BinaryOp) -> ExprB:
        op = "MUL"
        match lhs:
            case int() | str():
                if lhs == 1:
                    return rhs[+rhs, "OPB":"SHIFT"]
                else:
                    return rhs[+rhs, "OPB":"SHIFT", op:lhs]
            case Int():
                return lhs[+rhs, "OPB":"SHIFT", op : lhs.put()]
            case _:
                return rhs.rshift(lhs, op)

    def __rrshift__(rhs: RegBType, lhs: int | str | BinaryOp) -> ExprB:
        unsigned = rhs.unsigned if isinstance(lhs, int) else lhs.unsigned
        op = "SHR" if unsigned else "SAR"
        match lhs:
            case int() | str():
                return rhs[+rhs, "BSLOAD":lhs, "OPB":op]
            case Int():
                return lhs[+rhs, "BSLOAD" : lhs.put(), "OPB":op]
            case _:
                return rhs.rshift(lhs, op)

    def __call__(
        self,
        regb: int | str | BinaryOp,
        acc: int | str | Int | Expr = 0,
        op: str = "BLOAD",
    ) -> ExprB:
        if isinstance(acc, (int, str, Int)):
            acc = Acc(acc)
        match regb:
            case int() | str():
                return self["LOAD":regb, acc:op]
            case BinaryOp():
                return self[+regb, acc:op]
            case _:
                raise TypeError(f"{type(regb)} is not supported")


RegB = RegBType()
RegBU = RegBType(True)


class Label(Code):
    def __init__(self, offset: int = 0):
        super().__init__("", "", offset=offset)

    def __lshift__(self, rhs: str | Bool | Iterable[Code]) -> Code:
        match rhs:
            case str():
                code = Code(rhs)
                self.ref.append(code)
                return code
            case Bool():
                self.ref.extend(rhs.on[False])
                self.ref.extend(rhs.on[True])
                return self
            case _:
                self.ref.extend(rhs)
                return self

    def deploy(self, memory: list[Code], ncpu: int) -> bool:
        address = len(memory) + self.offset
        for c in self.ref:
            c.operand = address
        return True


class Align(Label):
    def __init__(self, label: Label):
        super().__init__()
        label.ref.append(self)

    def deploy(self, memory: list[Code], ncpu: int) -> bool:
        if not isinstance(self.operand, int):
            return False
        address = len(memory)
        if (address ^ self.operand) & (ncpu - 1):
            return False
        for c in self.ref:
            c.operand = address
        return True


class Bool(ErrorStatement):
    def __init__(self, expr: ExprB, invert: bool = False):
        self.expr = expr
        self.invert = invert
        self.on = ([], [])

    def __invert__(self) -> Bool:
        b = Bool(self.expr, not self.invert)
        b.on[True].extend(self.on[False])
        b.on[False].extend(self.on[True])
        return b

    def __getitem__(self, rhs: tuple[bool | Bool | Code]) -> Bool:
        lhs = self
        for r in rhs:
            match r:
                case bool():
                    jump = Code(("JNE", "JEQ")[r ^ self.invert])
                    b = Bool(lhs.expr[lhs.expr, jump, Label() << lhs.on[r]], lhs.invert)
                    b.on[not r].extend(lhs.on[not r])
                    b.on[not r].append(jump)
                    lhs = b
                case Bool():
                    b = Bool(lhs.expr[lhs.expr, r.expr], r.invert)
                    b.on[False].extend(lhs.on[False])
                    b.on[False].extend(r.on[False])
                    b.on[True].extend(lhs.on[True])
                    b.on[True].extend(r.on[True])
                    lhs = b
                case Code():
                    lhs = Bool(lhs.expr[lhs.expr, r], lhs.invert)
                case _:
                    raise TypeError(f"{type(r)} is not supported")
        return lhs

    def __and__(lhs, rhs: Bool) -> Bool:
        return lhs[True, rhs]

    def __or__(lhs, rhs: Bool) -> Bool:
        return lhs[False, rhs]


class Block(Statement):
    def __init__(self, terminal: bool = False):
        self.block = []
        self._terminal = terminal

    def terminal(self) -> bool:
        return self._terminal

    def render(self, codes: list[Code]) -> list[Code]:
        on_render = ReLM.on_render
        for s in self.block:
            if on_render:
                ReLM.on_render = type(s)
            s.render(codes)
        ReLM.on_render = on_render
        return codes

    def __getitem__(self, item: Any) -> Block:
        if not isinstance(item, tuple):
            item = (item,)
        for s in item:
            if isinstance(s, Statement):
                self.block.append(s)
                self._terminal |= s.terminal()
        return self

    @classmethod
    def __class_getitem__(cls, item: Any) -> Block:
        return cls()[item]


class If(ErrorStatement):
    def __init__(self, if_: Bool, align: bool = False):
        self.iftrue = if_[True,]
        self.align = align

    def __getitem__(self, then: Any) -> IfThen:
        self.then = Block[then]
        return IfThen(self)


class IfThen(Statement):
    def __init__(self, if_: If):
        self.if_ = if_
        self.Else = self

    def render(self, codes: list[Code]) -> list[Code]:
        self.if_.iftrue.expr.render(codes)
        if self.if_.align and self.if_.then.terminal():
            codes.append(align := Label())
        self.if_.then.render(codes)
        if self.if_.align and self.if_.then.terminal():
            codes.append(Align(align))
        codes.append(Label() << self.if_.iftrue)
        return codes

    def __getitem__(self, else_: Any) -> IfThenElse:
        self.else_ = Block[else_]
        return IfThenElse(self)


class IfThenElse(Statement):
    def __init__(self, ifthen: IfThen):
        self.if_ = ifthen.if_
        self.else_ = ifthen.else_

    def terminal(self) -> bool:
        return self.if_.then.terminal() and self.else_.terminal()

    def render(self, codes: list[Code]) -> list[Code]:
        self.if_.iftrue.expr.render(codes)
        if self.if_.align:
            codes.append(align := Label())
        self.if_.then.render(codes)
        if not self.if_.then.terminal():
            codes.append((endif := Label()) << "JUMP")
        if self.if_.align:
            codes.append(Align(align))
        codes.append(Label() << self.if_.iftrue)
        self.else_.render(codes)
        if not self.if_.then.terminal():
            codes.append(endif)
        return codes


class Loop(ErrorStatement):
    current = None

    def __init__(self):
        self.continue_ = Label()
        self.align = None
        self.break_ = Label()
        self.parent = Loop.current
        Loop.current = self

    def Continue(self) -> Block:
        return Block(True)[self.continue_ << "JUMP"]

    def Break(self, align: bool = False) -> Block:
        b = Block(True)[self.break_ << "JUMP"]
        if align:
            self.align = Label()
            b[self.align]
        return b


def Continue() -> Block:
    return Loop.current.Continue()


def Break(align: bool = False) -> Block:
    return Loop.current.Break(align)


class Do(Loop):
    def __getitem__(self, block: Any) -> DoLoop:
        Loop.current = self.parent
        return DoLoop(self, Block[self.continue_][block])


class While(Loop):
    def __init__(self, while_: Bool):
        super().__init__()
        self.whiletrue = while_[True,]
        self.break_ << self.whiletrue

    def __getitem__(self, block: Any) -> DoLoop:
        Loop.current = self.parent
        b = Block[self.continue_, self.whiletrue.expr]
        if self.align is None:
            self.align = Label()
            b[self.align]
        return DoLoop(self, b[block])


class DoLoop(Statement):
    def __init__(self, loop: Loop, block: Block):
        self.loop = loop
        self.block = block

    def render(self, codes: list[Code]) -> list[Code]:
        if not self.block.terminal():
            self.block[self.loop.Continue()]
        self.block.render(codes)
        if self.loop.align:
            codes.append(Align(self.loop.align))
        codes.append(self.loop.break_)
        return codes

    def terminal(self) -> bool:
        return not self.loop.break_.ref

    def While(self, while_: Bool) -> DoWhile:
        return DoWhile(self.loop, self.block, while_)


class DoWhile(Statement):
    def __init__(self, loop: Loop, block: Block, while_: Bool | bool):
        self.loop = loop
        self.block = block
        self.while_ = while_

    def render(self, codes: list[Code]) -> list[Code]:
        self.block.render(codes)
        if isinstance(self.while_, Bool):
            whilefalse = self.while_[False,]
            whilefalse.expr.render(codes)
            self.loop.continue_ << whilefalse
        else:
            assert not self.while_
        codes.append(self.loop.break_)
        return codes


class Function(ErrorStatement):
    current = None

    def __init__(self, *args: Int):
        self.args = args
        self.entry = Label()
        self.return_ = Label()
        self.align = Label()
        self.body = Block[self.entry, self.return_ << "PUT"]
        self.unsigned = False
        Function.current = self

    def value(self, expr: int | str | BinaryOp) -> Block:
        match expr:
            case int() | str():
                return Block[Code("LOAD", expr)]
            case BinaryOp():
                self.unsigned = expr.unsigned
                return Block[+expr]
            case _:
                raise TypeError(f"{type(expr)} is not supported")

    def Return(self, expr: int | str | BinaryOp) -> IntFunction:
        Function.current = None
        self.body[self.value(expr)]
        return IntFunction(self)

    def __getitem__(self, block: Any) -> VoidFunction:
        assert Function.current is self, "Function is not nestable"
        Function.current = None
        self.body[block]
        return VoidFunction(self)

    def call(self, *args: int | str | BinaryOp) -> Block:
        b = Block()
        for f, c in zip(self.args, args):
            b[f(c)]
        return_ = Label()
        b[return_ << "LOAD", self.entry << "JUMP", Align(self.align), return_]
        return b


def Return(expr: int | ExprB | None = None) -> Block:
    jump = Function.current.return_ << "JUMP"
    if expr is None:
        return Block[jump]
    else:
        return Function.current.value(expr)[jump]


class IntFunction(Statement):
    def __init__(self, func: Function):
        self.func = func

    def render(self, codes: list[Code]) -> list[Code]:
        self.func.body.render(codes)
        codes.append(self.func.return_)
        codes.append(Code("JUMP"))
        codes.append(self.func.align)
        return codes

    def __call__(self, *args: int | str | BinaryOp) -> ExprB:
        codes = self.func.call(*args).render([])
        return ExprB(*codes, unsigned=self.func.unsigned)


class VoidFunction(IntFunction):
    def __call__(self, *args: int | str | BinaryOp) -> Block:
        return self.func.call(*args)

    def Return(self, expr: int | str | BinaryOp) -> IntFunction:
        return self.func.Return(expr)


class Loader:
    blocks = []
    entry = []

    @classmethod
    def __class_getitem__(cls, block: Any) -> ErrorStatement:
        label = Label()
        cls.blocks.append(Block[label][block])
        cls.entry.append(label << "JUMP")
        return ErrorStatement()


class Thread:
    blocks = []
    entry = []

    @classmethod
    def __class_getitem__(cls, block: Any) -> ErrorStatement:
        label = Label()
        block = Block[label][block]
        if not block.terminal():
            block[Code("OPB", "HALT")]
        cls.blocks.append(block)
        cls.entry.append(label << "JUMP")
        return ErrorStatement()


class Define:
    @classmethod
    def __class_getitem__(cls, block: Any) -> ErrorStatement:
        Thread.blocks.append(Block[block])
        return ErrorStatement()


def In(port: int | str, unsigned: bool = False, op: str = "IN") -> Expr:
    return Expr(Code(op, port), unsigned=unsigned)


def IO(
    port: int | str,
    expr: int | str | BinaryOp,
    unsigned: bool = False,
    load: str = "LOAD",
    op: str = "IO",
) -> ExprB:
    t = Expr(unsigned=unsigned)
    match expr:
        case int() | str():
            return t[Code(load, expr), Code(op, port)]
        case BinaryOp():
            return t[+expr, Code(op, port)]
        case _:
            raise TypeError(f"{type(expr)} is not supported")


def Out(
    port: int | str, *expr: int | str | BinaryOp, load: str = "LOAD", op: str = "OUT"
) -> Block:
    init: list[Int] = []
    burst: list[Code] = []
    opb = -1
    for e in expr:
        match e:
            case int() | str():
                burst.append(Code(op, e))
            case Int():
                burst.append(Code(op, e.put()))
            case BinaryOp():
                init.append(Int(e))
                opb = len(burst)
                burst.append(Code(op, init[-1].put()))
            case _:
                raise TypeError(f"{type(e)} is not supported")
    if opb >= 0:
        burst[opb] = Code("OPB", op)
        init[-1].ref[0] = Code("BLOAD", port)
        return Block[(*init, *burst)]
    else:
        return Block[(Code(load, port), *burst)]


class FIFO:
    pool = []

    def __init__(self, port: str, size: int):
        self.port = port
        self.size = size
        self.locked = False
        FIFO.pool.append(self)

    @classmethod
    def Alloc(cls, size: int = 0) -> FIFO:
        candidate = [f.size for f in cls.pool if f.size >= size]
        assert candidate, "FIFO is not available"
        size = min(candidate)
        candidate = [i for i, f in enumerate(cls.pool) if f.size == size]
        return cls.pool.pop(candidate[0])

    def Free(self) -> None:
        FIFO.pool.append(self)

    def Lock(self, load: str = "LOAD") -> Expr:
        assert not self.locked, "FIFO is locked"
        self.locked = True
        return IO(self.port, 0x80000000, load=load, op="POP")

    def IsEmpty(self, load: str = "LOAD") -> Bool:
        assert not self.locked, "FIFO is locked"
        return IO(self.port, 0x0, load=load, op="POP") == 0

    def Pop(self, unsigned: bool = False, load: str = "LOAD") -> Expr:
        if self.locked:
            return In(self.port, unsigned=unsigned, op="POP")
        else:
            return IO(self.port, 0x1, unsigned=unsigned, load=load, op="POP")

    def Push(self, *value: int | str | BinaryOp, load: str = "LOAD") -> Block:
        return Out(self.port, *value, load=load, op="PUSH")


class SRAM:
    def __init__(self, port: str, offset: int, size: int, unsigned: bool = False):
        self.port = port
        self.offset = offset
        self.size = size
        self.unsigned = unsigned

    def Alloc(self, size: int, unsigned: bool = False) -> SRAM:
        assert size <= self.size, "SRAM is not available"
        offset = self.offset
        self.offset += size
        self.size -= size
        return SRAM(self.port, offset, size, unsigned)

    def __getitem__(self, index: int | BinaryOp) -> SRAMOffset | SRAMElement:
        match index:
            case int():
                return SRAMOffset(self, self.offset + index)
            case BinaryOp():
                return SRAMElement(self, index)
            case _:
                raise TypeError(f"{type(index)} is not supported")


class SRAMOffset(Expr):
    def __init__(self, sram: SRAM, offset: int):
        super().__init__(
            *IO(sram.port, offset).codes, *In(sram.port).codes, unsigned=sram.unsigned
        )
        self.sram = sram
        self.offset = offset

    def __call__(self, *value: int | str | BinaryOp) -> Block:
        b = Block()
        vlist = []
        for v in value:
            if isinstance(v, BinaryOp) and not isinstance(v, Int):
                vi = Int(v)
                vlist.append(vi)
                b[vi]
            else:
                vlist.append(v)
        return b[IO(self.sram.port, self.offset), Out(self.sram.port, *vlist)]


class SRAMElement(Expr):
    def __init__(self, sram: SRAM, index: BinaryOp):
        index = index + sram.offset if sram.offset else +index
        super().__init__(
            *IO(sram.port, index).codes, *In(sram.port).codes, unsigned=sram.unsigned
        )
        self.sram = sram
        self.index = index

    def __call__(self, *value: int | str | BinaryOp) -> Block:
        b = Block()
        vlist = []
        for v in value:
            if isinstance(v, BinaryOp) and not isinstance(v, Int):
                vi = Int(v)
                vlist.append(vi)
                b[vi]
            else:
                vlist.append(v)
        return b[IO(self.sram.port, self.index), Out(self.sram.port, *vlist)]


class Table(Statement):
    def __init__(self, size: int):
        self.base = Label()
        self.case = [None] * size

    def render(self, codes: list[Code]) -> list[Code]:
        codes.append(self.base)
        codes.extend(l << "JUMP" for l in self.case)
        return codes

    def Case(self, *index: int) -> Label:
        label = Label()
        for i in index:
            self.case[i] = label
        return label

    def Default(self) -> Label:
        label = Label()
        for i, c in enumerate(self.case):
            if c is None:
                self.case[i] = label
        return label

    def Switch(
        self,
        index: int | BinaryOp,
        acc: int | str | None = None,
        unsigned: bool = False,
    ) -> ExprB:
        if acc is None:
            match index:
                case int():
                    return ExprB(self.case[index] << "JUMP", unsigned=unsigned)
                case BinaryOp():
                    index = +index
                    return ExprB(
                        *index.codes,
                        self.base << "ADD",
                        put := Code("PUT"),
                        Code("JUMP", put),
                        unsigned=unsigned,
                    )
                case _:
                    raise TypeError(f"{type(index)} is not supported")
        else:
            ret = Label()
            match index:
                case int():
                    return ExprB(
                        ret << "LOAD",
                        Code("BLOAD", acc),
                        self.case[index] << "JUMP",
                        ret,
                        unsigned=unsigned,
                    )
                case BinaryOp():
                    index = +index
                    return ExprB(
                        *index.codes,
                        self.base << "ADD",
                        put := Code("PUT"),
                        ret << "LOAD",
                        Code("BLOAD", acc),
                        Code("JUMP", put),
                        ret,
                        unsigned=unsigned,
                    )
                case _:
                    raise TypeError(f"{type(index)} is not supported")

    def Return(self) -> Code:
        return Code("OPB", "JUMP")


class Array(Statement):
    def __init__(
        self, *data: int | str | float, op: str = "PUSH", unsigned: bool = False
    ):
        self.data = data
        self.op = op
        self.unsigned = unsigned
        self.label = []

    def render(self, codes: list[Code]) -> list[Code]:
        codes.extend(self.label)
        for i, d in enumerate(self.data):
            codes.append(Code(self.op, d, debug=(i < 10)))
        return codes

    def offset(self, index: int) -> Label:
        self.label.append(l := Label(index))
        return l

    def __getitem__(self, index: int | BinaryOp) -> ArrayOffset | ArrayElement:
        if not isinstance(index, tuple):
            index = (index,)
        offset, expr = 0, None
        for i in index:
            if isinstance(i, int):
                offset += i
            elif expr is None:
                expr = i
            else:
                expr += i
        if expr is None:
            return self.OffsetExpr(offset)
        else:
            return self.ElementExpr(expr, offset)

    def OffsetExpr(self, offset: int) -> ArrayOffset:
        return ArrayOffset(self, offset)

    def ElementExpr(self, index: BinaryOp, offset: int) -> ArrayElement:
        return ArrayElement(self, index, offset)


class ArrayOffset(Expr):
    def __init__(self, array: Array, offset: int):
        super().__init__(
            (ret := Label()) << "LOAD",
            array.offset(offset | 0x80000000) << "JUMP",
            Align(array.offset(offset + 1)),
            ret,
            unsigned=array.unsigned,
        )
        self.array = array
        self.offset = offset

    def __call__(self, value: int | str | BinaryOp) -> ExprB:
        offset = self.array.offset(self.offset)
        match value:
            case int() | str():
                return self[offset << "LOAD", "BLOAD":value, "OPB":"PUT"]
            case Int():
                return self[offset << "LOAD", "BLOAD" : value.put(), "OPB":"PUT"]
            case BinaryOp():
                value = +value
                if isinstance(value, Expr):
                    return self[offset << "LOAD", value.bload(), "OPB":"PUT"]
                else:
                    return self[value, offset << "BLOAD", "OPB":"BLOAD", "OPB":"PUT"]
            case _:
                raise TypeError(f"{type(value)} is not supported")


class ArrayElement(ExprB):
    def __init__(self, array: Array, index: BinaryOp, offset: int):
        self.index = +index
        super().__init__(
            *self.index.codes,
            array.offset(offset | 0x80000000) << "ADD",
            (ret := Label()) << "BLOAD",
            Code("OPB", "JUMP"),
            Align(array.offset(len(array.data))),
            ret,
            unsigned=array.unsigned,
        )
        self.array = array
        self.offset = offset

    def __call__(self, value: int | str | BinaryOp) -> ExprB:
        offset = self.array.offset(self.offset) << "ADD"
        match value:
            case int() | str():
                return self[self.index, offset, "BLOAD":value, "OPB":"PUT"]
            case Int():
                return self[self.index, offset, "BLOAD" : value.put(), "OPB":"PUT"]
            case BinaryOp():
                value = +value
                if isinstance(value, Expr):
                    return self[self.index, offset, value.bload(), "OPB":"PUT"]
                elif isinstance(self.index, Expr):
                    return self[
                        value,
                        self.index.bload(),
                        offset,
                        "OPB":"BLOAD",
                        "OPB":"PUT",
                    ]
                else:
                    return self[
                        self.index,
                        offset,
                        put := Code("PUT"),
                        value,
                        "PUT":put,
                    ]
            case _:
                raise TypeError(f"{type(value)} is not supported")


def Wait(align: int, loop: int = 0) -> Block:
    assert align >= 0 and loop >= 0, "align and loop must be positive"
    src = Label(align)
    b = Block[src]
    dest = Label()
    if loop == 0:
        if align:
            b[dest << "JUMP", Align(src), dest]
        return b
    if align < 2:
        loop -= 1
        if loop == 0:
            if align:
                b[Wait(1)]
            return b[dest << "JUMP", Align(src), dest]
    wait = Label()
    return b[Acc(loop), wait, dest << "JEQ", Acc - 1, wait << "JUMP", Align(src), dest]


class Atomic(Statement):
    def __init__(self, init: int = 0, unsigned: bool = False):
        self.init = init
        self.unsigned = unsigned
        self.entry = Label()
        self.align = Label()

    def render(self, codes: list[Code]) -> list[Code]:
        swap = Label()
        return Acc[
            self.entry,
            swap << "PUT",
            swap,
            "SWAP" : self.init,
            "OPB":"JUMP",
            self.align,
        ].render(codes)

    def __call__(self, value: int | str | BinaryOp) -> ExprB:
        acc = AccU if self.unsigned else Acc
        ret = Label()
        match value:
            case int() | str():
                return acc[
                    ret << "LOAD",
                    "BLOAD":value,
                    self.entry << "JUMP",
                    Align(self.align),
                    ret,
                ]
            case Int():
                return acc[
                    ret << "LOAD",
                    "BLOAD" : value.put(),
                    self.entry << "JUMP",
                    Align(self.align),
                    ret,
                ]
            case AccExpr():
                return acc[
                    ret << "BLOAD",
                    "OPB":"BLOAD",
                    self.entry << "JUMP",
                    Align(self.align),
                    ret,
                ]
            case BinaryOp():
                value = +value
                if isinstance(value, Expr):
                    return acc[
                        ret << "LOAD",
                        value.bload(),
                        self.entry << "JUMP",
                        Align(self.align),
                        ret,
                    ]
                else:
                    return acc[
                        value,
                        ret << "BLOAD",
                        "OPB":"BLOAD",
                        self.entry << "JUMP",
                        Align(self.align),
                        ret,
                    ]
            case _:
                raise TypeError(f"{type(value)} is not supported")


class Mutex(Atomic):
    def __init__(self, init: int = 1):
        super().__init__(init)

    def Acquire(self) -> Block:
        return Block[Do()[...].While(self(0) == 0),]

    def Release(self) -> Block:
        return Block[self(1),]

    def __getitem__(self, block: Any) -> Block:
        return self.Acquire()[block][self.Release()]


class Semaphore(Mutex):
    def __init__(self, init: int = 0):
        super().__init__(init + 1)

    def Acquire(self, count: int = 1) -> Block:
        if count == 1:
            return Block[
                Do()[
                    Do()[...].While(self(0) == 0),
                    If(Acc - 1 == 0)[self(1), Continue()],
                    self(Acc),
                ].While(False),
            ]
        else:
            return Block[
                rest := Int(-count),
                Do()[
                    Do()[...].While(self(0) == 0),
                    If(rest(Acc - 1 + rest) < 0)[self(1), Continue()],
                    self(rest + 1),
                ].While(False),
            ]

    def Release(self, count: int = 1) -> Block:
        return Block[
            Do()[...].While(self(0) == 0),
            Acc + count,
            self(Acc),
        ]


class Mnemonic(type):
    class OpDict(dict):
        def __getitem__(self, key: Any) -> Any:
            if isinstance(key, float):
                return ctypes.c_uint.from_buffer(ctypes.c_float(key)).value
            v = super().get(key, key)
            assert isinstance(v, int), f"{v} is not supported"
            return v

    mnemonic = OpDict()

    def __setitem__(cls, key, value) -> None:
        match key:
            case str():
                assert isinstance(value, int), "value must be integer"
                cls.mnemonic[key] = value
            case int():
                if isinstance(value, str):
                    cls.mnemonic[value] = key
                else:
                    for v in value:
                        cls[key] = v
            case slice():
                start = 0 if key.start is None else key.start
                step = 1 if key.step is None else key.step
                for i, v in zip(itertools.count(start, step), value):
                    cls[i] = v
            case _:
                raise TypeError(f"{type(key)} is not supported")


class ReLM(metaclass=Mnemonic):
    mnemonic = Mnemonic.mnemonic
    on_render = None
    ncpu = 0

    def __init__(self, ncpu: int, loader: bool = True):
        assert ncpu & (ncpu - 1) == 0, "ncpu must be power of 2"
        ReLM.ncpu = ncpu
        self.memory: list[Code] = [Code("JUMP", i) for i in range(ncpu)]
        self.nthread = 0
        if loader:
            self.deploy(Loader)

    def deploy(self, thread: type = Thread) -> None:
        nthread = len(thread.entry)
        assert self.nthread + nthread <= ReLM.ncpu, "too many threads"
        if thread == Thread:
            self.memory[self.nthread : self.nthread + nthread] = thread.entry
            self.nthread += nthread
        else:
            self.memory[ReLM.ncpu - nthread : ReLM.ncpu] = thread.entry
        thread.entry.clear()
        pending: list[list[Code]] = []
        aligned: tuple[list[list[Code]]] = tuple([] for _ in range(ReLM.ncpu))
        unaligned: list[list[Code]] = []
        ReLM.on_render = Block
        for b in thread.blocks:
            codes = b.render([])
            split = [i for i, c in enumerate(codes) if isinstance(c, Align)]
            if split:
                if split[0]:
                    unaligned.append(codes[: split[0]])
                pending.extend(codes[i:j] for i, j in zip(split[:-1], split[1:]))
                pending.append(codes[split[-1] :])
            else:
                unaligned.append(codes)
        thread.blocks.clear()
        while True:
            p = []
            for codes in pending:
                align = codes[0].operand
                if isinstance(align, int):
                    aligned[align & (ReLM.ncpu - 1)].append(codes)
                else:
                    p.append(codes)
            pending = p
            while True:
                align = len(self.memory) & (ReLM.ncpu - 1)
                if aligned[align]:
                    codes = aligned[align].pop(0)
                    break
                elif unaligned:
                    codes = unaligned.pop(0)
                    break
                elif any(aligned):
                    self.memory.append(Code("OPB", "HALT"))
                else:
                    ReLM.on_render = None
                    assert not pending, "unresolved alignment"
                    return
            while codes and codes[0].deploy(self.memory, ReLM.ncpu):
                del codes[0]
            if codes:
                pending.append(codes)

    def print(self, file=None) -> ReLM:
        def tab(s: str, w: int = 8) -> str:
            return s + " " * (w - len(s))

        omit = False
        for i, c in enumerate(self.memory):
            if isinstance(c.debug, str):
                omit = False
                if isinstance(c.operand, int):
                    operand = c.operand & 0xFFFFFFFF
                    operand = (
                        f"{operand:04X}:"
                        if c.op in {"PUT", "PUTS", "PUTM", "JEQ", "JNE", "JUMP"}
                        else f"{operand:08X}"
                    )
                    operand = tab(operand, 24)
                elif isinstance(c.operand, float):
                    operand = tab(f"{c.operand:+E}", 24)
                else:
                    operand = tab(c.operand, 24)
                print(tab(f"{i:04X}:") + tab(c.op) + operand + c.debug, file=file)
            elif not omit:
                omit = True
                print("...", file=file)
        return self

    def save(self, *path: str, code="code{:02d}.txt", data="data{:02d}.txt") -> ReLM:
        path = Path(*path).resolve()
        if path.is_file():
            path = path.parent
        path.mkdir(exist_ok=True)
        for i in range(ReLM.ncpu):
            pcode = path.joinpath(code.format(i))
            print(pcode)
            with open(pcode, "w") as fcode:
                pdata = path.joinpath(data.format(i))
                print(pdata)
                with open(pdata, "w") as fdata:
                    for c in self.memory[i :: ReLM.ncpu]:
                        op = self.mnemonic[c.op]
                        print(f"{op:b}", file=fcode)
                        operand = self.mnemonic[c.operand]
                        print(f"{operand & 0xFFFFFFFF:X}", file=fdata)
        return self


ReLM[:] = (
    "LOAD",
    ("SWAP", "SHIFT"),
    "BLOAD",
    "BSLOAD",
    "ADD",
    "AND",
    "XOR",
    "OR",
    ("OUT", "PUSH"),
    ("IO", "IN", "POP"),
    "PUT",
    ("PUTS", "PUTM"),
    "RSUB",
    "JEQ",
    "JNE",
    "JUMP",
    "UGT",
    "ULT",
    "IGT",
    "ILT",
    "SUB",
    "MUL",
    "SHR",
    "SAR",
)
ReLM[0x1F] = "OPB", "HALT"
ReLM[0x22:] = "BLOADX", "BSLOADX"
