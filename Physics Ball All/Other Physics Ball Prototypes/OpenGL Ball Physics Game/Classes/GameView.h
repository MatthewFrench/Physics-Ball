#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "Image.h"

@interface GameView : UIView {
	CGPoint screenDimensions;
	CGPoint rotationOffset;
	CGPoint rotationNeg;
	float viewRotation,viewTranslationX,viewTranslationY;
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
}
@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) renderScene;
- (void) drawImage:(Image*)image AtPoint:(CGPoint)point;
- (void) drawRect:(CGRect)rect color:(float[])color;
- (void)setOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;
- (void)drawLine:(float)width color:(float[])color from:(CGPoint)point1 to:(CGPoint)point2;
- (void)drawCurve:(float)width color:(float[])color from:(CGPoint)point1 control:(CGPoint)point2 to:(CGPoint)point3;
- (void)drawLineAntialias:(int)X0 Y0:(int)Y0  X1:(int)X1 Y1:(int)Y1
				BaseColor:(float)BaseColor NumLevels:(int)NumLevels IntensityBits:(int)IntensityBits;
- (void)drawLineAntialias2:(int)x1 Y0:(int)y1  X1:(int)x2 Y1:(int)y2;
- (void)plot:(float)x y:(float)y c:(float)c;
- (float)ipart:(float)x;
- (float)roundX:(float)x;
- (float)fpart:(float)x;
- (float)rfpart:(float)x;
- (int)sgn:(int)num;
- (void)lineDraw2:(int)x0 y0:(int)y0 x1:(int)x1 y1:(int)y1
			color:(float)c;
@end
