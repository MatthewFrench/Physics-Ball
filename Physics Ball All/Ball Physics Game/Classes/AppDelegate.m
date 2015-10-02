#import "AppDelegate.h"

#define lineReg 0
#define lineRed 1
#define lineInvis 2
#define lineImag 3
#define lineBounce 4
#define lineBend 5

@implementation AppDelegate

@synthesize window, menuController,touchedScreen1,touchedScreen2,touch1,touch2,gameView,cameraPos,yAcceleration;
//@synthesize viewController;
#pragma mark -
#pragma mark Menu
- (IBAction)toInstructions:(id)sender {
	[mainMenuView pauseGame];
	[self switchView:menuController.view to:instructionsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)toMenu:(id)sender {
	[self pauseGame];
	[self switchView:menuController.view to:mainMenuView with:UIViewAnimationTransitionFlipFromRight time:1.0];
}
- (IBAction)toCredits:(id)sender {
	[mainMenuView pauseGame];
	[self switchView:menuController.view to:creditsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)toGameScreen:(id)sender {
	[self switchView:menuController.view to:gameView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)toLevelSelect:(id)sender {
	[mainMenuView pauseGame];
	[self switchView:menuController.view to:levelsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)startLevel:(id)sender {
	UIButton* pressed = sender;
	[self initializeLevel: [[pressed.currentTitle substringFromIndex:[pressed.currentTitle rangeOfString:@" "].location+1] intValue]];
}

- (void)switchView:(UIView*)oldView to:(UIView*)newView with:(UIViewAnimationTransition)trans time:(float)sec {
	[oldView removeFromSuperview];
		[menuController setView:newView];
		//Manually re-orient the view if in OS less than 4.0
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
			if ([menuController currentOrientation] == UIInterfaceOrientationLandscapeRight) {
				if (newView.transform.a == 0.0 && newView.transform.b == -1.0 && newView.transform.c == 1.0 &&
					newView.transform.d == 0.0 && newView.transform.tx == 0.0 && newView.transform.ty == 0.0) {
					[newView setTransform:CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, 0.0, 0.0)];
				} else if (!(newView.transform.a == 0.0 && newView.transform.b == 1.0 && newView.transform.c == -1.0 &&
							 newView.transform.d == 0.0 && newView.transform.tx == 0.0 && newView.transform.ty == 0.0)) {
					[newView setTransform:CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, -80.0, 80.0)];
				}
			}
			if ([menuController currentOrientation] == UIInterfaceOrientationLandscapeLeft) {
				if (newView.transform.a == 0.0 && newView.transform.b == 1.0 && newView.transform.c == -1.0 &&
					newView.transform.d == 0.0 && newView.transform.tx == 0.0 && newView.transform.ty == 0.0) {
					[newView setTransform:CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, 0.0, 0.0)];
				} else if (!(newView.transform.a == 0.0 && newView.transform.b == -1.0 && newView.transform.c == 1.0 &&
							 newView.transform.d == 0.0 && newView.transform.tx == 0.0 && newView.transform.ty == 0.0)) {
					[newView setTransform:CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, -80.0, 80.0)];
				}
			}
		}
	[self.window addSubview:newView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:sec];
	[UIView setAnimationTransition:trans
						   forView:window
							 cache:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished)];
	[UIView commitAnimations];
	
	//Can use CATransitions for custom transitions
}
- (void)animationFinished {
	//This tells us when our flipping animation finishes so we can start the timer.
	if ([[window subviews] containsObject:gameView]) {
		[self initializeTimer];
	}
	if ([[window subviews] containsObject:mainMenuView]) {
		[mainMenuView initializeTimer];
	}
}
#pragma mark -
#pragma mark In Game
- (void)pauseGame {
	if (theTimer != nil) {
		[theTimer invalidate];
		theTimer = nil;
		[physicsTimer invalidate];
		physicsTimer = nil;
	}
}
- (void)initializeTimer {
	if (theTimer == nil) {
		//theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/120.0 target:self selector:@selector(gameLogic) userInfo:nil repeats:YES];
		
		theTimer = [CADisplayLink displayLinkWithTarget:gameView selector:@selector(setNeedsDisplay)];
		theTimer.frameInterval = 2;//1 = 60fps, 2 = 30fps
		[theTimer addToRunLoop: [NSRunLoop currentRunLoop]
					   forMode: NSDefaultRunLoopMode];
		physicsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(gameLogic) userInfo:nil repeats:YES];
		//fpsCounter = CFAbsoluteTimeGetCurrent();
	}
}
- (void)gameLogic {
	//Delta is still experimental!!! If bad results disable.
	//Made to keep things smooth even when they skip frames.
	//float delta = (CFAbsoluteTimeGetCurrent() - fpsCounter)*120;
	//if (rand()%20 == 5) {
		//NSLog(@"%f",1/(CFAbsoluteTimeGetCurrent() - fpsCounter));
	//}
	//fpsCounter = CFAbsoluteTimeGetCurrent();
	//delta = 1.0;
	
	
	//Run the camera to focus on the ball
	//CGPoint oldBallPos = ballxy;
	[self runPhysics];
	[self runPhysics];
	[self runPhysics];
	//cameraPos = CGPointMake(cameraPos.x-(ballxy.x-oldBallPos.x), cameraPos.y-(ballxy.y-oldBallPos.y));
	cameraPos = CGPointMake(-(player.ballxy.x)+480/2, -(player.ballxy.y)+320/2);
	if (player.ballxy.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
	if (player.ballxy.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
	
	if (player.ballxy.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
	if (player.ballxy.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
	//if (cameraPos.x+480/2 > levelDimensions.size.width) {cameraPos.x = levelDimensions.size.width;}
	//if (cameraPos.y < levelDimensions.origin.y) {cameraPos.y = levelDimensions.origin.y;}
	//if (cameraPos.y > levelDimensions.size.height) {cameraPos.y = levelDimensions.size.height;}
	
	
	
	
	//Touches
	//if (touch1 != nil) {
	//	player.ballxy = CGPointMake(touchedScreen1.x-player.ballrad-cameraPos.x, touchedScreen1.y-player.ballrad-cameraPos.y);
	//	player.ballvel = CGPointMake(0, 0);
	//	touch1 = nil;
	//}	
	//Now draw everything
	//if (drawTimer == 2) {
		//[gameView setNeedsDisplay];
	//	drawTimer = 0;
	//}
	//drawTimer += 1;
}
/**
- (void)drawGame {
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//Draw the goal
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
	CGContextMoveToPoint(context, goalStart.x, goalStart.y);
	CGContextAddCurveToPoint(context,goalControl1.x, goalControl1.y, goalControl2.x, goalControl2.y, goalEnd.x, goalEnd.y);
	CGContextStrokePath(context);
	CGContextRestoreGState (context); 
	
	//Draw Shadow
	CGContextSaveGState(context);
    CGContextSetShadow (context, CGSizeMake(5, 5), 5); 
	
	//Draw Circle
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
	CGRect rectangle = CGRectMake(ballxy.x,ballxy.y,ballrad*2,ballrad*2);
	CGContextAddEllipseInRect(context, rectangle);
	CGContextStrokePath(context); 
    CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		
		//Draw Bezier Curve
		CGContextSaveGState(context);
		
		CGContextSetLineWidth(context, 2.0);
		
		CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
		
		CGContextMoveToPoint(context, curve.curve0.x, curve.curve0.y);
		
		CGContextAddQuadCurveToPoint(context, curve.curve1.x, curve.curve1.y, curve.curve2.x, curve.curve2.y);
		
		CGContextStrokePath(context);
		
		CGContextRestoreGState (context);
	}
	//Now for custom level code
	if (currentLevel == 1) {
		NSString* infoText = @"Tilt to roll to the goal...";
		CGSize textSize = [infoText sizeWithFont:[UIFont fontWithName:@"Georgia" size:20]];
		[infoText drawAtPoint:CGPointMake(gameView.bounds.size.width/2 - textSize.width/2, 50) 
					 withFont:[UIFont fontWithName:@"Georgia" size:20]];
	}
	if (currentLevel == 2) {
		NSString* infoText = @"Over the hill...";
		CGSize textSize = [infoText sizeWithFont:[UIFont fontWithName:@"Georgia" size:20]];
		[infoText drawAtPoint:CGPointMake(gameView.bounds.size.width/2 - textSize.width/2, 50) 
					 withFont:[UIFont fontWithName:@"Georgia" size:20]];
	}
	if (currentLevel == 3) {
		NSString* infoText = @"You're a-mazing. Teehee.";
		CGSize textSize = [infoText sizeWithFont:[UIFont fontWithName:@"Georgia" size:20]];
		[infoText drawAtPoint:CGPointMake(gameView.bounds.size.width/2 - textSize.width/2, 20) 
					 withFont:[UIFont fontWithName:@"Georgia" size:20]];
	}
}
 **/
- (void)drawGame {
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();;
	
	//Draw the goal
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0);
	if (goalStart.x+cameraPos.x > -20 && goalStart.x+cameraPos.x < 500
		&& goalStart.y+cameraPos.y > -20 && goalStart.y+cameraPos.y < 340) {
		CGContextSetRGBStrokeColor(context, 1.0, 0.8, 0.0, 1.0);
		CGContextMoveToPoint(context, goalStart.x+cameraPos.x, goalStart.y+cameraPos.y);
		CGContextAddCurveToPoint(context,goalControl1.x+cameraPos.x, goalControl1.y+cameraPos.y, 
								goalControl2.x+cameraPos.x, goalControl2.y+cameraPos.y, goalEnd.x+cameraPos.x, goalEnd.y+cameraPos.y);
		CGContextStrokePath(context);
	}
	CGContextRestoreGState (context);
	
	//Draw Gravity
	for (int i = 0; i < [reverseGravityX count]; i ++) {
		if ([[reverseGravityX objectAtIndex:i] intValue]+cameraPos.x > -20 && [[reverseGravityX objectAtIndex:i] intValue]+cameraPos.x < 500
			&& [[reverseGravityY objectAtIndex:i] intValue]+cameraPos.y > -20 && [[reverseGravityY objectAtIndex:i] intValue]+cameraPos.y < 340) {
			[reverseGravity drawAtPoint:CGPointMake([[reverseGravityX objectAtIndex:i] intValue]+cameraPos.x, [[reverseGravityY objectAtIndex:i] intValue]+cameraPos.y)];
		}
	}
	//Draw Shadow
	CGContextSaveGState(context);
    CGContextSetShadow (context, CGSizeMake(5, 5), 5); 
	
	//Draw Circle
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
	CGRect rectangle = CGRectMake(player.ballxy.x+cameraPos.x,player.ballxy.y+cameraPos.y,player.ballrad*2,player.ballrad*2);
	CGContextAddEllipseInRect(context, rectangle);
	CGContextStrokePath(context); 
    CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	
	
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		//Draw Shadow
		CGContextSaveGState(context);
		CGContextSetShadow (context, CGSizeMake(5, 5), 5); 
		
		//Draw Circle
		CGContextSetLineWidth(context, 2.0);
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		CGRect rectangle = CGRectMake(ball.ballxy.x+cameraPos.x,ball.ballxy.y+cameraPos.y,ball.ballrad*2,ball.ballrad*2);
		CGContextAddEllipseInRect(context, rectangle);
		CGContextStrokePath(context); 
		CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	}
	
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	CGContextSetLineWidth(context, 2.0);
	int e = 0;
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		if (480 >= curve.xBounds.x+delegate.cameraPos.x && 0 <= curve.xBounds.y+delegate.cameraPos.x &&
			320 >= curve.yBounds.x+delegate.cameraPos.y && 0 <= curve.yBounds.y+delegate.cameraPos.y) {
			e+=1;
			
			if (curve.type == lineReg) {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
			} else if (curve.type == lineRed) {
				CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
			} else if (curve.type == lineInvis) {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.0);
			} else if (curve.type == lineImag) {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.8, 1.0);
			} else if (curve.type == lineBounce) {
				CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
			} else if (curve.type == lineBend) {
				CGContextSetRGBStrokeColor(context, 0.5, 0.2, 0.0, 1.0);
			}
			CGContextBeginPath(context);
			if (!curve.snapped) {
				CGContextMoveToPoint(context, curve.curve0.x+delegate.cameraPos.x, curve.curve0.y+delegate.cameraPos.y);
				
				CGContextAddQuadCurveToPoint(context, curve.curve1.x+delegate.cameraPos.x, curve.curve1.y+delegate.cameraPos.y, curve.curve2.x+delegate.cameraPos.x, curve.curve2.y+delegate.cameraPos.y);
				
				//CGContextStrokePath(context);
			} else {
				CGContextMoveToPoint(context, curve.snap0.x+delegate.cameraPos.x, curve.snap0.y+delegate.cameraPos.y);
				
				CGContextAddQuadCurveToPoint(context, curve.snap1.x+delegate.cameraPos.x, curve.snap1.y+delegate.cameraPos.y, curve.snap2.x+delegate.cameraPos.x, curve.snap2.y+delegate.cameraPos.y);
				
				//CGContextStrokePath(context);
				
				CGContextMoveToPoint(context, curve.snap3.x+delegate.cameraPos.x, curve.snap3.y+delegate.cameraPos.y);
				
				CGContextAddQuadCurveToPoint(context, curve.snap4.x+delegate.cameraPos.x, curve.snap4.y+delegate.cameraPos.y, curve.snap5.x+delegate.cameraPos.x, curve.snap5.y+delegate.cameraPos.y);
				
				//CGContextStrokePath(context);
			}
			CGContextStrokePath(context);
			
			//Draw end points to smoothen
			float pointrad = 1.0/8.0;
			CGContextSaveGState(context);
			CGRect rectangle = CGRectMake(curve.curve0.x+cameraPos.x-pointrad,curve.curve0.y+cameraPos.y-pointrad,pointrad*2,pointrad*2);
			CGContextAddEllipseInRect(context, rectangle);
			CGContextStrokePath(context); 
			
			
			rectangle = CGRectMake(curve.curve2.x+cameraPos.x-pointrad,curve.curve2.y+cameraPos.y-pointrad,pointrad*2,pointrad*2);
			CGContextAddEllipseInRect(context, rectangle);
			CGContextStrokePath(context);
			CGContextRestoreGState (context);
			//CGContextDrawPath(context, kCGPathStroke);
			 
		}
	}
	for (int i = 0; i < [texts count]; i ++) {
		Text* text = [texts objectAtIndex:i];

		CGSize size = [text.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16]];
		[[text text] drawAtPoint:CGPointMake(text.pos.x - size.width/2.0 +cameraPos.x, text.pos.y - size.height/2.0 +cameraPos.y) withFont:[UIFont fontWithName:@"Helvetica" size:16]];
	}
	//NSLog(@"Drew %d lines.",e);
	
}

