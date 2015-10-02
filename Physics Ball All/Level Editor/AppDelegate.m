//
//  Level_EditorAppDelegate.m
//  Level Editor
//
//  Created by Matthew French on 8/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#define lineReg 0
#define lineRed 1
#define lineInvis 2
#define lineImag 3
#define lineBounce 4
#define lineBend 5




/**
 Here's the idea. Don't use CALayers when editting, too hard as they can resize and be moved.
 Instead just use CALayers when test playing can curves don't resize, they just move.
 Good plan Matthew, good plan...
 Muhahahahaha. Hah.
 **/




@implementation AppDelegate

@synthesize window,mouseClick,gameView,selectRadio,eraseRadio,addTextField,gravTextX,gravTextY,testing;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	levelDimensions = CGRectMake(0, 0, 480, 320);
	cameraPos = CGPointMake(0, 0);
	mouseClick = CGPointMake(-1, -1);
	player = [[Ball alloc] initWithRad:10 pos:CGPointMake(0, 0) vel:CGPointMake(0, 0)];
	levelGravity.y = -0.1;
	goalPos = CGPointMake(400, 200);
	goalStart = CGPointMake(400-30, 200);
	goalEnd = CGPointMake(400+30, 200);
	goalControl1 = CGPointMake(400-20, 200+50);
	goalControl2 = CGPointMake(400+20, 200+50);
	curves = [[NSMutableArray alloc] init];
	balls = [[NSMutableArray alloc] init];
	texts = [[NSMutableArray alloc] init];
	reverseGravityX = [[NSMutableArray alloc] init];
	reverseGravityY = [[NSMutableArray alloc] init];
	reverseGravity = [NSImage imageNamed:@"reverse gravity.png"];
	[reverseGravity retain];
	savePath = @"";
	
	// Insert code here to initialize your application
	drawTimerMax = 2;
	theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}
