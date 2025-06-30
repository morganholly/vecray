import vector2, vector3
import std/[macros, math, hashes]


type Array3d*[T] = object
    data *: ptr UncheckedArray[T]
    sizeX *: uint
    sizeY *: uint
    sizeZ *: uint

proc newArray3d*[T](sizeX, sizeY, sizeZ: uint): Array3d[T] =
    return Array3d[T](
        data   : cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(sizeX * sizeY * sizeZ))),
        sizeX  : sizeX,
        sizeY  : sizeY,
        sizeZ  : sizeZ,
    )
proc newArray3d*[T](sizeX, sizeY, sizeZ: int): Array3d[T] =
    return Array3d[T](
        data  : cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(uint(sizeX) * uint(sizeY) * uint(sizeZ)))),
        sizeX : uint(sizeX),
        sizeY : uint(sizeY),
        sizeZ : uint(sizeZ),
    )


proc `=destroy`*[T](a: Array3d[T]): void =
    if a.data != nil:
        for i in 0..<(a.sizeX * a.sizeY * a.sizeZ):
            `=destroy`(a.data[i])
        dealloc(a.data)

proc `=wasMoved`*[T](a: var Array3d[T]): void =
    a.data = nil

proc `=trace`*[T](a: var Array3d[T], env: pointer): void =
    if a.data != nil:
        for i in 0..<(a.sizeX * a.sizeY * a.sizeZ):
            `=trace`(a.data[i], env)

proc `=copy`*[T](a1: var Array3d[T], a2: Array3d[T]): void =
    if a1.data == a2.data: return
    `=destroy`(a1)
    `=wasMoved`(a1)
    a1.sizeX = a2.sizeX
    a1.sizeY = a2.sizeY
    a1.sizeZ = a2.sizeZ
    if a2.data != nil:
        a1.data = cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(uint(a2.sizeX) * uint(a2.sizeY))))
        for i in 0..<(a2.sizeX * a2.sizeY * a2.sizeZ):
            a1.data[i] = a2.data[i]

proc `=dup`*[T](a: Array3d[T]): Array3d[T] =
    result = newArray3d[T](a.sizeX, a.sizeY, a.sizeZ)
    if a.data != nil:
        result.data = cast[ptr UncheckedArray[T]](alloc0(sizeof(T) * int(uint(a.sizeX) * uint(a.sizeY))))
        for i in 0..<(a.sizeX * a.sizeY * a.sizeZ):
            result.data[i] = `=dup`(a.data[i])

proc `=sink`*[T](a1: var Array3d[T], a2: Array3d[T]): void =
    `=destroy`(a1)
    a1.sizeX = a2.sizeX
    a1.sizeY = a2.sizeY
    a1.sizeZ = a2.sizeZ
    a1.data = a2.data


proc `[]`*[T](a: Array3d[T], x, y, z: uint): var T =
    return a.data[x + y * a.sizeX + z * a.sizeX * a.sizeY]

proc `[]`*[T](a: Array3d[T], x, y, z: int): var T =
    return a.data[uint(x) + uint(y) * a.sizeX + uint(z) * a.sizeX * a.sizeY]

proc `[]=`*[T](a: var Array3d[T], x, y, z: uint, val: T) =
    a.data[x + y * a.sizeX + z * a.sizeX * a.sizeY] = val

proc `[]=`*[T](a: var Array3d[T], x, y, z: int, val: T) =
    a.data[uint(x) + uint(y) * a.sizeX + uint(z) * a.sizeX * a.sizeY] = val


proc `[]`*[T](a: Array3d[T], pos: Vector3i): var T =
    return a.data[uint(pos.x) + uint(pos.y) * a.sizeX + uint(pos.z) * a.sizeX * a.sizeY]

proc `[]=`*[T](a: var Array3d[T], pos: Vector3i, val: T) =
    a.data[uint(pos.x) + uint(pos.y) * a.sizeX + uint(pos.z) * a.sizeX * a.sizeY] = val


proc set3d*[T](a: var Array3d[T], x, y, z: Slice[SomeInteger], val: T) =
    for plane in z.a .. z.b:
        for row in y.a .. y.b:
            for col in x.a .. x.b:
                a.data[uint(col) + uint(row) * a.sizeX + uint(plane) * a.sizeX * a.sizeY] = val


proc `$`*[T](a: Array3d[T]): string =
    result &= "[\n"
    for plane in 0..<a.sizeZ:
        result &= "z"
        result &= $plane
        result &= "\n["
        for row in 0..<a.sizeY:
            result &= "["
            for col in 0..<a.sizeX:
                result &= $a.data[uint(col) + uint(row) * a.sizeX + uint(plane) * a.sizeX * a.sizeY]
                result &= ", "
            result &= "],\n"
        result &= "],\n\n"
    result &= "]"


# var a = newArray3d[int](4, 4, 2)
# a.set3d(0..2, 0..3, 0..1, 5)
# a[3, 2, 1] = 10
# echo(a)
# echo(a[2, 3, 0])
# echo(a[3, 2, 1])
