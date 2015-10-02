#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[window setDefaultButtonCell:[newProjectBtn cell]];
}

- (IBAction)newProject:(id)sender {
	[window close];
	[toolsPanel makeKeyAndOrderFront:self];
	[cardWindow makeKeyAndOrderFront:self];
	shapes = [[NSMutableArray alloc] init];
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
	// Define the gravity vector.
	gravity.Set(0.0f, -30.0f); //Realistic gravity
}

- (IBAction)makeBall:(id)sender {
	Shape* shape = [[Shape alloc] initCircle:30 At:CGPointMake(100, 100) density:0.5 friction:0.1 restitution:0.5 state:@"Dynamic" rotation:0.0];
	[shapes addObject:shape];
	[shape release];
	if (physicsOn) {
		[shape actualizeShape:world];
	}
	[shape setName:[NSString stringWithFormat:@"Shape %d",[shapes count]]];
	selectedShape = shape;
	[self updateTextFields];
}
- (IBAction)makeBox:(id)sender {
	Shape* shape = [[Shape alloc] initBox:30 height:30 At:CGPointMake(100, 100) density:0.5 friction:0.1 restitution:0.1 state:@"Dynamic" rotation:0];
	[shapes addObject:shape];
	[shape release];
	if (physicsOn) {
		[shape actualizeShape:world];
	}
	[shape setName:[NSString stringWithFormat:@"Shape %d",[shapes count]]];
	selectedShape = shape;
	[self updateTextFields];
}
- (IBAction)makePolygon:(id)sender {}
- (IBAction)makeRope:(id)sender {}

