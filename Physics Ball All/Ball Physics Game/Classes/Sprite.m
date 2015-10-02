#import "Sprite.h"

@implementation Sprite
@synthesize position, vel;
- (id)init 
{
	//if (self = [super init])
	position = CGPointMake(0,0);
	vel = CGPointMake(0, 0);
	return self;
}
- (id)initWithPosition:(CGPoint)initPosition vel:(CGPoint)velocity
{
	//if (self = [super init])
	position = initPosition;
	vel = velocity;
	return self;
}
//encode the data
- (void) encodeWithCoder: (NSCoder *)coder
{   

} 
//init from coder
- (id) initWithCoder: (NSCoder *) coder
{
    [self init];
    return self;
}
-(void)dealloc {
	[super dealloc];
}
@end
