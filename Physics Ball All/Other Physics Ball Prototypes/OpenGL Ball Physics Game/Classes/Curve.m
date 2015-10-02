//
//  Curve.m
//  iPad Quartz Vector Drawing
//
//  Created by Matthew French on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Curve.h"
#import "AppDelegate.h"

#define lineReg 0
#define lineRed 1
#define lineInvis 2
#define lineImag 3
#define lineBounce 4
#define lineBend 5

@implementation Curve

@synthesize curve0,curve1,curve2,curvePtX,curvePtY,type,originalCurve0,originalCurve1,
originalCurve2,snapped,snap0,snap1,snap2,snap3,snap4,snap5,xBounds,yBounds;
- (id)initWithCurves:(CGPoint)pt1 and:(CGPoint)pt2 and:(CGPoint)pt3 {
	self = [super init];
	if (self != nil) {
		curve0 = pt1;
		curve1 = pt2;
		curve2 = pt3;
		curvePtX = [[NSMutableArray alloc] init];
		curvePtY = [[NSMutableArray alloc] init];
		type = 0;
		[self sync];
	}
	return self;
}
-(void) sync {
	// getPoints //
	[curvePtX removeAllObjects];
	[curvePtY removeAllObjects];

	float steps = [self bezierLength:curve0 p1:curve1 p2:curve2];
	steps = steps/5;
	
	xBounds = CGPointMake(curve0.x, curve0.x);
	yBounds = CGPointMake(curve0.y, curve0.y);
	
	[curvePtX addObject:[NSNumber numberWithFloat:curve0.x]];
	[curvePtY addObject:[NSNumber numberWithFloat:curve0.y]];
	
	for(float t=0; t <= 1; t += 1.0/steps) {
		float x = (1-t)*(1-t)*curve0.x + 2*(1-t)*t*curve1.x + t*t*curve2.x;
		float y = (1-t)*(1-t)*curve0.y + 2*(1-t)*t*curve1.y + t*t*curve2.y;
		
		[curvePtX addObject:[NSNumber numberWithFloat:x]];
		[curvePtY addObject:[NSNumber numberWithFloat:y]];
		
		if (x < xBounds.x) {xBounds.x = floor(x);}
		if (x > xBounds.y) {xBounds.y = ceil(x);}
		if (y < yBounds.x) {yBounds.x = floor(y);}
		if (y > yBounds.y) {yBounds.y = ceil(y);}
	}
	[curvePtX addObject:[NSNumber numberWithFloat:curve2.x]];
	[curvePtY addObject:[NSNumber numberWithFloat:curve2.y]];
	if (curve2.x < xBounds.x) {xBounds.x = floor(curve2.x);}
	if (curve2.x > xBounds.y) {xBounds.y = ceil(curve2.x);}
	if (curve2.y < yBounds.x) {yBounds.x = floor(curve2.y);}
	if (curve2.y > yBounds.y) {yBounds.y = ceil(curve2.y);}
	
}
-(float) bezierLength:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2
{
	CGPoint a,b;
	a.x = p0.x - 2*p1.x + p2.x;
	a.y = p0.y - 2*p1.y + p2.y;
	b.x = 2*p1.x - 2*p0.x;
	b.y = 2*p1.y - 2*p0.y;
	float A = 4*(a.x*a.x + a.y*a.y);
	float B = 4*(a.x*b.x + a.y*b.y);
	float C = b.x*b.x + b.y*b.y;
	
	float Sabc = 2*sqrt(A+B+C);
	float A_2 = sqrt(A);
	float A_32 = 2*A*A_2;
	float C_2 = 2*sqrt(C);
	float BA = B/A_2;
	
	return ( A_32*Sabc + A_2*B*(Sabc-C_2) + (4*C*A-B*B)*log( (2*A_2+BA+Sabc)/(BA+C_2) ) )/(4*A_32);
}
//encode the data
- (void) encodeWithCoder: (NSCoder *)coder
{   
	[coder encodeObject:[NSNumber numberWithFloat:curve0.x] forKey:@"curve0.x"];
	[coder encodeObject:[NSNumber numberWithFloat:curve0.y] forKey:@"curve0.y"];
	[coder encodeObject:[NSNumber numberWithFloat:curve1.x] forKey:@"curve1.x"];
	[coder encodeObject:[NSNumber numberWithFloat:curve1.y] forKey:@"curve1.y"];
	[coder encodeObject:[NSNumber numberWithFloat:curve2.x] forKey:@"curve2.x"];
	[coder encodeObject:[NSNumber numberWithFloat:curve2.y] forKey:@"curve2.y"];
	[coder encodeObject:[NSNumber numberWithInt:type] forKey:@"type"];
} 
//init from coder
- (id) initWithCoder: (NSCoder *) coder
{
    [self init];
	curvePtX = [[NSMutableArray alloc] init];
	curvePtY = [[NSMutableArray alloc] init];
	curve0.x = [[coder decodeObjectForKey:@"curve0.x"] floatValue];
	curve0.y = [[coder decodeObjectForKey:@"curve0.y"] floatValue];
	curve1.x = [[coder decodeObjectForKey:@"curve1.x"] floatValue];
	curve1.y = [[coder decodeObjectForKey:@"curve1.y"] floatValue];
	curve2.x = [[coder decodeObjectForKey:@"curve2.x"] floatValue];
	curve2.y = [[coder decodeObjectForKey:@"curve2.y"] floatValue];
	
	if ([coder decodeObjectForKey:@"type"]) {
		type = [[coder decodeObjectForKey:@"type"] intValue];
	}
	
	[self sync];
    return self;
}
-(void) dealloc {
	[curvePtX release];
	[curvePtY release];
	[super dealloc];
}

@end
