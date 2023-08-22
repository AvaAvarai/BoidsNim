import opengl/glut, opengl, opengl/glu, math, random

const
    BOID_COUNT = 500
    VIEW_RADIUS = 20.0
    MAX_SPEED = 5.0
    MAX_FORCE = 0.5
    WINDOW_WIDTH = 500.0
    WINDOW_HEIGHT = 500.0
    ALIGNMENT_WEIGHT = 1.2
    COHESION_WEIGHT = 1.0
    SEPARATION_WEIGHT = 1.5
    WALL_MARGIN = 10.0

type
  Vector = tuple[x, y: float32]
  Boid = object
    position: Vector
    velocity: Vector
    acceleration: Vector
    color: float32  # A value between 0.0 (darkest) and 1.0 (brightest)

var boids: array[BOID_COUNT, Boid]

# Utility functions for vector operations
proc add(a, b: Vector): Vector = (x: a.x + b.x, y: a.y + b.y)
proc sub(a, b: Vector): Vector = (x: a.x - b.x, y: a.y - b.y)
proc mult(a: Vector, scalar: float32): Vector = (x: a.x * scalar, y: a.y * scalar)
proc normalize(a: Vector): Vector =
  let mag = float32(sqrt(a.x * a.x + a.y * a.y))
  if mag > 0:
    return (x: a.x / mag, y: a.y / mag)
  return a

# Implement the three rules for boid movement
proc align(boid: Boid): Vector =
  var sum: Vector = (x: 0.0f, y: 0.0f)
  var count = 0
  for other in boids:
    let d = sqrt((boid.position.x - other.position.x)^2 + (boid.position.y - other.position.y)^2)
    if d > 0 and d < VIEW_RADIUS:
      sum = sum.add(other.velocity)
      count += 1
  if count > 0:
    sum = sum.mult(1.0 / count.float32)
    sum = sum.normalize().mult(MAX_SPEED)
    return sum.sub(boid.velocity)
  return (x: 0.0, y: 0.0)

proc cohesion(boid: Boid): Vector =
  var sum: Vector = (x: 0.0f, y: 0.0f)
  var count = 0
  for other in boids:
    let d = sqrt((boid.position.x - other.position.x)^2 + (boid.position.y - other.position.y)^2)
    if d > 0 and d < VIEW_RADIUS:
      sum = sum.add(other.position)
      count += 1
  if count > 0:
    sum = sum.mult(1.0 / count.float32)
    return sum.sub(boid.position).normalize().mult(MAX_SPEED).sub(boid.velocity)
  return (x: 0.0, y: 0.0)

proc separation(boid: Boid): Vector =
  var steer: Vector = (x: 0.0f, y: 0.0f)
  var count = 0
  for other in boids:
    let d = sqrt((boid.position.x - other.position.x)^2 + (boid.position.y - other.position.y)^2)
    if d > 0 and d < VIEW_RADIUS:
      let diff = boid.position.sub(other.position).normalize().mult(1.0 / d)
      steer = steer.add(diff)
      count += 1
  if count > 0:
    steer = steer.mult(1.0 / count.float32)
  if steer.x != 0 or steer.y != 0:
    steer = steer.normalize().mult(MAX_SPEED).sub(boid.velocity)
  return steer

proc avoidWalls(boid: Boid): Vector =
  var steer: Vector = (x: 0.0f, y: 0.0f)

  # Left Wall
  if boid.position.x < WALL_MARGIN:
    steer.x = MAX_SPEED
  # Right Wall
  if boid.position.x > WINDOW_WIDTH - WALL_MARGIN:
    steer.x = -MAX_SPEED
  # Top Wall
  if boid.position.y < WALL_MARGIN:
    steer.y = MAX_SPEED
  # Bottom Wall
  if boid.position.y > WINDOW_HEIGHT - WALL_MARGIN:
    steer.y = -MAX_SPEED

  return steer

proc getOrientation(velocity: Vector): float32 =
  return arctan2(velocity.y, velocity.x)