- (IBAction)openPcFile:(id)sender {
	NSOpenPanel *op = [NSOpenPanel openPanel];
    if ([op runModal] == NSOKButton)
    {
        //NSString *filename = [op filename];
		
    }
}
- (void) tick {
	if (physicsOn) {
		int32 velocityIterations = 24;
		int32 positionIterations = 24;
	
		if (mouseJoint) {
			mouseJoint->SetTarget(b2Vec2(mousePos.x/PTM_RATIO,mousePos.y/PTM_RATIO));
		}
	
		float time = 1.0/(float)FPS;
	
		world->Step(time, velocityIterations, positionIterations);
	}
	
	[mainView setNeedsDisplay:TRUE];
}
- (void) drawScreen {
	// Drawing code
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

	//Draw Origin
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextMoveToPoint(context, (-5)-cameraPos.x, (0)-cameraPos.y);
	CGContextAddLineToPoint(context, (5)-cameraPos.x, (0)-cameraPos.y);
	CGContextStrokePath(context);
	CGContextMoveToPoint(context, (0)-cameraPos.x, (-5)-cameraPos.y);
	CGContextAddLineToPoint(context, (0)-cameraPos.x, (5)-cameraPos.y);
	CGContextStrokePath(context); 
	CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	
	//Draw Circle
	for (int i = 0; i < [shapes count]; i ++) {
		Shape* shape = [shapes objectAtIndex:i];
		
		if ([shape getShapeType] == shapeCircle) {
			
			CGContextSaveGState(context);
			CGContextSetLineWidth(context, 2.0);
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
			CGRect rectangle;
			if (physicsOn) {
				rectangle = CGRectMake([shape getBody]->GetPosition().x*PTM_RATIO-[shape getRadius],[shape getBody]->GetPosition().y*PTM_RATIO-[shape getRadius],[shape getRadius]*2,[shape getRadius]*2);
			} else {
				rectangle = CGRectMake([shape getPosition].x-[shape getRadius],[shape getPosition].y-[shape getRadius],[shape getRadius]*2,[shape getRadius]*2);
			}
			CGContextAddEllipseInRect(context, rectangle);
			CGContextStrokePath(context); 
			CGContextRestoreGState (context);  
			
		} else if ([shape getShapeType] == shapeRect) {
			if (physicsOn) {
				[self drawBox:[shape getHeight] h:[shape getWidth] rotation:[shape getBody]->GetAngle() x:[shape getBody]->GetPosition().x*PTM_RATIO y:[shape getBody]->GetPosition().y*PTM_RATIO];
			} else {
				[self drawBox:[shape getHeight] h:[shape getWidth] rotation:[shape getRotation] x:[shape getPosition].x y:[shape getPosition].y];
			}
		}
	}
}
- (void)createPhysicsWorld:(CGSize)size infinite:(BOOL)infinite {
	// Do we want to let bodies sleep?
	// This will speed up the physics simulation
	bool doSleep = TRUE; //If gravity never changes then some objects can sleep
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(gravity, doSleep); //Make world with gravity
	
	world->SetContinuousPhysics(true); //Setting continuous physics
	
	world->SetAutoClearForces(TRUE);
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
	// Define the ground box shape.
	b2EdgeShape groundBox;
	
	
	b2Filter filter;
	if (!infinite) {
		filter.groupIndex = -1;
	}
	
	// bottom
	groundBox.Set(b2Vec2(0,0), b2Vec2(640/PTM_RATIO,0));
	b2FixtureDef fixDef;
	fixDef.shape = &groundBox;
	fixDef.restitution = 0.0;
	fixDef.friction = 1.0;
	if (!infinite) {
		fixDef.filter = filter;
	}
	groundBody->CreateFixture(&fixDef);
	
	// top
	groundBox.Set(b2Vec2(0,480/PTM_RATIO), b2Vec2(640/PTM_RATIO,480/PTM_RATIO));
	b2FixtureDef fixDef2;
	fixDef2.shape = &groundBox;
	fixDef.restitution = 0.0;
	fixDef.friction = 1.0;
	if (!infinite) {
		fixDef2.filter = filter;
	}
	groundBody->CreateFixture(&fixDef2);
	
	// left
	groundBox.Set(b2Vec2(0,480/PTM_RATIO), b2Vec2(0,0));
	b2FixtureDef fixDef3;
	fixDef3.shape = &groundBox;
	fixDef.restitution = 0.0;
	fixDef.friction = 1.0;
	if (!infinite) {
		fixDef3.filter = filter;
	}
	groundBody->CreateFixture(&fixDef3);		
	// right
	groundBox.Set(b2Vec2(640/PTM_RATIO,480/PTM_RATIO), b2Vec2(640/PTM_RATIO,0));
	b2FixtureDef fixDef4;
	fixDef4.shape = &groundBox;
	fixDef.restitution = 0.0;
	fixDef.friction = 1.0;
	if (!infinite) {
		fixDef4.filter = filter;
	}
	groundBody->CreateFixture(&fixDef4);
}
- (void) makeMouseJoint {
	b2Body* tapBody = NULL;
	
	b2AABB aabb;
	b2Vec2 d = b2Vec2(0.001f, 0.001f);
	aabb.lowerBound = b2Vec2(mousePos.x/PTM_RATIO - 0.001f,(mousePos.y)/PTM_RATIO - 0.001f);
	aabb.upperBound = b2Vec2(mousePos.x/PTM_RATIO + 0.001f,(mousePos.y)/PTM_RATIO + 0.001f);
	
	// Query the world for overlapping shapes.
	QueryCallback callback(b2Vec2(mousePos.x/PTM_RATIO,(mousePos.y)/PTM_RATIO));
	world->QueryAABB(&callback, aabb);
	
	if (callback.m_fixture)
	{	
		tapBody = callback.m_fixture->GetBody();
	}
	
	if (tapBody) {
		b2MouseJointDef md1;
		
		md1.bodyA = groundBody;
		md1.bodyB = tapBody;
		md1.collideConnected = true;
		md1.maxForce = 1000 * tapBody->GetMass();
		md1.target = b2Vec2(mousePos.x/PTM_RATIO,(mousePos.y)/PTM_RATIO);
		mouseJoint = (b2MouseJoint *)world->CreateJoint(&md1);
	}	
}
- (void) destroyMouseJoint {
	if (mouseJoint) {
		world->DestroyJoint(mouseJoint);
		mouseJoint = NULL;
	}	
}

- (IBAction)startPhysics:(id)sender {
	physicsOn = TRUE;
	[self createPhysicsWorld:CGSizeMake(640, 480) infinite:TRUE];
	for (int i = 0; i < [shapes count];i ++) {
		Shape* shape = [shapes objectAtIndex:i];
		[shape actualizeShape:world];
	}
	[self updateTextFields];
	[makeBall setEnabled:FALSE];
	[makePolygon setEnabled:FALSE];
	[makeBox setEnabled:FALSE];
	[makeRope setEnabled:FALSE];
	
	[shapeNameTxt setEnabled:FALSE];
	[shapeFrictionTxt setEnabled:FALSE];
	[shapeDensityTxt setEnabled:FALSE];
	[shapeRestitutionTxt setEnabled:FALSE];
	[shapeTypeTxt setEnabled:FALSE];
	
	[gravityXTxt setEnabled:FALSE];
	[gravityYTxt setEnabled:FALSE];
}
- (IBAction)endPhysics:(id)sender {
	for (int i = 0; i < [shapes count];i ++) {
		Shape* shape = [shapes objectAtIndex:i];
		if ([shape getBody]) {
			world->DestroyBody([shape getBody]);
			[shape setBody:nil];
		}
	}
	delete world;
	physicsOn = FALSE;
	[makeBall setEnabled:TRUE];
	[makePolygon setEnabled:TRUE];
	[makeBox setEnabled:TRUE];
	[makeRope setEnabled:TRUE];
	
	[shapeNameTxt setEnabled:TRUE];
	[shapeFrictionTxt setEnabled:TRUE];
	[shapeDensityTxt setEnabled:TRUE];
	[shapeRestitutionTxt setEnabled:TRUE];
	[shapeTypeTxt setEnabled:TRUE];
	
	[gravityXTxt setEnabled:TRUE];
	[gravityYTxt setEnabled:TRUE];
	[self updateTextFields];
}

