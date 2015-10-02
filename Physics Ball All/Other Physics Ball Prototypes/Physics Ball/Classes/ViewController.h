//
//  Physics_BallViewController.h
//  Physics Ball
//
//  Created by Matthew French on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
	IBOutlet UIView* mainMenu,*levels,*game,*instructions,*credits;
}
- (IBAction)play;
- (IBAction)instructions;
- (IBAction)credits;
- (IBAction)menu;
- (IBAction)getNewLevels;

@end

