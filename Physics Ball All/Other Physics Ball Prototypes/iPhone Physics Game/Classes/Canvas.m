//
//  Canvas.m
//  iPad Quartz Vector Drawing
//
//  Created by Matthew French on 8/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Canvas.h"


@implementation Canvas


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	ballxy = CGPointMake(100, 100);
	ballrad = 10;
	gravity = 0.2;
	
	curves = [[NSMutableArray alloc] init];
	
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(0, 200) 
											 and:CGPointMake(self.bounds.size.width/2.0, 300) 
											 and:CGPointMake(self.bounds.size.width, 200)];
	[curves addObject:curve];
	[curve release];
	Curve* curve2 = [[Curve alloc] initWithCurves:CGPointMake(2, 0) 
											 and:CGPointMake(2, 200/2.0) 
											 and:CGPointMake(2, 200)];
	[curves addObject:curve2];
	[curve2 release];
	Curve* curve3 = [[Curve alloc] initWithCurves:CGPointMake(self.bounds.size.width - 2.0, 200) 
											  and:CGPointMake(self.bounds.size.width - 2.0, 200/2.0) 
											  and:CGPointMake(self.bounds.size.width - 2.0, 0)];
	[curves addObject:curve3];
	[curve3 release];
	Curve* curve4 = [[Curve alloc] initWithCurves:CGPointMake(self.bounds.size.width, 2.0) 
											  and:CGPointMake(self.bounds.size.width/2.0, 2.0) 
											  and:CGPointMake(0, 2.0)];
	[curves addObject:curve4];
	[curve4 release];
	
	[self configureAccelerometer];
	gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(gameTimerTick) userInfo:nil repeats:YES];
	
	CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(M_PI/2.0);
	landscapeTransform = CGAffineTransformTranslate (landscapeTransform, +80.0, +100.0);
	
	[self setTransform:landscapeTransform];
}

- (void)gameTimerTick {
	[self runPhysics];
	[self setNeedsDisplay];
}

- (void)runPhysics {
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
			for ( int p = 0 ; p < [curve.curvePtX count] - 1 ; p++ ) {
				
				CGPoint p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue], [[curve.curvePtY objectAtIndex:p] floatValue]);
				CGPoint p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue], [[curve.curvePtY objectAtIndex:p+1] floatValue]);
				
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
					
					// calc new Vector //
					
					float vx = bvy * sin1 + bvx * cos1;
					float vy = bvy * cos1 - bvx * sin1;
					
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
				
			}
}
			
			//if ( bx < br - 200 ) bx = br - 200, bvx = -bvx;
			//if ( bx > 200 - br ) bx = 200 - br, bvx = -bvx;
			
			ballxy.x = bx;
			ballxy.y = by;
			
			ballvel.x = bvx;
			ballvel.y = bvy;
			
	//if ( ballxy.y > 500 + br ) {
	//	ballxy.y = 0;
	//	ballxy.x = 50;
	//	ballvel.y = 0;
	//	ballvel.x = 0;
	//}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	//Draw Gradient Ball
	//CGContextSaveGState(context);
	//CGGradientRef myGradient;
	//CGColorSpaceRef myColorspace;
	//size_t num_locations = 2;
	//CGFloat locations[2] = { 0.0, 1.0 };
	//CGFloat components[8] = { 0.9, 0.9, 1.0, 1.0,  // Start color
	//	1.0, 1.0, 0.0, 1.0 }; // End color
	//myColorspace = CGColorSpaceCreateDeviceRGB();
	//myGradient = CGGradientCreateWithColorComponents (myColorspace,components,locations, num_locations);
	//CGColorSpaceRelease(myColorspace);
	//CGContextDrawRadialGradient(context, myGradient, CGPointMake(ballxy.x+ballrad/2, ballxy.y+ballrad/2), 0, CGPointMake(ballxy.x+ballrad, ballxy.y+ballrad), ballrad, 0);
	//CGContextRestoreGState(context);
	
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
		CGContextSetLineWidth(context, 2.0);
	
		CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
	
		CGContextMoveToPoint(context, curve.curve0.x, curve.curve0.y);
	
		CGContextAddQuadCurveToPoint(context, curve.curve1.x, curve.curve1.y, curve.curve2.x, curve.curve2.y);
	
		CGContextStrokePath(context);
	
		//CGContextRestoreGState (context);
	}
}
-(void) gradientColorWithRed:(CGFloat)aRed green:(CGFloat)aGreen blue:(CGFloat)aBlue
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	colorArray = [[NSArray arrayWithObjects:[NSNumber numberWithFloat:aRed],[NSNumber numberWithFloat:aGreen],[NSNumber numberWithFloat:aBlue],nil] retain];
	CGFloat colors[] =
	{
		aRed, aGreen, aBlue, 1,
		0, 1, 1, 1.0,
	};
	gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*3));
	CGColorSpaceRelease(rgb);
	
	self.backgroundColor = [UIColor clearColor];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	NSArray* allTouches = [touches allObjects];
	CGPoint touch = CGPointMake([[allTouches objectAtIndex:0] locationInView:self].x, [[allTouches objectAtIndex:0] locationInView:self].y);
	ballxy = CGPointMake(touch.x-ballrad, touch.y-ballrad);
	ballvel = CGPointMake(0, 0);
	
	/**
	 float xleg = touch.x-starttoset.x;
	 float yleg = touch.y-starttoset.y;
	 float hypotenuse = sqrt((xleg*xleg)+(yleg*yleg));
	 CFTimeInterval time = CFAbsoluteTimeGetCurrent();
	 float delta = (time - swipetimer);
	 //NSLog(@"Delta: %f vs Max:%f", delta,  swipetimermax);
	 if (delta < swipetimermax && hypotenuse >= swipemindist) {
	 startpoint = starttoset;
	 endpoint = touch;
	 swiperotation = atan2(yleg, xleg) / M_PI * 180;
	 rotationVel += hypotenuse*delta;
	 }
	 **/
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
	accelGravity.x = -acceleration.y * gravity;
    accelGravity.y = 0.2; //Disabled vertical gravity+
	
}

- (void)dealloc {
	[gameTimer invalidate];
    [super dealloc];
}


@end
