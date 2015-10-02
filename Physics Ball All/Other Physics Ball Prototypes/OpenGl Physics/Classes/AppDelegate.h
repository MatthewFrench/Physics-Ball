#import "Level.h"


@class EAGLView;

@interface AppDelegate : NSObject <UIApplicationDelegate,UIAccelerometerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet EAGLView *glView;
	
	Level* level;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) EAGLView *glView;

-(void)timerTick;
-(void)draw;
-(void)touchBegan:(CGPoint)pos;
-(void)touchMoved:(CGPoint)pos;
-(void)touchEnded:(CGPoint)pos;

@end

