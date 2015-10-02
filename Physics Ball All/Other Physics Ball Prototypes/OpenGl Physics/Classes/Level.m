//
//  Level.m
//  OpenGl Physics
//
//  Created by Matthew French on 12/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Level.h"


@implementation Level
@synthesize world, shapes, player,groundBody,name;
- (id)initLevel:(NSString*)levelName {
	//Create physics world
	[self createPhysicsWorld];
	
	name = levelName;
	shapes = [NSMutableArray new];
	//Load Level
	NSMutableArray* loadData;
	NSString * path = [[NSBundle mainBundle]
					   pathForResource:levelName ofType:@"lvl"];
	loadData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	NSMutableArray* curves = [loadData objectAtIndex:12];
	
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		curve.curve0 = CGPointMake(curve.curve0.x, curve.curve0.y);
		curve.curve1 = CGPointMake(curve.curve1.x, curve.curve1.y);
		curve.curve2 = CGPointMake(curve.curve2.x, curve.curve2.y);
		curve.originalCurve0 = curve.curve0;
		curve.originalCurve1 = curve.curve1;
		curve.originalCurve2 = curve.curve2;
		[curve sync];
		[curve retain];
		
		Shape* shape = [[Shape alloc] initShape:shapeCurve data:curve inWorld:world At:CGPointMake(0, 0)];
		[shapes addObject:shape];
	}
	levelDimensions = CGRectMake(
								 [[loadData objectAtIndex:15] floatValue], [[loadData objectAtIndex:16] floatValue],
								 [[loadData objectAtIndex:17] floatValue], [[loadData objectAtIndex:18] floatValue]);
	CGPoint startxy = CGPointMake([[loadData objectAtIndex:0] floatValue], [[loadData objectAtIndex:1] floatValue]);
	
	
	
	//Update Camera Position
	cameraPos = CGPointMake(-(startxy.x)+480/2, -(startxy.y)+320/2);
	if (startxy.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
	if (startxy.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
	if (startxy.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
	if (startxy.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
	
	
	//Make player
	Circle* circle = [[Circle alloc] initWithRadius:10 colorR:0.0 colorG:0.0 colorB:1.0 colorA:1.0];
	Shape* circleShape = [[Shape alloc] initShape:shapeCircle data:circle inWorld:world At:startxy];
	[shapes addObject:circleShape];
	player = circleShape;
	
	return self;
}

-(void)createPhysicsWorld {
	CGSize screenSize = CGSizeMake(320, 480);
	
	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(0.0f, -9.81f); //Realistic gravity
	
	// Do we want to let bodies sleep?
	// This will speed up the physics simulation
	bool doSleep = FALSE; //If gravity never changes then some objects can sleep
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(gravity, doSleep); //Make world with gravity
	
	world->SetContinuousPhysics(true); //Setting continuous physics
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
}

- (void)tick {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 10;
	int32 positionIterations = 10;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	float time = 1.0/60.0;
    if (lastTime)
    {
        NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastTime;
        time = timeSinceLastDraw;
    }
	world->Step(1.0f/60.0f, velocityIterations, positionIterations);
	lastTime = [NSDate timeIntervalSinceReferenceDate];
	
	CGPoint playerPos = CGPointMake(player.body->GetPosition().x*PTM_RATIO, player.body->GetPosition().y*PTM_RATIO);
	cameraPos = CGPointMake(-(playerPos.x)+480/2, -(playerPos.y)+320/2);
	if (playerPos.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
	if (playerPos.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
	
	if (playerPos.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
	if (playerPos.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
}

- (void)draw {
	for (int i = 0; i < [shapes count];i ++) {
		Shape* shape = [shapes objectAtIndex:i];
		CGPoint position = CGPointMake(shape.body->GetPosition().x*PTM_RATIO+cameraPos.x, shape.body->GetPosition().y*PTM_RATIO+cameraPos.y);
		[shape drawAt:position];
	}
}

- (void)dealloc {
	delete world;
	[super dealloc];
}
@end