- (IBAction)addLineCurve:(id)sender {
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(-cameraPos.x +480/2 - 40, -cameraPos.y +320/2 - 10) 
											 and:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2 - 50) 
											 and:CGPointMake(-cameraPos.x +480/2 + 40, -cameraPos.y +320/2 - 10)];
	[curves addObject:curve];
	[curve release];
	//[gameView.layer setDelegate:curve];
}
- (IBAction)addText:(id)sender {
	Text* text = [[Text alloc] initWithText: [addTextField stringValue] pos:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2)];
	[texts addObject:text];
	[text release];
}
- (IBAction)addBall:(id)sender {
	Ball* ball = [[Ball alloc] initWithRad:10 pos:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2) vel:CGPointMake(0, 0)];
	[balls addObject:ball];
	[ball release];
}
- (IBAction)addDeathLine:(id)sender {
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(-cameraPos.x +480/2 - 40, -cameraPos.y +320/2 - 10) 
											 and:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2 - 50) 
											 and:CGPointMake(-cameraPos.x +480/2 + 40, -cameraPos.y +320/2 - 10)];
	curve.type = lineRed;
	[curves addObject:curve];
	[curve release];
}
- (IBAction)addReverseGravity:(id)sender {
	[reverseGravityX addObject:[NSNumber numberWithInt:-cameraPos.x +480/2]];
	[reverseGravityY addObject:[NSNumber numberWithInt:-cameraPos.y +320/2]];
}
- (IBAction)addInvisibleLine:(id)sender{
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(-cameraPos.x +480/2 - 40, -cameraPos.y +320/2 - 10) 
											 and:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2 - 50) 
											 and:CGPointMake(-cameraPos.x +480/2 + 40, -cameraPos.y +320/2 - 10)];
	curve.type = lineInvis;
	[curves addObject:curve];
	[curve release];
}
- (IBAction)addImaginaryLine:(id)sender{
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(-cameraPos.x +480/2 - 40, -cameraPos.y +320/2 - 10) 
											 and:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2 - 50) 
											 and:CGPointMake(-cameraPos.x +480/2 + 40, -cameraPos.y +320/2 - 10)];
	curve.type = lineImag;
	[curves addObject:curve];
	[curve release];
}
- (IBAction)addBouncyLine:(id)sender{
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(-cameraPos.x +480/2 - 40, -cameraPos.y +320/2 - 10) 
											 and:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2 - 50) 
											 and:CGPointMake(-cameraPos.x +480/2 + 40, -cameraPos.y +320/2 - 10)];
	curve.type = lineBounce;
	[curves addObject:curve];
	[curve release];
}
- (IBAction)addBendSnapLine:(id)sender{
	Curve* curve = [[Curve alloc] initWithCurves:CGPointMake(-cameraPos.x +480/2 - 40, -cameraPos.y +320/2 - 10) 
											 and:CGPointMake(-cameraPos.x +480/2, -cameraPos.y +320/2 - 50) 
											 and:CGPointMake(-cameraPos.x +480/2 + 40, -cameraPos.y +320/2 - 10)];
	curve.type = lineBend;
	[curves addObject:curve];
	[curve release];
}
- (IBAction)testPlay:(id)sender {
	player.ballvel = CGPointMake(0, 0);
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		ball.ballvel = CGPointMake(0, 0);
	}
	levelGravity = CGPointMake([gravTextX floatValue],[gravTextY floatValue]);
	playerGravity = CGPointMake(0.0, 0.0);
	touchingReverseGravityNum = -1;
	if (testing) {
		testing = FALSE;
		[self endLevel];
	} else {
		testing = TRUE;
		[self startLevel];
	}
}
- (IBAction)pressedSelect:(id)sender{
	[eraseRadio setState:FALSE];
}
- (IBAction)pressedErase:(id)sender{
	[selectRadio setState:FALSE];
}
- (IBAction)pressedSave:(id)sender{
	if (testing) {
		player.ballvel = CGPointMake(0, 0);
		for (int i = 0; i < [balls count]; i ++) {
			Ball* ball = [balls objectAtIndex:i];
			ball.ballvel = CGPointMake(0, 0);
		}
		levelGravity = CGPointMake([gravTextX floatValue],[gravTextY floatValue]);
		playerGravity = CGPointMake(0.0, 0.0);
		touchingReverseGravityNum = -1;
			testing = FALSE;
			[self endLevel];
	}
	if ([savePath length] == 0) {
		NSSavePanel *save = [NSSavePanel savePanel];
	
		//Optional : Add Code here to change NSSavePanel basic configuration
	
		int result = [save runModal];
	
		if (result == NSOKButton){
			savePath = [save filename];
			[savePath retain];
		}
	}
	if ([savePath length]>0) {
		//Add Additional code to handle the save;
		// save the people array
		NSMutableArray* saveObjects = [[NSMutableArray alloc] init];
		[saveObjects addObject:[NSNumber numberWithFloat:player.ballxy.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:player.ballxy.y]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalStart.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalStart.y]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalEnd.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalEnd.y]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalControl1.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalControl1.y]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalControl2.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalControl2.y]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalPos.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:goalPos.y]];
		[saveObjects addObject:curves];
		[saveObjects addObject:reverseGravityX];
		[saveObjects addObject:reverseGravityY];
		[saveObjects addObject:[NSNumber numberWithFloat:levelDimensions.origin.x]];
		[saveObjects addObject:[NSNumber numberWithFloat:levelDimensions.origin.y]];
		[saveObjects addObject:[NSNumber numberWithFloat:levelDimensions.size.width]];
		[saveObjects addObject:[NSNumber numberWithFloat:levelDimensions.size.height]];
		[saveObjects addObject:balls];
		[saveObjects addObject:texts];
		NSLog(@"%@",[gravTextX stringValue]);
		[saveObjects addObject:[gravTextX stringValue]];
		[saveObjects addObject:[gravTextY stringValue]];
		[NSKeyedArchiver archiveRootObject:saveObjects toFile:savePath];
		[saveObjects release];
	}
}
- (IBAction)pressedOpen:(id)sender{
	if (testing) {
		player.ballvel = CGPointMake(0, 0);
		for (int i = 0; i < [balls count]; i ++) {
			Ball* ball = [balls objectAtIndex:i];
			ball.ballvel = CGPointMake(0, 0);
		}
		levelGravity = CGPointMake([gravTextX floatValue],[gravTextY floatValue]);
		playerGravity = CGPointMake(0.0, 0.0);
		touchingReverseGravityNum = -1;
		testing = FALSE;
		[self endLevel];
	}
	NSOpenPanel *open = [NSOpenPanel openPanel];
	
	//Optional : Add Code here to change NSSavePanel basic configuration
	
	int result = [open runModal];
	
	if (result == NSOKButton){
		[self eraseEverything];
		savePath = [open filename];
		[savePath retain];
		NSMutableArray* loadData;
		loadData = [NSKeyedUnarchiver unarchiveObjectWithFile:savePath];
		player.ballxy = CGPointMake([[loadData objectAtIndex:0] floatValue], [[loadData objectAtIndex:1] floatValue]);

		goalStart.x = [[loadData objectAtIndex:2] floatValue];
		goalStart.y = [[loadData objectAtIndex:3] floatValue];
		
		goalEnd.x = [[loadData objectAtIndex:4] floatValue];
		goalEnd.y = [[loadData objectAtIndex:5] floatValue];
		
		goalControl1.x = [[loadData objectAtIndex:6] floatValue];
		goalControl1.y = [[loadData objectAtIndex:7] floatValue];
		
		goalControl2.x = [[loadData objectAtIndex:8] floatValue];
		goalControl2.y = [[loadData objectAtIndex:9] floatValue];
		
		goalPos.x = [[loadData objectAtIndex:10] floatValue];
		goalPos.y = [[loadData objectAtIndex:11] floatValue];
		
		if (curves != nil) {[curves release];}
		curves = [loadData objectAtIndex:12];
		[curves retain];
		
		if ([loadData count]-1> 12) {
			if (reverseGravityX != nil) {[reverseGravityX release];}
			reverseGravityX = [loadData objectAtIndex:13];
			[reverseGravityX retain];
		
			if (reverseGravityY != nil) {[reverseGravityY release];}
			reverseGravityY = [loadData objectAtIndex:14];
			[reverseGravityY retain];
		}
		levelDimensions = CGRectMake(0, 0, 480, 320);
		if ([loadData count]-1> 14) {
			levelDimensions = CGRectMake([[loadData objectAtIndex:15] floatValue], [[loadData objectAtIndex:16] floatValue],
										 [[loadData objectAtIndex:17] floatValue], [[loadData objectAtIndex:18] floatValue]);
		}
		if ([loadData count]-1 > 18) {
			balls = [loadData objectAtIndex:19];
			[balls retain];
		}
		if ([loadData count]-1 > 19) {
			texts = [loadData objectAtIndex:20];
			[texts retain];
		}
		if ([loadData count]-1 > 20) {
			[gravTextX setStringValue:[loadData objectAtIndex:21]];
			[gravTextY setStringValue:[loadData objectAtIndex:22]];
		}
	}
}
- (void) eraseEverything {
	[gravTextX setStringValue:@"0.0"];
	[gravTextY setStringValue:@"0.1"];
	levelDimensions = CGRectMake(0, 0, 480, 320);
	cameraPos = CGPointMake(0, 0);
	mouseClick = CGPointMake(-1, -1);
	if (player) {[player release];}
	player = [[Ball alloc] initWithRad:10 pos:CGPointMake(0, 0) vel:CGPointMake(0, 0)];
	levelGravity.y = 0.1;
	goalPos = CGPointMake(400, 200);
	goalStart = CGPointMake(400-30, 200);
	goalEnd = CGPointMake(400+30, 200);
	goalControl1 = CGPointMake(400-20, 200-50);
	goalControl2 = CGPointMake(400+20, 200-50);
	if (curves) {[curves release];}
	curves = [[NSMutableArray alloc] init];
	if (balls) {[balls release];}
	balls = [[NSMutableArray alloc] init];
	if (texts) {[texts release];}
	texts = [[NSMutableArray alloc] init];
	if (reverseGravityX) {[reverseGravityX release];[reverseGravityY release];}
	reverseGravityX = [[NSMutableArray alloc] init];
	reverseGravityY = [[NSMutableArray alloc] init];
	savePath = @"";
}
- (IBAction)pressedNew:(id)sender {
	[self eraseEverything];
}
- (IBAction)changedGravText:(id)sender {
	levelGravity = CGPointMake([gravTextX floatValue],[gravTextY floatValue]);
}

