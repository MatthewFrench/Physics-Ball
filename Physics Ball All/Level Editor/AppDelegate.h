//
//  Level_EditorAppDelegate.h
//  Level Editor
//
//  Created by Matthew French on 8/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import "GameView.h"
#import "Curve.h"
#import "Ball.h"
#import "Text.h"

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface AppDelegate : NSObject
#else
@interface AppDelegate : NSObject <NSApplicationDelegate>
#endif
{
    NSWindow *window;
	NSTimer* theTimer;
	int drawTimer,drawTimerMax;
	
	NSMutableArray *curves, *reverseGravityX,*reverseGravityY, *balls, *texts;
	CGPoint levelGravity,originalLevelGravity, playerGravity;
	Ball* player;
	
	CGPoint goalStart,goalEnd,goalControl1,goalControl2, goalPos;
	NSImage* reverseGravity;
	
	CGPoint mouseClick;
	
	BOOL holdingPlayer, holdingBall, ballNum, holdingText, textNum;
	BOOL holdingGoal, holdingGoalStart, holdingGoalEnd, holdingGoalControl1, holdingGoalControl2, holdingReverseGravity;
	BOOL holdingCurve, holdingCurveStart, holdingCurveEnd, holdingCurveControl;
	int curveNum, reverseGravityNum, touchingReverseGravityNum;
	
	BOOL testing;
	
	NSString* savePath;
	
	CGPoint cameraPos,originalCameraPos;
	CGRect levelDimensions;
	BOOL scrolling,holdingOriginScroll,holdingSizeScroll;
	CGPoint lastScroll;
	
	IBOutlet GameView *gameView;
	IBOutlet NSButton *selectRadio,*eraseRadio;
	IBOutlet NSTextField* addTextField,*gravTextX,*gravTextY;
}
- (void)drawGame;
- (IBAction)addText:(id)sender;
- (IBAction)addBall:(id)sender;
- (IBAction)addLineCurve:(id)sender;
- (IBAction)addDeathLine:(id)sender;
- (IBAction)addReverseGravity:(id)sender;
- (IBAction)addInvisibleLine:(id)sender;
- (IBAction)addImaginaryLine:(id)sender;
- (IBAction)addBouncyLine:(id)sender;
- (IBAction)addBendSnapLine:(id)sender;
- (void)drawHoldCircle:(CGPoint)position;
- (void)runPhysics;
- (void)runGravityForAllBalls;
- (void)runPhysicsForBendLines;
- (void)runPhysicsForBall:(Ball*)ball;
- (IBAction)testPlay:(id)sender;
- (IBAction)pressedSelect:(id)sender;
- (IBAction)pressedErase:(id)sender;
- (IBAction)pressedSave:(id)sender;
- (IBAction)pressedOpen:(id)sender;
- (void)mouseDown:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)keydown:(UniChar)key;
- (void)keyup:(UniChar)key;
-(void)startLevel;
-(void)endLevel;
- (void) eraseEverything;
- (IBAction)pressedNew:(id)sender;
- (IBAction)changedGravText:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,assign) IBOutlet GameView *gameView;
@property (nonatomic,assign) IBOutlet NSButton *selectRadio,*eraseRadio;
@property (nonatomic,assign) IBOutlet NSTextField * addTextField, *gravTextX,*gravTextY;
@property (nonatomic) CGPoint mouseClick;
@property (nonatomic) BOOL testing;

@end
