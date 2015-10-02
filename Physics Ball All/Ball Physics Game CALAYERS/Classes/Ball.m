//
//  Ball.m
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"
#import "AppDelegate.h"


@implementation Ball

@synthesize originalballxy,ballxy,ballvel,ballrad,layer;
- (id)init {
	player = TRUE;
	
	layer = [CALayer layer];
	[layer retain];
	layer.bounds = CGRectMake(-5, -5, 20+15, 20+15);
	[layer setAnchorPoint:CGPointMake(0.0,0.0)];
	[layer setDelegate:self];
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.contentsScale = [UIScreen mainScreen].scale;
	return self;
}
- (id)initWithRad:(float)rad pos:(CGPoint)pos vel:(CGPoint)vel{
	self = [super init];
	if (self != nil) {
		ballrad = rad;
		originalballxy = pos;
		ballxy = pos;
		ballvel = vel;
		
	}
	return self;
}
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext
{	
	//CGSize size = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16]];
	//AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	//Draw Shadow
	CGContextSaveGState(theContext);
    CGContextSetShadow (theContext, CGSizeMake(5, 5), 5); 
	
	//Draw Circle
	CGContextSetLineWidth(theContext, 2.0);
	if (player) {
		CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 1.0, 1.0);
	} else {
		CGContextSetRGBStrokeColor(theContext, 0.0, 0.0, 0.0, 1.0);
	}
	CGRect rectangle = CGRectMake(0,0,ballrad*2,ballrad*2);
	CGContextAddEllipseInRect(theContext, rectangle);
	CGContextStrokePath(theContext); 
    CGContextRestoreGState (theContext);     //Restore the context to the previously saved state in case you want to do something else.
}
//encode the data
- (void) encodeWithCoder: (NSCoder *)coder
{   
	[coder encodeObject:[NSNumber numberWithFloat:originalballxy.x] forKey:@"originalballxy.x"];
	[coder encodeObject:[NSNumber numberWithFloat:originalballxy.y] forKey:@"originalballxy.y"];
	[coder encodeObject:[NSNumber numberWithFloat:ballxy.x] forKey:@"ballxy.x"];
	[coder encodeObject:[NSNumber numberWithFloat:ballxy.y] forKey:@"ballxy.y"];
	[coder encodeObject:[NSNumber numberWithFloat:ballvel.x] forKey:@"ballvel.x"];
	[coder encodeObject:[NSNumber numberWithFloat:ballvel.y] forKey:@"ballvel.y"];
	[coder encodeObject:[NSNumber numberWithFloat:ballrad] forKey:@"ballrad"];
} 
//init from coder
- (id) initWithCoder: (NSCoder *) coder
{
    [self init];
	originalballxy.x = [[coder decodeObjectForKey:@"originalballxy.x"] floatValue];
	originalballxy.y = [[coder decodeObjectForKey:@"originalballxy.y"] floatValue];
	ballxy.x = [[coder decodeObjectForKey:@"ballxy.x"] floatValue];
	ballxy.y = [[coder decodeObjectForKey:@"ballxy.y"] floatValue];
	ballvel.x = [[coder decodeObjectForKey:@"ballvel.x"] floatValue];
	ballvel.y = [[coder decodeObjectForKey:@"ballvel.y"] floatValue];
	ballrad = [[coder decodeObjectForKey:@"ballrad"] floatValue];
	player = FALSE;
	
	layer = [CALayer layer];
	[layer retain];
	layer.bounds = CGRectMake(-5, -5, ballrad*2+15, ballrad*2+15);
	[layer setAnchorPoint:CGPointMake(0.0,0.0)];
	[layer setDelegate:self];
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
    layer.contentsScale = [[UIScreen mainScreen] scale];
    return self;
}
-(void) dealloc {
	[layer removeFromSuperlayer];
	[layer release];
	[super dealloc];
}

@end
