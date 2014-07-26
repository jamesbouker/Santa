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
@property (strong, nonatomic) NSMutableArray *coal, *presents;  // will hold list of UIImageView's
@property (strong, nonatomic) CMMotionManager *manger;          // used to get phones tilt
@property (strong, nonatomic) IBOutlet UILabel *health;         // displays health to player
@property (strong, nonatomic) IBOutlet UIImageView *santa;      // renders santa
@property (strong, nonatomic) NSArray *walkRight, *walkLeft;    // holds array of UIImages

@end

@implementation ViewController {
    NSString *lastDir;  // can be 'R', 'L', or 'S' for right,left,still - santas possible directions
    int hp;             // stores the players health
    int diff;           // stores the difficulty of the game
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup health and difficulty
    hp = 10;
    diff = 50;
    
    //setup the coal and present arrays
    self.coal = [[NSMutableArray alloc] init];
    self.presents = [[NSMutableArray alloc] init];
    
    //setup the image arrays
    self.walkLeft = [self loadImagesForFilename:@"santaLeft" type:@"png" count:15];
    self.walkRight = [self loadImagesForFilename:@"santa" type:@"png" count:15];
    
    //setup the Core Motion Manager
	self.manger = [[CMMotionManager alloc] init];
    self.manger.accelerometerUpdateInterval = 1.0/30.0;
    [self.manger startAccelerometerUpdates];
    
    //setup the game loop
    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void)spawn:(NSString*)image {
    //create the image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    float w = imageView.width / 10;
    float h = imageView.height / 10;
    imageView.width = w;
    imageView.height = h;
    imageView.y = -h;
    imageView.x = arc4random()%((int)(self.view.width-w));
    
    //add imageView to the view
    [self.view insertSubview:imageView atIndex:0];
    
    //create the item
    NSDictionary *item = @{
        @"speed" : @(arc4random()%10 + 2),
        @"obj" : imageView
    };
    
    //add the item to the appropriate array
    if([image isEqualToString:@"LumpofCoal.png"])
        [self.coal addObject:item];
    else
        [self.presents addObject:item];
}

-(void)updateAllCoal {
    //create array for coal to remove
    NSMutableArray *deadCoals = [NSMutableArray array];
    
    for(NSDictionary *d in _coal) {
        //update the coals location
        UIImageView *coal = d[@"obj"];
        coal.y += [d[@"speed"] integerValue];
        
        if(coal.y > self.view.height) {
            //if coal off screen, remove from view
            [coal removeFromSuperview];
            [deadCoals addObject:d];
        }
        else if([self checkCollisionWBigRed:coal]) {
            //if coal colides with santa, remove coal & decrease health
            [coal removeFromSuperview];
            [deadCoals addObject:d];
            hp--;
            
            //if health less than 0, exit the app
            if(hp<0)
                exit(1);
            
            //update the health label
            _health.text = [NSString stringWithFormat:@"Health: %d", hp];
        }
    }
    
    //remove coal that has either collided or gone off screen from the coal array
    [_coal removeObjectsInArray:deadCoals];
}

-(void)updatePresents {
    //very similar to the above method
    //increasing the difficulty and health when santa collides w/ a present
    
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
    //get acceleration data
    float xAccel = self.manger.accelerometerData.acceleration.x;
    
    //update coal and presents
    [self updateAllCoal];
    [self updatePresents];
    
    if(arc4random() % 100 < 10) {
        //ten percent of the frames, add a coal or a present depending on difficulty
        [self spawn:(arc4random()%100 < diff)? @"LumpofCoal.png" : @"present.png"];
    }
    
    if(xAccel > .3) {
        //move santa to the right
        _santa.x += 2;
        [self changeDirection:@"R"];
        
        //prevent him from walking off screen
        if(_santa.x > self.view.width) {
            _santa.x = -_santa.width;
        }
    }
    else if(xAccel <-.3) {
        //move santa to the left
        _santa.x -= 2;
        [self changeDirection:@"L"];
        
        //prevent him from walking off screen
        if(_santa.x < -_santa.width) {
            _santa.x = self.view.width;
        }
    }
    else {
        //stop santa from moving
        [_santa stopAnimating];
        
        //set Santas image depending on the direction he is facing
        if([lastDir isEqualToString:@"R"])
            [_santa setImage:[UIImage imageNamed:@"santa1.png"]];
        else if([lastDir isEqualToString:@"L"])
            [_santa setImage:[UIImage imageNamed:@"santaLeft1.png"]];
        
        lastDir = @"S";
    }
}

-(void)changeDirection:(NSString *)dir {
    //prevent restarting the animation if direction did not change
    if([lastDir isEqualToString:dir])
        return;
    
    //set the current direction and animation
    lastDir = dir;
    NSArray *anim = ([lastDir isEqualToString:@"R"])? _walkRight : _walkLeft;
    
    //restart the animation in the new direction
    [_santa stopAnimating];
    _santa.animationImages = anim;
    _santa.animationDuration = 1;
    [_santa startAnimating];
}

//Best method ever! loads an array of images - to be used in animations
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
