//
//  UIView+Category.m
//
//  Created by Jimmy on 8/21/12.
//  Copyright (c) 2013 Jimmy Bouker. All rights reserved.
//

#import "UIView+Category.h"
#import <objc/runtime.h>

@implementation UIView (Category)
static const char * LAYOUT_KEY = "com.jimmyBouker.BrainTrain.layoutKey";

-(void)setX:(float)x {
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

-(void)setY:(float)y {
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

-(void)setWidth:(float)width {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

-(void)setHeight:(float)height {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

-(void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

-(float)x {
    return self.frame.origin.x;
}

-(float)y {
    return self.frame.origin.y;
}

-(float)width {
    return self.frame.size.width;
}

-(float)height {
    return self.frame.size.height;
}

-(CGPoint)origin {
    return self.frame.origin;
}

-(void)storeLayout {
    NSDictionary *frame = [NSDictionary dictionaryWithObjects:
                           @[[NSNumber numberWithFloat:self.x],
                             [NSNumber numberWithFloat:self.y],
                             [NSNumber numberWithFloat:self.width],
                             [NSNumber numberWithFloat:self.height]]
                                                      forKeys:@[@"x", @"y", @"w", @"h"]];
    
    objc_setAssociatedObject(self, LAYOUT_KEY, frame, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)restoreLayout {
    NSDictionary *frameMp = objc_getAssociatedObject(self, LAYOUT_KEY);
    if(frameMp != nil) {
        NSNumber *x = [frameMp objectForKey:@"x"];
        NSNumber *y = [frameMp objectForKey:@"y"];
        NSNumber *w = [frameMp objectForKey:@"w"];
        NSNumber *h = [frameMp objectForKey:@"h"];
        
        CGRect frame = CGRectMake(x.floatValue, y.floatValue, w.floatValue, h.floatValue);
        self.frame =frame;
    }
}

-(void)roundEdges:(float)radius {
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
}

@end