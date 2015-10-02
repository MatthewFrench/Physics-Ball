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

@synthesize curve0,curve1,curve2,curvePtX,curvePtY,type,originalCurve0,originalCurve1,originalCurve2,snapped,snap0,snap1,snap2,snap3,snap4,
snap5,xBounds,yBounds,layer;
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
	if (curve2.x < xBounds.x) {xBounds.x = floor(curve2.x);}
	if (curve2.x > xBounds.y) {xBounds.y = ceil(curve2.x);}
	if (curve2.y < yBounds.x) {yBounds.x = floor(curve2.y);}
	if (curve2.y > yBounds.y) {yBounds.y = ceil(curve2.y);}
	
	//Optimize points
	//Go through each point, get angle degree of first to second and second to third. If the 2 slopes are close enough then get rid of point 2.
	float originalDegree;
	BOOL usingOriginal = FALSE;
	for (int i = 0; i < [curvePtX count]; i ++) {
		CGPoint point1 = CGPointMake([[curvePtX objectAtIndex: i] floatValue], [[curvePtY objectAtIndex: i] floatValue]);
		if (i + 2 < [curvePtX count]) {
			CGPoint point2 = CGPointMake([[curvePtX objectAtIndex: i+1] floatValue], [[curvePtY objectAtIndex: i+1] floatValue]);
			CGPoint point3 = CGPointMake([[curvePtX objectAtIndex: i+2] floatValue], [[curvePtY objectAtIndex: i+2] floatValue]);
			float slope1 = atan2(point2.y-point1.y, point2.x-point1.x)/M_PI*180;
			float slope2 = atan2(point3.y-point2.y, point3.x-point2.x)/M_PI*180;
			if (slope1 > 170 && slope2 < -170) {slope2 += 360;}
			if (slope2 > 170 && slope1 < -170) {slope1 += 360;}
			if (usingOriginal) {slope1 = originalDegree;}
			if (fabs(slope1 - slope2) < 10) {
				originalDegree = slope1;
				usingOriginal = TRUE;
				[curvePtX removeObjectAtIndex:i+1];
				[curvePtY removeObjectAtIndex:i+1];
				i -= 1;
			} else {
				usingOriginal = FALSE;
			}
		}
	}
	
	[curvePtX insertObject:[NSNumber numberWithFloat:curve0.x] atIndex:0];
	[curvePtY insertObject:[NSNumber numberWithFloat:curve0.y] atIndex:0];
	[curvePtX addObject:[NSNumber numberWithFloat:curve2.x]];
	[curvePtY addObject:[NSNumber numberWithFloat:curve2.y]];
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
};
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{
	/** For comparing physics lines to drawing curves
	CGContextSetLineWidth(theContext, 2.0);
	CGContextSetRGBStrokeColor(theContext, 1.0, 0.0, 0.0, 1.0);
	CGContextMoveToPoint(theContext, [[curvePtX objectAtIndex: 0] floatValue] - xBounds.x, [[curvePtY objectAtIndex: 0] floatValue] - yBounds.x);
	for (int i = 1; i < [curvePtX count];i++) {
		CGPoint point = CGPointMake([[curvePtX objectAtIndex: i] floatValue] - xBounds.x, [[curvePtY objectAtIndex: i] floatValue] - yBounds.x);
		CGContextAddLineToPoint(theContext, point.x, point.y);
	}
	CGContextStrokePath(theContext);
	 **/
	
	CGPoint point0 = CGPointMake(curve0.x - xBounds.x, curve0.y - yBounds.x);
	CGPoint point1 = CGPointMake(curve1.x - xBounds.x, curve1.y - yBounds.x);
	CGPoint point2 = CGPointMake(curve2.x - xBounds.x, curve2.y - yBounds.x);

	//Draw Bezier Curve
	CGContextSetLineWidth(theContext, 2.0);
	
	if (type == lineReg) {
		CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 1.0, 1.0);
	} else if (type == lineRed) {
		CGContextSetRGBStrokeColor(theContext, 1.0, 0.0, 0.0, 1.0);
	} else if (type == lineInvis) {
			CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 0.0, 0.0);
	} else if (type == lineImag) {
			CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 0.8, 1.0);
	} else if (type == lineBounce) {
		CGContextSetRGBStrokeColor(theContext, 0.0, 1.0, 0.0, 1.0);
	} else if (type == lineBend) {
		CGContextSetRGBStrokeColor(theContext, 0.5, 0.2, 0.0, 1.0);
	}
	if (!snapped) {
		CGContextSaveGState(theContext);
		CGContextMoveToPoint(theContext, point0.x, point0.y);
		
		CGContextAddQuadCurveToPoint(theContext, point1.x, point1.y, point2.x, point2.y);
		
		CGContextStrokePath(theContext);
		CGContextRestoreGState (theContext);
	} else {
		CGContextSaveGState(theContext);
		CGContextMoveToPoint(theContext, snap0.x - xBounds.x, snap0.y - yBounds.x);
		
		CGContextAddQuadCurveToPoint(theContext, snap1.x - xBounds.x, snap1.y - yBounds.x, snap2.x - xBounds.x, snap2.y - yBounds.x);
		
		CGContextStrokePath(theContext);
		
		CGContextMoveToPoint(theContext, snap3.x - xBounds.x, snap3.y - yBounds.x);
		
		CGContextAddQuadCurveToPoint(theContext, snap4.x - xBounds.x, snap4.y - yBounds.x, snap5.x - xBounds.x, snap5.y - yBounds.x);
		
		CGContextStrokePath(theContext);
		CGContextRestoreGState (theContext);
	}
	
	float pointrad = 1.0/8.0;
	CGContextSaveGState(theContext);
	CGRect rectangle = CGRectMake(point0.x-pointrad,point0.y-pointrad,pointrad*2,pointrad*2);
	CGContextAddEllipseInRect(theContext, rectangle);
	CGContextStrokePath(theContext); 
	
	
	rectangle = CGRectMake(point2.x-pointrad,point2.y-pointrad,pointrad*2,pointrad*2);
	CGContextAddEllipseInRect(theContext, rectangle);
	CGContextStrokePath(theContext);
	CGContextRestoreGState (theContext);
	 
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
	
	
	layer = [CALayer layer];
	[layer retain];
	layer.bounds = CGRectMake(-5, -5, xBounds.y - xBounds.x + 10, yBounds.y - yBounds.x + 10);
	[layer setAnchorPoint:CGPointMake(0, 0)];
	[layer setDelegate:self];
	layer.rasterizationScale = [[UIScreen mainScreen] scale];
	layer.contentsScale = [UIScreen mainScreen].scale;
    return self;
}
-(void) dealloc {
	[layer removeFromSuperlayer];
	[layer release];
	[curvePtX removeAllObjects];
	[curvePtX release];
	[curvePtY removeAllObjects];
	[curvePtY release];
	[super dealloc];
}

@end
