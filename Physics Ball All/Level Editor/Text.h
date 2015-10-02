//
//  Text.h
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Text : NSObject {
	CGPoint pos;
	NSString* text;
}
@property(nonatomic) CGPoint pos;
@property(nonatomic,retain) NSString* text;
- (id)initWithText:(NSString*)string pos:(CGPoint)textpos;
-(void) setText:(NSString *)newText;
@end
