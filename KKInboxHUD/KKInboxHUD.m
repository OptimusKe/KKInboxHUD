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
    UIColor *strokeColor;
    UIColor *interpolateColor;
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
        strokeColor = [UIColor greenColor];
        interpolateColor = strokeColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, interpolateColor.CGColor);
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
        
        if(waitingFrame == 0){
            //change next color
            if([strokeColor isEqual:[UIColor greenColor]]){
                strokeColor = [UIColor blueColor];
            } else {
                strokeColor = [UIColor greenColor];
            }
        }
        
        //star waiting
        waitingFrame++;
        
        //color interpolate
        CGFloat colorProgress = waitingFrame / waitingFrameDuration;
        const CGFloat* originColors = CGColorGetComponents( interpolateColor.CGColor );
        const CGFloat* targetColors = CGColorGetComponents( strokeColor.CGColor );
        CGFloat newRed   = (1.0 - colorProgress) * originColors[0] + colorProgress * targetColors[0];
        CGFloat newGreen = (1.0 - colorProgress) * originColors[1] + colorProgress * targetColors[1];
        CGFloat newBlue  = (1.0 - colorProgress) * originColors[2] + colorProgress * targetColors[2];
        interpolateColor = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.0];
        
        
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
