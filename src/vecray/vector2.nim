import std/[macros, math, hashes]


type
    Vector2f* = object
        x*, y*: float

    Vector2i* = object
        x*, y*: int

    Vector2b* = object
        x*, y*: bool


proc vec2*(f: Vector2f): Vector2f = f
proc vec2*(i: Vector2i): Vector2i = i
proc vec2*(b: Vector2b): Vector2b = b

proc vec2*(x, y: float): Vector2f = Vector2f(x: x, y: y)
proc vec2*(x, y: int):   Vector2i = Vector2i(x: x, y: y)
proc vec2*(x, y: uint):  Vector2i = Vector2i(x: int(x), y: int(y))
proc vec2*(x, y: bool):  Vector2b = Vector2b(x: x, y: y)

proc vec2*(f: float): Vector2f = Vector2f(x: f, y: f)
proc vec2*(i: int):   Vector2i = Vector2i(x: i, y: i)
proc vec2*(u: uint):  Vector2i = Vector2i(x: int(u), y: int(u))
proc vec2*(b: bool):  Vector2b = Vector2b(x: b, y: b)


macro vec_infix_op2*(op_sym: static[string], vec_type_in, vec_type_out: static[string]): untyped =
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
                newIdentNode(vec_type_out),
                nnkIdentDefs.newTree(
                    newIdentNode("v1"),
                    newIdentNode("v2"),
                    newIdentNode(vec_type_in),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkReturnStmt.newTree(
                    nnkObjConstr.newTree(
                        newIdentNode(vec_type_out),
                        nnkExprColonExpr.newTree(
                            newIdentNode("x"),
                            nnkInfix.newTree(
                                newIdentNode(op_sym),
                                nnkDotExpr.newTree(
                                    newIdentNode("v1"),
                                    newIdentNode("x")
                                ),
                                nnkDotExpr.newTree(
                                    newIdentNode("v2"),
                                    newIdentNode("x")
                                )
                            )
                        ),
                        nnkExprColonExpr.newTree(
                            newIdentNode("y"),
                            nnkInfix.newTree(
                                newIdentNode(op_sym),
                                nnkDotExpr.newTree(
                                    newIdentNode("v1"),
                                    newIdentNode("y")
                                ),
                                nnkDotExpr.newTree(
                                    newIdentNode("v2"),
                                    newIdentNode("y")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

macro vec_unary_op2*(op_sym: static[string], vec_type: static[string]): untyped =
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
                newIdentNode(vec_type),
                nnkIdentDefs.newTree(
                    newIdentNode("v"),
                    newIdentNode(vec_type),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkReturnStmt.newTree(
                    nnkObjConstr.newTree(
                        newIdentNode(vec_type),
                        nnkExprColonExpr.newTree(
                            newIdentNode("x"),
                            nnkPrefix.newTree(
                                newIdentNode(op_sym),
                                nnkDotExpr.newTree(
                                    newIdentNode("v"),
                                    newIdentNode("x")
                                )
                            )
                        ),
                        nnkExprColonExpr.newTree(
                            newIdentNode("y"),
                            nnkPrefix.newTree(
                                newIdentNode(op_sym),
                                nnkDotExpr.newTree(
                                    newIdentNode("v"),
                                    newIdentNode("y")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

macro vec_op_set2*(op_sym: static[string], vec_type: static[string]): untyped =
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
                newIdentNode("void"),
                nnkIdentDefs.newTree(
                    newIdentNode("v1"),
                    nnkVarTy.newTree(
                        newIdentNode(vec_type)
                    ),
                    newEmptyNode()
                ),
                nnkIdentDefs.newTree(
                    newIdentNode("v2"),
                    newIdentNode(vec_type),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkInfix.newTree(
                    newIdentNode(op_sym),
                    nnkDotExpr.newTree(
                        newIdentNode("v1"),
                        newIdentNode("x")
                    ),
                    nnkDotExpr.newTree(
                        newIdentNode("v2"),
                        newIdentNode("x")
                    )
                ),
                nnkInfix.newTree(
                    newIdentNode(op_sym),
                    nnkDotExpr.newTree(
                        newIdentNode("v1"),
                        newIdentNode("y")
                    ),
                    nnkDotExpr.newTree(
                        newIdentNode("v2"),
                        newIdentNode("y")
                    )
                )
            )
        )
    )

macro vec_func2*(name: static[string], function: static[string], vec_type_in, vec_type_out: static[string]): untyped =
    nnkStmtList.newTree(
        nnkProcDef.newTree(
            nnkPostfix.newTree(
                newIdentNode("*"),
                newIdentNode(name)
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkFormalParams.newTree(
                newIdentNode(vec_type_out),
                nnkIdentDefs.newTree(
                    newIdentNode("v"),
                    newIdentNode(vec_type_in),
                    newEmptyNode()
                )
            ),
            newEmptyNode(),
            newEmptyNode(),
            nnkStmtList.newTree(
                nnkReturnStmt.newTree(
                    nnkObjConstr.newTree(
                        newIdentNode(vec_type_out),
                        nnkExprColonExpr.newTree(
                            newIdentNode("x"),
                            nnkCall.newTree(
                                newIdentNode(function),
                                nnkDotExpr.newTree(
                                    newIdentNode("v"),
                                    newIdentNode("x")
                                )
                            )
                        ),
                        nnkExprColonExpr.newTree(
                            newIdentNode("y"),
                            nnkCall.newTree(
                                newIdentNode(function),
                                nnkDotExpr.newTree(
                                    newIdentNode("v"),
                                    newIdentNode("y")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

macro vec_swizzle2*(vec_type: static[string]): untyped =
    result = nnkStmtList.newTree()
    for c1 in ["x", "y"]:
        for c2 in ["x", "y"]:
            var components = c1 & c2
            result &= nnkStmtList.newTree(
                nnkProcDef.newTree(
                    nnkPostfix.newTree(
                        newIdentNode("*"),
                        newIdentNode(components)
                    ),
                    newEmptyNode(),
                    newEmptyNode(),
                    nnkFormalParams.newTree(
                        newIdentNode(vec_type),
                        nnkIdentDefs.newTree(
                            newIdentNode("v"),
                            newIdentNode(vec_type),
                            newEmptyNode()
                        )
                    ),
                    newEmptyNode(),
                    newEmptyNode(),
                    nnkStmtList.newTree(
                        nnkReturnStmt.newTree(
                            nnkObjConstr.newTree(
                                newIdentNode(vec_type),
                                nnkExprColonExpr.newTree(
                                    newIdentNode("x"),
                                    nnkDotExpr.newTree(
                                        newIdentNode("v"),
                                        newIdentNode(c1)
                                    )
                                ),
                                nnkExprColonExpr.newTree(
                                    newIdentNode("y"),
                                    nnkDotExpr.newTree(
                                        newIdentNode("v"),
                                        newIdentNode(c2)
                                    )
                                )
                            )
                        )
                    )
                )
            )


converter vec2_int_to_float*(v: Vector2i): Vector2f = return Vector2f(x: float(v.x), y: float(v.y))
converter vec2_bool_to_float*(v: Vector2b): Vector2f = return Vector2f(x: float(v.x), y: float(v.y))
converter vec2_bool_to_int*(v: Vector2b): Vector2i = return Vector2i(x: int(v.x), y: int(v.y))

# converter vec2_from_float*(f: float): Vector2f = return Vector2f(x: f, y: f)
# converter vec2_from_int*(i: int): Vector2i = return Vector2i(x: i, y: i)
# converter vec2_from_bool*(b: bool): Vector2b = return Vector2b(x: b, y: b)


vec_swizzle2("Vector2f")
vec_swizzle2("Vector2i")
vec_swizzle2("Vector2b")


proc merge_add*(v: Vector2f): float = return v.x + v.y
proc merge_add*(v: Vector2i): int = return v.x + v.y

proc merge_mul*(v: Vector2f): float = return v.x * v.y
proc merge_mul*(v: Vector2i): int = return v.x * v.y


proc merge_and*(v: Vector2b): bool = return v.x and v.y
proc merge_and*(v: Vector2i): int = return v.x and v.y

proc merge_or*(v: Vector2b): bool = return v.x or v.y
proc merge_or*(v: Vector2i): int = return v.x or v.y

proc merge_xor*(v: Vector2b): bool = return v.x xor v.y
proc merge_xor*(v: Vector2i): int = return v.x xor v.y

converter vec2_bool*(v: Vector2b): bool = return merge_and(v)


proc hash*(v: Vector2f): Hash =
    var h: Hash = 0
    h = h !& hash(v.x)
    h = h !& hash(v.y)
    return !$ h
proc hash*(v: Vector2i): Hash =
    var h: Hash = 0
    h = h !& hash(v.x)
    h = h !& hash(v.y)
    return !$ h
proc hash*(v: Vector2b): Hash =
    var h: Hash = 0
    h = h !& hash(v.x)
    h = h !& hash(v.y)
    return !$ h


vec_infix_op2("+", "Vector2f", "Vector2f")
vec_infix_op2("-", "Vector2f", "Vector2f")
vec_infix_op2("*", "Vector2f", "Vector2f")
vec_infix_op2("/", "Vector2f", "Vector2f")

vec_unary_op2("-", "Vector2f")

vec_op_set2("+=", "Vector2f")
vec_op_set2("-=", "Vector2f")
vec_op_set2("*=", "Vector2f")
vec_op_set2("/=", "Vector2f")


vec_infix_op2("==", "Vector2f", "Vector2b")
vec_infix_op2("!=", "Vector2f", "Vector2b")
vec_infix_op2("<",  "Vector2f", "Vector2b")
vec_infix_op2("<=", "Vector2f", "Vector2b")
vec_infix_op2(">",  "Vector2f", "Vector2b")
vec_infix_op2(">=", "Vector2f", "Vector2b")


vec_infix_op2("+",    "Vector2i", "Vector2i")
vec_infix_op2("-",    "Vector2i", "Vector2i")
vec_infix_op2("*",    "Vector2i", "Vector2i")
vec_infix_op2("/",    "Vector2i", "Vector2f")
vec_infix_op2("div",  "Vector2i", "Vector2i")
vec_infix_op2("mod",  "Vector2i", "Vector2i")
vec_infix_op2("shr",  "Vector2i", "Vector2i")
vec_infix_op2("shl",  "Vector2i", "Vector2i")
vec_infix_op2("ashr", "Vector2i", "Vector2i")
vec_infix_op2("and",  "Vector2i", "Vector2i")
vec_infix_op2("or",   "Vector2i", "Vector2i")
vec_infix_op2("xor",  "Vector2i", "Vector2i")

vec_unary_op2("-",   "Vector2i")
vec_unary_op2("not", "Vector2i")

vec_op_set2("+=", "Vector2i")
vec_op_set2("-=", "Vector2i")
vec_op_set2("*=", "Vector2i")


vec_infix_op2("==", "Vector2i", "Vector2b")
vec_infix_op2("!=", "Vector2i", "Vector2b")
vec_infix_op2("<",  "Vector2i", "Vector2b")
vec_infix_op2("<=", "Vector2i", "Vector2b")
vec_infix_op2(">",  "Vector2i", "Vector2b")
vec_infix_op2(">=", "Vector2i", "Vector2b")


vec_infix_op2("and", "Vector2b", "Vector2b")
vec_infix_op2("or",  "Vector2b", "Vector2b")
vec_infix_op2("xor", "Vector2b", "Vector2b")
vec_unary_op2("not", "Vector2b")


proc length*(v: Vector2f): float = return sqrt(v.x * v.x + v.y * v.y)
proc length*(v: Vector2i): float = return sqrt(float(v.x) * float(v.x) + float(v.y) * float(v.y))
proc length*(v: Vector2b): float = return sqrt(float(v.x) * float(v.x) + float(v.y) * float(v.y))

proc norm*(v: Vector2f): Vector2f = return v / vec2(length(v))
proc norm*(v: Vector2i): Vector2f = return v / vec2(length(v))
proc norm*(v: Vector2b): Vector2f = return v / vec2(length(v))

proc dot*(v1, v2: Vector2f): float = return merge_add(v1 * v2)

