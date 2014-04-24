//
//  ViewController.m
//  Santa
//
//  Created by Jimmy on 4/17/14.
//  Copyright (c) 2014 JimmyBouker. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *coal, *presents;
@property (strong, nonatomic) CMMotionManager *manger;
@property (strong, nonatomic) IBOutlet UILabel *health;
@property (strong, nonatomic) IBOutlet UIImageView *santa;
@property (strong, nonatomic) NSArray *walkRight, *walkLeft;

@end

@implementation ViewController {
    NSString *lastDir;
    int hp, diff;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hp = 10;
    diff = 50;
    
    self.coal = [[NSMutableArray alloc] init];
    self.presents = [[NSMutableArray alloc] init];
    
    self.walkLeft = [self loadImagesForFilename:@"santaLeft" type:@"png" count:15];
    self.walkRight = [self loadImagesForFilename:@"santa" type:@"png" count:15];
    
	self.manger = [[CMMotionManager alloc] init];
    self.manger.accelerometerUpdateInterval = 1.0/30.0;
    [self.manger startAccelerometerUpdates];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void)spawn:(NSString*)image {
    UIImageView *coal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    float w = coal.width / 10;
    float h = coal.height / 10;
    coal.width = w;
    coal.height = h;
    coal.y = -h;
    coal.x = arc4random()%((int)(self.view.width-w));
    
    //adds to back
    [self.view insertSubview:coal atIndex:0];
    
    if([image isEqualToString:@"LumpofCoal.png"])
        [self.coal addObject:@{@"speed" : @(arc4random()%10 + 2),
                               @"obj" : coal}];
    else
        [self.presents addObject:@{@"speed" : @(arc4random()%10 + 2),
                                   @"obj" : coal}];
}

-(void)updateAllCoal {
    NSMutableArray *deadCoals = [NSMutableArray array];
    for(NSDictionary *d in _coal) {
        UIImageView *coal = d[@"obj"];
        coal.y += [d[@"speed"] integerValue];
        
        if(coal.y > self.view.height) {
            [coal removeFromSuperview];
            [deadCoals addObject:d];
        }
        else if([self checkCollisionWBigRed:coal]) {
            [coal removeFromSuperview];
            [deadCoals addObject:d];
            hp--;
            if(hp<0)
                exit(1);
            _health.text = [NSString stringWithFormat:@"Health: %d", hp];
        }
    }
    
    [_coal removeObjectsInArray:deadCoals];
}

-(void)updatePresents {
    NSMutableArray *deadPresents = [NSMutableArray array];
    for(NSDictionary *d in _presents) {
        UIImageView *present = d[@"obj"];
        present.y += [d[@"speed"] integerValue];
        
        if(present.y > self.view.height) {
            [present removeFromSuperview];
            [deadPresents addObject:d];
        }
        else if([self checkCollisionWBigRed:present]) {
            [present removeFromSuperview];
            [deadPresents addObject:d];
            hp++;
            _health.text = [NSString stringWithFormat:@"Health: %d", hp];
            
            if(hp>10) {
                diff+= hp / 10;
            }
        }
    }
    
    [_presents removeObjectsInArray:deadPresents];
}

-(BOOL)checkCollisionWBigRed:(UIView*)aView {
    return CGRectIntersectsRect(_santa.frame, aView.frame);
}

-(void)update {
    float xAccel = self.manger.accelerometerData.acceleration.x;
    
    [self updateAllCoal];
    [self updatePresents];
    
    if(arc4random() % 100 < 10) {
        [self spawn:(arc4random()%100 < diff)? @"LumpofCoal.png" : @"present.png"];
    }
    
    if(xAccel > .3) {
        _santa.x += 2;
        [self changeDirection:@"R"];
        
        if(_santa.x > self.view.width) {
            _santa.x = -_santa.width;
        }
    }
    else if(xAccel <-.3) {
        _santa.x -= 2;
        [self changeDirection:@"L"];
        
        if(_santa.x < -_santa.width) {
            _santa.x = self.view.width;
        }
    }
    else {
        [_santa stopAnimating];
        
        if([lastDir isEqualToString:@"R"]) {
            [_santa setImage:[UIImage imageNamed:@"santa1.png"]];
        }
        else if([lastDir isEqualToString:@"L"]) {
            [_santa setImage:[UIImage imageNamed:@"santaLeft1.png"]];
        }
        
        lastDir = @"S";
    }
}

-(void)changeDirection:(NSString *)dir {
    if([lastDir isEqualToString:dir])
        return;
    
    lastDir = dir;
    NSArray *anim = ([lastDir isEqualToString:@"R"])? _walkRight : _walkLeft;
    
    [_santa stopAnimating];
    _santa.animationImages = anim;
    _santa.animationDuration = 1;
    [_santa startAnimating];
}

-(NSMutableArray*)loadImagesForFilename:(NSString *)filename type:(NSString*)extension count:(int)count {
    NSMutableArray *images = [NSMutableArray array];
    for(int i=1; i<= count; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d.%@", filename, i, extension]];
        if(image != nil)
            [images addObject:image];
    }
    return images;
}

@end
