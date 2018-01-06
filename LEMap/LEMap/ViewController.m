//
//  ViewController.m
//  LEMap
//
//  Created by mac on 2018/1/6.
//  Copyright © 2018年 le. All rights reserved.
//

#import "ViewController.h"
#import "BMHomeMapVC.h"
#import "UIInfomationView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (IBAction)showMap:(id)sender {
    BMHomeMapVC *map = [[BMHomeMapVC alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:map];
    [self presentViewController:navi animated:YES completion:nil];
}

@end
