#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "AppDelegate.h"

@interface EAGLView (EAGLViewPrivate)

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@interface EAGLView (EAGLViewSprite)

- (void)setupView;

@end

@implementation EAGLView
AppDelegate* delegate;

@synthesize animating;
@dynamic animationFrameInterval;

// You must implement this
+ (Class) layerClass
{
	return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder])) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
		if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
			[self release];
			return nil;
		}
		
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
		
		[self setupView];
		[self drawView];
	}
	
	return self;
}


- (void)layoutSubviews
{
	[EAGLContext setCurrentContext:context];
	[self destroyFramebuffer];
	[self createFramebuffer];
	[self drawView];
}


- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	
	return YES;
}


- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if(depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}

- (void) startAnimation
{
	delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:delegate selector:@selector(timerTick)];
			[displayLink setFrameInterval:1];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0 / 60.0) target:delegate selector:@selector(timerTick) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}

- (void)setupView
{
	// Sets up matrices and transforms for OpenGL ES
	glViewport(0, 0, backingWidth, backingHeight);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, 320, 0, 480, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	//Landscape right
	glRotatef(-90.0, 0.0f, 0.0f, 1.0f);
	glTranslatef(-480.0, 0.0, 0.0f );
	
	// Initialize OpenGL states
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glEnableClientState(GL_VERTEX_ARRAY);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void)drawView {
	// Make sure that you are drawing to the current context
	[EAGLContext setCurrentContext:context];
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	glClear(GL_COLOR_BUFFER_BIT);
	
	
	// Set client states so that the Texture Coordinate Array will be used during rendering
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Enable Texture_2D
	glEnable(GL_TEXTURE_2D);
	
	// Enable blending as we want the transparent parts of the image to be transparent
	glEnable(GL_BLEND);
	
	
	[delegate draw];
	
	// Now we are done drawing disable blending
	glDisable(GL_BLEND);
	
	// Disable as necessary
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}
- (void)drawRect:(CGRect)rect color:(float[])color {
	/**
	 GLfloat vertx[4*2];
	 
	 vertx[2] = rect.origin.x;
	 vertx[3] = 320-rect.origin.y;
	 vertx[0] = rect.size.width;
	 vertx[1] = 320-rect.origin.y;
	 vertx[4] = rect.size.width;
	 vertx[5] = 320-rect.size.height;
	 vertx[6] = rect.origin.x;
	 vertx[7] = 320-rect.size.height;
	 
	 GLfloat colors[4 * 4];
	 
	 for(int i = 0; i < 4 * 4; i++) {
	 colors[i] = color[0];
	 colors[++i] = color[1];
	 colors[++i] = color[2];
	 colors[++i] = color[3];
	 }
	 glEnable(GL_BLEND);
	 //glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	 glDisable(GL_DEPTH_TEST);
	 
	 glVertexPointer(2, GL_FLOAT, 0, vertx);
	 glEnableClientState(GL_VERTEX_ARRAY);
	 glColorPointer(4, GL_FLOAT, 0, colors);
	 glEnableClientState(GL_COLOR_ARRAY);
	 glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	 glDisableClientState(GL_COLOR_ARRAY);
	 
	 //glEnable(GL_DEPTH_TEST);
	 glDisable(GL_BLEND);
	 **/
	// Replace the implementation of this method to do your own custom drawing
	
	glDisable(GL_TEXTURE_2D);
	
	GLfloat squareVertices[] = {
        rect.origin.x,  rect.origin.y,
		rect.size.width, rect.origin.y,
        rect.origin.x,  rect.size.height,
		rect.size.width,  rect.size.height,
    };
	
	GLubyte squareColors[] = {
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
    };
	glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glEnable(GL_TEXTURE_2D);
}
- (void)drawLine:(float)width color:(float[])color from:(CGPoint)point1 to:(CGPoint)point2 {
	glDisable(GL_TEXTURE_2D);
	
	GLfloat* vertices;
	vertices = (float *)malloc(2*2 * sizeof(float));
	vertices[0] = point1.x;
	vertices[1] = point1.y;
	vertices[2] = point2.x;
	vertices[3] = point2.y;
	glVertexPointer(2, GL_FLOAT, 0, vertices); 
	glLineWidth(1.0*width);
	glColor4f(color[0], color[1], color[2], color[3]*0.5);
	glDrawArrays(GL_LINE_STRIP, 0, 2);
	glLineWidth(2.0*width);
	glColor4f(color[0], color[1], color[2], color[3]*0.3);
	glDrawArrays(GL_LINE_STRIP, 0, 2);
	glLineWidth(3.0*width);
	glColor4f(color[0], color[1], color[2], color[3]*0.2);
	glDrawArrays(GL_LINE_STRIP, 0, 2);
	free(vertices);
	
	glEnable(GL_TEXTURE_2D);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	[delegate touchBegan:CGPointMake([touch locationInView:self].x, 480-[touch locationInView:self].y)];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	[delegate touchMoved:CGPointMake([touch locationInView:self].x, 480-[touch locationInView:self].y)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	[delegate touchEnded:CGPointMake([touch locationInView:self].x, 480-[touch locationInView:self].y)];
}


// Release resources when they are no longer needed.
- (void)dealloc
{
	if([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[context release];
	context = nil;
	
	[super dealloc];
}

@end
