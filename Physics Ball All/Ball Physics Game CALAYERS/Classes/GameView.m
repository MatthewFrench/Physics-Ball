#import "GameView.h"
#import "AppDelegate.h"

@implementation GameView


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    
    if ((self = [super initWithCoder:coder])) {
		screenDimensions = CGPointMake([self bounds].size.height, [self bounds].size.width);
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
		//[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	}
    return self;
	
}
/**
- (void)drawRect:(CGRect)rect {
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate drawGame];
}
**/
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSArray* allTouches = [touches allObjects];
	
	for (int i = 0; i < [allTouches count]; i +=1) {
		if (delegate.touch1 == nil) {
			delegate.touch1 = [allTouches objectAtIndex:i];
			CGPoint touch = CGPointMake([[allTouches objectAtIndex:i] locationInView:self].x, [[allTouches objectAtIndex:i] locationInView:self].y);
			delegate.touchedScreen1 = touch;
			
			
		} else if (delegate.touch2 == nil) {
			delegate.touch2 = [allTouches objectAtIndex:i];
			CGPoint touch = CGPointMake([[allTouches objectAtIndex:i] locationInView:self].x, [[allTouches objectAtIndex:i] locationInView:self].y);
			delegate.touchedScreen2 = touch;
		}
	}
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSArray* allTouches = [touches allObjects];
	
	for (int i = 0; i < [allTouches count]; i +=1) {
		if ([allTouches objectAtIndex:i] == delegate.touch1) {
			CGPoint touch = CGPointMake([[allTouches objectAtIndex:i] locationInView:self].x, [[allTouches objectAtIndex:i] locationInView:self].y);
			delegate.touchedScreen1 = touch;
		} else if ([allTouches objectAtIndex:i] == delegate.touch2) {
			CGPoint touch = CGPointMake([[allTouches objectAtIndex:i] locationInView:self].x, [[allTouches objectAtIndex:i] locationInView:self].y);
			delegate.touchedScreen2 = touch;
		}
	}
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	
	NSArray* allTouches = [touches allObjects];
	
	for (int i = 0; i < [allTouches count]; i +=1) {
		if ([allTouches objectAtIndex:i] == delegate.touch1) {
			CGPoint touch = CGPointMake([[allTouches objectAtIndex:i] locationInView:self].x, [[allTouches objectAtIndex:i] locationInView:self].y);
			delegate.touchedScreen1 = touch;
			delegate.touch1 = nil;
		} else if ([allTouches objectAtIndex:i] == delegate.touch2) {
			CGPoint touch = CGPointMake([[allTouches objectAtIndex:i] locationInView:self].x, [[allTouches objectAtIndex:i] locationInView:self].y);
			delegate.touchedScreen2 = touch;
			delegate.touch2 = nil;
		}
		
	}
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
    [super dealloc];
}

@end
