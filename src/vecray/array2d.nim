import vector2, vector3
import std/[macros, math, hashes]


type Array2d*[T] = object
    data *: ptr UncheckedArray[T]
    sizeX *: uint
    sizeY *: uint

proc newArray2d*[T](sizeX, sizeY: uint): Array2d[T] =
    return Array2d[T](
        data  : cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(sizeX * sizeY))),
        sizeX : sizeX,
        sizeY : sizeY,
    )
proc newArray2d*[T](sizeX, sizeY: int): Array2d[T] =
    return Array2d[T](
        data  : cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(uint(sizeX) * uint(sizeY)))),
        sizeX : uint(sizeX),
        sizeY : uint(sizeY),
    )


proc `=destroy`*[T](a: Array2d[T]): void =
    if a.data != nil:
        for i in 0..<(a.sizeX * a.sizeY):
            `=destroy`(a.data[i])
        dealloc(a.data)

proc `=wasMoved`*[T](a: var Array2d[T]): void =
    a.data = nil

proc `=trace`*[T](a: var Array2d[T], env: pointer): void =
    if a.data != nil:
        for i in 0..<(a.sizeX * a.sizeY):
            `=trace`(a.data[i], env)

proc `=copy`*[T](a1: var Array2d[T], a2: Array2d[T]): void =
    if a1.data == a2.data: return
    `=destroy`(a1)
    `=wasMoved`(a1)
    a1.sizeX = a2.sizeX
    a1.sizeY = a2.sizeY
    if a2.data != nil:
        a1.data = cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(uint(a2.sizeX) * uint(a2.sizeY))))
        for i in 0..<(a2.sizeX * a2.sizeY):
            a1.data[i] = a2.data[i]

proc `=dup`*[T](a: Array2d[T]): Array2d[T] =
    result = newArray2d[T](a.sizeX, a.sizeY)
    if a.data != nil:
        result.data = cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(uint(a.sizeX) * uint(a.sizeY))))
        for i in 0..<(a.sizeX * a.sizeY):
            result.data[i] = `=dup`(a.data[i])

proc `=sink`*[T](a1: var Array2d[T], a2: Array2d[T]): void =
    `=destroy`(a1)
    a1.sizeX = a2.sizeX
    a1.sizeY = a2.sizeY
    a1.data = a2.data


proc `[]`*[T](a: Array2d[T], x, y: uint): var T =
    return a.data[y * a.sizeX + x]

proc `[]`*[T](a: Array2d[T], x, y: int): var T =
    return a.data[uint(y) * a.sizeX + uint(x)]

proc `[]=`*[T](a: var Array2d[T], x, y: uint, val: sink T) =
    a.data[y * a.sizeX + x] = val

proc `[]=`*[T](a: var Array2d[T], x, y: int, val: sink T) =
    a.data[uint(y) * a.sizeX + uint(x)] = val


proc `[]`*[T](a: Array2d[T], pos: Vector2i): var T =
    return a.data[uint(pos.y) * a.sizeX + uint(pos.x)]

proc `[]=`*[T](a: var Array2d[T], pos: Vector2i, val: sink T) =
    a.data[uint(pos.y) * a.sizeX + uint(pos.x)] = val


proc set2d*[T](a: var Array2d[T], x, y: Slice[SomeInteger], val: sink T) =
    for row in y.a .. y.b:
        for col in x.a .. x.b:
            a.data[row * int(a.sizeX) + col] = val


proc make_rect_add*[T: SomeNumber](x, y: openArray[T]): Array2d[T] =
    result = newArray2d[T](len(x), len(y))
    for row in 0..<len(y):
        for col in 0..<len(x):
            result.data[row * len(x) + col] = x[col] + y[row]

proc make_rect_mul*[T: SomeNumber](x, y: openArray[T]): Array2d[T] =
    result = newArray2d[T](len(x), len(y))
    for row in 0..<len(y):
        for col in 0..<len(x):
            result.data[row * len(x) + col] = x[col] * y[row]

