extends Node2D

var points = []
var sticks = []

export var normalColor : Color
export var lockedColor : Color

export var pointsRadius : float
export var lineWidth : float

export var gravity = 200

export var cut = false

var start = false

var lastPressed : Point
var addPoint = true

var pressed = false

var dist = 20
var col = 30
var line = 20

func _init():
	#Tissue Simulation 
	for i in range(col):
		for j in range(line):
			add_point(Vector2(i*dist+dist, j*dist+dist))
			if j>0:
				var stick = Stick.new()
				stick.pointA = points[j-1+i*line]
				stick.pointB = points[j+i*line]
				
				stick.length = stick.pointA.position.distance_to(stick.pointB.position)
				
				sticks.append(stick)
			
			if i>0:
				var stick = Stick.new()
				stick.pointA = points[j+(i-1)*line]
				stick.pointB = points[j+i*line]
				
				stick.length = stick.pointA.position.distance_to(stick.pointB.position)
				
				sticks.append(stick)
	points[line].locked = true
	points[line*(col-2)].locked = true
	points[line*(col/3)].locked = true
	points[line*(col/3*2)].locked = true
	
	pass

func _input(event):
	if not cut:
		if event is InputEventMouseButton and event.is_pressed():
			for p in points:
				if p.position.distance_to(event.position) < pointsRadius:
					lastPressed = p
					break
		
		elif event is InputEventMouseButton:
			if lastPressed != null:
				for p in points:
					if p.position.distance_to(event.position) < pointsRadius:
						if p == lastPressed:
							p.locked = not p.locked
						else:
							var stick = Stick.new()
							stick.pointA = p
							stick.pointB = lastPressed
							
							stick.length = p.position.distance_to(lastPressed.position)
							
							sticks.append(stick)
						addPoint = false
						break
				if addPoint:
					add_point(event.position)
					var stick = Stick.new()
					stick.pointA = points[-1]
					stick.pointB = lastPressed
					
					stick.length = stick.pointA.position.distance_to(lastPressed.position)
					
					sticks.append(stick)
				addPoint = true
				lastPressed = null
			else:
				add_point(event.position)
				
	else:
		if event is InputEventMouseButton and event.is_pressed():
			pressed = true
		elif event is InputEventMouseButton and not event.is_pressed():
			pressed = false
		
		if pressed:
			for s in sticks:
				var stickCenter = (s.pointA.position + s.pointB.position)/2
				if stickCenter.distance_to(event.position) < 10:
					sticks.erase(s)
		
	
	if event is InputEventKey and event.is_pressed():
		start = not start
	
	
func add_point(pos):
	var point = Point.new()
	point.position = pos
	point.prevPosition = point.position
	points.append(point)

func _draw():
	for stick in sticks:
		draw_line(stick.pointA.position, stick.pointB.position, normalColor, lineWidth)
		
	for point in points:
		if point.locked:
			draw_circle(point.position, pointsRadius, lockedColor)
		else:
			draw_circle(point.position, pointsRadius, normalColor)
			
	
	
func _process(delta):
	if start:
		for p in points:
			if not p.locked:
				var positionBeforeUpdate = p.position
				p.position += p.position - p.prevPosition
				p.position += Vector2(0,1)*gravity*delta*delta
				p.prevPosition = positionBeforeUpdate
		
		for i in range(50):
			for s in sticks:
				var stickCenter = (s.pointA.position + s.pointB.position)/2
				var stickDir = (s.pointA.position - s.pointB.position).normalized()
				
				if not s.pointA.locked:
					s.pointA.position = stickCenter + stickDir * s.length /2
				if not s.pointB.locked:
					s.pointB.position = stickCenter - stickDir * s.length /2
		
	update()

