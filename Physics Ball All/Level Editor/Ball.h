//
//  Ball.h
//  Level Editor
//
//  Created by Matthew French on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Ball : NSObject {
	CGPoint originalballxy,ballxy,ballvel;
	float ballrad;
	
}
@property(nonatomic) CGPoint originalballxy,ballxy,ballvel;
@property(nonatomic) float ballrad;
- (id)initWithRad:(float)rad pos:(CGPoint)pos vel:(CGPoint)vel;
@end
