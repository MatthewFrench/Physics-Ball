//
//  Canvas.h
//  iPad Quartz Vector Drawing
//
//  Created by Matthew French on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Curve.h"

@interface Canvas : UIView<UIAccelerometerDelegate> {
	NSMutableArray *curves;
	
	CGPoint ballxy, ballvel;
	float ballrad;
	
	NSTimer *gameTimer;
	
	CGGradientRef gradient;
	NSArray *colorArray;
	
	float gravity;
	CGPoint accelGravity;
}
- (void)runPhysics;
-(void) gradientColorWithRed:(CGFloat)aRed green:(CGFloat)aGreen blue:(CGFloat)aBlue;
- (void)configureAccelerometer;

@end
