//
//  MainWindow.m
//  PhysicsCreator v1.0
//
//  Created by Matthew French on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainWindow.h"


@implementation MainWindow
- (BOOL)isMainWindow
{
    return YES;
}

- (BOOL)isKeyWindow
{
    return ([NSApp isActive]) ? YES : [super isKeyWindow];
}
@end
