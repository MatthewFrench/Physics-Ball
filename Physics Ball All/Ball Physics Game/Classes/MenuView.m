//
//  MenuView.m
//  Ball Physics Game
//
//  Created by Matthew French on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuView.h"
#import "AppDelegate.h"

#define lineReg 0
#define lineRed 1
#define lineInvis 2
#define lineImag 3
#define lineBounce 4
#define lineBend 5


@implementation MenuView
//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
		screenDimensions = CGPointMake([self bounds].size.height, [self bounds].size.width);
		reverseGravity = [UIImage imageNamed:@"reverse gravity.png"];
		[reverseGravity retain];
		[self initializeLevel];
		[self initializeTimer];
		//[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	}
    return self;
	
}

- (void)initializeLevel {
	accelGravity.y = 0.1;
	if ([curves count] > 0) {
		[curves removeAllObjects];
	}
	ballvel = CGPointMake(0, 0);
	ballrad = 10;	
	
	//Load Level
	NSMutableArray* loadData;
	NSString * path = [[NSBundle mainBundle]
					   pathForResource:@"Menu Level"
					   ofType:@"lvl"];
	loadData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	ballxy.x = [[loadData objectAtIndex:0] floatValue];
	ballxy.y = [[loadData objectAtIndex:1] floatValue];
	originalBallxy = ballxy;
	
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
}
- (void)gameLogic {
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	accelGravity.x = -delegate.yAcceleration * 0.1;
	
	[self runPhysics];
	[self runPhysics];
	[self runPhysics];
	cameraPos = CGPointMake(-(ballxy.x)+480/2, -(ballxy.y)+320/2);
	if (ballxy.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
	if (ballxy.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
	
	if (ballxy.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
	if (ballxy.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
}
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
		
		theTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
		theTimer.frameInterval = 2;//1 = 60fps, 2 = 30fps
		[theTimer addToRunLoop: [NSRunLoop currentRunLoop]
					   forMode: NSDefaultRunLoopMode];
		physicsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(gameLogic) userInfo:nil repeats:YES];
		//fpsCounter = CFAbsoluteTimeGetCurrent();
	}
}
- (void)drawGame {
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();;
	
	//Draw the goal
	//CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0);
	if (goalStart.x+cameraPos.x > -20 && goalStart.x+cameraPos.x < 500
		&& goalStart.y+cameraPos.y > -20 && goalStart.y+cameraPos.y < 340) {
		CGContextSetRGBStrokeColor(context, 1.0, 0.8, 0.0, 1.0);
		CGContextMoveToPoint(context, goalStart.x+cameraPos.x, goalStart.y+cameraPos.y);
		CGContextAddCurveToPoint(context,goalControl1.x+cameraPos.x, goalControl1.y+cameraPos.y, 
								 goalControl2.x+cameraPos.x, goalControl2.y+cameraPos.y, goalEnd.x+cameraPos.x, goalEnd.y+cameraPos.y);
		CGContextStrokePath(context);
	}
	//CGContextRestoreGState (context);
	
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
	CGRect rectangle = CGRectMake(ballxy.x+cameraPos.x,ballxy.y+cameraPos.y,ballrad*2,ballrad*2);
	CGContextAddEllipseInRect(context, rectangle);
	CGContextStrokePath(context); 
    CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	

	//CGContextSetLineWidth(context, 2.0);
	int e = 0;
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		
		
		
		
		if (480 >= curve.xBounds.x+cameraPos.x && 0 <= curve.xBounds.y+cameraPos.x &&
			320 >= curve.yBounds.x+cameraPos.y && 0 <= curve.yBounds.y+cameraPos.y) {
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
				CGContextMoveToPoint(context, curve.curve0.x+cameraPos.x, curve.curve0.y+cameraPos.y);
				
				CGContextAddQuadCurveToPoint(context, curve.curve1.x+cameraPos.x, curve.curve1.y+cameraPos.y, curve.curve2.x+cameraPos.x, curve.curve2.y+cameraPos.y);
				
				//CGContextStrokePath(context);
			} else {
				CGContextMoveToPoint(context, curve.snap0.x+cameraPos.x, curve.snap0.y+cameraPos.y);
				
				CGContextAddQuadCurveToPoint(context, curve.snap1.x+cameraPos.x, curve.snap1.y+cameraPos.y, curve.snap2.x+cameraPos.x, curve.snap2.y+cameraPos.y);
				
				//CGContextStrokePath(context);
				
				CGContextMoveToPoint(context, curve.snap3.x+cameraPos.x, curve.snap3.y+cameraPos.y);
				
				CGContextAddQuadCurveToPoint(context, curve.snap4.x+cameraPos.x, curve.snap4.y+cameraPos.y, curve.snap5.x+cameraPos.x, curve.snap5.y+cameraPos.y);
				
				//CGContextStrokePath(context);
			}
			CGContextStrokePath(context);
			//CGContextDrawPath(context, kCGPathStroke);
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
	
	//Run line collisions
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
		if (ballxy.x >= curve.xBounds.x-40 && ballxy.x <= curve.xBounds.y+40 &&
			ballxy.y >= curve.yBounds.x-40 && ballxy.y <= curve.yBounds.y+40) {
			
			//Run line end-point circle collisions
			for (int e = 1; e < 2 && curve.type != lineImag; e ++) {
				double cx,cy;
				if (e == 1) {
					cx = curve.curve0.x-ballrad;
					cy = curve.curve0.y-ballrad;
				} else {
					cx = curve.curve2.x-ballrad;
					cy = curve.curve2.y-ballrad;
				}
				if ([self collisionOfCircles:ballxy rad:ballrad c2:CGPointMake(cx,cy) rad:1.0]) {
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
			
			//Ball is near curve, now check if it's touching any point of the curve
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
				
				if ( bry > p0y - br && brx > p0x && brx < p1rx && cp > 0 && !(p0x == p1x && p0y == p1y)) {
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
		ballxy = originalBallxy;
	}
	if (dead) {
		ballxy = originalBallxy;
	}
}

- (void)drawRect:(CGRect)rect {
    [self drawGame];
}

- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r  {
	float a, dx, dy, d, h, rx, ry;
	float x2, y2;
	
	/* dx and dy are the vertical and horizontal distances between
	 * the circle centers.
	 */
	dx = c2.x - c1.x;
	dy = c2.y - c1.y;
	
	/* Determine the straight-line distance between the centers. */
	//d = sqrt((dy*dy) + (dx*dx));
	d = hypot(dx,dy); // Suggested by Keith Briggs
	
	/* Check for solvability. */
	if (d > (c1r + c2r))
	{
		/* no solution. circles do not intersect. */
		return FALSE;
	}
	if (d < abs(c1r - c2r))
	{
		/* no solution. one circle is contained in the other */
		return TRUE;
	}
	
	/* 'point 2' is the point where the line through the circle
	 * intersection points crosses the line between the circle
	 * centers.  
	 */
	
	/* Determine the distance from point 0 to point 2. */
	a = ((c1r*c1r) - (c2r*c2r) + (d*d)) / (2.0 * d) ;
	
	/* Determine the coordinates of point 2. */
	x2 = c1.x + (dx * a/d);
	y2 = c1.y + (dy * a/d);
	
	/* Determine the distance from point 2 to either of the
	 * intersection points.
	 */
	h = sqrt((c1r*c1r) - (a*a));
	
	/* Now determine the offsets of the intersection points from
	 * point 2.
	 */
	rx = -dy * (h/d);
	ry = dx * (h/d);
	
	/* Determine the absolute intersection points. */
	
	return TRUE;
}

- (void)dealloc {
	[self pauseGame];
	[reverseGravity release];
	[curves release];
    [super dealloc];
}

@end