- (void)mouseDown:(NSEvent*)event{
	mouseClick = CGPointMake(mouseClick.x-cameraPos.x,mouseClick.y-cameraPos.y);
	lastScroll = mouseClick;
	BOOL holding = FALSE;
	if (!testing) {
		if ([event modifierFlags] & NSControlKeyMask && !holding) {
			scrolling = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > player.ballxy.x && mouseClick.x < player.ballxy.x + player.ballrad*2 && 
			mouseClick.y > player.ballxy.y && mouseClick.y < player.ballxy.y + player.ballrad*2 && !holding) {
			holdingPlayer = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > goalPos.x-5 && mouseClick.x < goalPos.x + 10 && 
			mouseClick.y > goalPos.y-5 && mouseClick.y < goalPos.y + 10 && !holding) {
			holdingGoal = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > goalStart.x-5 && mouseClick.x < goalStart.x + 10 && 
			mouseClick.y > goalStart.y-5 && mouseClick.y < goalStart.y + 10 && !holding) {
			holdingGoalStart = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > goalEnd.x-5 && mouseClick.x < goalEnd.x + 10 && 
			mouseClick.y > goalEnd.y-5 && mouseClick.y < goalEnd.y + 10 && !holding) {
			holdingGoalEnd = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > goalControl1.x-5 && mouseClick.x < goalControl1.x + 10 && 
			mouseClick.y > goalControl1.y-5 && mouseClick.y < goalControl1.y + 10 && !holding) {
			holdingGoalControl1 = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > goalControl2.x-5 && mouseClick.x < goalControl2.x + 10 && 
			mouseClick.y > goalControl2.y-5 && mouseClick.y < goalControl2.y + 10 && !holding) {
			holdingGoalControl2 = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > levelDimensions.origin.x-5 && mouseClick.x < levelDimensions.origin.x+ 10 && 
			mouseClick.y > levelDimensions.origin.y-5 && mouseClick.y < levelDimensions.origin.y+ 10 && !holding) {
			holdingOriginScroll = TRUE;
			holding = TRUE;
		}
		if (mouseClick.x > levelDimensions.size.width+levelDimensions.origin.x-5 &&
			mouseClick.x < levelDimensions.size.width+levelDimensions.origin.x + 10 && 
			mouseClick.y > levelDimensions.size.height+levelDimensions.origin.y-5 &&
			mouseClick.y < levelDimensions.size.height+levelDimensions.origin.y + 10 && !holding) {
			holdingSizeScroll = TRUE;
			holding = TRUE;
		}
		
		for (int i = 0;i < [curves count] && !holding; i ++) {
			Curve* curve = [curves objectAtIndex:i];
			if (mouseClick.x > curve.curve0.x-5 && mouseClick.x < curve.curve0.x + 10 && 
				mouseClick.y > curve.curve0.y-5 && mouseClick.y < curve.curve0.y + 10 && !holding) {
				holdingCurveStart = TRUE;
				holding = TRUE;
				curveNum = i;
			}
			if (mouseClick.x > curve.curve1.x-5 && mouseClick.x < curve.curve1.x + 10 && 
				mouseClick.y > curve.curve1.y-5 && mouseClick.y < curve.curve1.y + 10 && !holding) {
				holdingCurveControl = TRUE;
				holding = TRUE;
				curveNum = i;
			} 
			if (mouseClick.x > curve.curve2.x-5 && mouseClick.x < curve.curve2.x + 10 && 
				mouseClick.y > curve.curve2.y-5 && mouseClick.y < curve.curve2.y + 10 && !holding) {
				holdingCurveEnd = TRUE;
				holding = TRUE;
				curveNum = i;
			} 
			if (mouseClick.x > (curve.curve0.x + curve.curve2.x)/2.0-5 && mouseClick.x < (curve.curve0.x + curve.curve2.x)/2 + 10 && 
				mouseClick.y > (curve.curve0.y + curve.curve2.y)/2.0-5 && mouseClick.y < (curve.curve0.y + curve.curve2.y)/2 + 10 && !holding) {
				if (selectRadio.state == TRUE) {
					holdingCurve = TRUE;
					holding = TRUE;
					curveNum = i;
				} 
				if (eraseRadio.state == TRUE) {
					[curves removeObjectAtIndex:i];
					i = [curves count];
				}
			}  
		}
		for (int i = 0; i < [reverseGravityX count] && !holding; i ++) {
			int x = [[reverseGravityX objectAtIndex:i] intValue];
			int y = [[reverseGravityY objectAtIndex:i] intValue];
			if (mouseClick.x > x && mouseClick.x < x+20
				&& mouseClick.y > y && mouseClick.y < y+20) {
				
				if (selectRadio.state == TRUE) {
					holdingReverseGravity = TRUE;
					holding = TRUE;
					reverseGravityNum = i;
				} 
				if (eraseRadio.state == TRUE) {
					[reverseGravityX removeObjectAtIndex:i];
					[reverseGravityY removeObjectAtIndex:i];
					i = [reverseGravityX count];
				}
			}
		}
		for (int i = 0; i < [balls count] && !holding; i ++) {
			Ball* ball = [balls objectAtIndex:i];
			if (mouseClick.x > ball.ballxy.x && mouseClick.x < ball.ballxy.x + ball.ballrad*2 && 
				mouseClick.y > ball.ballxy.y && mouseClick.y < ball.ballxy.y + ball.ballrad*2 && !holding) {
				if (selectRadio.state == TRUE) {
					holdingBall = TRUE;
					ballNum = i;
					holding = TRUE;
				}
				if (eraseRadio.state == TRUE) {
					[balls removeObjectAtIndex:i];
					i = [balls count];
				}
			}
		}
		for (int i = 0; i < [texts count] && !holding; i ++) {
			Text* text = [texts objectAtIndex:i];
			NSFont * myFont = [NSFont fontWithName:@"Helvetica" size:16];
			
			NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSColor blackColor], NSForegroundColorAttributeName,
									   myFont, NSFontAttributeName,
									   [NSNumber numberWithInt:NSNoUnderlineStyle],
									   NSUnderlineStyleAttributeName,
									   nil ];
			NSSize size = [text.text sizeWithAttributes:attsDict];
			if (mouseClick.x > text.pos.x - 10 && mouseClick.x < text.pos.x+20 && 
				mouseClick.y > text.pos.y - 10+size.height && mouseClick.y < text.pos.y+20+size.height && !holding) {
				if (selectRadio.state == TRUE) {
					holdingText = TRUE;
					textNum = i;
					holding = TRUE;
				}
				if (eraseRadio.state == TRUE) {
					[texts removeObjectAtIndex:i];
					i = [texts count];
				}
			}
		}
	}
}
- (void)mouseDragged:(NSEvent*)event{
	mouseClick = CGPointMake(mouseClick.x-cameraPos.x,mouseClick.y-cameraPos.y);
	if (holdingPlayer) {
		player.ballxy = CGPointMake(mouseClick.x - player.ballrad, mouseClick.y - player.ballrad);
	}
	if (holdingGoal) {
		CGPoint changed = CGPointMake(mouseClick.x - goalPos.x, mouseClick.y - goalPos.y);
		goalPos = mouseClick;
		goalStart = CGPointMake(goalStart.x + changed.x, goalStart.y + changed.y);
		goalEnd = CGPointMake(goalEnd.x + changed.x, goalEnd.y + changed.y);
		goalControl1 = CGPointMake(goalControl1.x + changed.x, goalControl1.y + changed.y);
		goalControl2 = CGPointMake(goalControl2.x + changed.x, goalControl2.y + changed.y);
	}
	if (holdingGoalStart) {
		goalStart = mouseClick;
	}
	if (holdingGoalEnd) {
		goalEnd = mouseClick;
	}
	if (holdingGoalControl1) {
		goalControl1 = mouseClick;
	}
	if (holdingGoalControl2) {
		goalControl2 = mouseClick;
	}
	if (holdingCurveStart) {
		Curve* curve = [curves objectAtIndex:curveNum];
		curve.curve0 = CGPointMake(mouseClick.x, mouseClick.y);
	}
	if (holdingCurveControl) {
		Curve* curve = [curves objectAtIndex:curveNum];
		curve.curve1 = CGPointMake(mouseClick.x, mouseClick.y);
	}
	if (holdingCurveEnd) {
		Curve* curve = [curves objectAtIndex:curveNum];
		curve.curve2 = CGPointMake(mouseClick.x, mouseClick.y);
	}
	if (holdingCurve) {
		Curve* curve = [curves objectAtIndex:curveNum];
		CGPoint changed = CGPointMake(mouseClick.x - (curve.curve0.x + curve.curve2.x)/2, mouseClick.y - (curve.curve0.y + curve.curve2.y)/2);
		curve.curve0 = CGPointMake(curve.curve0.x + changed.x, curve.curve0.y + changed.y);
		curve.curve1 = CGPointMake(curve.curve1.x + changed.x, curve.curve1.y + changed.y);
		curve.curve2 = CGPointMake(curve.curve2.x + changed.x, curve.curve2.y + changed.y);
	}
	if (holdingReverseGravity) {
		int x = [[reverseGravityX objectAtIndex:reverseGravityNum] intValue];
		int y = [[reverseGravityY objectAtIndex:reverseGravityNum] intValue];
		x = mouseClick.x-10;
		y = mouseClick.y-10;
		[reverseGravityX replaceObjectAtIndex:reverseGravityNum withObject:[NSNumber numberWithInt:x]];
		[reverseGravityY replaceObjectAtIndex:reverseGravityNum withObject:[NSNumber numberWithInt:y]];
	}
	if (holdingBall) {
		Ball* ball = [balls objectAtIndex:ballNum];
		ball.ballxy = CGPointMake(mouseClick.x-10, mouseClick.y-10);
	}
	if (holdingText) {
		Text* text = [texts objectAtIndex:textNum];
		NSFont * myFont = [NSFont fontWithName:@"Helvetica" size:16];
		NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSColor blackColor], NSForegroundColorAttributeName,
								   myFont, NSFontAttributeName,
								   [NSNumber numberWithInt:NSNoUnderlineStyle],
								   NSUnderlineStyleAttributeName,
								   nil ];
		NSSize size = [text.text sizeWithAttributes:attsDict];
		text.pos = CGPointMake(mouseClick.x, mouseClick.y - size.height);
	}
	if (scrolling) {
		CGPoint oldCamPos = cameraPos;
		cameraPos = CGPointMake(mouseClick.x-lastScroll.x+cameraPos.x, mouseClick.y-lastScroll.y+cameraPos.y);
		lastScroll = CGPointMake(mouseClick.x+oldCamPos.x-cameraPos.x, mouseClick.y+oldCamPos.y-cameraPos.y);
	}
	if (holdingOriginScroll) {
		CGPoint changed = CGPointMake(mouseClick.x - levelDimensions.origin.x, mouseClick.y - levelDimensions.origin.y);
		levelDimensions.origin = CGPointMake(levelDimensions.origin.x + changed.x, levelDimensions.origin.y + changed.y);
		levelDimensions.size = CGSizeMake(levelDimensions.size.width-changed.x, levelDimensions.size.height-changed.y);
	}
	if (holdingSizeScroll) {
		CGPoint changed = CGPointMake(mouseClick.x - levelDimensions.size.width, mouseClick.y - levelDimensions.size.height);
		levelDimensions.size = CGSizeMake(levelDimensions.size.width-levelDimensions.origin.x+changed.x, levelDimensions.size.height-levelDimensions.origin.y+changed.y);
	}
}
- (void)mouseUp:(NSEvent*)event{
	//Snap curves to ends
	
	if (holdingCurveStart || holdingCurveEnd) {
		Curve* snapCurve = [curves objectAtIndex:curveNum];
		for (int i = 0; i < [curves count]; i ++) {
			if (i != curveNum) {
				Curve* curve = [curves objectAtIndex:i];
				if (holdingCurveStart) {
					if (snapCurve.curve0.x > curve.curve0.x-5 && snapCurve.curve0.x < curve.curve0.x+5 &&
						snapCurve.curve0.y > curve.curve0.y-5 && snapCurve.curve0.y < curve.curve0.y+5) {
						snapCurve.curve0 = curve.curve0;
						i = [curves count];
					} else if (snapCurve.curve0.x > curve.curve2.x-5 && snapCurve.curve0.x < curve.curve2.x+5 &&
							   snapCurve.curve0.y > curve.curve2.y-5 && snapCurve.curve0.y < curve.curve2.y+5) {
						snapCurve.curve0 = curve.curve2;
						i = [curves count];
					}

				} else if (holdingCurveEnd) {
					if (snapCurve.curve2.x > curve.curve0.x-5 && snapCurve.curve2.x < curve.curve0.x+5 &&
						snapCurve.curve2.y > curve.curve0.y-5 && snapCurve.curve2.y < curve.curve0.y+5) {
						snapCurve.curve2 = curve.curve0;
						i = [curves count];
					} else if (snapCurve.curve2.x > curve.curve2.x-5 && snapCurve.curve2.x < curve.curve2.x+5 &&
						snapCurve.curve2.y > curve.curve2.y-5 && snapCurve.curve2.y < curve.curve2.y+5) {
						snapCurve.curve2 = curve.curve2;
						i = [curves count];
					}
				}
			}
		}
	}
	
	holdingPlayer = FALSE;
	holdingGoal = FALSE;
	holdingGoalStart = FALSE;
	holdingGoalEnd = FALSE;
	holdingGoalControl1 = FALSE;
	holdingGoalControl2 = FALSE;
	holdingCurve = FALSE;
	holdingCurveStart = FALSE;
	holdingCurveEnd = FALSE;
	holdingCurveControl = FALSE;
	holdingReverseGravity = FALSE;
	holdingBall = FALSE;
	holdingText = FALSE;
	scrolling = FALSE;
	holdingOriginScroll = FALSE;
	holdingSizeScroll = FALSE;
	curveNum = -1;
	ballNum = -1;
	textNum = -1;
	reverseGravityNum = -1;
	
	mouseClick = CGPointMake(-1, -1);
}
- (void)timerTick {
	if (testing) {
		//Run the camera to focus on the ball
		CGPoint oldBallPos = player.ballxy;
		//Double the physics awesomeness. So it reaches 120fps.
		[self runPhysics];
		[self runPhysics];
		cameraPos = CGPointMake(cameraPos.x-(player.ballxy.x-oldBallPos.x), cameraPos.y-(player.ballxy.y-oldBallPos.y));
		if (player.ballxy.x < levelDimensions.origin.x+480/2) {cameraPos.x = -levelDimensions.origin.x;}
		if (player.ballxy.x > levelDimensions.size.width+levelDimensions.origin.x-480/2) {cameraPos.x = -levelDimensions.size.width-levelDimensions.origin.x+480;}
		
		if (player.ballxy.y < levelDimensions.origin.y+320/2) {cameraPos.y = -levelDimensions.origin.y;}
		if (player.ballxy.y > levelDimensions.size.height+levelDimensions.origin.y-320/2) {cameraPos.y = -levelDimensions.size.height-levelDimensions.origin.y+320;}
		//if (cameraPos.x+480/2 > levelDimensions.size.width) {cameraPos.x = levelDimensions.size.width;}
		//if (cameraPos.y < levelDimensions.origin.y) {cameraPos.y = levelDimensions.origin.y;}
		//if (cameraPos.y > levelDimensions.size.height) {cameraPos.y = levelDimensions.size.height;}
		if (testing == FALSE) {
			[self endLevel];
		}
	}
	//drawTimer += 1;
	//if (drawTimer == drawTimerMax) {
		[gameView setNeedsDisplay:YES];
	//	drawTimer = 0;
	//}
}
- (void)drawGame {
	// Drawing code
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	
	//Draw the goal
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 1.0, 0.8, 0.0, 1.0);
	CGContextMoveToPoint(context, goalStart.x+cameraPos.x, goalStart.y+cameraPos.y);
	CGContextAddCurveToPoint(context,goalControl1.x+cameraPos.x, goalControl1.y+cameraPos.y, 
							 goalControl2.x+cameraPos.x, goalControl2.y+cameraPos.y, goalEnd.x+cameraPos.x, goalEnd.y+cameraPos.y);
	CGContextStrokePath(context);
	CGContextRestoreGState (context);
	
	if (!testing) {
		[self drawHoldCircle:goalStart];
		[self drawHoldCircle:goalControl1];
		[self drawHoldCircle:goalControl2];
		[self drawHoldCircle:goalEnd];
		[self drawHoldCircle:goalPos];
	}
	
	//Draw Gravity
	for (int i = 0; i < [reverseGravityX count]; i ++) {
		[reverseGravity drawAtPoint:
		 NSMakePoint([[reverseGravityX objectAtIndex:i] intValue]+cameraPos.x, [[reverseGravityY objectAtIndex:i] intValue]+cameraPos.y)
						   fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	//Draw Shadow
	CGContextSaveGState(context);
    CGContextSetShadow (context, CGSizeMake(5, 5), 5); 
	
	//Draw Circle
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
	CGRect rectangle = CGRectMake(player.ballxy.x+cameraPos.x,player.ballxy.y+cameraPos.y,player.ballrad*2,player.ballrad*2);
	CGContextAddEllipseInRect(context, rectangle);
	CGContextStrokePath(context); 
    CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		//Draw Shadow
		CGContextSaveGState(context);
		CGContextSetShadow (context, CGSizeMake(5, 5), 5); 
		
		//Draw Circle
		CGContextSetLineWidth(context, 2.0);
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
		CGRect rectangle = CGRectMake(ball.ballxy.x+cameraPos.x,ball.ballxy.y+cameraPos.y,ball.ballrad*2,ball.ballrad*2);
		CGContextAddEllipseInRect(context, rectangle);
		CGContextStrokePath(context); 
		CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
	}
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		
		//Draw Bezier Curve
		CGContextSetLineWidth(context, 2.0);
		
		if (curve.type == lineReg) {
			CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
		} else if (curve.type == lineRed) {
			CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
		} else if (curve.type == lineInvis) {
			if (testing) {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.0);
			} else {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 0.5);
			}
		} else if (curve.type == lineImag) {
			if (testing) {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.8, 1.0);
			} else {
				CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.4, 1.0);
			}
		} else if (curve.type == lineBounce) {
			CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
		} else if (curve.type == lineBend) {
			CGContextSetRGBStrokeColor(context, 0.5, 0.2, 0.0, 1.0);
		}
		if (!curve.snapped) {
			CGContextSaveGState(context);
		CGContextMoveToPoint(context, curve.curve0.x+cameraPos.x, curve.curve0.y+cameraPos.y);
		
		CGContextAddQuadCurveToPoint(context, curve.curve1.x+cameraPos.x, curve.curve1.y+cameraPos.y, curve.curve2.x+cameraPos.x, curve.curve2.y+cameraPos.y);
		
		CGContextStrokePath(context);
			CGContextRestoreGState (context);
		} else {
			CGContextSaveGState(context);
			CGContextMoveToPoint(context, curve.snap0.x+cameraPos.x, curve.snap0.y+cameraPos.y);
			
			CGContextAddQuadCurveToPoint(context, curve.snap1.x+cameraPos.x, curve.snap1.y+cameraPos.y, curve.snap2.x+cameraPos.x, curve.snap2.y+cameraPos.y);
			
			CGContextStrokePath(context);
			
			CGContextMoveToPoint(context, curve.snap3.x+cameraPos.x, curve.snap3.y+cameraPos.y);
			
			CGContextAddQuadCurveToPoint(context, curve.snap4.x+cameraPos.x, curve.snap4.y+cameraPos.y, curve.snap5.x+cameraPos.x, curve.snap5.y+cameraPos.y);
			
			CGContextStrokePath(context);
			CGContextRestoreGState (context);
		}
		
		float pointrad = 1.0/8.0;
		CGContextSaveGState(context);
		CGRect rectangle = CGRectMake(curve.curve0.x+cameraPos.x-pointrad,curve.curve0.y+cameraPos.y-pointrad,pointrad*2,pointrad*2);
		CGContextAddEllipseInRect(context, rectangle);
		CGContextStrokePath(context); 
		
		
		rectangle = CGRectMake(curve.curve2.x+cameraPos.x-pointrad,curve.curve2.y+cameraPos.y-pointrad,pointrad*2,pointrad*2);
		CGContextAddEllipseInRect(context, rectangle);
		CGContextStrokePath(context);
		CGContextRestoreGState (context);
		
		if (!testing) {
			CGContextSaveGState(context);
			[self drawHoldCircle:CGPointMake(curve.curve0.x,curve.curve0.y)];
			[self drawHoldCircle:CGPointMake(curve.curve1.x,curve.curve1.y)];
			[self drawHoldCircle:CGPointMake(curve.curve2.x,curve.curve2.y)];
			[self drawHoldCircle:CGPointMake((curve.curve0.x + curve.curve2.x)/2, (curve.curve0.y + curve.curve2.y)/2)];
			CGContextRestoreGState (context);
		}
	}
	for (int i = 0; i < [texts count]; i ++) {
		Text* text = [texts objectAtIndex:i];
		
		NSFont * myFont = [NSFont fontWithName:@"Helvetica" size:16];
		
		NSDictionary * attsDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSColor blackColor], NSForegroundColorAttributeName,
								   myFont, NSFontAttributeName,
								   [NSNumber numberWithInt:NSNoUnderlineStyle],
								   NSUnderlineStyleAttributeName,
								   nil ];
		NSSize size = [text.text sizeWithAttributes:attsDict];
		CGContextSaveGState(context);
		[text.text drawAtPoint:NSMakePoint(text.pos.x - size.width/2.0 + cameraPos.x, text.pos.y  - size.height/2.0 + cameraPos.y) withAttributes:attsDict];
		if (!testing) {
			[self drawHoldCircle:CGPointMake(text.pos.x, text.pos.y+size.height)];
		}
		CGContextRestoreGState (context);
	}
	if (!testing) {
		//Draw level boundaries and bubbles for resizing
		CGContextSaveGState(context);
		
		CGContextSetLineWidth(context, 1.0);
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
		CGRect rectangle = CGRectMake(levelDimensions.origin.x+cameraPos.x,levelDimensions.origin.y+cameraPos.y,levelDimensions.size.width,levelDimensions.size.height);
		CGContextAddRect(context, rectangle);
		CGContextStrokePath(context); 
		CGContextRestoreGState (context);     //Restore the context to the previously saved state in case you want to do something else.
		[self drawHoldCircle:CGPointMake(levelDimensions.origin.x, levelDimensions.origin.y)];
		[self drawHoldCircle:CGPointMake(levelDimensions.size.width+levelDimensions.origin.x, levelDimensions.size.height+levelDimensions.origin.y)];
	}
	/**
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		//Draw Bezier Curve
		CGContextSaveGState(context);
		
		CGContextSetLineWidth(context, 2.0);
		
		CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
		
		CGContextMoveToPoint(context, curve.curve0.x, curve.curve0.y);
		for (int e = 0; e < [curve.curvePtX count]; e++) {
		
			CGContextAddLineToPoint(context, [[curve.curvePtX objectAtIndex:e] floatValue], [[curve.curvePtY objectAtIndex:e] floatValue]);
			
		}
		CGContextStrokePath(context);
		
		CGContextRestoreGState (context);
	}
	 **/
}

