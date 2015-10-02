#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Menu.h"
#import "GameView.h"
#import "Texture2D.h"
#import "Image.h"
#import "Sprite.h"
#import "Curve.h"

@interface AppDelegate : NSObject <UIApplicationDelegate,UIAccelerometerDelegate> {
    UIWindow *window;
    Menu *menuController;
	CADisplayLink* theTimer;
	CFTimeInterval fpsCounter;
	
	 CGPoint touchedScreen1;
	 UITouch* touch1;
	 CGPoint touchedScreen2;
	 UITouch* touch2;
	
	int drawTimer;
	
	NSMutableArray *curves, *reverseGravityX,*reverseGravityY;
	CGPoint ballxy,ballvel,accelGravity;
	float ballrad;
	CGPoint goalStart,goalEnd,goalControl1,goalControl2, goalPos;
	Image* reverseGravity,*ball;
	int touchingReverseGravityNum;
	
	CGPoint cameraPos;
	CGRect levelDimensions;
	
	int currentLevel;
	
	
	
	IBOutlet GameView *gameView;
	IBOutlet UIView *mainMenuView,*instructionsView,*creditsView,*levelsView;
	
	
	//CGPoint testLine;
}
- (IBAction)toInstructions:(id)sender;
- (IBAction)toMenu:(id)sender;
- (IBAction)toCredits:(id)sender;
- (IBAction)toGameScreen:(id)sender;
- (IBAction)toLevelSelect:(id)sender;
- (IBAction)startLevel:(id)sender;
//- (IBAction)toMenuFromGameScreen:(id)sender;
- (void)pauseGame;
- (void)initializeTimer;
- (void)gameLogic;
- (void)drawGame;
- (void)switchView:(UIView*)oldView to:(UIView*)newView with:(UIViewAnimationTransition)trans time:(float)sec;
- (void)animationFinished;
- (void)runPhysics;
- (void)configureAccelerometer;
- (void)initializeLevel:(int)level;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Menu *menuController;

@property (nonatomic, assign) CGPoint touchedScreen1,touchedScreen2,cameraPos;
@property (nonatomic, assign) UITouch *touch1, *touch2;
@property (nonatomic, assign) GameView *gameView;

@end