# proc make_rect*[T](p: proc(x: T, y: T): T, x, y: openArray[T]): Array2d[T] =
#     result = newArray2d[T](len(x), len(y))
#     for row in 0..<len(y):
#         for col in 0..<len(x):
#             result.data[row * len(x) + col] = p(x[col], y[row])


# dumpAstGen:
#     proc `/`*(a: Array2d[T], scalar: T): Array2d[Y] =
#         result = newArray2d[T](a.sizeX, a.sizeY)
#         for row in 0..<a.sizeY:
#             for col in 0..<a.sizeX:
#                 result.data[row * a.sizeX + col] = myfunc(a.data[row * a.sizeX + col]) / myfunc(scalar)

#     proc `/`*(a, b: Array2d[T]): Array2d[Y] =
#         result = newArray2d[T](min(a.sizeX, b.sizeX), min(a.sizeY, b.sizeY))
#         for row in 0..<result.sizeY:
#             for col in 0..<result.sizeX:
#                 result.data[row * a.sizeX + col] = myfunc(a.data[row * a.sizeX + col]) / myfunc(b.data[row * b.sizeX + col])

#     proc `/=`*(a: var Array2d[T], scalar: T) =
#         for row in 0..<a.sizeY:
#             for col in 0..<a.sizeX:
#                 a.data[row * a.sizeX + col] /= myfunc(scalar)

#     proc `/=`*(a: var Array2d[T], b: Array2d[T]) =
#         for row in 0..<min(a.sizeY, b.sizeY):
#             for col in 0..<min(a.sizeX, b.sizeX):
#                 a.data[row * a.sizeX + col] /= myfunc(b.data[row * b.sizeX + col])

#TODO add func2 macro for dots, lens, dists, etc
#TODO add func1 macro for abs, etc
#TODO array scalar also needs scalar array
#TODO add unary op
#TODO add somenumber compares
#TODO add non-vector bool ops and bitwise ops

