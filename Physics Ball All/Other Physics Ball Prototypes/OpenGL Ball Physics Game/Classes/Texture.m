//
//  Texture.m
//  OpenGl TEST
//
//  Created by Matthew French on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Texture.h"

#define kMaxTextureSize	 1024

@implementation Texture
@synthesize width,height;

- (id) initWithImageAtPath:(NSString *)path {
	UIImage* image = [UIImage imageNamed:path];
	width = image.size.width;
	height = image.size.height;
	return [self initWithImage:image filter:GL_NEAREST];
}

- (id) initWithImage:(UIImage *)uiImage filter:(GLenum)filter
{
	NSUInteger				imageWidth,
	imageHeight,
	i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;
	CGImageRef				image;
	UIImageOrientation		orientation;
	BOOL					sizeToFit = NO;
	
	
	image = [uiImage CGImage];
	orientation = [uiImage imageOrientation]; 
	
	if(image == NULL) {
		[self release];
		NSLog(@"Image is Null");
		return nil;
	}
	
	
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	if(CGImageGetColorSpace(image)) {
		if(hasAlpha)
			pixelFormat = kTexture2DPixelFormat_RGBA8888;
		else
			//Messing up gradients so changing to full quality
			pixelFormat = kTexture2DPixelFormat_RGBA8888;
	} else  //NOTE: No colorspace means a mask image
		pixelFormat = kTexture2DPixelFormat_A8;
	
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	imageWidth = imageSize.width;
	
	if((imageWidth != 1) && (imageWidth & (imageWidth - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < imageWidth)
			i *= 2;
		imageWidth = i;
	}
	imageHeight = imageSize.height;
	if((imageHeight != 1) && (imageHeight & (imageHeight - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < imageHeight)
			i *= 2;
		imageHeight = i;
	}
	while((imageWidth > kMaxTextureSize) || (imageHeight > kMaxTextureSize)) {
		imageWidth /= 2;
		imageHeight /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat) {		
		case kTexture2DPixelFormat_RGBA8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(imageHeight * imageWidth * 4);
			context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, 4 * imageWidth, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(imageHeight * imageWidth * 4);
			context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, 4 * imageWidth, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_A8:
			data = malloc(imageHeight * imageWidth);
			context = CGBitmapContextCreate(data, imageWidth, imageHeight, 8, imageWidth, NULL, kCGImageAlphaOnly);
			break;				
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	
	CGContextClearRect(context, CGRectMake(0, 0, imageWidth, imageHeight));
	CGContextTranslateCTM(context, 0, imageHeight - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = malloc(imageHeight * imageWidth * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < imageWidth * imageHeight; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:imageWidth pixelsHigh:imageHeight contentSize:imageSize filter:filter];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}
- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)imageWidth pixelsHigh:(NSUInteger)imageHeight contentSize:(CGSize)size filter:(GLenum)filter
{
	GLint					saveName;
	if((self = [super init])) {
		glGenTextures(1, &_name);
		glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
		glBindTexture(GL_TEXTURE_2D, _name);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filter);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filter);
		switch(pixelFormat) {
				
			case kTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case kTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, imageWidth, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, imageWidth, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
				
		}
		glBindTexture(GL_TEXTURE_2D, saveName);
		
		_size = size;
		_width = imageWidth;
		_height = height;
		_format = pixelFormat;
		_maxS = size.width / (float)width;
		_maxT = size.height / (float)height;
	}					
	return self;
}
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger			 stringWidth,
	stringHeight,
	i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	UIFont *				font;
	
	font = [UIFont fontWithName:name size:size];
	
	stringWidth = dimensions.width;
	if((stringWidth != 1) && (stringWidth & (stringWidth - 1))) {
		i = 1;
		while(i < stringWidth)
			i *= 2;
		stringWidth = i;
	}
	stringHeight = dimensions.height;
	if((stringHeight != 1) && (stringHeight & (stringHeight - 1))) {
		i = 1;
		while(i < stringHeight)
			i *= 2;
		stringHeight = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(stringHeight, stringWidth);
	context = CGBitmapContextCreate(data, stringWidth, stringHeight, 8, stringWidth, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, stringHeight);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
	[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:stringWidth pixelsHigh:stringHeight contentSize:dimensions filter:GL_LINEAR];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}


- (void) drawAtPoint:(CGPoint)point 
{
	GLfloat		coordinates[] = { 0,	_maxT,
		_maxS,	_maxT,
		0,		0,
		_maxS,	0 };
	GLfloat	imageWidth = (GLfloat)_width * _maxS,
	imageHeight = (GLfloat)_height * _maxT;
	GLfloat		vertices[] = {	-imageWidth / 2 + point.x,	-imageHeight / 2 + point.y,	0.0,
		imageWidth / 2 + point.x,	-imageHeight / 2 + point.y,	0.0,
		-imageWidth / 2 + point.x,	imageHeight / 2 + point.y,	0.0,
		imageWidth / 2 + point.x,	imageHeight / 2 + point.y,	0.0 };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void) drawInRect:(CGRect)rect
{
	GLfloat	 coordinates[] = {  0,		_maxT,
		_maxS,	_maxT,
		0,		0,
		_maxS,	0  };
	GLfloat	vertices[] = {	rect.origin.x,							rect.origin.y,							0.0,
		rect.origin.x + rect.size.width,		rect.origin.y,							0.0,
		rect.origin.x,							rect.origin.y + rect.size.height,		0.0,
		rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		0.0 };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void) dealloc{
	if(_name)
	glDeleteTextures(1, &_name);
	
	[super dealloc];
}
@end
