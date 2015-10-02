#import <UIKit/UIKit.h>

@interface GameView : UIView {
	CGPoint screenDimensions;
}
- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;
@end
