//
//  Physics_BallViewController.m
//  Physics Ball
//
//  Created by Matthew French on 12/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

AppDelegate* delegate;

@implementation ViewController

- (IBAction)play {
	levels.alpha = 0.0f;
	self.view = levels;
	[delegate.window addSubview:mainMenu];
	[delegate.window addSubview:levels];
	[UIView beginAnimations:@"fadeInSecondView" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:mainMenu];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	levels.alpha = 1.0f;
	[UIView commitAnimations];
}
- (IBAction)instructions {
	instructions.alpha = 0.0f;
	self.view = instructions;
	[delegate.window addSubview:mainMenu];
	[delegate.window addSubview:instructions];
	[UIView beginAnimations:@"fadeInSecondView" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:mainMenu];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	instructions.alpha = 1.0f;
	[UIView commitAnimations];
}
- (IBAction)credits {
	credits.alpha = 0.0f;
	self.view = credits;
	[delegate.window addSubview:mainMenu];
	[delegate.window addSubview:credits];
	[UIView beginAnimations:@"fadeInSecondView" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:mainMenu];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	credits.alpha = 1.0f;
	[UIView commitAnimations];
}
- (IBAction)menu {
	UIView* prev = self.view;
	mainMenu.alpha = 0.0f;
	self.view = mainMenu;
	[delegate.window addSubview:prev];
	[delegate.window addSubview:mainMenu];
	[UIView beginAnimations:@"fadeInSecondView" context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:prev];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	mainMenu.alpha = 1.0f;
	[UIView commitAnimations];
}
- (IBAction)getNewLevels {
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:nil message:@"No new levels available." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
	[alert show];
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [super viewDidLoad];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
