//
//  DrawShape.m
//  OpenGl Physics
//
//  Created by Matthew French on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Shape.h"

@implementation Shape
//@synthesize shapeType,world,body,radius,width,height,prevPos,prevRot;
- (id)initCircle:(float)rad At:(CGPoint)pos density:(float)d friction:(float)f restitution:(float)r state:(NSString*)s rotation:(float)rot {
	shapeType = shapeCircle;
	radius = rad;
	density = d;
	friction = f;
	restitution = r;
	state = s;
	rotation = rot;
	position = pos;
	return self;
}
- (id)initBox:(float)w height:(float)h At:(CGPoint)pos density:(float)d friction:(float)f restitution:(float)r state:(NSString*)s rotation:(float)rot {
	shapeType = shapeRect;
	width = w;
	height = h;
	density = d;
	friction = f;
	restitution = r;
	state = s;
	rotation = rot;
	position = pos;
	return self;
}
std::vector<std::vector<b2Vec2> > polygons;
- (id)initPolygon:(NSString*)vertices At:(CGPoint)pos density:(float)d friction:(float)f restitution:(float)r  state:(NSString*)s rotation:(float)rot {
	shapeType = shapePolygon;
	density = d;
	friction = f;
	restitution = r;
	state = s;
	rotation = rot;
	position = pos;
	return self;
}
void IFoundAPolygon(PolyDecompBayazit *poly) {
	//poly->points
	polygons.push_back(poly->points);
}
- (void)actualizeShape:(b2World*)theWorld {
	world = theWorld;
	if (shapeType == shapeCircle) {
		// Define the dynamic body.
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		if ([[state lowercaseString] isEqualToString:@"kinematic"]) {bodyDef.type = b2_kinematicBody;}
		if ([[state lowercaseString] isEqualToString:@"dynamic"]) {bodyDef.type = b2_dynamicBody;}
		if ([[state lowercaseString] isEqualToString:@"static"]) {bodyDef.type = b2_staticBody;}
		
		bodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
		bodyDef.angle = rotation;
		// Tell the physics world to create the body
		body = world->CreateBody(&bodyDef);
		// Define another box shape for our dynamic body.
		b2CircleShape circleShape;
		circleShape.m_radius = radius/PTM_RATIO;
		
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circleShape;
		ballShapeDef.density = density;
		ballShapeDef.friction = friction;
		ballShapeDef.restitution = restitution;
		body->CreateFixture(&ballShapeDef);
		body->SetSleepingAllowed(TRUE);
		body->SetUserData(self);
		shapeDead = FALSE;
		if (radius < 10) {
			//body->SetBullet(TRUE);
		}
	}
	if (shapeType == shapeRect) {
		// Create paddle body
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		if ([[state lowercaseString] isEqualToString:@"kinematic"]) {bodyDef.type = b2_kinematicBody;}
		if ([[state lowercaseString] isEqualToString:@"dynamic"]) {bodyDef.type = b2_dynamicBody;}
		if ([[state lowercaseString] isEqualToString:@"static"]) {bodyDef.type = b2_staticBody;}
		bodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
		bodyDef.angle = rotation;
		body = world->CreateBody(&bodyDef);
		
		// Create paddle shape
		b2PolygonShape dynamicBox;
		dynamicBox.SetAsBox(width/(float)PTM_RATIO/2.0-0.01/2.0, 
							height/(float)PTM_RATIO/2.0-0.01/2.0);
		
		// Create shape definition and add to body
		b2FixtureDef fixtureDef;
		fixtureDef.shape = &dynamicBox;
		fixtureDef.density = density;
		fixtureDef.friction = friction;
		fixtureDef.restitution = restitution;
		body->CreateFixture(&fixtureDef);
		body->SetSleepingAllowed(TRUE);
		body->SetUserData(self);
		shapeDead = FALSE;
		if (width < 25 || height < 25) {
			//body->SetBullet(TRUE);
		}
	}
	if (shapeType == shapePolygon) {
		/*
		 // Create paddle body
		 b2BodyDef bodyDef;
		 bodyDef.type = b2_dynamicBody;
		 if ([[s lowercaseString] isEqualToString:@"kinematic"]) {bodyDef.type = b2_kinematicBody;}
		 if ([[s lowercaseString] isEqualToString:@"dynamic"]) {bodyDef.type = b2_dynamicBody;}
		 if ([[s lowercaseString] isEqualToString:@"static"]) {bodyDef.type = b2_staticBody;}
		 bodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
		 bodyDef.angle = rot;
		 body = world->CreateBody(&bodyDef);
		 
		 NSArray *chunks = [vertices componentsSeparatedByString: @";"];
		 //b2Vec2 vert[[chunks count]];
		 std::vector<b2Vec2> vert;
		 for (int i = 0; i < [chunks count]; i ++) {
		 NSArray *chips = [[chunks objectAtIndex:i] componentsSeparatedByString: @","];
		 vert.push_back(b2Vec2([[chips objectAtIndex:0] floatValue]/PTM_RATIO,[[chips objectAtIndex:1] floatValue]/PTM_RATIO));
		 }
		 
		 PolyDecompBayazit bayazit = PolyDecompBayazit(vert);
		 bayazit.decompose(IFoundAPolygon, 0);
		 for (int i = 0; i < polygons.size(); i++) {
		 std::vector<b2Vec2> poly = polygons[i];
		 b2Vec2 points[polygons[i].size()];
		 for (int j = 0; j < poly.size(); j++) {
		 points[j] = poly[j];
		 }
		 //Add points
		 b2PolygonShape dynamicBox;
		 dynamicBox.Set(points, poly.size());
		 // Create shape definition and add to body
		 b2FixtureDef fixtureDef;
		 fixtureDef.shape = &dynamicBox;
		 fixtureDef.density = d;
		 fixtureDef.friction = f;
		 fixtureDef.restitution = r;
		 body->CreateFixture(&fixtureDef);
		 }
		 polygons.clear();
		 
		 body->SetSleepingAllowed(TRUE);
		 body->SetUserData(self);
		 shapeDead = FALSE;
		 if (width < 25 || height < 25) {
		 //body->SetBullet(TRUE);
		 }
		 
		 */
	}
}

