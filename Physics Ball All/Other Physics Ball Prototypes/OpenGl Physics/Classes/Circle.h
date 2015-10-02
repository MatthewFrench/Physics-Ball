#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "Image.h"

@interface Circle : NSObject {
	float radius;
	float colorR, colorG, colorB, colorA;
	Image* texture;
}

@property(nonatomic) float radius, colorR, colorG, colorB, colorA;

- (id)initWithRadius:(float)rad colorR:(float)r colorG:(float)g colorB:(float)b colorA:(float)a;
- (void)drawAt:(CGPoint)position;
@end
