//
//  Text.m
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Text.h"
#import "AppDelegate.h"


@implementation Text
@synthesize pos,text,layer;
- (id)initWithText:(NSString*)string pos:(CGPoint)textpos{
	self = [super init];
	if (self != nil) {
		pos = textpos;
		text = string;
		[text retain];
	}
	return self;
}

- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{	
	//CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16]];
	//AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	UIGraphicsPushContext(theContext);
		[text drawAtPoint:CGPointMake(0, 0) withFont:[UIFont fontWithName:@"Helvetica" size:16]];
	UIGraphicsPopContext();
}

-(void) setText:(NSString *)newText {
	[text release];
	text = nil;
	text = newText;
	[text retain];
}
//encode the data
- (void) encodeWithCoder: (NSCoder *)coder
{   
	[coder encodeObject:[NSNumber numberWithFloat:pos.x] forKey:@"pos.x"];
	[coder encodeObject:[NSNumber numberWithFloat:pos.y] forKey:@"pos.y"];
	[coder encodeObject:text forKey:@"text"];
} 
//init from coder
- (id) initWithCoder: (NSCoder *) coder
{
	[self init];
	pos.x = [[coder decodeObjectForKey:@"pos.x"] floatValue];
	pos.y = [[coder decodeObjectForKey:@"pos.y"] floatValue];
	text = [coder decodeObjectForKey:@"text"];
	[text retain];
	
	CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16]];
	
	
	layer = [CALayer layer];
	[layer retain];
	layer.bounds = CGRectMake(0, 0, size.width, size.height);
	[layer setDelegate:self];
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return self;
}
-(void) dealloc {
	[layer removeFromSuperlayer];
	[layer release];
	[text release];
	[super dealloc];
}

@end