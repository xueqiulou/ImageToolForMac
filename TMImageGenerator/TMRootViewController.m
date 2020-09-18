//
//  TMRootViewController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/7.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMRootViewController.h"
#import "TMGenerateScaleImageController.h"

@interface TMRootViewController ()

@end

@implementation TMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TMGenerateScaleImageController *vc1 = [[TMGenerateScaleImageController alloc] init];
    
    [self addChildViewController:vc1];
    
}

@end
