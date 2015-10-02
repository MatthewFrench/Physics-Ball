//
//  DrawShape.h
//  OpenGl Physics
//
//  Created by Matthew French on 12/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "Image.h"
#import <Box2D/Box2D.h>
#import "QueryCallback.h"
#import "Curve.h"
#import "Circle.h"

#define PTM_RATIO 120 //pixels in a meter, the more pixels = less meters

#define shapeCircle 0
#define shapeRect 1
#define shapeLine 2
#define shapeCurve 3
#define shapeTexture 4

@interface Shape : NSObject {
	int shapeType;
	BOOL staticShape;
	NSObject* data;
	b2Body* body;
	b2World* world;
}
@property(nonatomic,assign) NSObject* data;
@property(nonatomic) int shapeType;
@property(nonatomic) BOOL staticShape;
@property(nonatomic,assign) b2World* world;
@property(nonatomic,assign) b2Body* body;

- (id)initShape:(int)type data:(NSObject*)shapeData inWorld:(b2World*)theWorld At:(CGPoint)position;
- (void)drawAt:(CGPoint)position;

@end
