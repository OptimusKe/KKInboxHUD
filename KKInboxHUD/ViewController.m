//
//  ViewController.m
//  KKInboxHUD
//
//  Created by OptimusKe on 2014/11/5.
//  Copyright (c) 2014年 KerKer. All rights reserved.
//

#import "ViewController.h"
#import "KKInboxHUD.h"

@interface ViewController () {
    KKInboxHUD *hud;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hud = [[KKInboxHUD alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    hud.center = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - action

- (IBAction)toggleHUD:(id)sender {
    if ([hud superview]) {
        [hud removeFromSuperview];
    }
    else {
        [self.view addSubview:hud];
    }
}

@end
