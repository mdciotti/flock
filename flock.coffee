window.requestAnimFrame = do ->
	window.requestAnimationFrame ||
	window.webkitRequestAnimationFrame ||
	window.mozRequestAnimationFrame ||
	(callback) -> window.setTimeout callback, 1000 / 60

class Boid
	constructor: (x, y, z, vx = 0, vy = 0, vz) ->
		@position = new Vector x, y, z
		@velocity = new Vector vx, vy, vz

	getNeighbors: (boids, radiusSq) ->
		boids.filter (b) =>
			@position.distSq(b.position) < radiusSq and b isnt this

flooredDivision = (a, n) -> a - n * Math.floor a / n

class Rule
	constructor: (@weight, fn) ->
		# if fn throw new Error "Rule() requires a corrector function"
		# else @corrector = fn
		@corrector = fn

class Flock

	radiusSq = null

	constructor: (@ctx) ->
		@boids = []
		@rules = []
		@options = {}

	setStage: (opts) ->
		@options.width = opts.width ? 500
		@options.height = opts.height ? 500
		@options.depth = opts.depth ? 500
		@options.cameraPlane = opts.cameraPlane ? 100
		@options.focalLength = opts.focalLength ? 100
		@options.backgroundColor = opts.backgroundColor ? "rgb(0, 0, 0)"
		@options.boidColor = opts.boidColor ? "rgb(180, 180, 180)"
		@options.speedLimit = (opts.speedLimit ? 9) / 3
		@options.radius = opts.radius ? 50
		radiusSq = @options.radius * @options.radius

		@ctx.canvas.width = @options.width
		@ctx.canvas.height = @options.height
		# document.body.style.backgroundColor = @options.backgroundColor
		# @ctx.canvas.style.borderColor = @options.boidColor
		return this

	applyRule: (rule) ->
		# @rules.push(rule) if typeof rule is "function"
		@rules.push rule if rule instanceof Rule
		return this

	updatePositions: () ->
		w = @ctx.canvas.width
		h = @ctx.canvas.height

		for b in @boids
			neighbors = b.getNeighbors @boids, radiusSq

			b.velocity = @rules.reduce (velocity, rule) =>
				velocity.addSelf rule.corrector(b, neighbors).scaleSelf(rule.weight)
			, b.velocity

			# Limit velocity
			if b.velocity.magnitudeSq() > @options.speedLimit * @options.speedLimit
				b.velocity.normalizeSelf().scaleSelf(@options.speedLimit)

			# Bounding box
			lowerMargin = @options.boundary ? 0.2
			upperMargin = 1 - lowerMargin
			factor = 0.05

			if b.position.x < @options.width * lowerMargin
				b.velocity.x += factor
			else if b.position.x > @options.width * upperMargin
				b.velocity.x -= factor

			if b.position.y < @options.height * lowerMargin
				b.velocity.y += factor
			else if b.position.y > @options.height * upperMargin
				b.velocity.y -= factor

			if b.position.z < @options.depth * lowerMargin
				b.velocity.z += factor
			else if b.position.z > @options.depth * upperMargin
				b.velocity.z -= factor

			# TODO: handle dynamic time steps
			b.position.addSelf b.velocity

	render: =>
		@ctx.fillStyle = @options.backgroundColor
		@ctx.fillRect 0, 0, @options.width, @options.height
		@ctx.fillStyle = @options.boidColor

		do @updatePositions

		for b in @boids
			x = b.position.x
			y = b.position.y
			z = b.position.z
			dir = b.velocity.phi() - Math.PI / 2
			foreshortening = 1 - Math.abs(2 * b.velocity.theta() / Math.PI - 1)
			
			# Pinhole camera projection
			scale = 5 * @options.focalLength / (z + @options.cameraPlane)
			fade = 1 - 0.5 * z / @options.depth

			do @ctx.save
			@ctx.globalAlpha = fade
			@ctx.translate x, y
			@ctx.rotate dir
			@ctx.scale scale, scale
			@ctx.scale 1, foreshortening

			do @ctx.beginPath
			@ctx.moveTo 0, 4
			@ctx.lineTo 2, -2
			@ctx.lineTo 0, 0
			@ctx.lineTo -2, -2
			do @ctx.closePath
			do @ctx.fill
			do @ctx.restore

		window.requestAnimFrame @render

	addBoid: (x, y, z, vx = 0, vy = 0, vz = 0) ->
		x ?= @options.width * Math.random()
		y ?= @options.height * Math.random()
		z ?= @options.depth * Math.random()
		@boids.push new Boid x, y, z, vx, vy, vz
		return this

	initialize: (n) ->
		do @addBoid while @boids.length < n
		do @render
		return this

# COHESION: steer to move toward the average position (center of mass) of local flockmates
cohesion = new Rule 0.0005, (boid, neighbors) ->
	correction = new Vector()
	if neighbors.length <= 0 then return correction

	correction.addSelf n.position for n in neighbors

	correction.scaleSelf 1 / neighbors.length
	correction.subtractSelf boid.position
	return correction

# SEPARATION: steer to avoid crowding local flockmates
separation = new Rule 0.01, (boid, neighbors) ->
	correction = new Vector()
	if neighbors.length <= 0 then return correction
	for n in neighbors when boid.position.distSq(n.position) < 100
		correction.subtractSelf n.position.subtract(boid.position)
	return correction

# ALIGNMENT: steer towards the average heading of local flockmates
alignment = new Rule 0.05, (boid, neighbors) ->
	correction = new Vector()
	if neighbors.length <= 0 then return correction
	correction.addSelf n.velocity for n in neighbors
	correction.scaleSelf 1 / neighbors.length
	return correction.subtractSelf boid.velocity

# WIND
wind = (speed, heading) ->
	return new Rule 1, (boid, neighbors) -> new Vector().setPolar(speed / 100, 0, heading)

init = () ->
	canvas = document.createElement "CANVAS"
	canvas.innerText = "You must use an HTML5 compatible browser to view this lab."
	document.body.appendChild canvas
	ctx = canvas.getContext "2d"
	canvas.style.display = "block"
	canvas.style.margin = "0 auto"
	document.body.style.margin = 0
	document.body.style.backgroundColor = "#222222"

	x0 = 0
	y0 = 0

	canvas.addEventListener "mousedown", (e) ->
		x0 = e.clientX - canvas.offsetLeft
		y0 = e.clientY - canvas.offsetTop

	canvas.addEventListener "mouseup", (e) ->
		x = e.clientX - canvas.offsetLeft
		y = e.clientY - canvas.offsetTop
		vx = (x - x0) / 50
		vy = (y - y0) / 50
		vz = 0
		flock.addBoid x0, y0, null, vx, vy, vz

	window.flock = new Flock ctx, 0

	sky = ctx.createLinearGradient 0, 0, 0, 500
	sky.addColorStop 0, "#0072ff"
	sky.addColorStop 1, "#00c6ff"

	flock.setStage
		width: 500
		height: 500
		depth: 500
		cameraPlane: 100
		focalLength: 200
		backgroundColor: sky
		boidColor: "rgb(0,0,0)"

	flock.applyRule cohesion
	flock.applyRule separation
	flock.applyRule alignment
	flock.applyRule wind(0, Math.PI / 2)

	flock.initialize 10

	window.addEventListener "resize", flock.setStage, false
	# window.addEventListener "keydown", flock.render, false

window.addEventListener "load", init, false
