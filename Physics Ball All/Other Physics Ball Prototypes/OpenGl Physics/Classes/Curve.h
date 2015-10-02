#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define lineReg 0
#define lineRed 1
#define lineInvis 2
#define lineImag 3
#define lineBounce 4
#define lineBend 5


@interface Curve : NSObject {
	CGPoint curve0,curve1,curve2;
	CGPoint originalCurve0,originalCurve1,originalCurve2;
	NSMutableArray *curvePtX,*curvePtY;
	int type;
	BOOL snapped;
	CGPoint snap0,snap1,snap2;
	CGPoint snap3,snap4,snap5;
	
	CGPoint xBounds;
	CGPoint yBounds;
}
@property(nonatomic) CGPoint curve0,curve1,curve2, originalCurve0,originalCurve1,originalCurve2;
@property(nonatomic) int type;
@property(nonatomic, assign) NSMutableArray *curvePtX,*curvePtY;
@property(nonatomic) BOOL snapped;
@property(nonatomic) CGPoint snap0,snap1,snap2,snap3,snap4,snap5,xBounds,yBounds;
@property(nonatomic, assign) CALayer* layer;
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext;
- (id)initWithCurves:(CGPoint)pt1 and:(CGPoint)pt2 and:(CGPoint)pt3;
- (void)sync;
- (float)bezierLength:(CGPoint)p0 p1:(CGPoint)p1 p2:(CGPoint)p2;
- (void)drawCurve:(float)width color:(float[])color from:(CGPoint)point1 control:(CGPoint)point2 to:(CGPoint)point3;
- (void)drawAt:(CGPoint)position;
@end