- (void)runPhysics {
	[self runPhysicsForBendLines];
	[self runGravityForAllBalls];
	[self runPhysicsForBall:player];
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		[self runPhysicsForBall:ball];
	}
}
- (void)runGravityForAllBalls {
	player.ballvel = CGPointMake(player.ballvel.x+levelGravity.x+playerGravity.x, player.ballvel.y+levelGravity.y+playerGravity.y);
	player.ballxy = CGPointMake(player.ballxy.x + player.ballvel.x, player.ballxy.y + player.ballvel.y);
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		ball.ballvel = CGPointMake(ball.ballvel.x+levelGravity.x, ball.ballvel.y+levelGravity.y);
		ball.ballxy = CGPointMake(ball.ballxy.x + ball.ballvel.x, ball.ballxy.y + ball.ballvel.y);
	}
}
- (void)runPhysicsForBendLines {
	for (int i = 0; i < [curves count];i++) {
		Curve* curve = [curves objectAtIndex:i];
		
		//If curve has snapped then do snap animation
		if (curve.type == lineBend && curve.snapped) {
			BOOL resync = FALSE;
			if (curve.snap1.x > curve.snap0.x) {
				curve.snap1 = CGPointMake(curve.snap1.x-1.0, curve.snap1.y);
				resync = TRUE;
			}
			if (curve.snap2.x > curve.snap0.x) {
				curve.snap2 = CGPointMake(curve.snap2.x-1.0, curve.snap2.y+0.5);
				resync = TRUE;
			}
			if (curve.snap4.x < curve.snap3.x) {
				curve.snap4 = CGPointMake(curve.snap4.x+1.0, curve.snap4.y);
				resync = TRUE;
			}
			if (curve.snap5.x < curve.snap3.x) {
				curve.snap5 = CGPointMake(curve.snap5.x+1.0, curve.snap5.y+0.5);
				resync = TRUE;
			}
			if (resync) {[curve sync];}
		}
	}
}
- (void)runPhysicsForBall:(Ball*)ball {
	float br = ball.ballrad;
	
	float bx = ball.ballxy.x;
	float by = ball.ballxy.y;
	
	float bvx = ball.ballvel.x;
	float bvy = ball.ballvel.y;
	
	//Run phsyics for ball-ball collisions
	int startBall = 0;
	if (ball != player) {startBall = [balls indexOfObject:ball]+1;}
	//Balloon Collision
	for (int j = startBall; j < [balls count]; j ++) {
		Ball* collideBall = [balls objectAtIndex:j];
		
		if ([gameView collisionOfCircles:CGPointMake(ceil(bx+br), ceil(by+br)) rad:br
											   c2:CGPointMake(ceil(collideBall.ballxy.x+collideBall.ballrad), ceil(collideBall.ballxy.y+collideBall.ballrad)) rad:collideBall.ballrad]) {
			double x, y, d2;
			if (bx == collideBall.ballxy.x && by == collideBall.ballxy.y) {
				int randAdd = rand()%5;
				if (randAdd == 1) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x+1, collideBall.ballxy.y);}
				if (randAdd == 2) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x-1, collideBall.ballxy.y);}
				if (randAdd == 3) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x, collideBall.ballxy.y+1);}
				if (randAdd == 4) {collideBall.ballxy = CGPointMake(collideBall.ballxy.x, collideBall.ballxy.y-1);}
			}
			// displacement from i to j
			y = (collideBall.ballxy.y - by);
			x = (collideBall.ballxy.x - bx);
			
			// distance squared
			d2 = x * x + y * y;
			if (d2 == 0) {d2 = 1;}
			
			double kii, kji, kij, kjj;
			
			kji = (x * bvx + y * bvy) / d2; // k of j due to i
			kii = (x * bvy - y * bvx) / d2; // k of i due to i
			kij = (x * collideBall.ballvel.x + y * collideBall.ballvel.y) / d2; // k of i due to j
			kjj = (x * collideBall.ballvel.y - y * collideBall.ballvel.x) / d2; // k of j due to j
			
			// set velocity of i
			bvx = kij * x - kii * y;
			bvy = kij * y + kii * x;
			
			// set velocity of j
			collideBall.ballvel = CGPointMake(kji * x - kjj * y, kji * y + kjj * x);
			
			// the ratio between what it should be and what it really is
			float k = ((br*2+collideBall.ballrad*2)/2+0.1) / sqrt(d2);
			
			// difference between x and y component of the two vectors
			y *= (k - 1) / 2;
			x *= (k - 1) / 2;
			
			// set new coordinates of disks
			bx -= x;
			by -= y;
			collideBall.ballxy = CGPointMake(collideBall.ballxy.x + x,collideBall.ballxy.y + y);
			//j.y += y;
			//j.x += x;
			//i.y -= y;
			//i.x -= x;
			
		}
	}
	
	for (int i = 0; i < [curves count];i++) {
		Curve* curve = [curves objectAtIndex:i];
		
		if (bx >= curve.xBounds.x-40 && bx <= curve.xBounds.y+40 &&
			by >= curve.yBounds.x-40 && by <= curve.yBounds.y+40) {
			
			//Run line end-point circle collisions
			for (int e = 1; e < 2 && curve.type != lineImag; e ++) {
				double cx,cy;
				if (e == 1) {
					cx = curve.curve0.x-br;
					cy = curve.curve0.y-br;
				} else {
					cx = curve.curve2.x-br;
					cy = curve.curve2.y-br;
				}
				if ([gameView collisionOfCircles:CGPointMake(bx, by) rad:br c2:CGPointMake(cx,cy) rad:1.0]) {
					//Startpoint Collision
					
					double x, y, d2;
					
					// displacement from i to j
					y = (cy - by);
					x = (cx - bx);
					
					// distance squared
					d2 = x * x + y * y;
					
					// the ratio between what it should be and what it really is
					float k = ((20+2)/2+0.1) / sqrt(x * x + y * y);
					
					// difference between x and y component of the two vectors
					y *= (k - 1) / 2;
					x *= (k - 1) / 2;
					
					// set new coordinates of disks
					bx -= x;
					by -= y;
				}
			}
			
			BOOL ballHasCollided = FALSE;
			for ( int p = 1 ; p < [curve.curvePtX count] - 1 && ballHasCollided==FALSE && curve.type != lineImag; p++ ) {
				
				CGPoint p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
				CGPoint p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
				
				
				CGPoint average = CGPointMake((p0.x+p1.x)/2.0, (p0.y+p1.y)/2.0);
				float endAngle =  atan2( p1.y - average.y , p1.x - average.x )*180/M_PI + 180;
				float startAngle =  atan2( p0.y - average.y , p0.x - average.x )*180/M_PI + 180;
				float ballAngle =  atan2( by - average.y , bx - average.x )*180/M_PI + 180;
				BOOL reversed = FALSE;
				if (endAngle > startAngle) {
					if (ballAngle < startAngle || ballAngle > endAngle) {
						reversed = TRUE;
						p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
						p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
					}
				} else {
					if (ballAngle < startAngle && ballAngle > endAngle) {
						reversed = TRUE;
						p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
						p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
					}
				}
				
				float p0x = p0.x;
				float p0y = p0.y;
				float p1x = p1.x;
				float p1y = p1.y;
				
				// get Angle //
				
				float dx = p0x - p1x;
				float dy = p0y - p1y;
				
				float angle = atan2( dy , dx );
				
				float sin1 = sin ( angle );
				float cos1 = cos ( angle );
				
				// rotate p1 ( need only 'x' ) //
				
				float p1rx = dy * sin1 + dx * cos1 + p0x;
				
				// rotate ball //
				
				float px = p0x - bx;
				float py = p0y - by;
				
				float brx = py * sin1 + px * cos1 + p0x;
				float bry = py * cos1 - px * sin1 + p0y;
				
				float cp = ( bx - p0x ) * ( p1y - p0y ) - ( by - p0y ) * ( p1x - p0x );
				
				if ( bry > p0y - br && brx > p0x && brx < p1rx && cp > 0 ) {
					ballHasCollided = TRUE;
					if (curve.type == lineBend && !curve.snapped) {
						float toBend = fabs(ball.ballvel.x)*0.5;
						/**
						 if (curve.originalCurve1.y-curve.curve1.y != 0) {
						 toBend = 1.0/((curve.curve1.y-curve.originalCurve1.y)/50);
						 } else {
						 toBend = 1;
						 }
						 **/
						curve.curve1 = CGPointMake(curve.curve1.x, curve.curve1.y+toBend);
						if (bx > curve.curve1.x) {
							curve.curve1 = CGPointMake(curve.curve1.x + 1, curve.curve1.y);
						} else if (bx < curve.curve1.x) {
							curve.curve1 = CGPointMake(curve.curve1.x - 1, curve.curve1.y);
						}
						[curve sync];
						//Now that it's resync redo all the calculations so the ball doesn't jump
						if (reversed) {
							p0 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);
							p1 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
						} else {
							p0 = CGPointMake([[curve.curvePtX objectAtIndex:p] floatValue]-br, [[curve.curvePtY objectAtIndex:p] floatValue]-br);
							p1 = CGPointMake([[curve.curvePtX objectAtIndex:p+1] floatValue]-br, [[curve.curvePtY objectAtIndex:p+1] floatValue]-br);	
						}
						p0x = p0.x;
						p0y = p0.y;
						p1x = p1.x;
						p1y = p1.y;
						
						// get Angle //
						
						dx = p0x - p1x;
						dy = p0y - p1y;
						
						angle = atan2( dy , dx );
						
						sin1 = sin ( angle );
						cos1 = cos ( angle );
						
						// rotate p1 ( need only 'x' ) //
						
						p1rx = dy * sin1 + dx * cos1 + p0x;
						
						// rotate ball //
						
						px = p0x - bx;
						py = p0y - by;
						
						brx = py * sin1 + px * cos1 + p0x;
						bry = py * cos1 - px * sin1 + p0y;
						
						cp = ( bx - p0x ) * ( p1y - p0y ) - ( by - p0y ) * ( p1x - p0x );
						
						if (curve.curve1.y-curve.originalCurve1.y > 100) {
							curve.snapped = TRUE;
							
							curve.snap0 = curve.curve0;
							curve.snap1 = CGPointMake((curve.curve1.x+curve.curve0.x)/2.0, (curve.curve1.y+curve.curve0.y)/2.0);
							curve.snap2 = CGPointMake(curve.curve1.x, by + br);
							
							curve.snap3 = curve.curve2;
							curve.snap4 = CGPointMake((curve.curve1.x+curve.curve2.x)/2.0, (curve.curve1.y+curve.curve2.y)/2.0);
							curve.snap5 = CGPointMake(curve.curve1.x, by + br);
						}
					}
					if (curve.snapped == FALSE) {
						// calc new Vector //
						
						float vx = bvy * sin1 + bvx * cos1;
						float vy = bvy * cos1 - bvx * sin1;
						
						if (curve.type == lineBounce) {
							vy *= 2.0;
						}
						vy *= -.8;
						vx *= .98;
						
						sin1 = sin ( -angle );
						cos1 = cos ( -angle );
						
						bvx = vy * sin1 + vx * cos1;
						bvy = vy * cos1 - vx * sin1;
						
						// calc new Position //
						
						bry = p0y - br;
						
						dx = p0x - brx;
						dy = p0y - bry;
						
						bx = dy * sin1 + dx * cos1 + p0x;
						by = dy * cos1 - dx * sin1 + p0y;
					}
					
					//Check if touching death line
					if (curve.type == lineRed && ball == player) {
						testing = FALSE;
						[self endLevel];
					}
				}
			}
		}
	}
	
	//if ( bx < br - 200 ) bx = br - 200, bvx = -bvx;
	//if ( bx > 200 - br ) bx = 200 - br, bvx = -bvx;
	
	ball.ballxy = CGPointMake(bx, by);
	
	ball.ballvel = CGPointMake(bvx, bvy);
	
	//Limit velocity
	if (ball.ballvel.x > 5.0/2.0) {ball.ballvel = CGPointMake(5.0/2.0, ball.ballvel.y);}
	if (ball.ballvel.x < -5.0/2.0) {ball.ballvel = CGPointMake(-5.0/2.0, ball.ballvel.y);}
	if (ball.ballvel.y > 5.0/2.0) {ball.ballvel = CGPointMake(ball.ballvel.x, 5.0/2.0);}
	if (ball.ballvel.y < -5.0/2.0) {ball.ballvel = CGPointMake(ball.ballvel.x, -5.0/2.0);}
	
	if (ball = player) {
		//Check if touching gravity
		for (int i = 0; i < [reverseGravityX count]; i ++) {
		int x = [[reverseGravityX objectAtIndex:i] intValue];
		int y = [[reverseGravityY objectAtIndex:i] intValue];
		if (ball.ballxy.x+ball.ballrad > x && ball.ballxy.x+ball.ballrad < x+20
			&& ball.ballxy.y+ball.ballrad > y && ball.ballxy.y+ball.ballrad < y+20) {
			if (touchingReverseGravityNum != i) {
				levelGravity.y *= -1;
				touchingReverseGravityNum = i;
			}
		} else {
			if (touchingReverseGravityNum == i) {touchingReverseGravityNum = -1;}
		}
	}
	}
	
	if ( abs(ball.ballxy.y) > 1000 + levelDimensions.size.height && ball == player) {
		testing = FALSE;
		[self endLevel];
	}
	//Set up the goal
	if (ball.ballxy.x > goalPos.x - 20 && ball.ballxy.x < goalPos.x + 20
		&& ball.ballxy.y < goalPos.y && ball.ballxy.y > goalPos.y - 40 && ball == player) {
		//Beat the level
		testing = FALSE;
		[self endLevel];
	}
}

