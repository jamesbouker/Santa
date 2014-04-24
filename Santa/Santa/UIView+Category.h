//
//  UIView+Category.h
//
//  Created by Jimmy on 8/21/12.
//  Copyright (c) 2013 Jimmy Bouker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

@property float x;
@property float y;
@property float width;
@property float height;
@property CGPoint origin;

-(void)storeLayout;
-(void)restoreLayout;
-(void)roundEdges:(float)radius;

@end