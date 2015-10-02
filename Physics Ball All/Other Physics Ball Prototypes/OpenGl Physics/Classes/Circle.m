//
//  Circle.m
//  OpenGl Physics
//
//  Created by Matthew French on 12/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Circle.h"


@implementation Circle
@synthesize radius, colorR, colorG, colorB, colorA;
- (id)initWithRadius:(float)rad colorR:(float)r colorG:(float)g colorB:(float)b colorA:(float)a {
	radius = rad;
	colorR = r;
	colorG = g;
	colorB = b;
	colorA = a;
	float color[] = {r,g,b,a};
	texture = [[Image alloc] initWithTexture:[[Texture2D alloc] initWithCircle:radius color:color]];
	return self;
}
- (void)drawAt:(CGPoint)position {
	[texture renderAtPoint:position];
}
@end