-(void)startLevel {
	player.originalballxy = player.ballxy;
	originalCameraPos = cameraPos;
	cameraPos = CGPointMake(-player.ballxy.x + 480/2, -player.ballxy.y + 320/2);
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		[curve sync];
		curve.originalCurve0 = curve.curve0;
		curve.originalCurve1 = curve.curve1;
		curve.originalCurve2 = curve.curve2;
		curve.snapped = FALSE;
		
		//curve.layer = [CALayer layer];
		//[curve.layer retain];
		//curve.layer.bounds = CGRectMake(0, 0, curve.xBounds.y - curve.xBounds.x, curve.yBounds.y - curve.yBounds.x);
		//curve.layer.needsDisplayOnBoundsChange = YES;
		//[curve.layer setPosition:CGPointMake(curve.xBounds.x + cameraPos.x, curve.yBounds.x + cameraPos.y)];
		//[curve.layer setDelegate:curve];
		//CATransform3D aTransform = CATransform3DIdentity;
		//aTransform = CATransform3DMakeRotation(M_PI, 1, 0, 0);  
		//curve.layer.transform = aTransform;
		
		//[gameView.layer addSublayer:curve.layer];
		//[curve.layer setNeedsDisplay];
	}
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		ball.originalballxy = ball.ballxy;
	}
}
-(void)endLevel {
	testing = FALSE;
	player.ballxy = player.originalballxy;
	cameraPos = originalCameraPos;
	for (int i = 0; i < [curves count]; i ++) {
		Curve* curve = [curves objectAtIndex:i];
		curve.curve0 = curve.originalCurve0;
		curve.curve1 = curve.originalCurve1;
		curve.curve2 = curve.originalCurve2;
		curve.snapped = FALSE;
	}
	for (int i = 0; i < [balls count]; i ++) {
		Ball* ball = [balls objectAtIndex:i];
		ball.ballxy = ball.originalballxy;
	}
}

