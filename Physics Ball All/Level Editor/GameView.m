#import "GameView.h"
#import "AppDelegate.h"

@implementation GameView
@synthesize theRootLayer;

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
		
		//[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	}
    return self;
	
}
- (id)init {
	
	return self;
}
- (void)awakeFromNib {
	screenDimensions = CGPointMake([self bounds].size.width, [self bounds].size.height);
}

- (void)drawRect:(NSRect)rect {
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [delegate drawGame];
}

- (void)mouseDown:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	delegate.mouseClick = aMousePoint;
	
	[delegate mouseDown:theEvent];
}
- (void)mouseDragged:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	delegate.mouseClick = aMousePoint;
	
	[delegate mouseDragged:theEvent];
}
- (void)mouseUp:(NSEvent*)theEvent{
	CGPoint aMousePoint = CGPointMake([self convertPoint:[theEvent locationInWindow] fromView:nil].x, [self convertPoint:[theEvent locationInWindow] fromView:nil].y);
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	delegate.mouseClick = aMousePoint;
	
	[delegate mouseUp:theEvent];
}

- (void)keyDown:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate keydown:aKey];
}
- (void)keyUp:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate keyup:aKey];
}
/**
- (BOOL)isFlipped{
    return YES;
}
 **/
- (BOOL)acceptsFirstResponder {
	return YES;
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
	if (theRootLayer) {
		[theRootLayer release];
    }
	[super dealloc];
}

@end
