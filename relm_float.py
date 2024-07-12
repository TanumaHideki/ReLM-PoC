from __future__ import annotations
import ctypes
import math
from relm import *

BinaryOp.useB |= {"ITOF", "ITOFX", "FMUL", "FSQU", "FADD", "ROUND"}


class FloatExprB(ExprB):
    def __init__(self, *codes: Code | list[Code], minus: bool = False, sign: int = 0):
        super().__init__(*codes)
        self.minus = minus
        self.sign = sign

    def _sign(self, sign: int) -> FloatExprB:
        self.sign = sign
        return self

    def __getitem__(self, items: Any) -> FloatExprB:
        codes = []
        self.getitem(items, codes)
        return FloatExprB(*codes, minus=self.minus)

    def __neg__(self) -> FloatExprB:
        return FloatExprB(*self.codes, minus=not self.minus, sign=-self.sign)

    def __pos__(self) -> FloatExprB:
        return AccF[self ^ 0x80000000]._sign(self.sign) if self.minus else self

    def fadd(lhs: FloatExprB, rhs: float | BinaryOp, sub: bool = False) -> FloatExprB:
        a = Acc.opb("ITOF").opb("ITOFX")
        af = Acc.opb("ITOFX")
        match rhs:
            case float():
                if sub:
                    rhs = -rhs
                s = lhs.sign if lhs.sign * rhs >= 0 else 0
                r = ctypes.c_uint.from_buffer(
                    ctypes.c_float(-rhs if lhs.minus else rhs)
                ).value
                return lhs[lhs, "FADD":r, af if s else a]._sign(s)
            case Float():
                r = -rhs.sign if sub else rhs.sign
                s = lhs.sign if lhs.sign == r else 0
                return lhs[
                    lhs, "FADD" : rhs.put(lhs.minus ^ sub), af if s else a
                ]._sign(s)
            case FloatExprB():
                if sub:
                    rhs = -rhs
                s = lhs.sign if lhs.sign == rhs.sign else 0
                if lhs.minus and rhs.minus:
                    return lhs[
                        l := Float(lhs), rhs, "FADD" : l.put(True), af if s else a
                    ]._sign(s)
                elif rhs.minus:
                    return AccF[
                        r := Float(rhs), lhs, "FADD" : r.put(), af if s else a
                    ]._sign(s)
                else:
                    return AccF[
                        l := Float(lhs), rhs, "FADD" : l.put(), af if s else a
                    ]._sign(s)
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
        m = Acc.opb("ITOFX")
        match rhs:
            case float():
                r = ctypes.c_uint.from_buffer(
                    ctypes.c_float(-rhs if lhs.minus else rhs)
                ).value
                return AccF[lhs, "FMUL":r, m]._sign(lhs.sign if rhs >= 0 else -lhs.sign)
            case Float():
                return AccF[lhs, "FMUL" : rhs.put(lhs.minus), m]._sign(
                    lhs.sign * rhs.sign
                )
            case FloatExprB():
                return AccF[l := Float(lhs), rhs, "FMUL" : l.put(rhs.minus), m]._sign(
                    lhs.sign * rhs.sign
                )
            case _:
                return NotImplemented

    def __mul__(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        return lhs.fmul(rhs)

    def __rmul__(rhs: FloatExprB, lhs: float | BinaryOp) -> FloatExprB:
        return rhs.fmul(lhs)

    @staticmethod
    def fdiv() -> FloatExprB:
        return AccF[
            D := Float(AccF, 1),
            x := Float(((AccF - 1.5) ** 2 + 2.0) * (D - 3.0) * (-128.0 / 577.0), 1),
            e := Float(AccF * D - 1.0),
            ex := Float(AccF * x),
            AccF * e - ex + x,
            Acc.opb("FMUL").opb("ITOFX"),
        ]

    def __truediv__(lhs: FloatExprB, rhs: float | BinaryOp) -> FloatExprB:
        match rhs:
            case float():
                return lhs.fmul(1.0 / rhs)
            case Float():
                return AccF[
                    lhs, "BLOAD" : rhs.put(lhs.minus), "OPB":"FDIV", lhs.fdiv()
                ]._sign(lhs.sign * rhs.sign)
            case FloatExprB():
                return AccF[
                    l := Float(lhs), rhs, "FDIV" : l.put(rhs.minus), lhs.fdiv()
                ]._sign(lhs.sign * rhs.sign)
            case _:
                return NotImplemented

    def __rtruediv__(rhs: FloatExprB, lhs: float | BinaryOp) -> FloatExprB:
        match lhs:
            case float():
                l = ctypes.c_uint.from_buffer(
                    ctypes.c_float(-lhs if rhs.minus else lhs)
                ).value
                return AccF[rhs, "FDIV":l, rhs.fdiv()]._sign(
                    rhs.sign if lhs >= 0 else -rhs.sign
                )
            case Float():
                return AccF[rhs, "FDIV" : lhs.put(rhs.minus), rhs.fdiv()]._sign(
                    lhs.sign * rhs.sign
                )
            case FloatExprB():
                return AccF[
                    l := Float(lhs), rhs, "FDIV" : l.put(rhs.minus), rhs.fdiv()
                ]._sign(lhs.sign * rhs.sign)
            case _:
                return NotImplemented

    def __abs__(self) -> FloatExprB:
        return AccF[self & 0x7FFFFFFF]._sign(1)

    def __trunc__(self) -> FloatExprB:
        return self[self.opb("TRUNC")]._sign(self.sign)

    def round(self, offset: float) -> FloatExprB:
        o = ctypes.c_uint.from_buffer(ctypes.c_float(offset)).value
        return self[
            self,
            "ROUND":o,
            (
                Acc.opb("FADD").opb("ITOFX").opb("TRUNC")
                if offset == 0.5
                else Acc.opb("TRUNC").opb("FADD").opb("ITOFX")
            ),
        ]._sign(self.sign)

    def __round__(self) -> FloatExprB:
        return self.round(0.5)

    def __ceil__(self) -> FloatExprB:
        return self.round(-1.0 if self.minus else 1.0)

    def __floor__(self) -> FloatExprB:
        return self.round(1.0 if self.minus else -1.0)

    def __pow__(lhs: FloatExprB, rhs: int) -> FloatExprB:
        if isinstance(rhs, int):
            if rhs == 0:
                return AccF(1.0)
            elif rhs == 1:
                return lhs
            elif rhs == 2:
                return AccF[lhs.opb("FSQU").opb("ITOFX")]._sign(1)
            elif rhs < 0:
                return 1.0 / (lhs**-rhs)
            else:
                l = Float(lhs, lhs.sign)
                p = AccF
                for c in f"{rhs:b}"[1:]:
                    p = p**2
                    if c == "1":
                        p = p * l
                return AccF[l, p]._sign(p.sign)
        else:
            return NotImplemented

    def fcomp(lhs: FloatExprB, rhs: float | BinaryOp, cond: int, eq: bool) -> Bool:
        match rhs:
            case float():
                r = ctypes.c_uint.from_buffer(
                    ctypes.c_float(-rhs if lhs.minus else rhs)
                ).value
                sign = Acc[lhs, "FCOMP":r]
            case Float():
                sign = Acc[lhs, "FCOMP" : rhs.put(lhs.minus)]
            case FloatExprB():
                sign = Acc[r := Float(rhs), lhs, "FCOMP" : r.put(lhs.minus)]
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


class AccFloatExprB(FloatExprB):
    def __init__(self, sign: int = 0):
        super().__init__(sign=sign)

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        match value:
            case float():
                v = ctypes.c_uint.from_buffer(ctypes.c_float(value)).value
                return self["LOAD":v]._sign(1 if value >= 0 else -1)
            case Float():
                return +self
            case FloatExprB():
                return value
            case _:
                raise TypeError(f"{type(value)} is not supported")


AccF = AccFloatExprB()
AccFP = AccFloatExprB(sign=1)
AccFM = AccFloatExprB(sign=-1)


class Float(Int):
    def __init__(self, value: float | BinaryOp | None = None, sign: int = 0):
        super().__init__()
        self.refm = []
        self.minus = False
        self.sign = sign
        match value:
            case float():
                assert sign * value >= 0, "Sign mismatch"
                self.expr = AccF[AccF(value)]._sign(1 if value >= 0 else -1)
            case Float():
                assert sign * value.sign >= 0, "Sign mismatch"
                self.expr = AccF[+value]._sign(sign | value.sign)
            case FloatExprB():
                assert sign * value.sign >= 0, "Sign mismatch"
                self.minus = value.minus
                self.expr = value[value]._sign(sign | value.sign)
            case None:
                self.expr = None
            case _:
                raise TypeError(f"{type(value)} is not supported")

    def put(self, minus: bool = False) -> tuple[Code]:
        c = Code("PUT", debug="->      ")
        cm = Code("PUTM", debug="->      ", offset=0x80000000)
        if minus:
            self.ref.append(cm)
            self.refm.append(c)
        else:
            self.ref.append(c)
            self.refm.append(cm)
        return (c, cm)

    def load(self, minus: bool = False) -> FloatExprB:
        return AccF["LOAD" : self.put(minus)]._sign(-self.sign if minus else self.sign)

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
        expr = Float(value, self.sign).expr
        return expr[expr, self.refm if self.minus else self.ref]._sign(expr.sign)

    def fadd(
        lhs: Float, rhs: float | BinaryOp, sub: bool = False, rsub: bool = False
    ) -> FloatExprB:
        a = Acc.opb("ITOF").opb("ITOFX")
        af = Acc.opb("ITOFX")
        sign = -lhs.sign if rsub else lhs.sign
        match rhs:
            case float():
                if sub:
                    rhs = -rhs
                s = sign if sign * rhs >= 0 else 0
                r = ctypes.c_uint.from_buffer(ctypes.c_float(rhs)).value
                return AccF[lhs.load(rsub), "FADD":r, af if s else a]._sign(s)
            case Float():
                r = -rhs.sign if sub else rhs.sign
                s = sign if sign == r else 0
                return AccF[
                    lhs.load(rsub), "FADD" : rhs.put(sub), af if s else a
                ]._sign(s)
            case FloatExprB():
                if sub:
                    rhs = -rhs
                s = sign if sign == rhs.sign else 0
                return rhs[
                    rhs, "FADD" : lhs.put(rhs.minus ^ rsub), af if s else a
                ]._sign(s)
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
        m = Acc.opb("ITOFX")
        match rhs:
            case float():
                r = ctypes.c_uint.from_buffer(ctypes.c_float(rhs)).value
                return AccF[+lhs, "FMUL":r, m]._sign(
                    lhs.sign if rhs >= 0 else -lhs.sign
                )
            case Float():
                return AccF[+lhs, "FMUL" : rhs.put(), m]._sign(lhs.sign * rhs.sign)
            case FloatExprB():
                return AccF[l := Float(lhs), rhs, "FMUL" : l.put(rhs.minus), m]._sign(
                    lhs.sign * rhs.sign
                )
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
                return AccF[+rhs, "FDIV" : lhs.put(), AccF.fdiv()]._sign(
                    lhs.sign * rhs.sign
                )
            case FloatExprB():
                return AccF[rhs, "FDIV" : lhs.put(rhs.minus), AccF.fdiv()]._sign(
                    lhs.sign * rhs.sign
                )
            case _:
                return NotImplemented

    def __rtruediv__(rhs: Float, lhs: float | BinaryOp) -> FloatExprB:
        match lhs:
            case float():
                l = ctypes.c_uint.from_buffer(ctypes.c_float(lhs)).value
                return AccF[+rhs, "FDIV":l, AccF.fdiv()]._sign(
                    rhs.sign if lhs >= 0 else -rhs.sign
                )
            case Float():
                return AccF[+rhs, "FDIV" : lhs.put(), AccF.fdiv()]._sign(
                    lhs.sign * rhs.sign
                )
            case FloatExprB():
                return AccF[
                    lhs, "BLOAD" : rhs.put(lhs.minus), "OPB":"FDIV", AccF.fdiv()
                ]._sign(lhs.sign * rhs.sign)
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
                r = ctypes.c_uint.from_buffer(ctypes.c_float(rhs)).value
                sign = Acc[+lhs, "FCOMP":r]
            case Float():
                sign = Acc[+lhs, "FCOMP" : rhs.put()]
            case FloatExprB():
                cond = cond if rhs.minus else -cond
                sign = Acc[rhs, "FCOMP" : lhs.put(rhs.minus)]
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
        return AccF[v, "ITOF":0x4E800000, AccF.opb("ITOFX")]._sign(1)
    else:
        return AccF[v, "ITOF":0x4E800020, AccF.opb("ITOF").opb("ITOFX")]


class FunctionF(Function):
    def __init__(self, *args: Int):
        super().__init__(*args)
        self.minus = None

    def value(self, expr: float | BinaryOp) -> Block:
        match expr:
            case float():
                self.minus = bool(self.minus)
                v = -expr if self.minus else expr
                v = ctypes.c_uint.from_buffer(ctypes.c_float(v)).value
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
    def __init__(self, *fdata: float, op: str = "PUSH", sign: int = 0):
        idata = [ctypes.c_uint.from_buffer(ctypes.c_float(f)).value for f in fdata]
        super().__init__(*idata, op=op)
        self.sign = sign
        if sign:
            for f in fdata:
                assert sign * f >= 0, "Sign mismatch"

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
            sign=array.sign,
        )
        self.array = array
        self.offset = offset

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        offset = self.array.offset(self.offset)
        match value:
            case float():
                assert self.array.sign * value >= 0, "Sign mismatch"
                v = ctypes.c_uint.from_buffer(ctypes.c_float(value)).value
                return AccF[offset << "LOAD", "BLOAD":v, "OPB":"PUT"]._sign(
                    1 if value >= 0 else -1
                )
            case Float():
                assert self.array.sign * value.sign >= 0, "Sign mismatch"
                return AccF[offset << "LOAD", "BLOAD" : value.put(), "OPB":"PUT"]._sign(
                    self.array.sign | value.sign
                )
            case FloatExprB():
                assert self.array.sign * value.sign >= 0, "Sign mismatch"
                return value[
                    value,
                    offset << "BLOAD",
                    "OPB":"BLOAD",
                    "OPB" : "PUTMX" if value.minus else "PUT",
                ]._sign(self.array.sign | value.sign)
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
            sign=array.sign,
        )
        self.array = array
        self.offset = offset

    def __call__(self, value: float | BinaryOp) -> FloatExprB:
        offset = self.array.offset(self.offset) << "ADD"
        match value:
            case float():
                assert self.array.sign * value >= 0, "Sign mismatch"
                v = ctypes.c_uint.from_buffer(ctypes.c_float(value)).value
                return AccF[self.index, offset, "BLOAD":v, "OPB":"PUT"]._sign(
                    1 if value >= 0 else -1
                )
            case Float():
                assert self.array.sign * value.sign >= 0, "Sign mismatch"
                return AccF[
                    self.index, offset, "BLOAD" : value.put(), "OPB":"PUT"
                ]._sign(self.array.sign | value.sign)
            case FloatExprB():
                assert self.array.sign * value.sign >= 0, "Sign mismatch"
                if isinstance(self.index, Expr):
                    return value[
                        value,
                        self.index.bload(),
                        offset,
                        "OPB":"BLOAD",
                        "OPB" : "PUTMX" if value.minus else "PUT",
                    ]._sign(self.array.sign | value.sign)
                else:
                    if value.minus:
                        offset = self.array.offset(self.offset | 0x80000000) << "ADD"
                    return value[
                        self.index,
                        offset,
                        put := Code("PUT"),
                        value,
                        "PUTM" if value.minus else "PUT" : put,
                    ]._sign(self.array.sign | value.sign)
            case _:
                raise TypeError(f"{type(value)} is not supported")
