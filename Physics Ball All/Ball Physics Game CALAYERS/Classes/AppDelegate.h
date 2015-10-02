#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Menu.h"
#import "GameView.h"
#import "Sprite.h"
#import "Curve.h"
#import "MenuView.h"
#import "Ball.h"
#import "Text.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate> {
    UIWindow *window;
    Menu *menuController;
	CADisplayLink* physicsTimer;
	CFTimeInterval fpsCounter;
	
	 CGPoint touchedScreen1;
	 UITouch* touch1;
	 CGPoint touchedScreen2;
	 UITouch* touch2;
	
	
	NSMutableArray *curves, *reverseGravityX,*reverseGravityY, *reverseGravityLayer,*balls,*texts;
	CGPoint levelGravity, playerGravity;

	Ball* player;
	CALayer* goalLayer;
	CGPoint goalStart,goalEnd,goalControl1,goalControl2, goalPos,goalXBounds,goalYBounds;
	UIImage* reverseGravity;
	int touchingReverseGravityNum;
	
	CGPoint cameraPos;
	CGRect levelDimensions;
	
	int currentLevel;
	BOOL endLevel;
	
	float gameSpeed;
	
	
	
	IBOutlet GameView *gameView;
	IBOutlet UIView *instructionsView,*creditsView,*levelsView;
	IBOutlet MenuView *mainMenuView;
	
	float yAcceleration;
}
- (IBAction)toInstructions:(id)sender;
- (IBAction)toMenu:(id)sender;
- (IBAction)toCredits:(id)sender;
- (IBAction)toGameScreen:(id)sender;
- (IBAction)toLevelSelect:(id)sender;
- (IBAction)startLevel:(id)sender;
- (void)demolishLevel;
- (void)pauseGame;
- (void)initializeTimer;
- (void)gameLogic;
- (void)switchView:(UIView*)oldView to:(UIView*)newView with:(UIViewAnimationTransition)trans time:(float)sec;
- (void)animationFinished;
- (void)runPhysics;
- (void)runGravityForAllBalls;
- (void)runPhysicsForBendLines;
- (void)runPhysicsForBall:(Ball*)ball;
- (void)configureAccelerometer;
- (void)initializeLevel:(int)level;
- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)theContext;
- (void)updateScreen;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Menu *menuController;

@property (nonatomic) float yAcceleration;
@property (nonatomic, assign) CGPoint touchedScreen1,touchedScreen2,cameraPos;
@property (nonatomic, assign) UITouch *touch1, *touch2;
@property (nonatomic, assign) GameView *gameView;

@end

