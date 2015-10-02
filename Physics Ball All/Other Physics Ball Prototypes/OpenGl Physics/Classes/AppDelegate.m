#import "AppDelegate.h"
#import "EAGLView.h"

@implementation AppDelegate

@synthesize window,glView;

- (void)timerTick {
	[level tick];
	[glView drawView];
}
- (void)draw {
	[level draw];
}
- (void)touchBegan:(CGPoint)pos {}
- (void)touchMoved:(CGPoint)pos {}
- (void)touchEnded:(CGPoint)pos {}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//Configure and start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60.0)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];

	level = [[Level alloc] initLevel:@"Level"];
	[glView startAnimation];
}
/**
-(void)addPhysicalBodyForRect:(CGSize)size At:(CGPoint)p Color:(float[])color
{
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	CGPoint boxDimensions = CGPointMake(size.width/PTM_RATIO/2.0,size.height/PTM_RATIO/2.0);
	
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	
	Image* texture = [[Image alloc] initWithTexture:[[Texture2D alloc] initWithRect:size color:color]];
	Shape* shape = [Shape alloc];
	shape.shapeType = shapeTexture;
	shape.texture = texture;
	bodyDef.userData = shape;
	
	// Tell the physics world to create the body
	b2Body *body = world->CreateBody(&bodyDef);
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	
	dynamicBox.SetAsBox(boxDimensions.x, boxDimensions.y);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	fixtureDef.restitution = 0.5f; // 0 is a lead ball, 1 is a super bouncy ball
	body->CreateFixture(&fixtureDef);
	
	// a dynamic body reacts to forces right away
	body->SetType(b2_dynamicBody);
}
-(void)addPhysicalBodyForCircle:(float)radius At:(CGPoint)p Color:(float[])color
{
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	
	Image* texture = [[Image alloc] initWithTexture:[[Texture2D alloc] initWithCircle:radius color:color]];
	Shape* shape = [Shape alloc];
	shape.shapeType = shapeTexture;
	shape.texture = texture;
	bodyDef.userData = shape;
	playerTexture = texture;
	
	// Tell the physics world to create the body
	b2Body *body = world->CreateBody(&bodyDef);
	// Define another box shape for our dynamic body.
	b2CircleShape circle;
	circle.m_radius = radius/PTM_RATIO;
	player = body;
	
	b2FixtureDef ballShapeDef;
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 1.0f;
	ballShapeDef.friction = 0.2f;
	ballShapeDef.restitution = 0.5f;
	body->CreateFixture(&ballShapeDef);
}
-(void)addPhysicalBodyForLine:(CGPoint)from To:(CGPoint)to Color:(float[])color
{	
	// Define the dynamic body.
	b2BodyDef bodyDef;
	//bodyDef.position.Set(from.x/PTM_RATIO, from.y/PTM_RATIO);
	
	Shape* drawShape = [Shape alloc];
	drawShape.shapeType = shapeLine;
	drawShape.staticShape = TRUE;
	drawShape.fromVert = from;
	drawShape.toVert = to;
	drawShape.colorR = color[0];
	drawShape.colorG = color[1];
	drawShape.colorB = color[2];
	drawShape.colorA = color[3];
	bodyDef.userData = drawShape;
	
	// Tell the physics world to create the body
	b2Body *body = world->CreateBody(&bodyDef);
	
	
	
	
	b2LoopShape shape;
	b2Vec2 list[] = {b2Vec2(from.x/PTM_RATIO,from.y/PTM_RATIO),b2Vec2(to.x/PTM_RATIO,to.y/PTM_RATIO)};
	shape.Create(list, 2);
	
	b2FixtureDef loopShapeDef;
	loopShapeDef.shape = &shape;
	//loopShapeDef.density = 1.0f;
	//loopShapeDef.friction = 0.2f;
	//loopShapeDef.restitution = 0.8f;
	body->CreateFixture(&loopShapeDef);
}
**/
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	b2Vec2 gravity;
	gravity.Set( -acceleration.y * 9.81,  -9.81f );
	
	level.world->SetGravity(gravity);
}

- (void) applicationWillResignActive:(UIApplication *)application {
	[glView stopAnimation];
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
	[glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[glView stopAnimation];
}

- (void) dealloc {	
	[level release];
	[window release];
	[glView release];
	
	[super dealloc];
}

@end
