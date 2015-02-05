class Vector
    constructor: (@x = 0, @y = 0, @z = 0) ->

    set: (@x, @y, @z) -> @

    transform: (fn, args) ->
        new Vector fn.apply(null, [@x].concat(args)),
            fn.apply(null, [@y].concat(args)),
            fn.apply(null, [@z].concat(args))

    transformSelf: (fn, args) ->
        @x = fn.apply(null, [@x].concat(args))
        @y = fn.apply(null, [@y].concat(args))
        @z = fn.apply(null, [@z].concat(args))
        @

    setPolar: (r, phi, theta) ->
        @x = r * Math.sin(theta) * Math.cos(phi)
        @y = r * Math.sin(theta) * Math.sin(phi)
        @z = r * Math.cos(theta)
        @

    add: (v) -> new Vector(@x + v.x, @y + v.y, @z + v.z)

    subtract: (v) -> new Vector(@x - v.x, @y - v.y, @z - v.z)

    scale: (s) -> new Vector(@x * s, @y * s, @z * s)

    magnitude: () -> Math.sqrt(@x * @x + @y * @y + @z * @z)

    magnitudeSq: () -> @x * @x + @y * @y + @z * @z

    midpoint: (v) -> @add(v).scale(0.5)

    normalize: () ->
        iMag = 1 / @magnitude()
        new Vector(@x * iMag, @y * iMag, @z * iMag)

    dot: (v) -> @x * v.x + @y * v.y + @z * v.z

    cross: (v) ->
        new Vector(@y * v.z - @z * v.y, @x * v.z - @z * v.x, @x * v.y - @y * v.x)

    radius: @magnitude

    phi: () -> Math.atan2 @y, @x

    theta: () ->
        mag = @magnitude()
        if mag is 0 then 0 else Math.acos @z / mag

    copy: (v) -> new Vector(v.x, v.y, v.z)

    dist: (v) ->
        dx = v.x - @x
        dy = v.y - @y
        dz = v.z - @z
        Math.sqrt(dx*dx + dy*dy + dz*dz)

    distSq: (v) ->
        dx = v.x - @x
        dy = v.y - @y
        dz = v.z - @z
        dx*dx + dy*dy + dz*dz

    addSelf: (v) ->
        @x += v.x
        @y += v.y
        @z += v.z
        @

    subtractSelf: (v) ->
        @x -= v.x
        @y -= v.y
        @z -= v.z
        @

    scaleSelf: (k) ->
        @x *= k
        @y *= k
        @z *= k
        @

    zero: () ->
        @x = 0
        @y = 0
        @z = 0
        @

    normalizeSelf: () ->
        iMag = 1 / @magnitude()
        @x *= iMag
        @y *= iMag
        @z *= iMag
        @

    distToXAxis: () -> Math.sqrt z * z + y * y
    distSqToXAxis: () -> z * z + y * y

    distToYAxis: () -> Math.sqrt x * x + z * z
    distSqToYAxis: () -> x * x + z * z

    distToZAxis: () -> Math.sqrt x * x + y * y
    distSqToZAxis: () -> x * x + y * y
