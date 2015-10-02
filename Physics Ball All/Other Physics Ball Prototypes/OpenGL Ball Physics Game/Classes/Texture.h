#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8,
} Texture2DPixelFormat;

@interface Texture : NSObject {
	size_t width;
	size_t height;
	
	GLuint						_name;
	CGSize						_size;
	NSUInteger					_width,
	_height;
	Texture2DPixelFormat		_format;
	GLfloat						_maxS,
	_maxT;
}
@property(nonatomic) size_t width, height;
- (id) initWithImageAtPath:(NSString*)path;
- (id) initWithImage:(UIImage *)uiImage filter:(GLenum)filter;
- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)imageWidth pixelsHigh:(NSUInteger)imageHeight contentSize:(CGSize)size filter:(GLenum)filter;
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
- (void) drawAtPoint:(CGPoint)position;
- (void) drawInRect:(CGRect)rect;

@end
