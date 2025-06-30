import std/[macros, math, hashes]


type
    Vector3f* = object
        x*, y*, z*: float

    Vector3i* = object
        x*, y*, z*: int

    Vector3b* = object
        x*, y*, z*: bool


proc vec3*(x, y, z: float): Vector3f = Vector3f(x: x, y: y, z: z)
proc vec3*(x, y, z: int):   Vector3i = Vector3i(x: x, y: y, z: z)
proc vec3*(x, y, z: uint):   Vector3i = Vector3i(x: int(x), y: int(y), z: int(z))
proc vec3*(x, y, z: bool):  Vector3b = Vector3b(x: x, y: y, z: z)

proc vec3*(f: float): Vector3f = Vector3f(x: f, y: f, z: f)
proc vec3*(i: int):   Vector3i = Vector3i(x: i, y: i, z: i)
proc vec3*(u: uint):   Vector3i = Vector3i(x: int(u), y: int(u), z: int(u))
proc vec3*(b: bool):  Vector3b = Vector3b(x: b, y: b, z: b)


macro vec_infix_op3*(op_sym: static[string], vec_type_in, vec_type_out: static[string]): untyped =
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
                        ),
                        nnkExprColonExpr.newTree(
                            newIdentNode("z"),
                            nnkInfix.newTree(
                                newIdentNode(op_sym),
                                nnkDotExpr.newTree(
                                    newIdentNode("v1"),
                                    newIdentNode("z")
                                ),
                                nnkDotExpr.newTree(
                                    newIdentNode("v2"),
                                    newIdentNode("z")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

macro vec_unary_op3*(op_sym: static[string], vec_type: static[string]): untyped =
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
                        ),
                        nnkExprColonExpr.newTree(
                            newIdentNode("z"),
                            nnkPrefix.newTree(
                                newIdentNode(op_sym),
                                nnkDotExpr.newTree(
                                    newIdentNode("v"),
                                    newIdentNode("z")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

macro vec_op_set3*(op_sym: static[string], vec_type: static[string]): untyped =
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
                ),
                nnkInfix.newTree(
                    newIdentNode(op_sym),
                    nnkDotExpr.newTree(
                        newIdentNode("v1"),
                        newIdentNode("z")
                    ),
                    nnkDotExpr.newTree(
                        newIdentNode("v2"),
                        newIdentNode("z")
                    )
                )
            )
        )
    )

macro vec_func3*(name: static[string], function: static[string], vec_type_in, vec_type_out: static[string]): untyped =
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
                        ),
                        nnkExprColonExpr.newTree(
                            newIdentNode("z"),
                            nnkCall.newTree(
                                newIdentNode(function),
                                nnkDotExpr.newTree(
                                    newIdentNode("v"),
                                    newIdentNode("z")
                                )
                            )
                        )
                    )
                )
            )
        )
    )

macro vec_swizzle3*(vec_type: static[string]): untyped =
    result = nnkStmtList.newTree()
    for c1 in ["x", "y", "z"]:
        for c2 in ["x", "y", "z"]:
            for c3 in ["x", "y", "z"]:
                var components = c1 & c2 & c3
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
                                    ),
                                    nnkExprColonExpr.newTree(
                                        newIdentNode("z"),
                                        nnkDotExpr.newTree(
                                            newIdentNode("v"),
                                            newIdentNode(c3)
                                        )
                                    )
                                )
                            )
                        )
                    )
                )


converter vec3_int_to_float*(v: Vector3i): Vector3f = return Vector3f(x: float(v.x), y: float(v.y), z: float(v.z))
converter vec3_bool_to_float*(v: Vector3b): Vector3f = return Vector3f(x: float(v.x), y: float(v.y), z: float(v.z))
converter vec3_bool_to_int*(v: Vector3b): Vector3i = return Vector3i(x: int(v.x), y: int(v.y), z: int(v.z))

# converter vec3_from_float*(f: float): Vector3f = return Vector3f(x: f, y: f, z: f)
# converter vec3_from_int*(i: int): Vector3i = return Vector3i(x: i, y: i, z: i)
# converter vec3_from_bool*(b: bool): Vector3b = return Vector3b(x: b, y: b, z: b)


vec_swizzle3("Vector3f")
vec_swizzle3("Vector3i")
vec_swizzle3("Vector3b")


proc merge_add*(v: Vector3f): float = return v.x + v.y + v.z
proc merge_add*(v: Vector3i): int = return v.x + v.y + v.z

proc merge_mul*(v: Vector3f): float = return v.x * v.y * v.z
proc merge_mul*(v: Vector3i): int = return v.x * v.y * v.z