macro arr2_infix_op_opset_as_aa_generic_number*(op_sym: static[string]): untyped =
    nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            nnkGenericParams.newTree(
                nnkIdentDefs.newTree(
                    newIdentNode("T"),
                    newIdentNode("SomeNumber"),
                    newEmptyNode()
                )
            ),
            nnkFormalParams.newTree(
                nnkBracketExpr.newTree(
                    newIdentNode("Array2d"),
                    newIdentNode("T")
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode("T")
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("scalar"),
                    newIdentNode("T"),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("newArray2d"),
                            newIdentNode("T")
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeX")
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    )
                ),
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("a"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkAsgn.newTree(
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("result"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode(op_sym),
                                        nnkBracketExpr.newTree(
                                            nnkDotExpr.newTree(
                                                newIdentNode("a"),
                                                newIdentNode("data")
                                            ),
                                            nnkInfix.newTree(
                                                newIdentNode("+"),
                                                nnkInfix.newTree(
                                                    newIdentNode("*"),
                                                    newIdentNode("row"),
                                                    nnkDotExpr.newTree(
                                                        newIdentNode("a"),
                                                        newIdentNode("sizeX")
                                                    )
                                                ),
                                                newIdentNode("col")
                                            )
                                        ),
                                        newIdentNode("scalar")
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            nnkGenericParams.newTree(
                nnkIdentDefs.newTree(
                    newIdentNode("T"),
                    newIdentNode("SomeNumber"),
                    newEmptyNode()
                )
            ),
            nnkFormalParams.newTree(
                nnkBracketExpr.newTree(
                    newIdentNode("Array2d"),
                    newIdentNode("T")
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("scalar"),
                    newIdentNode("T"),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode("T")
                    ),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("newArray2d"),
                            newIdentNode("T")
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeX")
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    )
                ),
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("a"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkAsgn.newTree(
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("result"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode(op_sym),
                                        nnkBracketExpr.newTree(
                                            nnkDotExpr.newTree(
                                                newIdentNode("a"),
                                                newIdentNode("data")
                                            ),
                                            nnkInfix.newTree(
                                                newIdentNode("+"),
                                                nnkInfix.newTree(
                                                    newIdentNode("*"),
                                                    newIdentNode("row"),
                                                    nnkDotExpr.newTree(
                                                        newIdentNode("a"),
                                                        newIdentNode("sizeX")
                                                    )
                                                ),
                                                newIdentNode("col")
                                            )
                                        ),
                                        newIdentNode("scalar")
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            nnkGenericParams.newTree(
                nnkIdentDefs.newTree(
                    newIdentNode("T"),
                    newIdentNode("SomeNumber"),
                    newEmptyNode()
                )
            ),
            nnkFormalParams.newTree(
                nnkBracketExpr.newTree(
                    newIdentNode("Array2d"),
                    newIdentNode("T")
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    newIdentNode("b"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode("T")
                    ),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("newArray2d"),
                            newIdentNode("T")
                        ),
                        nnkCall.newTree(
                            newIdentNode("min"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("sizeX")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("sizeX")
                            )
                        ),
                        nnkCall.newTree(
                            newIdentNode("min"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("sizeY")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("sizeY")
                            )
                        )
                    )
                ),
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("result"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("result"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkAsgn.newTree(
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("result"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode(op_sym),
                                        nnkBracketExpr.newTree(
                                            nnkDotExpr.newTree(
                                                newIdentNode("a"),
                                                newIdentNode("data")
                                            ),
                                            nnkInfix.newTree(
                                                newIdentNode("+"),
                                                nnkInfix.newTree(
                                                    newIdentNode("*"),
                                                    newIdentNode("row"),
                                                    nnkDotExpr.newTree(
                                                        newIdentNode("a"),
                                                        newIdentNode("sizeX")
                                                    )
                                                ),
                                                newIdentNode("col")
                                            )
                                        ),
                                        nnkBracketExpr.newTree(
                                            nnkDotExpr.newTree(
                                                newIdentNode("b"),
                                                newIdentNode("data")
                                            ),
                                            nnkInfix.newTree(
                                                newIdentNode("+"),
                                                nnkInfix.newTree(
                                                    newIdentNode("*"),
                                                    newIdentNode("row"),
                                                    nnkDotExpr.newTree(
                                                        newIdentNode("b"),
                                                        newIdentNode("sizeX")
                                                    )
                                                ),
                                                newIdentNode("col")
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym & "=")
                )
            ),
            newEmptyNode(),
            nnkGenericParams.newTree(
                nnkIdentDefs.newTree(
                    newIdentNode("T"),
                    newIdentNode("SomeNumber"),
                    newEmptyNode()
                )
            ),
            nnkFormalParams.newTree(
                newEmptyNode(),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkVarTy.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("Array2d"),
                            newIdentNode("T")
                        )
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("scalar"),
                    newIdentNode("T"),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("a"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkInfix.newTree(
                                    newIdentNode(op_sym & "="),
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("a"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    newIdentNode("scalar")
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym & "=")
                )
            ),
            newEmptyNode(),
            nnkGenericParams.newTree(
                nnkIdentDefs.newTree(
                    newIdentNode("T"),
                    newIdentNode("SomeNumber"),
                    newEmptyNode()
                )
            ),
            nnkFormalParams.newTree(
                newEmptyNode(),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkVarTy.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("Array2d"),
                            newIdentNode("T")
                        )
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("b"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode("T")
                    ),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkCall.newTree(
                            newIdentNode("min"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("sizeY")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("sizeY")
                            )
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkCall.newTree(
                                    newIdentNode("min"),
                                    nnkDotExpr.newTree(
                                        newIdentNode("a"),
                                        newIdentNode("sizeX")
                                    ),
                                    nnkDotExpr.newTree(
                                        newIdentNode("b"),
                                        newIdentNode("sizeX")
                                    )
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkInfix.newTree(
                                    newIdentNode(op_sym & "="),
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("a"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("b"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("b"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
    )

macro arr2_infix_op_as_aa*(op_sym, a_type, b_type, out_type, convert_func: static[string]): untyped =
    nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                nnkBracketExpr.newTree(
                    newIdentNode("Array2d"),
                    newIdentNode(out_type)
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode(a_type)
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("scalar"),
                    newIdentNode(b_type),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("newArray2d"),
                            newIdentNode(out_type)
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeX")
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    )
                ),
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("a"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkAsgn.newTree(
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("result"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode(op_sym),
                                        nnkCall.newTree(
                                            newIdentNode(convert_func),
                                            nnkBracketExpr.newTree(
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("data")
                                                ),
                                                nnkInfix.newTree(
                                                    newIdentNode("+"),
                                                    nnkInfix.newTree(
                                                        newIdentNode("*"),
                                                        newIdentNode("row"),
                                                        nnkDotExpr.newTree(
                                                            newIdentNode("a"),
                                                            newIdentNode("sizeX")
                                                        )
                                                    ),
                                                    newIdentNode("col")
                                                )
                                            )
                                        ),
                                        nnkCall.newTree(
                                            newIdentNode(convert_func),
                                            newIdentNode("scalar")
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                nnkBracketExpr.newTree(
                    newIdentNode("Array2d"),
                    newIdentNode(out_type)
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("scalar"),
                    newIdentNode(a_type),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode(b_type)
                    ),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("newArray2d"),
                            newIdentNode(out_type)
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeX")
                        ),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    )
                ),
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("a"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkAsgn.newTree(
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("result"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode(op_sym),
                                        nnkCall.newTree(
                                            newIdentNode(convert_func),
                                            nnkBracketExpr.newTree(
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("data")
                                                ),
                                                nnkInfix.newTree(
                                                    newIdentNode("+"),
                                                    nnkInfix.newTree(
                                                        newIdentNode("*"),
                                                        newIdentNode("row"),
                                                        nnkDotExpr.newTree(
                                                            newIdentNode("a"),
                                                            newIdentNode("sizeX")
                                                        )
                                                    ),
                                                    newIdentNode("col")
                                                )
                                            )
                                        ),
                                        nnkCall.newTree(
                                            newIdentNode(convert_func),
                                            newIdentNode("scalar")
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                nnkBracketExpr.newTree(
                    newIdentNode("Array2d"),
                    newIdentNode(out_type)
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode(a_type)
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("b"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode(b_type)
                    ),
                    newEmptyNode()
                ),
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkAsgn.newTree(
                    newIdentNode("result"),
                    nnkCall.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("newArray2d"),
                            newIdentNode(out_type)
                        ),
                        nnkCall.newTree(
                            newIdentNode("min"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("sizeX")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("sizeX")
                            )
                        ),
                        nnkCall.newTree(
                            newIdentNode("min"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("sizeY")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("sizeY")
                            )
                        )
                    )
                ),
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("result"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("result"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkAsgn.newTree(
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("result"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkInfix.newTree(
                                        newIdentNode(op_sym),
                                        nnkCall.newTree(
                                            newIdentNode(convert_func),
                                            nnkBracketExpr.newTree(
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("data")
                                                ),
                                                nnkInfix.newTree(
                                                    newIdentNode("+"),
                                                    nnkInfix.newTree(
                                                        newIdentNode("*"),
                                                        newIdentNode("row"),
                                                        nnkDotExpr.newTree(
                                                            newIdentNode("a"),
                                                            newIdentNode("sizeX")
                                                        )
                                                    ),
                                                    newIdentNode("col")
                                                )
                                            )
                                        ),
                                        nnkCall.newTree(
                                            newIdentNode(convert_func),
                                            nnkBracketExpr.newTree(
                                                nnkDotExpr.newTree(
                                                    newIdentNode("b"),
                                                    newIdentNode("data")
                                                ),
                                                nnkInfix.newTree(
                                                    newIdentNode("+"),
                                                    nnkInfix.newTree(
                                                        newIdentNode("*"),
                                                        newIdentNode("row"),
                                                        nnkDotExpr.newTree(
                                                            newIdentNode("b"),
                                                            newIdentNode("sizeX")
                                                        )
                                                    ),
                                                    newIdentNode("col")
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
    )

macro arr2_infix_opset_as_aa*(op_sym, a_type, b_type, convert_func: static[string]): untyped =
    nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newEmptyNode(),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkVarTy.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("Array2d"),
                            newIdentNode(a_type)
                        )
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("scalar"),
                    newIdentNode(b_type),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkDotExpr.newTree(
                            newIdentNode("a"),
                            newIdentNode("sizeY")
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkDotExpr.newTree(
                                    newIdentNode("a"),
                                    newIdentNode("sizeX")
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkInfix.newTree(
                                    newIdentNode(op_sym),
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("a"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkCall.newTree(
                                        newIdentNode(convert_func),
                                        newIdentNode("scalar")
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                nnkAccQuoted.newTree(
                    newIdentNode(op_sym)
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newEmptyNode(),
                nnkIdentDefs.newTree(
                    newIdentNode("a"),
                    nnkVarTy.newTree(
                        nnkBracketExpr.newTree(
                            newIdentNode("Array2d"),
                            newIdentNode(a_type)
                        )
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("b"),
                    nnkBracketExpr.newTree(
                        newIdentNode("Array2d"),
                        newIdentNode(b_type)
                    ),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkForStmt.newTree(
                    newIdentNode("row"),
                    nnkInfix.newTree(
                        newIdentNode("..<"),
                        newLit(0),
                        nnkCall.newTree(
                            newIdentNode("min"),
                            nnkDotExpr.newTree(
                                newIdentNode("a"),
                                newIdentNode("sizeY")
                            ),
                            nnkDotExpr.newTree(
                                newIdentNode("b"),
                                newIdentNode("sizeY")
                            )
                        )
                    ),
                    nnkStmtList.newTree(
                        nnkForStmt.newTree(
                            newIdentNode("col"),
                            nnkInfix.newTree(
                                newIdentNode("..<"),
                                newLit(0),
                                nnkCall.newTree(
                                    newIdentNode("min"),
                                    nnkDotExpr.newTree(
                                        newIdentNode("a"),
                                        newIdentNode("sizeX")
                                    ),
                                    nnkDotExpr.newTree(
                                        newIdentNode("b"),
                                        newIdentNode("sizeX")
                                    )
                                )
                            ),
                            nnkStmtList.newTree(
                                nnkInfix.newTree(
                                    newIdentNode(op_sym),
                                    nnkBracketExpr.newTree(
                                        nnkDotExpr.newTree(
                                            newIdentNode("a"),
                                            newIdentNode("data")
                                        ),
                                        nnkInfix.newTree(
                                            newIdentNode("+"),
                                            nnkInfix.newTree(
                                                newIdentNode("*"),
                                                newIdentNode("row"),
                                                nnkDotExpr.newTree(
                                                    newIdentNode("a"),
                                                    newIdentNode("sizeX")
                                                )
                                            ),
                                            newIdentNode("col")
                                        )
                                    ),
                                    nnkCall.newTree(
                                        newIdentNode(convert_func),
                                        nnkBracketExpr.newTree(
                                            nnkDotExpr.newTree(
                                                newIdentNode("b"),
                                                newIdentNode("data")
                                            ),
                                            nnkInfix.newTree(
                                                newIdentNode("+"),
                                                nnkInfix.newTree(
                                                    newIdentNode("*"),
                                                    newIdentNode("row"),
                                                    nnkDotExpr.newTree(
                                                        newIdentNode("b"),
                                                        newIdentNode("sizeX")
                                                    )
                                                ),
                                                newIdentNode("col")
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        ),
    )

arr2_infix_op_opset_as_aa_generic_number("+")
arr2_infix_op_opset_as_aa_generic_number("-")
arr2_infix_op_opset_as_aa_generic_number("*")
arr2_infix_op_opset_as_aa_generic_number("/")

template per_vector_macro_calls*(vecN, convert_func: static[string]) =
    arr2_infix_op_as_aa("+", vecN & "f", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", vecN & "f", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", vecN & "f", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", vecN & "f", vecN & "f", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", vecN & "f", "float", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", vecN & "f", "float", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", vecN & "f", "float", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", vecN & "f", "float", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", "float", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", "float", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", "float", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", "float", vecN & "f", vecN & "f", convert_func)


    arr2_infix_opset_as_aa("+=", vecN & "f", vecN & "f", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "f", vecN & "f", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "f", vecN & "f", convert_func)
    arr2_infix_opset_as_aa("/=", vecN & "f", vecN & "f", convert_func)

    arr2_infix_opset_as_aa("+=", vecN & "f", "float", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "f", "float", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "f", "float", convert_func)
    arr2_infix_opset_as_aa("/=", vecN & "f", "float", convert_func)


    arr2_infix_op_as_aa("+", vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("-", vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("*", vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("/", vecN & "i", vecN & "i", vecN & "f", convert_func) # converts

    arr2_infix_op_as_aa("+", vecN & "i", "int", vecN & "i", convert_func)
    arr2_infix_op_as_aa("-", vecN & "i", "int", vecN & "i", convert_func)
    arr2_infix_op_as_aa("*", vecN & "i", "int", vecN & "i", convert_func)
    arr2_infix_op_as_aa("/", vecN & "i", "int", vecN & "f", convert_func) # converts

    arr2_infix_op_as_aa("+", vecN & "i", "uint", vecN & "i", convert_func)
    arr2_infix_op_as_aa("-", vecN & "i", "uint", vecN & "i", convert_func)
    arr2_infix_op_as_aa("*", vecN & "i", "uint", vecN & "i", convert_func)
    arr2_infix_op_as_aa("/", vecN & "i", "uint", vecN & "f", convert_func) # converts

    arr2_infix_op_as_aa("+", "int", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("-", "int", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("*", "int", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("/", "int", vecN & "i", vecN & "f", convert_func) # converts

    arr2_infix_op_as_aa("+", "uint", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("-", "uint", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("*", "uint", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("/", "uint", vecN & "i", vecN & "f", convert_func) # converts


    arr2_infix_opset_as_aa("+=", vecN & "i", vecN & "i", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "i", vecN & "i", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "i", vecN & "i", convert_func)

    arr2_infix_opset_as_aa("+=", vecN & "i", "int", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "i", "int", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "i", "int", convert_func)

    arr2_infix_opset_as_aa("+=", vecN & "i", "uint", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "i", "uint", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "i", "uint", convert_func)


    arr2_infix_op_as_aa("+", vecN & "f", vecN & "i", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", vecN & "f", vecN & "i", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", vecN & "f", vecN & "i", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", vecN & "f", vecN & "i", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", vecN & "i", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", vecN & "i", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", vecN & "i", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", vecN & "i", vecN & "f", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", vecN & "f", "int", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", vecN & "f", "int", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", vecN & "f", "int", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", vecN & "f", "int", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", vecN & "f", "uint", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", vecN & "f", "uint", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", vecN & "f", "uint", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", vecN & "f", "uint", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", "int", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", "int", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", "int", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", "int", vecN & "f", vecN & "f", convert_func)

    arr2_infix_op_as_aa("+", "uint", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("-", "uint", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("*", "uint", vecN & "f", vecN & "f", convert_func)
    arr2_infix_op_as_aa("/", "uint", vecN & "f", vecN & "f", convert_func)


    arr2_infix_opset_as_aa("+=", vecN & "f", vecN & "i", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "f", vecN & "i", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "f", vecN & "i", convert_func)
    arr2_infix_opset_as_aa("/=", vecN & "f", vecN & "i", convert_func)

    arr2_infix_opset_as_aa("+=", vecN & "f", "int", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "f", "int", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "f", "int", convert_func)
    arr2_infix_opset_as_aa("/=", vecN & "f", "int", convert_func)

    arr2_infix_opset_as_aa("+=", vecN & "f", "uint", convert_func)
    arr2_infix_opset_as_aa("-=", vecN & "f", "uint", convert_func)
    arr2_infix_opset_as_aa("*=", vecN & "f", "uint", convert_func)
    arr2_infix_opset_as_aa("/=", vecN & "f", "uint", convert_func)


    arr2_infix_op_as_aa("==", vecN & "f", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa("!=", vecN & "f", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa("<",  vecN & "f", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa("<=", vecN & "f", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">",  vecN & "f", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">=", vecN & "f", vecN & "f", vecN & "b", convert_func)

    arr2_infix_op_as_aa("==", vecN & "i", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa("!=", vecN & "i", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa("<",  vecN & "i", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa("<=", vecN & "i", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">",  vecN & "i", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">=", vecN & "i", vecN & "i", vecN & "b", convert_func)

    arr2_infix_op_as_aa("<",  vecN & "f", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa("<=", vecN & "f", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">",  vecN & "f", vecN & "i", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">=", vecN & "f", vecN & "i", vecN & "b", convert_func)

    arr2_infix_op_as_aa("<",  vecN & "i", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa("<=", vecN & "i", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">",  vecN & "i", vecN & "f", vecN & "b", convert_func)
    arr2_infix_op_as_aa(">=", vecN & "i", vecN & "f", vecN & "b", convert_func)

    arr2_infix_op_as_aa("div",  vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("mod",  vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("shr",  vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("shl",  vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("ashr", vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("and",  vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("or",   vecN & "i", vecN & "i", vecN & "i", convert_func)
    arr2_infix_op_as_aa("xor",  vecN & "i", vecN & "i", vecN & "i", convert_func)

    arr2_infix_op_as_aa("and",  vecN & "b", vecN & "b", vecN & "b", convert_func)
    arr2_infix_op_as_aa("or",   vecN & "b", vecN & "b", vecN & "b", convert_func)
    arr2_infix_op_as_aa("xor",  vecN & "b", vecN & "b", vecN & "b", convert_func)

per_vector_macro_calls("Vector2", "vec2")
per_vector_macro_calls("Vector3", "vec3")

proc normalize_total*[T: SomeNumber](a: Array2d[T]): Array2d[T] =
    result = newArray2d[T](a.sizeX, a.sizeY)
    var total: T
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            total += a.data[row * a.sizeX + col]
    var scale = 1 / total
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            result.data[row * a.sizeX + col] = a.data[row * a.sizeX + col] * scale

proc normalize_corner_odd_total*[T: SomeNumber](a: Array2d[T]): Array2d[T] =
    ## treats top and left edges as mirror lines, does NOT duplicate them
    result = newArray2d[T](a.sizeX, a.sizeY)
    var total: T
    for row in 0..<a.sizeY:
        total += a.data[row * a.sizeX]
        for col in 1..<a.sizeX:
            total += 2 * a.data[row * a.sizeX + col]
    for row in 1..<a.sizeY:
        total += a.data[row * a.sizeX]
        for col in 1..<a.sizeX:
            total += 2 * a.data[row * a.sizeX + col]
    var scale = 1 / total
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            result.data[row * a.sizeX + col] = a.data[row * a.sizeX + col] * scale

proc normalize_corner_even_total*[T: SomeNumber](a: Array2d[T]): Array2d[T] =
    ## treats top and left edges as mirror lines, DOES duplicate them
    result = newArray2d[T](a.sizeX, a.sizeY)
    var total: T
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            total += 4 * a.data[row * a.sizeX + col]
    var scale = 1 / total
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            result.data[row * a.sizeX + col] = a.data[row * a.sizeX + col] * scale


proc normalize_max*[T: SomeNumber](a: Array2d[T]): Array2d[T] =
    result = newArray2d[T](a.sizeX, a.sizeY)
    var highest: T
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            let val = a.data[row * a.sizeX + col]
            if val > highest: highest = val
    var scale = 1 / highest
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            result.data[row * a.sizeX + col] = a.data[row * a.sizeX + col] * scale


proc `$`*[T](a: Array2d[T]): string =
    result &= "["
    for row in 0..<a.sizeY:
        result &= "["
        for col in 0..<a.sizeX:
            result &= $a.data[row * a.sizeX + col]
            result &= ", "
        result &= "],"
    result &= "]"
