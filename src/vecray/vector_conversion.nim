import vector2, vector3


proc to2_xy*(v: Vector3f): Vector2f = return Vector2f(x: v.x, y: v.y)
proc to2_xz*(v: Vector3f): Vector2f = return Vector2f(x: v.x, y: v.z)
proc to2_yz*(v: Vector3f): Vector2f = return Vector2f(x: v.y, y: v.z)

proc to2_xy*(v: Vector3i): Vector2i = return Vector2i(x: v.x, y: v.y)
proc to2_xz*(v: Vector3i): Vector2i = return Vector2i(x: v.x, y: v.z)
proc to2_yz*(v: Vector3i): Vector2i = return Vector2i(x: v.y, y: v.z)

proc to2_xy*(v: Vector3b): Vector2b = return Vector2b(x: v.x, y: v.y)
proc to2_xz*(v: Vector3b): Vector2b = return Vector2b(x: v.x, y: v.z)
proc to2_yz*(v: Vector3b): Vector2b = return Vector2b(x: v.y, y: v.z)


proc to3_xy0*(v: Vector2f): Vector3f = return Vector3f(x: v.x, y: v.y, z: 0)
proc to3_x0y*(v: Vector2f): Vector3f = return Vector3f(x: v.x, y: 0, z: v.y)
proc to3_0xy*(v: Vector2f): Vector3f = return Vector3f(x: 0, y: v.x, z: v.y)

proc to3_xy0*(v: Vector2i): Vector3i = return Vector3i(x: v.x, y: v.y, z: 0)
proc to3_x0y*(v: Vector2i): Vector3i = return Vector3i(x: v.x, y: 0, z: v.y)
proc to3_0xy*(v: Vector2i): Vector3i = return Vector3i(x: 0, y: v.x, z: v.y)

proc to3_xy0*(v: Vector2b): Vector3b = return Vector3b(x: v.x, y: v.y, z: false)
proc to3_x0y*(v: Vector2b): Vector3b = return Vector3b(x: v.x, y: false, z: v.y)
proc to3_0xy*(v: Vector2b): Vector3b = return Vector3b(x: false, y: v.x, z: v.y)


converter vec3_from_vec2_xy0*(v: Vector2f): Vector3f = return to3_xy0(v)
converter vec3_from_vec2_xy0*(v: Vector2i): Vector3i = return to3_xy0(v)
converter vec3_from_vec2_xy0*(v: Vector2b): Vector3b = return to3_xy0(v)
