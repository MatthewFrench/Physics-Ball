#import "AppDelegate.h"

#define lineReg 0
#define lineRed 1
#define lineInvis 2
#define lineImag 3
#define lineBounce 4
#define lineBend 5

@implementation AppDelegate

@synthesize window, menuController,touchedScreen1,touchedScreen2,touch1,touch2,gameView,cameraPos;
//@synthesize viewController;
#pragma mark -
#pragma mark Menu
- (IBAction)toInstructions:(id)sender {
	[self switchView:mainMenuView to:instructionsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)toMenu:(id)sender {
	[self switchView:menuController.view to:mainMenuView with:UIViewAnimationTransitionFlipFromRight time:1.0];
}
- (IBAction)toCredits:(id)sender {
	[self switchView:mainMenuView to:creditsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)toGameScreen:(id)sender {
	[self switchView:mainMenuView to:gameView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)toLevelSelect:(id)sender {
	[self switchView:menuController.view to:levelsView with:UIViewAnimationTransitionFlipFromLeft time:1.0];
}
- (IBAction)startLevel:(id)sender {
	UIButton* pressed = sender;
	[self initializeLevel: [[pressed.currentTitle substringFromIndex:[pressed.currentTitle rangeOfString:@" "].location+1] intValue]];
}


- (void)switchView:(UIView*)oldView to:(UIView*)newView with:(UIViewAnimationTransition)trans time:(float)sec {
	[oldView removeFromSuperview];
	if (newView == gameView) {
		[gameView setOrientation:[menuController currentOrientation]];
	} else {
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
	NSLog(@"Animation finished");
	//This tells us when our flipping animation finishes so we can start the timer.
	if ([[window subviews] containsObject:gameView]) {
		NSLog(@"Starting Timer");
		[self initializeTimer];
	}
}
#pragma mark -
#pragma mark In Game
- (void)pauseGame {
	if (theTimer != nil) {
		[theTimer invalidate];
		theTimer = nil;
	}
}
- (void)initializeTimer {
	if (theTimer == nil) {
		//theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/120.0 target:self selector:@selector(gameLogic) userInfo:nil repeats:YES];
		theTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLogic)];
		theTimer.frameInterval = 1;//1 = 60fps, 2 = 30fps
		[theTimer addToRunLoop: [NSRunLoop currentRunLoop]
					   forMode: NSDefaultRunLoopMode];
		fpsCounter = CFAbsoluteTimeGetCurrent();
	}
}
- (void)gameLogic {
	//Delta is still experimental!!! If bad results disable.
	//Made to keep things smooth even when they skip frames.
	float delta = (CFAbsoluteTimeGetCurrent() - fpsCounter)*120;
	if (rand()%20 == 5) {
		//NSLog(@"%f",1/(CFAbsoluteTimeGetCurrent() - fpsCounter));
	}
	fpsCounter = CFAbsoluteTimeGetCurrent();
	//delta = 1.0;
	
	
	//Run the camera to focus on the ball
	//CGPoint oldBallPos = ballxy;
	[self runPhysics];
	[self runPhysics];
	//cameraPos = CGPointMake(cameraPos.x-(ballxy.x-oldBallPos.x), cameraPos.y-(ballxy.y-oldBallPos.y));
	cameraPos = CGPointMake(-(ballxy.x)+480/2, -(ballxy.y)+320/2);
	if (ballxy.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
	if (ballxy.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
	
	if (ballxy.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
	if (ballxy.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
	//if (cameraPos.x+480/2 > levelDimensions.size.width) {cameraPos.x = levelDimensions.size.width;}
	//if (cameraPos.y < levelDimensions.origin.y) {cameraPos.y = levelDimensions.origin.y;}
	//if (cameraPos.y > levelDimensions.size.height) {cameraPos.y = levelDimensions.size.height;}
	
	
	//testLine = touchedScreen1;
	//Touches
	if (touch1 != nil) {
		ballxy = CGPointMake(touchedScreen1.x-ballrad-cameraPos.x, touchedScreen1.y-ballrad-cameraPos.y);
		ballvel = CGPointMake(0, 0);
		touch1 = nil;
	}
	
	//Now draw everything
	//if (drawTimer == 2) {
		[gameView renderScene];
	//	drawTimer = 0;
	//}
	//drawTimer += 1;
}

- (void)drawGame {
	
	float color[4];
	//Draw the goal
	color[0]=1.0;
	color[1]=0.8;
	color[2]=0.0;
	color[3]=1.0;
	[gameView drawCurve:2.0 color:color from:CGPointMake(goalStart.x+cameraPos.x, goalStart.y+cameraPos.y) 
				control:CGPointMake((goalControl1.x+goalControl2.x)/2+cameraPos.x, (goalControl1.y+goalControl2.y)/2+cameraPos.y) 
					 to:CGPointMake(goalEnd.x+cameraPos.x, goalEnd.y+cameraPos.y)];
	
	//Draw Gravity
	for (int i = 0; i < [reverseGravityX count]; i ++) {
		[gameView drawImage:reverseGravity AtPoint:CGPointMake([[reverseGravityX objectAtIndex:i] intValue]+cameraPos.x, [[reverseGravityY objectAtIndex:i] intValue]+cameraPos.y)];
	}
	
	[gameView drawImage:ball AtPoint:CGPointMake(ballxy.x+cameraPos.x, ballxy.y+cameraPos.y)];
	
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		
		
		
		//Draw Shape
		//curve.shapeDraw.position = CGPointMake(curve.hitBox.origin.x+cameraPos.x, curve.hitBox.origin.y+cameraPos.y);
		
		
		//if (!curve.shapeDraw) {
		//	NSLog(@"Hello");
		//AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
		
		//CGContextRef context = CGLayerGetContext(curve.shapeDraw);
		
		 //Draw Bezier Curve
		 
		 if (curve.type == lineReg) {
			 color[0] = 0.0;
			 color[1] = 0.0;
			 color[2] = 1.0;
			 color[3] = 1.0;
		 } else if (curve.type == lineRed) {
			 color[0] = 1.0;
			 color[1] = 0.0;
			 color[2] = 0.0;
			 color[3] = 1.0;
		 } else if (curve.type == lineInvis) {
			 color[0] = 0.0;
			 color[1] = 0.0;
			 color[2] = 0.0;
			 color[3] = 0.0;
		 } else if (curve.type == lineImag) {
			 color[0] = 0.0;
			 color[1] = 0.0;
			 color[2] = 0.8;
			 color[3] = 1.0;
		 } else if (curve.type == lineBounce) {
			 color[0] = 0.0;
			 color[1] = 1.0;
			 color[2] = 0.0;
			 color[3] = 1.0;
		 } else if (curve.type == lineBend) {
			 color[0] = 0.5;
			 color[1] = 0.2;
			 color[2] = 0.0;
			 color[3] = 1.0;
		 }
		 if (!curve.snapped) {
			 [gameView drawCurve:1.0 color:color 
							from:CGPointMake(curve.curve0.x+cameraPos.x, curve.curve0.y+cameraPos.y)
						 control:CGPointMake(curve.curve1.x+cameraPos.x, curve.curve1.y+cameraPos.y) 
							  to:CGPointMake(curve.curve2.x+cameraPos.x, curve.curve2.y+cameraPos.y)];
		 } else {
			 [gameView drawCurve:1.0 color:color 
							from:CGPointMake(curve.snap0.x+cameraPos.x, curve.snap0.y+cameraPos.y)
						 control:CGPointMake(curve.snap1.x+cameraPos.x, curve.snap1.y+cameraPos.y) 
							  to:CGPointMake(curve.snap2.x+cameraPos.x, curve.snap2.y+cameraPos.y)];
			 [gameView drawCurve:1.0 color:color 
							from:CGPointMake(curve.snap3.x+cameraPos.x, curve.snap3.y+cameraPos.y)
						 control:CGPointMake(curve.snap4.x+cameraPos.x, curve.snap4.y+cameraPos.y) 
							  to:CGPointMake(curve.snap5.x+cameraPos.x, curve.snap5.y+cameraPos.y)];
		 }
	}
	 
}

- (void)runPhysics {
	BOOL reachedGoal = FALSE;
	BOOL dead = FALSE;
	
	float br = ballrad;
	
	float bx = ballxy.x;
	float by = ballxy.y;
	
	float bvx = ballvel.x;
	float bvy = ballvel.y;
	
	bvx += accelGravity.x;
	bvy += accelGravity.y;
	
	bx += bvx;
	by += bvy;
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
		
		//Check if ball is near the curve
		//NSLog(@"Ball Location: %f and %f",ballxy.x,ballxy.y);
		//NSLog(@"XBounds: %f and %f",curve.xBounds.x,curve.xBounds.y);
		//NSLog(@"YBounds: %f and %f",curve.yBounds.x,curve.yBounds.y);
		if (ballxy.x >= curve.xBounds.x-40 && ballxy.x <= curve.xBounds.y+40 &&
				ballxy.y >= curve.yBounds.x-40 && ballxy.y <= curve.yBounds.y+40) {
		

			BOOL ballHasCollided = FALSE;
			for ( int p = 1 ; p < [curve.curvePtX count] - 1 && ballHasCollided==FALSE && curve.type != lineImag; p++ ) {
				
				CGPoint p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p] floatValue]-ballrad);
				CGPoint p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p+1] floatValue]-ballrad);
				
				
				CGPoint average = CGPointMake((p0.x+p1.x)/2.0, (p0.y+p1.y)/2.0);
				float endAngle =  atan2( p1.y - average.y , p1.x - average.x )*180/M_PI + 180;
				float startAngle =  atan2( p0.y - average.y , p0.x - average.x )*180/M_PI + 180;
				float ballAngle =  atan2( ballxy.y - average.y , ballxy.x - average.x )*180/M_PI + 180;
				BOOL reversed = FALSE;
				if (endAngle > startAngle) {
					if (ballAngle < startAngle || ballAngle > endAngle) {
						reversed = TRUE;
						p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p+1] floatValue]-ballrad);
						p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p] floatValue]-ballrad);
					}
				} else {
					if (ballAngle < startAngle && ballAngle > endAngle) {
						reversed = TRUE;
						p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p+1] floatValue]-ballrad);
						p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p] floatValue]-ballrad);
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
						float toBend = fabs(ballvel.x)*0.5;
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
							p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p+1] floatValue]-ballrad);
							p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p] floatValue]-ballrad);
						} else {
							p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p] floatValue]-ballrad);
							p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-ballrad, [[curve.curvePtY objectAtIndex:p+1] floatValue]-ballrad);	
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
							curve.snap2 = CGPointMake(curve.curve1.x, ballxy.y + ballrad);
							
							curve.snap3 = curve.curve2;
							curve.snap4 = CGPointMake((curve.curve1.x+curve.curve2.x)/2.0, (curve.curve1.y+curve.curve2.y)/2.0);
							curve.snap5 = CGPointMake(curve.curve1.x, ballxy.y + ballrad);
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
					if (curve.type == lineRed) {
						dead = TRUE;
					}
				}
				
			}
		}
}
	
	//if ( bx < br - 200 ) bx = br - 200, bvx = -bvx;
	//if ( bx > 200 - br ) bx = 200 - br, bvx = -bvx;
	
	ballxy.x = bx;
	ballxy.y = by;
	
	ballvel.x = bvx;
	ballvel.y = bvy;
	
	//Limit velocity
	if (ballvel.x > 5.0/2.0) {ballvel.x = 5.0/2.0;}
	if (ballvel.x < -5.0/2.0) {ballvel.x = -5.0/2.0;}
	if (ballvel.y > 5.0/2.0) {ballvel.y = 5.0/2.0;}
	if (ballvel.y < -5.0/2.0) {ballvel.y = -5.0/2.0;}
	
	//Check if touching gravity
	for (int i = 0; i < [reverseGravityX count]; i ++) {
		int x = [[reverseGravityX objectAtIndex:i] intValue];
		int y = [[reverseGravityY objectAtIndex:i] intValue];
		if (ballxy.x+ballrad > x && ballxy.x+ballrad < x+20
			&& ballxy.y+ballrad > y && ballxy.y+ballrad < y+20) {
			if (touchingReverseGravityNum != i) {
				accelGravity.y *= -1;
				touchingReverseGravityNum = i;
			}
		} else {
			if (touchingReverseGravityNum == i) {touchingReverseGravityNum = -1;}
		}
	}
	
	if ( abs(ballxy.y) > 1000) {
		reachedGoal = TRUE;
	}
	//If hit the goal
	if (ballxy.x > goalPos.x - 20 && ballxy.x < goalPos.x + 20
		&& ballxy.y < goalPos.y && ballxy.y > goalPos.y - 40) {
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
	accelGravity.y = 0.1;
	currentLevel = level;
	if ([curves count] > 0) {
		[curves removeAllObjects];
	}
	ballvel = CGPointMake(0, 0);
	ballrad = 10;	
	
	//Load Level
	NSMutableArray* loadData;
	NSString * path = [[NSBundle mainBundle]
					   pathForResource:[NSString stringWithFormat:@"Level %d",level]
					   ofType:@"lvl"];
	loadData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	NSLog(@"%d",[loadData count]);
	ballxy.x = [[loadData objectAtIndex:0] floatValue];
	ballxy.y = [[loadData objectAtIndex:1] floatValue];
	
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
	
	cameraPos = CGPointMake(-ballxy.x, -ballxy.y);
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
	// Override point for customization after application launch.
	curves = [[NSMutableArray alloc] init];
	reverseGravityX = [[NSMutableArray alloc] init];
	reverseGravityY = [[NSMutableArray alloc] init];
	reverseGravity = [[Image alloc] initWithImage:[UIImage imageNamed:@"reverse gravity.png"] filter:GL_NEAREST];
	ball = [[Image alloc] initWithImage:[UIImage imageNamed:@"ball.png"] filter:GL_NEAREST];
	
	
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
	accelGravity.x = -acceleration.y * 0.1;
	//accelGravity.x = 0.0;
	//if (-acceleration.y > 0.2) { accelGravity.x = 0.2;}
	//if (-acceleration.y < -0.2) { accelGravity.x = -0.2;}
    //accelGravity.y = 0.2; //Disabled vertical gravity+
	
}

- (void)dealloc {
	[self pauseGame];
	[reverseGravity release];
	[ball release];
    [menuController release];
    [window release];
    [super dealloc];
}


@end