- (void)drawHoldCircle:(CGPoint)position {
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	//Draw Circle
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5);
	CGRect rectangle = CGRectMake(position.x - 5+cameraPos.x,position.y - 5+cameraPos.y,10,10);
	CGContextAddEllipseInRect(context, rectangle);
	CGContextStrokePath(context); 
   CGContextRestoreGState (context); 
}
- (void)mouseDown:(NSEvent*)event{
	mousePos = CGPointMake([event locationInWindow].x, [event locationInWindow].y);
	if (physicsOn) {
		[self makeMouseJoint];
		selectedShape = nil;
		for (int i = 0; i < [shapes count]; i ++) {
			Shape* shape = [shapes objectAtIndex:i];
			if ([shape getShapeType] == shapeCircle) {
				if (hypot(mousePos.x-[shape getBody]->GetPosition().x*PTM_RATIO, mousePos.y-[shape getBody]->GetPosition().y*PTM_RATIO)<=[shape getRadius]) {
					selectedShape = shape;
				}
			}
			if ([shape getShapeType] == shapeRect) {
				if (mousePos.x > [shape getBody]->GetPosition().x*PTM_RATIO - [shape getWidth]/2.0 &&
					mousePos.x < [shape getBody]->GetPosition().x*PTM_RATIO + [shape getWidth]/2.0 &&
					mousePos.y > [shape getBody]->GetPosition().y*PTM_RATIO - [shape getHeight]/2.0 &&
					mousePos.y < [shape getBody]->GetPosition().y*PTM_RATIO + [shape getHeight]/2.0) {
					selectedShape = shape;
				}
			}
		}
	} else {
		selectedShape = nil;
		for (int i = 0; i < [shapes count]; i ++) {
			Shape* shape = [shapes objectAtIndex:i];
			if ([shape getShapeType] == shapeCircle) {
				if (hypot(mousePos.x-[shape getPosition].x, mousePos.y-[shape getPosition].y)<=[shape getRadius]) {
					selectedShape = shape;
				}
			}
			if ([shape getShapeType] == shapeRect) {
				if (mousePos.x > [shape getPosition].x - [shape getWidth]/2.0 &&
					mousePos.x < [shape getPosition].x + [shape getWidth]/2.0 &&
					mousePos.y > [shape getPosition].y - [shape getHeight]/2.0 &&
					mousePos.y < [shape getPosition].y + [shape getHeight]/2.0) {
					selectedShape = shape;
				}
			}
		}
	}
	[self updateTextFields];
}
- (void)mouseDragged:(NSEvent*)event{
	mousePos = CGPointMake([event locationInWindow].x, [event locationInWindow].y);
	if (selectedShape && !physicsOn) {
		[selectedShape setPosition:mousePos];
	}
}
- (void)mouseUp:(NSEvent*)event{
	mousePos = CGPointMake([event locationInWindow].x, [event locationInWindow].y);
	if (physicsOn) {
		[self destroyMouseJoint];
	}
}
- (void)keydown:(UniChar)key {
	if (key == NSLeftArrowFunctionKey) {
	}
	if (key == NSRightArrowFunctionKey) {
	}
	if (key == NSUpArrowFunctionKey) {
	}
	if (key == NSDownArrowFunctionKey) {
	}
}
- (void)keyup:(UniChar)key {
	if (key == NSLeftArrowFunctionKey) {
	}
	if (key == NSRightArrowFunctionKey) {
	}
	if (key == NSUpArrowFunctionKey) {
	}
	if (key == NSDownArrowFunctionKey) {
	}
}

- (IBAction)quit:(id)sender {
	[NSApp terminate: nil];
}

