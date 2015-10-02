//
//  DrawShape.m
//  OpenGl Physics
//
//  Created by Matthew French on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Shape.h"


@implementation Shape
@synthesize shapeType,staticShape,data,world,body;

- (id)initShape:(int)type data:(NSObject*)shapeData inWorld:(b2World*)theWorld At:(CGPoint)position {
	shapeType = type;
	data = shapeData;
	world = theWorld;
	
	if (shapeType == shapeCurve) {
		Curve* curve = (Curve*)shapeData;
		
		b2BodyDef bodyDef;
		bodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO); 
		
		// Tell the physics world to create the body
		body = world->CreateBody(&bodyDef);
		
		b2LoopShape shape;
        b2Vec2 *list = new b2Vec2[[curve.curvePtX count]];
        
		for (int j = 1; j < [curve.curvePtX count]-1; j++) {
			list[j] = b2Vec2([[curve.curvePtX objectAtIndex:j] floatValue]/PTM_RATIO,[[curve.curvePtY objectAtIndex:j] floatValue]/PTM_RATIO);
		}
		shape.Create(list, [curve.curvePtX count]);
		
		b2FixtureDef loopShapeDef;
		loopShapeDef.shape = &shape;
		//loopShapeDef.density = 1.0f;
		//loopShapeDef.friction = 0.2f;
		//loopShapeDef.restitution = 0.8f;
		body->CreateFixture(&loopShapeDef);
	}
	if (shapeType == shapeCircle) {
		Circle* circle = (Circle*)shapeData;
		
		// Define the dynamic body.
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
		
		// Tell the physics world to create the body
		body = world->CreateBody(&bodyDef);
		// Define another box shape for our dynamic body.
		b2CircleShape circleShape;
		circleShape.m_radius = circle.radius/PTM_RATIO;
		
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circleShape;
		ballShapeDef.density = 1.0f;
		ballShapeDef.friction = 0.2f;
		ballShapeDef.restitution = 0.5f;
		body->CreateFixture(&ballShapeDef);
	}
	return self;
}

- (void)drawAt:(CGPoint)position {
	if (shapeType == shapeCurve) {
		Curve* curve = (Curve*)data;
		[curve drawAt:position];
	}
	if (shapeType == shapeCircle) {
		Circle* circle = (Circle*)data;
		[circle drawAt:position];
	}
}

@end
