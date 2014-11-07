//
//  KKInboxHUD.m
//  KKInboxHUD
//
//  Created by OptimusKe on 2014/11/5.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import "KKInboxHUD.h"

static const CGFloat starProgress = 0.07;
static const CGFloat endProgress  = 1.0 - starProgress;
static const CGFloat defaultLineWidth = 5;
static const CGFloat rotateAngleStep  = 2 * M_PI * (0.7 / 60.0);
static const CGFloat waitingFrameDuration  = 30;

@interface KKInboxHUD () {
    CGFloat w;
    CGFloat rotateAngle;
    CGFloat progress;
    CGFloat waitingFrame;
    CGFloat starAngle;
    CGFloat endAngle;
    UIColor *strokeColor;
    UIColor *interpolateColor;
    CADisplayLink *displayTimer;
    BOOL increase;
    NSInteger colorIndex;
}

@end

@implementation KKInboxHUD

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //Google inbox hud colors
        self.customColors = @[[UIColor colorWithRed:71.0 / 255.0 green:116.0 / 255.0 blue:233.0 / 255.0 alpha:1.0],  //blue
                              [UIColor colorWithRed:221.0 / 255.0 green:25.0 / 255.0 blue:48.0 / 255.0 alpha:1.0],   //red
                              [UIColor colorWithRed:255.0 / 255.0 green:172.0 / 255.0 blue:6.0 / 255.0 alpha:1.0],   //yellow
                              [UIColor colorWithRed:6.0 / 255.0 green:173.0 / 255.0 blue:24.0 / 255.0 alpha:1.0]];   //green
        self.lineWidth = defaultLineWidth;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, interpolateColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = (rect.size.width - self.lineWidth) / 2;
    
    if (increase) {
        endAngle  = starAngle + (2 * M_PI * progress);
    }
    else {
        starAngle = endAngle - (2 * M_PI * progress);
    }
    CGContextAddArc(context, center.x, center.y, radius, starAngle + rotateAngle, endAngle + rotateAngle, 0);
    CGContextStrokePath(context);
}

#pragma mark - methods

- (void)reset {
    increase = YES;
    waitingFrame = 0;
    colorIndex = 0;
    strokeColor = [self.customColors objectAtIndex:colorIndex];
    interpolateColor = strokeColor;
    starAngle = 0;
    endAngle = 0;
}

- (void)updateProgress:(CADisplayLink *)sender {
    rotateAngle = fmodf(rotateAngle + rotateAngleStep, M_PI * 2); //mod for avoid overflow
    
    //no watting
    if (waitingFrame == 0) {
        // value : 0 ~ 3.14xxx
        w = fmodf(w + M_PI * (0.5 / 60.0), M_PI);  //mod for avoid overflow
    }
    
    CGFloat y = sinf(w);
    CGFloat percent = fabsf(y);
    
    if (percent < 0.001) {
        if (waitingFrame == 0) {
            colorIndex++;
            if (colorIndex >= self.customColors.count) {
                colorIndex = 0;
            }
            //change next color
            strokeColor = [self.customColors objectAtIndex:colorIndex];
        }
        
        //star waiting
        waitingFrame++;
        
        //color interpolate
        CGFloat colorProgress = waitingFrame / waitingFrameDuration;
        const CGFloat *originColors = CGColorGetComponents(interpolateColor.CGColor);
        const CGFloat *targetColors = CGColorGetComponents(strokeColor.CGColor);
        CGFloat newRed   = (1.0 - colorProgress) * originColors[0] + colorProgress * targetColors[0];
        CGFloat newGreen = (1.0 - colorProgress) * originColors[1] + colorProgress * targetColors[1];
        CGFloat newBlue  = (1.0 - colorProgress) * originColors[2] + colorProgress * targetColors[2];
        interpolateColor = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.0];
        
        
        //time out then keep drawing
        if (waitingFrame >= waitingFrameDuration) {
            waitingFrame = 0;
            increase = YES;
            starAngle = endAngle - (2 * M_PI * progress);
        }
    }
    else if (fabsf(y) == 1.0) {
        increase = NO;
        starAngle = endAngle;
    }
    
    progress = starProgress + (percent * (endProgress - starProgress));
    [self setNeedsDisplay];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reset];
        displayTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress:)];
        [displayTimer addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
    else {
        [displayTimer removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        displayTimer = nil;
    }
}

@end
