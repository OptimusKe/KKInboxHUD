//
//  KKInboxHUD.m
//  KKInboxHUD
//
//  Created by OptimusKe on 2014/11/5.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import "KKInboxHUD.h"

static const CGFloat starProgress = 0.05;
static const CGFloat endProgress  = 1.0 - starProgress;
static const CGFloat width  = 4;
static const CGFloat rotateAngleStep  = 2 * M_PI * (0.6 / 60.0);
static const CGFloat waitingFrameDuration  = 30;

@interface KKInboxHUD (){
    
    CGFloat w;
    CGFloat rotateAngle;
    CGFloat progress;
    CGFloat waitingFrame;
    BOOL increase;
    CGFloat starAngle;
    CGFloat endAngle;
    CADisplayLink *displayTimer;
}

@end

@implementation KKInboxHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        displayTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress:)];
        [displayTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        increase = YES;
        waitingFrame = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextSetLineWidth(context, width);
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = (rect.size.width - width) / 2;

    if(increase){
        endAngle  = starAngle + (2 * M_PI * progress);
    }
    else {
        starAngle = endAngle - (2 * M_PI * progress);
    }
    CGContextAddArc(context, center.x, center.y, radius, starAngle + rotateAngle, endAngle + rotateAngle, 0);


    CGContextStrokePath(context);
}

#pragma mark - methods

- (void)updateProgress:(CADisplayLink*)sender{
    
    rotateAngle = fmodf(rotateAngle + rotateAngleStep, M_PI * 2); //mod for avoid overflow
    
    //no watting
    if(waitingFrame == 0){
        // value : 0 ~ 3.14xxx
        w = fmodf(w + M_PI * (0.5 / 60.0), M_PI) ; //mod for avoid overflow
    }
    
    CGFloat y = sinf(w);
    CGFloat percent = fabsf(y);
    
    if(percent < 0.001){
        //star waiting
        waitingFrame++;
        
        //time out then keep drawing
        if(waitingFrame >= waitingFrameDuration){
            waitingFrame = 0;
            increase = YES;
            starAngle = endAngle - (2 * M_PI * progress);
        }
    } else if(fabsf(y) == 1.0){
        increase = NO;
        starAngle = endAngle;
    }
    
    progress = starProgress + (percent * (endProgress - starProgress));
    [self setNeedsDisplay];
}

@end
