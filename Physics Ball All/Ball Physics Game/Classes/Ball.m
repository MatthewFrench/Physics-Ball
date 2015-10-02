//
//  Ball.m
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"


@implementation Ball

@synthesize originalballxy,ballxy,ballvel,ballrad;
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
    return self;
}
-(void) dealloc {
	[super dealloc];
}

@end
