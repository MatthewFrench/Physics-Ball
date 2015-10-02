#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

@interface GameView : NSView {
	CGPoint screenDimensions;
	CALayer* theRootLayer;
}
@property(nonatomic,assign) CALayer *theRootLayer;
- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;
@end
