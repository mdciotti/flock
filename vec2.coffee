class Vector
    constructor: (@x = 0, @y = 0) ->

    set: (@x, @y) -> @

    transform: (fn, args) ->
        new Vector(fn.apply(null, [@x].concat(args)),
            fn.apply(null, [@y].concat(args)))

    transformSelf: (fn, args) ->
        @x = fn.apply(null, [@x].concat(args))
        @y = fn.apply(null, [@y].concat(args))
        @

    setPolar: (r, theta) ->
        @x = r * Math.cos theta
        @y = r * Math.sin theta
        @

    add: (v) -> new Vector(@x + v.x, @y + v.y)

    subtract: (v) -> new Vector(@x - v.x, @y - v.y)

    scale: (v) -> new Vector(@x * v, @y * v)

    magnitude: () -> Math.sqrt(@x * @x + @y * @y)

    magnitudeSq: () -> @x * @x + @y * @y

    midpoint: (v) ->
        # new Vector(0.5 * (@x + v.x), 0.5 * (@y + v.y));
        @add(v).scale(0.5)

    normalize: () ->
        iMag = 1 / @magnitude()
        new Vector(@x * iMag, @y * iMag)

    # Dot product
    dot: (v) -> @x * v.x + @y * v.y

    # Magnitude of cross product
    crossMag: (v) ->
        # (@magnitude() * v.magnitude()) * Math.sin(@angleFrom(v))
        @x * v.y - @y * v.x

    angle: () ->
        Math.atan2 @y, @x

    angleFrom: (v) ->
        Math.acos(@dot(v) / (@magnitude() * v.magnitude()))

    copy: (v) -> new Vector(v.x, v.y)

    dist: (v) ->
        dx = v.x - @x
        dy = v.y - @y
        Math.sqrt(dx*dx + dy*dy)

    distSq: (v) ->
        dx = v.x - @x
        dy = v.y - @y
        dx*dx + dy*dy

    addSelf: (v) ->
        @x += v.x
        @y += v.y
        @

    subtractSelf: (v) ->
        @x -= v.x
        @y -= v.y
        @

    scaleSelf: (k) ->
        @x *= k
        @y *= k
        @

    zero: () ->
        @x = 0
        @y = 0
        @

    normalizeSelf: () ->
        iMag = 1 / @magnitude()
        @x *= iMag
        @y *= iMag
        @

Vector.add = (a, b) -> new Vector(a.x + b.x, a.y + b.y)
Vector.subtract = (a, b) -> new Vector(a.x - b.x, a.y - b.y)
Vector.scale = (a, k) -> new Vector(k * a.x, k * a.y)
Vector.normalize = (a) -> new Vector(k * a.x, k * a.y)