proc merge_and*(v: Vector3b): bool = return v.x and v.y and v.z
proc merge_and*(v: Vector3i): int = return v.x and v.y and v.z

proc merge_or*(v: Vector3b): bool = return v.x or v.y or v.z
proc merge_or*(v: Vector3i): int = return v.x or v.y or v.z

proc merge_xor*(v: Vector3b): bool = return v.x xor v.y xor v.z
proc merge_xor*(v: Vector3i): int = return v.x xor v.y xor v.z

converter vec3_bool*(v: Vector3b): bool = return merge_and(v)


proc hash*(v: Vector3f): Hash =
    var h: Hash = 0
    h = h !& hash(v.x)
    h = h !& hash(v.y)
    h = h !& hash(v.z)
    return !$ h
proc hash*(v: Vector3i): Hash =
    var h: Hash = 0
    h = h !& hash(v.x)
    h = h !& hash(v.y)
    h = h !& hash(v.z)
    return !$ h
proc hash*(v: Vector3b): Hash =
    var h: Hash = 0
    h = h !& hash(v.x)
    h = h !& hash(v.y)
    h = h !& hash(v.z)
    return !$ h


vec_infix_op3("+", "Vector3f", "Vector3f")
vec_infix_op3("-", "Vector3f", "Vector3f")
vec_infix_op3("*", "Vector3f", "Vector3f")
vec_infix_op3("/", "Vector3f", "Vector3f")

vec_unary_op3("-", "Vector3f")

vec_op_set3("+=", "Vector3f")
vec_op_set3("-=", "Vector3f")
vec_op_set3("*=", "Vector3f")
vec_op_set3("/=", "Vector3f")


vec_infix_op3("==", "Vector3f", "Vector3b")
vec_infix_op3("!=", "Vector3f", "Vector3b")
vec_infix_op3("<",  "Vector3f", "Vector3b")
vec_infix_op3("<=", "Vector3f", "Vector3b")
vec_infix_op3(">",  "Vector3f", "Vector3b")
vec_infix_op3(">=", "Vector3f", "Vector3b")


vec_infix_op3("+",    "Vector3i", "Vector3i")
vec_infix_op3("-",    "Vector3i", "Vector3i")
vec_infix_op3("*",    "Vector3i", "Vector3i")
vec_infix_op3("/",    "Vector3i", "Vector3f")
vec_infix_op3("div",  "Vector3i", "Vector3i")
vec_infix_op3("mod",  "Vector3i", "Vector3i")
vec_infix_op3("shr",  "Vector3i", "Vector3i")
vec_infix_op3("shl",  "Vector3i", "Vector3i")
vec_infix_op3("ashr", "Vector3i", "Vector3i")
vec_infix_op3("and",  "Vector3i", "Vector3i")
vec_infix_op3("or",   "Vector3i", "Vector3i")
vec_infix_op3("xor",  "Vector3i", "Vector3i")

vec_unary_op3("-",   "Vector3i")
vec_unary_op3("not", "Vector3i")

vec_op_set3("+=", "Vector3i")
vec_op_set3("-=", "Vector3i")
vec_op_set3("*=", "Vector3i")


vec_infix_op3("==", "Vector3i", "Vector3b")
vec_infix_op3("!=", "Vector3i", "Vector3b")
vec_infix_op3("<",  "Vector3i", "Vector3b")
vec_infix_op3("<=", "Vector3i", "Vector3b")
vec_infix_op3(">",  "Vector3i", "Vector3b")
vec_infix_op3(">=", "Vector3i", "Vector3b")


vec_infix_op3("and", "Vector3b", "Vector3b")
vec_infix_op3("or",  "Vector3b", "Vector3b")
vec_infix_op3("xor", "Vector3b", "Vector3b")
vec_unary_op3("not", "Vector3b")


proc length*(v: Vector3f): float = return sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
proc length*(v: Vector3i): float = return sqrt(float(v.x) * float(v.x) + float(v.y) * float(v.y) + float(v.z) * float(v.z))
proc length*(v: Vector3b): float = return sqrt(float(v.x) * float(v.x) + float(v.y) * float(v.y) + float(v.z) * float(v.z))

proc norm*(v: Vector3f): Vector3f = return v / vec3(length(v))
proc norm*(v: Vector3i): Vector3f = return v / vec3(length(v))
proc norm*(v: Vector3b): Vector3f = return v / vec3(length(v))

proc dot*(v1, v2: Vector3f): float = return merge_add(v1 * v2)