- (void)dealloc {
	if (body) {world->DestroyBody(body); body = nil;}
	[super dealloc];
}


- (void)setShapeType:(int)var {shapeType = var;}
- (int)getShapeType {return shapeType;}
- (void)setRadius:(float)var {radius = var;}
- (float)getRadius {return radius;}
- (void)setWidth:(float)var {width = var;}
- (float)getWidth {return width;}
- (void)setHeight:(float)var {height = var;}
- (float)getHeight {return height;}
- (void)setPosition:(CGPoint)var {position = var;}
- (CGPoint)getPosition {return position;}
- (void)setRotation:(float)var {rotation = var;}
- (float)getRotation {return rotation;}
- (void)setWorld:(b2World*)var {world = var;}
- (b2World*)getWorld {return world;}
- (void)setBody:(b2Body *)var {body = var;}
- (b2Body*)getBody {return body;}
- (void)setSendVel:(BOOL)var {sendVel = var;}
- (BOOL)getSendVel {return sendVel;}
- (void)setSendColl:(BOOL)var {sendColl = var;}
- (BOOL)getSendColl {return sendColl;}
- (void)setShapeDead:(BOOL)var {shapeDead = var;}
- (BOOL)getShapeDead {return shapeDead;}

- (void)setDensity:(float)var {density = var;}
- (float)getDensity {return density;}
- (void)setFriction:(float)var {friction = var;}
- (float)getFriction {return friction;}
- (void)setRestitution:(float)var {restitution = var;}
- (float)getRestitution {return restitution;}
- (void)setState:(NSString*)var {
	if (state) {[state release];}
	state = var; 
	[state retain];
}
- (NSString*)getState {
	return state;
}
- (void)setName:(NSString*)var {
	if (name) {[name release];}
	name = var; 
	[name retain];
}
- (NSString*)getName {return name;}
@end
