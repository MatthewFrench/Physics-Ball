//
//  MenuView.h
//  Ball Physics Game
//
//  Created by Matthew French on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Curve.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface MenuView : UIView {
	CGPoint screenDimensions;
	NSMutableArray *curves, *reverseGravityX,*reverseGravityY;
	CGPoint ballxy,ballvel,accelGravity;
	float ballrad;
	CGPoint goalStart,goalEnd,goalControl1,goalControl2, goalPos;
	UIImage* reverseGravity;
	int touchingReverseGravityNum;
	
	CGPoint cameraPos;
	CGRect levelDimensions;
	
	CGPoint originalBallxy;
	
	CADisplayLink* theTimer;
	NSTimer* physicsTimer;
}
- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;
- (void)pauseGame;
- (void)initializeTimer;
- (void)gameLogic;
- (void)drawGame;
- (void)runPhysics;
- (void)initializeLevel;
@end