- (IBAction)shapeNameTxtChange:(id)sender {
	if (selectedShape && !physicsOn) {
		[selectedShape setName:[shapeNameTxt stringValue]];
	}
}
- (IBAction)shapeFrictionTxtChange:(id)sender {
	if (selectedShape && !physicsOn) {
		[selectedShape setFriction:[shapeFrictionTxt floatValue]];
	}
}
- (IBAction)shapeDensityTxtChange:(id)sender {
	if (selectedShape && !physicsOn) {
		[selectedShape setDensity:[shapeDensityTxt floatValue]];
	}
}
- (IBAction)shapeRotationTxtChange:(id)sender {
	if (selectedShape && !physicsOn) {
		[selectedShape setRotation:[shapeRotationTxt floatValue]*M_PI/180];
	}
}
- (IBAction)shapeRestitutionTxtChange:(id)sender {
	if (selectedShape && !physicsOn) {
		[selectedShape setRestitution:[shapeRestitutionTxt floatValue]];
	}
}
- (IBAction)shapeTypeTxtChange:(id)sender {
	if (selectedShape && !physicsOn) {
		[selectedShape setState:[shapeTypeTxt stringValue]];
	}
}
- (IBAction)gravityXTxtChange:(id)sender {gravity.x = [gravityXTxt floatValue];}
- (IBAction)gravityYTxtChange:(id)sender {gravity.y = [gravityYTxt floatValue];}

- (void)updateTextFields {
	if (selectedShape) {
		[shapeNameTxt setStringValue:[selectedShape getName]];
		[shapeFrictionTxt setStringValue:[NSString stringWithFormat:@"%f",[selectedShape getFriction]]];
		[shapeDensityTxt setStringValue:[NSString stringWithFormat:@"%f",[selectedShape getDensity]]];
		[shapeRotationTxt setStringValue:[NSString stringWithFormat:@"%f",[selectedShape getRotation]*180/M_PI]];
		[shapeRestitutionTxt setStringValue:[NSString stringWithFormat:@"%f",[selectedShape getRestitution]]];
		[shapeTypeTxt setStringValue:[selectedShape getState]];
	} else {
		[shapeNameTxt setStringValue:@""];
		[shapeFrictionTxt setStringValue:@""];
		[shapeDensityTxt setStringValue:@""];
		[shapeRotationTxt setStringValue:@""];
		[shapeRestitutionTxt setStringValue:@""];
		[shapeTypeTxt setStringValue:@""];
	}
	[gravityXTxt setStringValue:[NSString stringWithFormat:@"%f",gravity.x]];
	[gravityYTxt setStringValue:[NSString stringWithFormat:@"%f",gravity.y]];
}

-(void) controlTextDidChange:(NSNotification *)aNotification
{
	if (selectedShape && !physicsOn) {
		[selectedShape setName:[shapeNameTxt stringValue]];
		[selectedShape setFriction:[shapeFrictionTxt floatValue]];
		[selectedShape setDensity:[shapeDensityTxt floatValue]];
		[selectedShape setRotation:[shapeRotationTxt floatValue]*M_PI/180];
		[selectedShape setRestitution:[shapeRestitutionTxt floatValue]];
		[selectedShape setState:[shapeTypeTxt stringValue]];
		gravity.x = [gravityXTxt floatValue];
		gravity.y = [gravityYTxt floatValue];
	}
}

- (void) drawBox:(float)shapew h:(float)shapeh rotation:(float)rot x:(float)x y:(float)y {
	float v1x = -shapew/2.0;
	float v1y = -shapeh/2.0;
	
	float v2x = shapew/2.0;
	float v2y = -shapeh/2.0;
	
	float v3x = shapew/2.0;
	float v3y = shapeh/2.0;
	
	float v4x = -shapew/2.0;
	float v4y = shapeh/2.0;
	
	float r1x = (cos(rot) * (v1x)) - (sin(rot) * (v1y)) + x;
	float r1y = (sin(rot) * (v1x)) + (cos(rot) * (v1y)) + y;
		
	float r2x = (cos(rot) * (v2x)) - (sin(rot) * (v2y)) + x;
	float r2y = (sin(rot) * (v2x)) + (cos(rot) * (v2y)) + y;
	
	float r3x = (cos(rot) * (v3x)) - (sin(rot) * (v3y)) + x;
	float r3y = (sin(rot) * (v3x)) + (cos(rot) * (v3y)) + y;
	
	float r4x = (cos(rot) * (v4x)) - (sin(rot) * (v4y)) + x;
	float r4y = (sin(rot) * (v4x)) + (cos(rot) * (v4y)) + y;
	
	// Drawing code
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	
	//Draw Origin
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 1.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
	
	CGContextMoveToPoint(context, (r1x)-cameraPos.x, (r1y)-cameraPos.y);
	CGContextAddLineToPoint(context, (r2x)-cameraPos.x, (r2y)-cameraPos.y);
	CGContextAddLineToPoint(context, (r3x)-cameraPos.x, (r3y)-cameraPos.y);
	CGContextAddLineToPoint(context, (r4x)-cameraPos.x, (r4y)-cameraPos.y);
	CGContextAddLineToPoint(context, (r1x)-cameraPos.x, (r1y)-cameraPos.y);
	
	CGContextStrokePath(context);
	CGContextRestoreGState (context);
}

@end
