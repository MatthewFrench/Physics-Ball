//
//  MainView.m
//  PhysicsCreator v1.0
//
//  Created by Matthew French on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import "AppDelegate.h"

@implementation MainView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)mouseDown:(NSEvent*)theEvent{
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	//delegate.mouseClick = aMousePoint;
	
	[delegate mouseDown:theEvent];
}
- (void)mouseDragged:(NSEvent*)theEvent{
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	//delegate.mouseClick = aMousePoint;
	
	[delegate mouseDragged:theEvent];
}
- (void)mouseUp:(NSEvent*)theEvent{
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	//delegate.mouseClick = aMousePoint;
	
	[delegate mouseUp:theEvent];
}

- (void)keyDown:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate keydown:aKey];
}
- (void)keyUp:(NSEvent*)theEvent{
	unichar aKey = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate keyup:aKey];
}
- (BOOL)acceptsFirstResponder {
	return YES;
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
	return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
	[delegate drawScreen];
}

@end
