//
//  Text.m
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Text.h"


@implementation Text
@synthesize pos,text;
- (id)initWithText:(NSString*)string pos:(CGPoint)textpos{
	self = [super init];
	if (self != nil) {
		pos = textpos;
		text = string;
		[text retain];
	}
	return self;
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
    return self;
}
-(void) dealloc {
	[text release];
	[super dealloc];
}

@end