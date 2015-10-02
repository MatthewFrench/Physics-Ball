//
//  Text.h
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface Text : NSObject {
	CGPoint pos;
	NSString* text;
	CALayer* layer;
}
@property(nonatomic) CGPoint pos;
@property(nonatomic,retain) NSString* text;
@property(nonatomic, assign) CALayer* layer;
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext;
- (id)initWithText:(NSString*)string pos:(CGPoint)textpos;
-(void) setText:(NSString *)newText;
@end
