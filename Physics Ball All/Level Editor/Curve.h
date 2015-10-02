//
//  Curve.h
//  iPad Quartz Vector Drawing
//
//  Created by Matthew French on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

@interface Curve : NSObject {
	CGPoint curve0,curve1,curve2;
	CGPoint originalCurve0,originalCurve1,originalCurve2;
	NSMutableArray *curvePtX,*curvePtY;
	int type;
	BOOL snapped;
	CGPoint snap0,snap1,snap2;
	CGPoint snap3,snap4,snap5;
	
	CGPoint xBounds;
	CGPoint yBounds;
	
}
@property(nonatomic) CGPoint curve0,curve1,curve2, originalCurve0,originalCurve1,originalCurve2;
@property(nonatomic) int type;
@property(nonatomic, assign) NSMutableArray *curvePtX,*curvePtY;
@property(nonatomic) BOOL snapped;
@property(nonatomic) CGPoint snap0,snap1,snap2,snap3,snap4,snap5,xBounds,yBounds;
- (id)initWithCurves:(CGPoint)pt1 and:(CGPoint)pt2 and:(CGPoint)pt3;
-(void) sync;
-(float) bezierLength:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2;
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext;
- (void)drawHoldCircle:(CGPoint)position context:(CGContextRef)theContext;
@end
