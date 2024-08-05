from __future__ import annotations
import ctypes
import math
from relm import *

BinaryOp.useB |= {
    "FADD",
    "FRSUB",
    "FSUB",
    "FADDM",
    "FMUL",
    "FMULM",
    "ROUND",
    "FTOI",
    "ISIGN",
    "ITOF",
    "ITOFB",
    "ITOFG",
    "ITOFGB",
    "ITOFS",
    "ITOFSB",
    "ITOFSG",
    "ITOFSGB",
    "FDIV",
}


class FloatExprB(ExprB):
    add = (("FADD", "FSUB"), ("FRSUB", "FADDM"))
    mul = ("FMUL", "FMULM")

    def __init__(self, *codes: Code | list[Code], minus: bool = False):
        super().__init__(*codes)
        self.minus = minus
        if not isinstance(self, AccFloatExprB):
            self.AccF = AccFM if minus else AccF
            self.RegBF = RegBFM if minus else RegBF

    def itofb(self) -> FloatExprB:
        match (self.codes[-1].operand):
            case "ITOF":
                self.codes[-1].operand = "ITOFB"
            case "ITOFG":
                self.codes[-1].operand = "ITOFGB"
            case "ITOFS":
                self.codes[-1].operand = "ITOFSB"
            case "ITOFSG":
                self.codes[-1].operand = "ITOFSGB"
            case _:
                raise ValueError(f"Invalid operand: {self.codes[-1].operand}")
        return self

    def itofg(self) -> FloatExprB:
        match (self.codes[-1].operand):
            case "ITOF":
                self.codes[-1].operand = "ITOFG"
            case "ITOFB":
                self.codes[-1].operand = "ITOFGB"
            case "ITOFS":
                self.codes[-1].operand = "ITOFSG"
            case "ITOFSB":
                self.codes[-1].operand = "ITOFSGB"
            case _:
                raise ValueError(f"Invalid operand: {self.codes[-1].operand}")
        return self

    def itofs(self) -> FloatExprB:
        match (self.codes[-1].operand):
            case "ITOF":
                self.codes[-1].operand = "ITOFS"
            case "ITOFB":
                self.codes[-1].operand = "ITOFSB"
            case "ITOFG":
                self.codes[-1].operand = "ITOFSG"
            case "ITOFGB":
                self.codes[-1].operand = "ITOFSGB"
            case _:
                raise ValueError(f"Invalid operand: {self.codes[-1].operand}")
        return self

    def __getitem__(self, items: Any) -> FloatExprB:
        codes = []
        self.getitem(items, codes)
        return FloatExprB(*codes, minus=self.minus)

    def __neg__(self) -> FloatExprB:
        return FloatExprB(*self.codes, minus=not self.minus)

    def __pos__(self) -> FloatExprB:
        return AccF[self ^ 0x80000000] if self.minus else self

    def fadd(
        lhs: FloatExprB, rhs: float | BinaryOp | list, sub: bool = False
    ) -> FloatExprB:
        itof = Acc.opb("ITOF")
        match rhs:
            case float():
                r = -rhs if lhs.minus ^ sub else rhs
                return lhs[lhs, "FADD":r, itof]
            case Float():
                return lhs[lhs, "FADD" : rhs.put(lhs.minus ^ sub), itof]
            case FloatExprB():
                if sub:
                    rhs = -rhs
                if lhs.minus and rhs.minus:
                    return lhs[l := Float(lhs), rhs, "FADD" : l.put(True), itof]
                elif rhs.minus:
                    return AccF[r := Float(rhs), lhs, "FADD" : r.put(), itof]
                else:
                    return AccF[l := Float(lhs), rhs, "FADD" : l.put(), itof]
            case list():
                return lhs.fadd(rhs[-1], sub)
            case FloatRegBType():
                if rhs.regD:
                    lhs.itofg()
                op = lhs.add[lhs.minus][rhs.minus ^ sub]
                return AccF[lhs, "OPB":op, itof]
            case _:
                return NotImplemented

    def __add__(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fadd(rhs)

    def __radd__(rhs: FloatExprB, lhs: float | BinaryOp) -> FloatExprB:
        return rhs.fadd(lhs)

    def __sub__(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fadd(rhs, True)

    def __rsub__(rhs: FloatExprB, lhs: float | BinaryOp) -> FloatExprB:
        return (-rhs).fadd(lhs)

    def fmul(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        itof = Acc.opb("ITOF")
        match rhs:
            case float():
                r = -rhs if lhs.minus else rhs
                return AccF[lhs, "FMUL":r, itof]
            case Float():
                return AccF[lhs, "FMUL" : rhs.put(lhs.minus), itof]
            case FloatExprB():
                return AccF[l := Float(lhs), rhs, "FMUL" : l.put(rhs.minus), itof]
            case list():
                return lhs.fmul(rhs[-1])
            case FloatRegBType():
                if rhs.regD:
                    lhs.itofg()
                op = lhs.mul[lhs.minus ^ rhs.minus]
                return AccF[lhs, "OPB":op, itof]
            case _:
                return NotImplemented

    def __mul__(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fmul(rhs)

    def __rmul__(rhs: FloatExprB, lhs: float | BinaryOp) -> FloatExprB:
        return rhs.fmul(lhs)

    @staticmethod
    def fdiv(minus: bool = False) -> FloatExprB:
        return AccF[
            y := Float(AccFM if minus else AccF),
            Acc.opb("FDIVINIT"),
            D := Float(AccF),
            Acc << 8,
            (
                (
                    2.0
                    - RegBF(
                        AccF[
                            Acc.opb("DIVLOOP")
                            .opb("DIVLOOP")
                            .opb("DIVLOOP")
                            .opb("DIVLOOP")
                            .opb("DIVLOOP")
                            .opb("FDIVLOOP")
                            .opb("ITOF")
                        ],
                        x := [],
                    )
                    * D
                )
                * x
            )
            * y,
        ]

    def __truediv__(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        match rhs:
            case float():
                return lhs.fmul(1.0 / rhs)
            case Float():
                return AccF[lhs, "BLOAD" : rhs.put(lhs.minus), "OPB":"FDIV", lhs.fdiv()]
            case FloatExprB():
                return AccF[l := Float(lhs), rhs, "FDIV" : l.put(rhs.minus), lhs.fdiv()]
            case FloatRegBType():
                return AccF[lhs.swapAB(), "OPB":"FDIV", lhs.fdiv(lhs.minus ^ rhs.minus)]
            case _:
                return NotImplemented

    def __rtruediv__(rhs: FloatExprB, lhs: float | BinaryOp) -> FloatExprB:
        match lhs:
            case float():
                l = -lhs if rhs.minus else lhs
                return AccF[rhs, "FDIV":l, rhs.fdiv()]
            case Float():
                return AccF[rhs, "FDIV" : lhs.put(rhs.minus), rhs.fdiv()]
            case FloatExprB():
                return AccF[l := Float(lhs), rhs, "FDIV" : l.put(rhs.minus), rhs.fdiv()]
            case FloatRegBType():
                return AccF[rhs, "OPB":"FDIV", rhs.fdiv(lhs.minus ^ rhs.minus)]
            case _:
                return NotImplemented

    def __abs__(self) -> FloatExprB:
        return AccF[self & 0x7FFFFFFF]

    def __trunc__(self) -> FloatExprB:
        return self[self.opb("TRUNC")]

    def round(self, offset: float) -> FloatExprB:
        op = self.add[self.minus][self.minus]
        return AccF[
            self,
            "ROUND":offset,
            (
                Acc.opb(op).opb("ITOF").opb("TRUNC")
                if offset == 0.5
                else Acc.opb("TRUNC").opb(op).opb("ITOF")
            ),
        ]

    def __round__(self) -> FloatExprB:
        return self.round(0.5)

    def __ceil__(self) -> FloatExprB:
        return self.round(-1.0 if self.minus else 1.0)

    def __floor__(self) -> FloatExprB:
        return self.round(1.0 if self.minus else -1.0)

    def __pow__(lhs: FloatExprB, rhs: int) -> FloatExprB:
        match rhs:
            case int():
                if rhs == 0:
                    return AccF(1.0)
                elif rhs == 1:
                    return lhs
                elif rhs == 2:
                    return AccF[lhs.opb("BLOADX").opb("FMUL").opb("ITOF")]
                elif rhs < 0:
                    return 1.0 / (lhs**-rhs)
                elif rhs & 1:
                    l = Float()
                    return l(lhs) ** (rhs - 1) * l
                else:
                    return (lhs ** (rhs >> 1)) ** 2
            case _:
                return NotImplemented

    def fcomp(lhs: FloatExprB, rhs: float | BinaryOp, cond: int, eq: bool) -> Bool:
        match rhs:
            case float():
                r = -rhs if lhs.minus else rhs
                sign = Acc[lhs, "FCOMP":r]
            case Float():
                sign = Acc[lhs, "FCOMP" : rhs.put(lhs.minus)]
            case FloatExprB():
                sign = Acc[r := Float(rhs), lhs, "FCOMP" : r.put(lhs.minus)]
            case FloatRegBType():
                if rhs.minus:
                    return (-lhs).fcomp(RegBF, cond, eq)
                elif lhs.minus:
                    return (+lhs).fcomp(RegBF, cond, eq)
                sign = Acc[lhs, "OPB":"FCOMP"]
            case _:
                return NotImplemented
        c = -cond if lhs.minus else cond
        return (sign == c) if eq else (sign != c)

    def __lt__(lhs: FloatExprB, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, -1, True)

    def __ge__(lhs: FloatExprB, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, -1, False)

    def __gt__(lhs: FloatExprB, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 1, True)

    def __le__(lhs: FloatExprB, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 1, False)

    def __ne__(lhs: FloatExprB, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 0, False)

    def __eq__(lhs: FloatExprB, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 0, True)


class FloatRegBType(BinaryOp):
    def __init__(self, minus: bool = False, regD: bool = False):
        super().__init__()
        self.minus = minus
        self.regD = regD

    def __pos__(self) -> FloatExprB:
        acc = AccFM if self.minus else AccF
        return acc["OPB":"LOAD"]

    def __neg__(self) -> FloatExprB:
        acc = AccF if self.minus else AccFM
        return acc["OPB":"LOAD"]

    def __call__(
        self, value: FloatExprB, reg: list[FloatRegBType] | None = None
    ) -> FloatExprB:
        if reg is not None:
            reg.append(FloatRegBType(value.minus, self.regD))
        return value.itofs() if self.regD else value.itofb()


RegBF = FloatRegBType()
RegBFM = FloatRegBType(True)
RegDF = FloatRegBType(regD=True)


class AccFloatExprB(FloatExprB):
    def __init__(self, minus: bool = False):
        super().__init__(minus=minus)

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        match value:
            case float():
                return self["LOAD":value]
            case Float():
                return +self
            case FloatExprB():
                return value
            case _:
                raise TypeError(f"{type(value)} is not supported")


AccF = AccFloatExprB()
AccFM = AccFloatExprB(True)


class Float(Int):
    def __init__(self, value: float | BinaryOp | None = None):
        super().__init__()
        self.refm = []
        self.minus = False
        match value:
            case float():
                self.expr = AccF[AccF(value)]
            case Float() | FloatRegBType():
                self.expr = AccF[+value]
            case FloatExprB():
                self.minus = value.minus
                self.expr = value[value]
            case None:
                self.expr = None
            case _:
                raise TypeError(f"{type(value)} is not supported")
        self.AccF = AccFM if self.minus else AccF
        self.RegBF = RegBFM if self.minus else RegBF

    def put(self, minus: bool = False) -> tuple[Code]:
        c = Code("PUT", debug="->      ")
        cm = Code("PUTM", debug="->      ")
        if minus:
            self.ref.append(cm)
            self.refm.append(c)
        else:
            self.ref.append(c)
            self.refm.append(cm)
        return (c, cm)

    def load(self, minus: bool = False) -> FloatExprB:
        return AccF["LOAD" : self.put(minus)]

    def __pos__(self) -> FloatExprB:
        return self.load()

    def __neg__(self) -> FloatExprB:
        return self.load(True)

    def render(self, codes: list[Code]) -> list[Code]:
        if self.expr is not None:
            self.expr.render(codes)
            codes.extend(self.refm if self.minus else self.ref)
            self.expr = None
        return codes

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        expr = Float(value).expr
        return expr[expr, self.refm if self.minus else self.ref]

    def fadd(
        lhs: Float, rhs: float | BinaryOp, sub: bool = False, rsub: bool = False
    ) -> FloatExprB:
        itof = Acc.opb("ITOF")
        match rhs:
            case float():
                r = -rhs if sub else rhs
                return AccF[lhs.load(rsub), "FADD":r, itof]
            case Float():
                return AccF[lhs.load(rsub), "FADD" : rhs.put(sub), itof]
            case FloatExprB():
                if sub:
                    rhs = -rhs
                return rhs[rhs, "FADD" : lhs.put(rhs.minus ^ rsub), itof]
            case FloatRegBType():
                op = AccF.add[rsub][rhs.minus ^ sub]
                return AccF[lhs.load(), "OPB":op, itof]
            case _:
                return NotImplemented

    def __add__(lhs: Float, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fadd(rhs)

    def __radd__(rhs: Float, lhs: float | BinaryOp) -> FloatExprB:
        return rhs.fadd(lhs)

    def __sub__(lhs: Float, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fadd(rhs, True)

    def __rsub__(rhs: Float, lhs: float | BinaryOp) -> FloatExprB:
        return rhs.fadd(lhs, rsub=True)

    def fmul(lhs: Float, rhs: float | BinaryOp) -> FloatExprB:
        itof = Acc.opb("ITOF")
        match rhs:
            case float():
                return AccF[+lhs, "FMUL":rhs, itof]
            case Float():
                return AccF[+lhs, "FMUL" : rhs.put(), itof]
            case FloatExprB():
                return AccF[l := Float(lhs), rhs, "FMUL" : l.put(rhs.minus), itof]
            case FloatRegBType():
                op = AccF.mul[rhs.minus]
                return AccF[+lhs, "OPB":op, itof]
            case _:
                return NotImplemented

    def __mul__(lhs: Float, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fmul(rhs)

    def __rmul__(rhs: Float, lhs: float | BinaryOp) -> FloatExprB:
        return rhs.fmul(lhs)

    def __truediv__(lhs: Float, rhs: float | BinaryOp) -> FloatExprB:
        match rhs:
            case float():
                return lhs.fmul(1.0 / rhs)
            case Float():
                return AccF[+rhs, "FDIV" : lhs.put(), AccF.fdiv()]
            case FloatExprB():
                return AccF[rhs, "FDIV" : lhs.put(rhs.minus), AccF.fdiv()]
            case FloatRegBType():
                return AccF["OPB":"LOAD", "FDIV" : lhs.put(rhs.minus), AccF.fdiv()]
            case _:
                return NotImplemented

    def __rtruediv__(rhs: Float, lhs: float | BinaryOp) -> FloatExprB:
        match lhs:
            case float():
                return AccF[+rhs, "FDIV":lhs, AccF.fdiv()]
            case Float():
                return AccF[+rhs, "FDIV" : lhs.put(), AccF.fdiv()]
            case FloatExprB():
                return AccF[
                    lhs, "BLOAD" : rhs.put(lhs.minus), "OPB":"FDIV", AccF.fdiv()
                ]
            case FloatRegBType():
                return AccF[rhs.load(lhs.minus), "OPB":"FDIV", rhs.fdiv()]
            case _:
                return NotImplemented

    def __abs__(self) -> FloatExprB:
        return abs(+self)

    def __trunc__(self) -> FloatExprB:
        return math.trunc(+self)

    def __round__(self) -> FloatExprB:
        return round(+self)

    def __ceil__(self) -> FloatExprB:
        return math.ceil(+self)

    def __floor__(self) -> FloatExprB:
        return math.floor(+self)

    def __pow__(lhs: Float, rhs: int) -> FloatExprB:
        return (+lhs) ** rhs

    def fcomp(lhs: Float, rhs: float | BinaryOp, cond: int, eq: bool) -> Bool:
        match rhs:
            case float():
                sign = Acc[+lhs, "FCOMP":rhs]
            case Float():
                sign = Acc[+lhs, "FCOMP" : rhs.put()]
            case FloatExprB():
                cond = cond if rhs.minus else -cond
                sign = Acc[rhs, "FCOMP" : lhs.put(rhs.minus)]
            case FloatRegBType():
                if rhs.minus:
                    return (-lhs).fcomp(RegBF, -cond, eq)
                sign = Acc[+lhs, "OPB":"FCOMP"]
            case _:
                return NotImplemented
        return (sign == cond) if eq else (sign != cond)

    def __lt__(lhs: Float, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, -1, True)

    def __ge__(lhs: Float, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, -1, False)

    def __gt__(lhs: Float, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 1, True)

    def __le__(lhs: Float, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 1, False)

    def __ne__(lhs: Float, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 0, False)

    def __eq__(lhs: Float, rhs: float | BinaryOp) -> Bool:
        return lhs.fcomp(rhs, 0, True)


def ToInt(value: FloatExprB | Float) -> ExprB:
    match value:
        case FloatExprB() | Float():
            return (+value).opb("FTOI").opb("SAR")
        case _:
            raise TypeError(f"{type(value)} is not supported")


def ToFloat(value: BinaryOp, unsigned: bool = False) -> FloatExprB:
    v = +value
    if unsigned or v.unsigned:
        return AccF[v, "ITOF":0x4E800000]
    else:
        return AccF[v, AccF.opb("ISIGN").opb("ITOF")]


class FunctionF(Function):
    def __init__(self, *args: Int):
        super().__init__(*args)
        self.minus = None

    def value(self, expr: float | BinaryOp) -> Block:
        match expr:
            case float():
                self.minus = bool(self.minus)
                v = -expr if self.minus else expr
                return Block[Code("LOAD", v)]
            case Float():
                self.minus = bool(self.minus)
                return Block[expr.load(self.minus)]
            case FloatExprB():
                if self.minus is None:
                    self.minus = expr.minus
                return (
                    Block[expr ^ 0x80000000]
                    if self.minus != expr.minus
                    else Block[expr]
                )
            case _:
                raise TypeError(f"{type(expr)} is not supported")

    def Return(self, expr: float | BinaryOp) -> FloatFunction:
        Function.current = None
        self.body[self.value(expr)]
        return FloatFunction(self)


class FloatFunction(IntFunction):
    def __call__(self, *args: int | str | BinaryOp) -> FloatExprB:
        codes = self.func.call(*args).render([])
        return FloatExprB(*codes, minus=bool(self.func.minus))


class ArrayF(Array):
    def OffsetExpr(self, offset: int) -> ArrayOffsetF:
        return ArrayOffsetF(self, offset)

    def ElementExpr(self, index: BinaryOp, offset: int) -> ArrayElementF:
        return ArrayElementF(self, index, offset)


class ArrayOffsetF(FloatExprB):
    def __init__(self, array: ArrayF, offset: int):
        super().__init__(
            (ret := Label()) << "LOAD",
            array.offset(offset | 0x80000000) << "JUMP",
            Align(array.offset(offset + 1)),
            ret,
        )
        self.array = array
        self.offset = offset

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        offset = self.array.offset(self.offset)
        match value:
            case float():
                return AccF[offset << "LOAD", "BLOAD":value, "OPB":"PUT"]
            case Float():
                return AccF[offset << "LOAD", "BLOAD" : value.put(), "OPB":"PUT"]
            case FloatExprB():
                return value[
                    value,
                    offset << "BLOAD",
                    "OPB":"BLOAD",
                    "OPB" : "PUTM" if value.minus else "PUT",
                ]
            case _:
                raise TypeError(f"{type(value)} is not supported")


class ArrayElementF(FloatExprB):
    def __init__(self, array: ArrayF, index: BinaryOp, offset: int):
        self.index = +index
        super().__init__(
            *self.index.codes,
            array.offset(offset | 0x80000000) << "ADD",
            (ret := Label()) << "BLOAD",
            Code("OPB", "JUMP"),
            Align(array.offset(len(array.data))),
            ret,
        )
        self.array = array
        self.offset = offset

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        offset = self.array.offset(self.offset) << "ADD"
        match value:
            case float():
                return AccF[self.index, offset, "BLOAD":value, "OPB":"PUT"]
            case Float():
                return AccF[self.index, offset, "BLOAD" : value.put(), "OPB":"PUT"]
            case FloatExprB():
                if isinstance(self.index, Expr):
                    return value[
                        value,
                        self.index.bload(),
                        offset,
                        "OPB":"BLOAD",
                        "OPB" : "PUTM" if value.minus else "PUT",
                    ]
                else:
                    if value.minus:
                        offset = self.array.offset(self.offset | 0x80000000) << "ADD"
                    return value[
                        self.index,
                        offset,
                        put := Code("PUT"),
                        value,
                        "PUTM" if value.minus else "PUT" : put,
                    ]
            case _:
                raise TypeError(f"{type(value)} is not supported")
