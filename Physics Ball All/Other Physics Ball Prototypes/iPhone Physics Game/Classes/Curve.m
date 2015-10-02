//
//  Curve.m
//  iPad Quartz Vector Drawing
//
//  Created by Matthew French on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Curve.h"


@implementation Curve

@synthesize curve0,curve1,curve2,curvePtX,curvePtY;
- (id)initWithCurves:(CGPoint)pt1 and:(CGPoint)pt2 and:(CGPoint)pt3 {
	self = [super init];
	if (self != nil) {
		curve0 = pt1;
		curve1 = pt2;
		curve2 = pt3;
		
		// getPoints //
		
		float t = 0;
		float steps = 50;
		
		curvePtX = [[NSMutableArray alloc] init];
		curvePtY = [[NSMutableArray alloc] init];
		
		while ( t <= 1 ) {
			
			float t1 = 1 - t;
			float t1_2 = t1 * t1;
			float t2 = t * t;
			float tt12 = 2 * t * t1;
			
			float x = t1_2 * curve0.x + tt12 * curve1.x + t2 * curve2.x-10; //minus the ball radius
			float y = t1_2 * curve0.y + tt12 * curve1.y + t2 * curve2.y-10;
			
			[curvePtX addObject:[NSNumber numberWithFloat:x]];
			[curvePtY addObject:[NSNumber numberWithFloat:y]];
			
			t += 1/steps;
			
		}
		
	}
	return self;
}
-(void) dealloc {
	[curvePtX release];
	[curvePtY release];
	[super dealloc];
}

@end
