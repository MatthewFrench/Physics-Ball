//
//  DrawShape.h
//  OpenGl Physics
//
//  Created by Matthew French on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Box2D/Box2D.h>
#import "QueryCallback.h"
#import "PolyDecompBayazit.h"

#define PTM_RATIO 32 //pixels in a meter, the more pixels = less meters

#define shapeCircle 0
#define shapeRect 1
#define shapeLine 2
#define shapeCurve 3
#define shapePolygon 4

@interface Shape : NSObject {
	int shapeType;
	b2Body* body;
	b2World* world;
	
	float radius;
	float width;
	float height;
	float density,friction,restitution;
	NSString* state;
	
	CGPoint position;
	float rotation;
	
	BOOL sendVel, sendColl, shapeDead;
	
	NSString* name;
}
//@property(nonatomic) int shapeType;
//@property(nonatomic) float radius,width,height, prevRot;
//@property(nonatomic) CGPoint prevPos;
//@property(nonatomic,assign) b2World* world;
//@property(nonatomic,assign) b2Body* body;
- (void)setShapeType:(int)var;
- (int)getShapeType;
- (void)setRadius:(float)var;
- (float)getRadius;
- (void)setWidth:(float)var;
- (float)getWidth;
- (void)setHeight:(float)var;
- (float)getHeight;
- (void)setPosition:(CGPoint)var;
- (CGPoint)getPosition;
- (void)setRotation:(float)var;
- (float)getRotation;
- (void)setWorld:(b2World*)var;
- (b2World*)getWorld;
- (void)setBody:(b2Body *)var;
- (b2Body*)getBody;

- (void)setDensity:(float)var;
- (float)getDensity;
- (void)setFriction:(float)var;
- (float)getFriction;
- (void)setRestitution:(float)var;
- (float)getRestitution;
- (void)setState:(NSString*)var;
- (NSString*)getState;
- (void)setName:(NSString*)var;
- (NSString*)getName;

- (void)setSendVel:(BOOL)var;
- (BOOL)getSendVel;
- (void)setSendColl:(BOOL)var;
- (BOOL)getSendColl;
- (void)setShapeDead:(BOOL)var;
- (BOOL)getShapeDead;

void IFoundAPolygon(PolyDecompBayazit *poly);

- (id)initCircle:(float)rad At:(CGPoint)pos density:(float)d friction:(float)f restitution:(float)r state:(NSString*)s rotation:(float)rot;
- (id)initBox:(float)w height:(float)h At:(CGPoint)pos density:(float)d friction:(float)f restitution:(float)r state:(NSString*)s rotation:(float)rot;
- (id)initPolygon:(NSString*)vertices At:(CGPoint)pos density:(float)d friction:(float)f restitution:(float)r  state:(NSString*)s rotation:(float)rot;

- (void)actualizeShape:(b2World*)theWorld;

- (void)dealloc;

@end