# Update the boids' movement
proc updateBoid(boid: var Boid) =
  let a = align(boid).normalize().mult(MAX_FORCE)
  let c = cohesion(boid).normalize().mult(MAX_FORCE)
  let s = separation(boid).normalize().mult(MAX_FORCE)
  let w = avoidWalls(boid).normalize().mult(MAX_FORCE)
    
  boid.acceleration = boid.acceleration.add(w)
  boid.acceleration = boid.acceleration.add(a.mult(ALIGNMENT_WEIGHT))
  boid.acceleration = boid.acceleration.add(c.mult(COHESION_WEIGHT))
  boid.acceleration = boid.acceleration.add(s.mult(SEPARATION_WEIGHT))
  boid.velocity = boid.velocity.add(boid.acceleration)
  if sqrt(boid.velocity.x^2 + boid.velocity.y^2) > MAX_SPEED:
    boid.velocity = boid.velocity.normalize().mult(MAX_SPEED)
  boid.position = boid.position.add(boid.velocity)
  boid.acceleration = (x: 0.0, y: 0.0)

# Initialize boids
for i in 0..<BOID_COUNT:
  boids[i] = Boid(
      position: (
          x: (rand(WINDOW_WIDTH).float32 + WALL_MARGIN.float32),
          y: (rand(WINDOW_HEIGHT).float32 + WALL_MARGIN.float32)
      ), 
      velocity: (x: (rand(1.0) - 0.5).float32, y: (rand(1.0) - 0.5).float32), 
      acceleration: (x: 0.0, y: 0.0),
      color: rand(1.0).float32  # Assign a random shade of blue
  )

# Update display function
proc display() {.cdecl.} =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for boid in boids:
    let angle = getOrientation(boid.velocity) * (180.0 / PI)  # Convert radian to degree
    glPushMatrix()
    glTranslatef(boid.position.x, boid.position.y, 0.0)
    glRotatef(angle, 0.0, 0.0, 1.0)  # Rotate around the Z-axis
    glBegin(GL_TRIANGLES)
    glColor3f(0.0, 0.0, boid.color)  
    glVertex2f(-2.5, -2.5)
    glVertex2f(2.5, -2.5)
    glVertex2f(0.0, 2.5)
    glEnd()
    glPopMatrix()
  # render walls
  glColor3f(1.0, 0.0, 0.0) # Red color for walls
  glBegin(GL_LINE_LOOP)
  glVertex2f(WALL_MARGIN, WALL_MARGIN)
  glVertex2f(WINDOW_WIDTH - WALL_MARGIN, WALL_MARGIN)
  glVertex2f(WINDOW_WIDTH - WALL_MARGIN, WINDOW_HEIGHT - WALL_MARGIN)
  glVertex2f(WALL_MARGIN, WINDOW_HEIGHT - WALL_MARGIN)
  glEnd()
  glutSwapBuffers()

# Add an idle function to update boids
proc idle() {.cdecl.} = 
  for boid in boids.mitems():
    updateBoid(boid)
  glutPostRedisplay()


proc reshape(width: GLsizei, height: GLsizei) {.cdecl.} =
  # Compute aspect ratio of the new window
  if height == 0:
    return

  # Set the viewport to cover the new window
  glViewport(0, 0, width, height)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  gluOrtho2D(0.0, WINDOW_WIDTH, 0.0, WINDOW_HEIGHT)
  glDisable(GL_DEPTH_TEST)
  glDisable(GL_CULL_FACE)
  glDisable(GL_LIGHTING)
  glDisable(GL_BLEND)

var argc: cint = 0
glutInit(addr argc, nil)
glutInitDisplayMode(GLUT_DOUBLE)
glutInitWindowSize(int(WINDOW_WIDTH), int(WINDOW_HEIGHT))
discard glutCreateWindow("Boids in Nim with OpenGL and GLUT demo")

glutDisplayFunc(display)
glutIdleFunc(idle)
glutReshapeFunc(reshape)

loadExtensions()

glClearColor(0.0, 0.0, 0.0, 1.0)
glShadeModel(GL_SMOOTH)
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)

glutMainLoop()