- (void)drawHoldCircle:(CGPoint)position {
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	//Draw Circle
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5);
	CGRect rectangle = CGRectMake(position.x - 5+cameraPos.x,position.y - 5+cameraPos.y,10,10);
	CGContextAddEllipseInRect(context, rectangle);
	CGContextStrokePath(context); 
    CGContextRestoreGState (context); 
}

- (void)keydown:(UniChar)key {
	if (key == NSLeftArrowFunctionKey) {
		playerGravity.x = -0.1;
	}
	if (key == NSRightArrowFunctionKey) {
		playerGravity.x = 0.1;
	}
	if (key == NSUpArrowFunctionKey) {
		playerGravity.y = -0.1;
	}
	if (key == NSDownArrowFunctionKey) {
		playerGravity.y = 0.1;
	}
}
- (void)keyup:(UniChar)key {
	if (key == NSLeftArrowFunctionKey) {
		playerGravity.x = 0.0;
	}
	if (key == NSRightArrowFunctionKey) {
		playerGravity.x = 0.0;
	}
	if (key == NSUpArrowFunctionKey) {
		playerGravity.y = 0.0;
	}
	if (key == NSDownArrowFunctionKey) {
		playerGravity.y = 0.0;
	}
}

- (void) dealloc {
	[reverseGravity release];
	if ([savePath length]>0) {
		[savePath release];
	}
	[player release];
	[balls release];
	[curves release];
	[reverseGravityX release];
	[reverseGravityY release];
	[theTimer invalidate];
	[super dealloc];
}

@end
