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


proc scale*[T: SomeNumber](a: Array2d[T], scalar: T): Array2d[T] =
    result = newArray2d[T](a.sizeX, a.sizeY)
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            result.data[row * a.sizeX + col] = a.data[row * a.sizeX + col] * scalar

# proc scalar*[T](a: Array2d[T], p: proc(x: T, y: T): T, scalar: T): Array2d[T] =
#     for row in 0..<a.sizeY:
#         for col in 0..<a.sizeX:
#             result.data[row * a.sizeX + col] = p(a.data[row * a.sizeX + col], scalar)


proc add*[T: SomeNumber](a: Array2d[T], scalar: T): Array2d[T] =
    result = newArray2d[T](a.sizeX, a.sizeY)
    for row in 0..<a.sizeY:
        for col in 0..<a.sizeX:
            result.data[row * a.sizeX + col] = a.data[row * a.sizeX + col] + scalar


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
