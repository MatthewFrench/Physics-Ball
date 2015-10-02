//
//  Level.h
//  OpenGl Physics
//
//  Created by Matthew French on 12/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Texture2D.h"
#import "Image.h"
#import "QueryCallback.h"
#import "Shape.h"
#import "Curve.h"

#import <Box2D/Box2D.h>

#define PTM_RATIO 120 //pixels in a meter, the more pixels = less meters


@interface Level : NSObject {
	b2World* world;
	b2Body* groundBody;
	NSMutableArray* shapes;
	Shape* player;
	
	NSTimeInterval lastTime;
	
	CGRect levelDimensions;
	CGPoint cameraPos;
	
	NSString* name;
}

@property(nonatomic,assign) b2World* world;
@property(nonatomic,assign) b2Body* groundBody;
@property(nonatomic,assign) Shape* player;
@property(nonatomic,assign) NSMutableArray* shapes;
@property(nonatomic,assign) NSString* name;


- (id)initLevel:(NSString*)levelName;
- (void)createPhysicsWorld;
- (void)tick;
- (void)draw;


@end
