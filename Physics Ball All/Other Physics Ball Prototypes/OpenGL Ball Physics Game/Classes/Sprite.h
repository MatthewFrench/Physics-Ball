#import <Foundation/Foundation.h>
#import "Image.h"
@class Sprite;


@interface Sprite : NSObject {
	//*****Sprite Vars***
	CGPoint position,vel;
};
- (id)initWithPosition:(CGPoint)initPosition vel:(CGPoint)velocity;
-(void) dealloc;

@property(nonatomic) CGPoint position, vel;

@end
