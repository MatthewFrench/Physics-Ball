//
//  Curve.h
//  iPad Quartz Vector Drawing
//
//  Created by Matthew French on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Curve : NSObject {
	CGPoint curve0,curve1,curve2;
	NSMutableArray *curvePtX,*curvePtY;
}
@property(nonatomic) CGPoint curve0,curve1,curve2;
@property(nonatomic, assign) NSMutableArray *curvePtX,*curvePtY;
- (id)initWithCurves:(CGPoint)pt1 and:(CGPoint)pt2 and:(CGPoint)pt3;
@end