- (void)runPhysics {
	[self runPhysicsForBendLines];
	[self runGravityForAllBalls];
	[self runPhysicsForBall:player];
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		[self runPhysicsForBall:ball];
	}
}
- (void)runGravityForAllBalls {
	player.ballvel = CGPointMake(player.ballvel.x+levelGravity.x+playerGravity.x, player.ballvel.y+levelGravity.y+playerGravity.y);
	player.ballxy = CGPointMake(player.ballxy.x + player.ballvel.x, player.ballxy.y + player.ballvel.y);
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		ball.ballvel = CGPointMake(ball.ballvel.x+levelGravity.x, ball.ballvel.y+levelGravity.y);
		ball.ballxy = CGPointMake(ball.ballxy.x + ball.ballvel.x, ball.ballxy.y + ball.ballvel.y);
	}
}
- (void)runPhysicsForBendLines {
	for (int i = 0; i < [curves count];i++) {
		Curve* curve = [curves objectAtIndex:i];
		
		//If curve has snapped then do snap animation
		if (curve.type == lineBend && curve.snapped) {
			BOOL resync = FALSE;
			if (curve.snap1.x > curve.snap0.x) {
				curve.snap1 = CGPointMake(curve.snap1.x-1.0, curve.snap1.y);
				resync = TRUE;
			}
			if (curve.snap2.x > curve.snap0.x) {
				curve.snap2 = CGPointMake(curve.snap2.x-1.0, curve.snap2.y+0.5);
				resync = TRUE;
			}
			if (curve.snap4.x < curve.snap3.x) {
				curve.snap4 = CGPointMake(curve.snap4.x+1.0, curve.snap4.y);
				resync = TRUE;
			}
			if (curve.snap5.x < curve.snap3.x) {
				curve.snap5 = CGPointMake(curve.snap5.x+1.0, curve.snap5.y+0.5);
				resync = TRUE;
			}
			if (resync) {[curve sync];}
		}
	}
}
- (void)runPhysicsForBall:(Ball*)ball {
	BOOL reachedGoal = FALSE;
	BOOL dead = FALSE;
	
	float br = ball.ballrad;
	
	float bx = ball.ballxy.x;
	float by = ball.ballxy.y;
	
	float bvx = ball.ballvel.x;
	float bvy = ball.ballvel.y;
	
	//Run phsyics for ball-ball collisions
	int startBall = 0;
	if (ball != player) {startBall = [balls indexOfObject:ball]+1;}
	//Balloon Collision
	for (int j = startBall; j < [balls count]; j ++) {
		Ball* collideBall = [balls objectAtIndex:j];
		
		if ([gameView collisionOfCircles:CGPointMake(ceil(bx+br), ceil(by+br)) rad:br
									  c2:CGPointMake(ceil(collideBall.ballxy.x+collideBall.ballrad), ceil(collideBall.ballxy.y+collideBall.ballrad)) rad:collideBall.ballrad]) {
			double x, y, d2;
			if (bx == collideBall.ballxy.x && by == collideBall.ballxy.y) {
				int randAdd = rand()%5;
				if (randAdd == 1) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x+1, collideBall.ballxy.y);}
				if (randAdd == 2) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x-1, collideBall.ballxy.y);}
				if (randAdd == 3) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x, collideBall.ballxy.y+1);}
				if (randAdd == 4) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x, collideBall.ballxy.y-1);}
			}
			// displacement from i to j
			y = (collideBall.ballxy.y - by);
			x = (collideBall.ballxy.x - bx);
			
			// distance squared
			d2 = x * x + y * y;
			if (d2 == 0) {d2 = 1;}
			
			double kii, kji, kij, kjj;
			
			kji = (x * bvx + y * bvy) / d2; // k of j due to i
			kii = (x * bvy - y * bvx) / d2; // k of i due to i
			kij = (x * collideBall.ballvel.x + y * collideBall.ballvel.y) / d2; // k of i due to j
			kjj = (x * collideBall.ballvel.y - y * collideBall.ballvel.x) / d2; // k of j due to j
			
			// set velocity of i
			bvx = kij * x - kii * y;
			bvy = kij * y + kii * x;
			
			// set velocity of j
			collideBall.ballvel = CGPointMake(kji * x - kjj * y, kji * y + kjj * x);
			
			// the ratio between what it should be and what it really is
			float k = ((br*2+collideBall.ballrad*2)/2+0.1) / sqrt(d2);
			
			// difference between x and y component of the two vectors
			y *= (k - 1) / 2;
			x *= (k - 1) / 2;
			
			// set new coordinates of disks
			bx -= x;
			by -= y;
			collideBall.ballxy = CGPointMake(collideBall.ballxy.x + x,collideBall.ballxy.y + y);
			//j.y += y;
			//j.x += x;
			//i.y -= y;
			//i.x -= x;
			
		}
	}
	
	for (int i = 0; i < [curves count];i++) {
		Curve* curve = [curves objectAtIndex:i];
		
		if (bx >= curve.xBounds.x-40 && bx <= curve.xBounds.y+40 &&
			by >= curve.yBounds.x-40 && by <= curve.yBounds.y+40) {
			
			//Run line end-point circle collisions
			for (int e = 1; e < 2 && curve.type != lineImag; e ++) {
				double cx,cy;
				if (e == 1) {
					cx = curve.curve0.x-br;
					cy = curve.curve0.y-br;
				} else {
					cx = curve.curve2.x-br;
					cy = curve.curve2.y-br;
				}
				if ([gameView collisionOfCircles:CGPointMake(bx, by) rad:br c2:CGPointMake(cx,cy) rad:1.0]) {
					//Startpoint Collision
					
					double x, y, d2;
					
					// displacement from i to j
					y = (cy - by);
					x = (cx - bx);
					
					// distance squared
					d2 = x * x + y * y;
					
					// the ratio between what it should be and what it really is
					float k = ((20+2)/2+0.1) / sqrt(x * x + y * y);
					
					// difference between x and y component of the two vectors
					y *= (k - 1) / 2;
					x *= (k - 1) / 2;
					
					// set new coordinates of disks
					bx -= x;
					by -= y;
				}
			}
			
			BOOL ballHasCollided = FALSE;
			for ( int p = 1 ; p < [curve.curvePtX count] - 1 && ballHasCollided==FALSE && curve.type != lineImag; p++ ) {
				
				CGPoint p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
				CGPoint p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
				
				
				CGPoint average = CGPointMake((p0.x+p1.x)/2.0, (p0.y+p1.y)/2.0);
				float endAngle =  atan2( p1.y - average.y , p1.x - average.x )*180/M_PI + 180;
				float startAngle =  atan2( p0.y - average.y , p0.x - average.x )*180/M_PI + 180;
				float ballAngle =  atan2( by - average.y , bx - average.x )*180/M_PI + 180;
				BOOL reversed = FALSE;
				if (endAngle > startAngle) {
					if (ballAngle < startAngle || ballAngle > endAngle) {
						reversed = TRUE;
						p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
						p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
					}
				} else {
					if (ballAngle < startAngle && ballAngle > endAngle) {
						reversed = TRUE;
						p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
						p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
					}
				}
				
				float p0x = p0.x;
				float p0y = p0.y;
				float p1x = p1.x;
				float p1y = p1.y;
				
				// get Angle //
				
				float dx = p0x - p1x;
				float dy = p0y - p1y;
				
				float angle = atan2( dy , dx );
				
				float sin1 = sin ( angle );
				float cos1 = cos ( angle );
				
				// rotate p1 ( need only 'x' ) //
				
				float p1rx = dy * sin1 + dx * cos1 + p0x;
				
				// rotate ball //
				
				float px = p0x - bx;
				float py = p0y - by;
				
				float brx = py * sin1 + px * cos1 + p0x;
				float bry = py * cos1 - px * sin1 + p0y;
				
				float cp = ( bx - p0x ) * ( p1y - p0y ) - ( by - p0y ) * ( p1x - p0x );
				
				if ( bry > p0y - br && brx > p0x && brx < p1rx && cp > 0 ) {
					ballHasCollided = TRUE;
					if (curve.type == lineBend && !curve.snapped) {
						float toBend = fabs(ball.ballvel.x)*0.5;
						/**
						 if (curve.originalCurve1.y-curve.curve1.y != 0) {
						 toBend = 1.0/((curve.curve1.y-curve.originalCurve1.y)/50);
						 } else {
						 toBend = 1;
						 }
						 **/
						curve.curve1 = CGPointMake(curve.curve1.x, curve.curve1.y+toBend);
						if (bx > curve.curve1.x) {
							curve.curve1 = CGPointMake(curve.curve1.x + 1, curve.curve1.y);
						} else if (bx < curve.curve1.x) {
							curve.curve1 = CGPointMake(curve.curve1.x - 1, curve.curve1.y);
						}
						[curve sync];
						//Now that it's resync redo all the calculations so the ball doesn't jump
						if (reversed) {
							p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
							p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
						} else {
							p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
							p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);	
						}
						p0x = p0.x;
						p0y = p0.y;
						p1x = p1.x;
						p1y = p1.y;
						
						// get Angle //
						
						dx = p0x - p1x;
						dy = p0y - p1y;
						
						angle = atan2( dy , dx );
						
						sin1 = sin ( angle );
						cos1 = cos ( angle );
						
						// rotate p1 ( need only 'x' ) //
						
						p1rx = dy * sin1 + dx * cos1 + p0x;
						
						// rotate ball //
						
						px = p0x - bx;
						py = p0y - by;
						
						brx = py * sin1 + px * cos1 + p0x;
						bry = py * cos1 - px * sin1 + p0y;
						
						cp = ( bx - p0x ) * ( p1y - p0y ) - ( by - p0y ) * ( p1x - p0x );
						
						if (curve.curve1.y-curve.originalCurve1.y > 100) {
							curve.snapped = TRUE;
							
							curve.snap0 = curve.curve0;
							curve.snap1 = CGPointMake((curve.curve1.x+curve.curve0.x)/2.0, (curve.curve1.y+curve.curve0.y)/2.0);
							curve.snap2 = CGPointMake(curve.curve1.x, by + br);
							
							curve.snap3 = curve.curve2;
							curve.snap4 = CGPointMake((curve.curve1.x+curve.curve2.x)/2.0, (curve.curve1.y+curve.curve2.y)/2.0);
							curve.snap5 = CGPointMake(curve.curve1.x, by + br);
						}
					}
					if (curve.snapped == FALSE) {
						// calc new Vector //
						
						float vx = bvy * sin1 + bvx * cos1;
						float vy = bvy * cos1 - bvx * sin1;
						
						if (curve.type == lineBounce) {
							vy *= 2.0;
						}
						vy *= -.8;
						vx *= .98;
						
						sin1 = sin ( -angle );
						cos1 = cos ( -angle );
						
						bvx = vy * sin1 + vx * cos1;
						bvy = vy * cos1 - vx * sin1;
						
						// calc new Position //
						
						bry = p0y - br;
						
						dx = p0x - brx;
						dy = p0y - bry;
						
						bx = dy * sin1 + dx * cos1 + p0x;
						by = dy * cos1 - dx * sin1 + p0y;
					}
					
					//Check if touching death line
					if (curve.type == lineRed && ball == player) {
						dead = TRUE;
					}
				}
			}
		}
	}
	
	//if ( bx < br - 200 ) bx = br - 200, bvx = -bvx;
	//if ( bx > 200 - br ) bx = 200 - br, bvx = -bvx;
	
	ball.ballxy = CGPointMake(bx, by);
	
	ball.ballvel = CGPointMake(bvx, bvy);
	
	//Limit velocity
	if (ball.ballvel.x > 5.0/2.0) {ball.ballvel = CGPointMake(5.0/2.0, ball.ballvel.y);}
	if (ball.ballvel.x < -5.0/2.0) {ball.ballvel = CGPointMake(-5.0/2.0, ball.ballvel.y);}
	if (ball.ballvel.y > 5.0/2.0) {ball.ballvel = CGPointMake(ball.ballvel.x, 5.0/2.0);}
	if (ball.ballvel.y < -5.0/2.0) {ball.ballvel = CGPointMake(ball.ballvel.x, -5.0/2.0);}
	
	if (ball == player) {
		//Check if touching gravity
		for (int i = 0; i < [reverseGravityX count]; i ++) {
			int x = [[reverseGravityX objectAtIndex:i] intValue];
			int y = [[reverseGravityY objectAtIndex:i] intValue];
			if (ball.ballxy.x+ball.ballrad > x && ball.ballxy.x+ball.ballrad < x+20
				&& ball.ballxy.y+ball.ballrad > y && ball.ballxy.y+ball.ballrad < y+20) {
				if (touchingReverseGravityNum != i) {
					levelGravity.y *= -1;
					touchingReverseGravityNum = i;
				}
			} else {
				if (touchingReverseGravityNum == i) {touchingReverseGravityNum = -1;}
			}
		}
	}
	
	if ( abs(ball.ballxy.y) > 1000 && ball == player) {
		dead = TRUE;
	}
	//Set up the goal
	if (ball.ballxy.x > goalPos.x - 20 && ball.ballxy.x < goalPos.x + 20
		&& ball.ballxy.y < goalPos.y && ball.ballxy.y > goalPos.y - 40 && ball == player) {
		//Beat the level
		reachedGoal = TRUE;
	}
	if (reachedGoal) {
		[self pauseGame];
		[self switchView:gameView to:levelsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
	}
	if (dead) {
		[self pauseGame];
		[self switchView:gameView to:levelsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
	}
}

- (void)initializeLevel:(int)level {
	player = [[Ball alloc] init];
	player.ballrad = 10;
	currentLevel = level;
	if ([curves count] > 0) {
		[curves removeAllObjects];
	}

	//Load Level
	NSMutableArray* loadData;
	NSString * path = [[NSBundle mainBundle]
					   pathForResource:[NSString stringWithFormat:@"Level %d",level]
					   ofType:@"lvl"];
	loadData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	player.ballxy = CGPointMake([[loadData objectAtIndex:0] floatValue], [[loadData objectAtIndex:1] floatValue]);
	
	goalStart.x = [[loadData objectAtIndex:2] floatValue];
	goalStart.y = [[loadData objectAtIndex:3] floatValue];
	
	goalEnd.x = [[loadData objectAtIndex:4] floatValue];
	goalEnd.y = [[loadData objectAtIndex:5] floatValue];
	
	goalControl1.x = [[loadData objectAtIndex:6] floatValue];
	goalControl1.y = [[loadData objectAtIndex:7] floatValue];
	
	goalControl2.x = [[loadData objectAtIndex:8] floatValue];
	goalControl2.y = [[loadData objectAtIndex:9] floatValue];
	
	goalPos.x = [[loadData objectAtIndex:10] floatValue];
	goalPos.y = [[loadData objectAtIndex:11] floatValue];
	
	if (curves != nil) {[curves release];}
	curves = [loadData objectAtIndex:12];
	[curves retain];
	
	if ([loadData count]-1> 12) {
		if (reverseGravityX != nil) {[reverseGravityX release];}
		reverseGravityX = [loadData objectAtIndex:13];
		[reverseGravityX retain];
		
		if (reverseGravityY != nil) {[reverseGravityY release];}
		reverseGravityY = [loadData objectAtIndex:14];
		[reverseGravityY retain];
	}
	levelDimensions = CGRectMake(0, 0, 480, 320);
	if ([loadData count]-1> 14) {
		levelDimensions = CGRectMake([[loadData objectAtIndex:15] floatValue], [[loadData objectAtIndex:16] floatValue],
									 [[loadData objectAtIndex:17] floatValue], [[loadData objectAtIndex:18] floatValue]);
	}
	if ([loadData count]-1 > 18) {
		balls = [loadData objectAtIndex:19];
		[balls retain];
	}
	if ([loadData count]-1 > 19) {
		texts = [loadData objectAtIndex:20];
		[texts retain];
	}
	if ([loadData count]-1 > 20) {
		levelGravity = CGPointMake([[loadData objectAtIndex:21] floatValue], [[loadData objectAtIndex:22] floatValue]);
	}
	
	//Update Camera Position
	cameraPos = CGPointMake(-(player.ballxy.x)+480/2, -(player.ballxy.y)+320/2);
	if (player.ballxy.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
	if (player.ballxy.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
	if (player.ballxy.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
	if (player.ballxy.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
	
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		[curve sync];
		curve.originalCurve0 = curve.curve0;
		curve.originalCurve1 = curve.curve1;
		curve.originalCurve2 = curve.curve2;
		curve.snapped = FALSE;
	}
	[self switchView:menuController.view to:gameView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	curves = [[NSMutableArray alloc] init];
	reverseGravityX = [[NSMutableArray alloc] init];
	reverseGravityY = [[NSMutableArray alloc] init];
	
	reverseGravity = [UIImage imageNamed:@"reverse gravity.png"];
	[reverseGravity retain];
	

	[self configureAccelerometer];
    // Add the view controller's view to the window and display.
    [window addSubview:menuController.view];
    [window makeKeyAndVisible];

    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	[self pauseGame];
	touch1 = nil;
	touch2 = nil;
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	if ([[window subviews] containsObject:gameView]) {
		[self initializeTimer];
	}
}
- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)configureAccelerometer{
	UIAccelerometer*  theAccelerometer = [UIAccelerometer sharedAccelerometer];
	if(theAccelerometer)
	{
		theAccelerometer.updateInterval = 1.0 / 60;
		theAccelerometer.delegate = self;
	}
}
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	yAcceleration = acceleration.y;
	if (menuController.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		playerGravity.x = -acceleration.y * 0.1;
		playerGravity.y = -acceleration.x * 0.1;
	} else {
		playerGravity.x = acceleration.y * 0.1;
		playerGravity.y = acceleration.x * 0.1;
	}
	//accelGravity.x = 0.0;
	//if (-acceleration.y > 0.2) { accelGravity.x = 0.2;}
	//if (-acceleration.y < -0.2) { accelGravity.x = -0.2;}
    //accelGravity.y = 0.2; //Disabled vertical gravity+
	

}

- (void)dealloc {
	[self pauseGame];
	[reverseGravity release];
    [menuController release];
    [window release];
    [super dealloc];
}


@end
