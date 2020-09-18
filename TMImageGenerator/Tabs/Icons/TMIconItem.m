//
//  TMIconItem.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/9.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMIconItem.h"

@interface TMIconItem ()

@end

@implementation TMIconItem

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = true;
    
//    self.view.layer.borderColor = [NSColor blueColor].CGColor;
//    self.view.layer.borderWidth = 1.;
    
    NSButton *button = [NSButton checkboxWithTitle:@"xxx" target:self action:@selector(click:)];
    [self.view addSubview:button];
    self.checkBtn = button;
    
}

-(void)click:(NSButton*)sender{

    _model.isSelected = sender.state == 1;
    
}

-(void)setModel:(TMIconsModel *)model{
    _model = model;
    self.checkBtn.title = [NSString stringWithFormat:@"%@x%@",model.sizeWidth,model.sizeWidth];
    self.checkBtn.state = model.isSelected;
}

-(void)viewDidLayout{
    [super viewDidLayout];
    CGFloat w = 100;
    CGFloat h = 30;
    CGFloat x = 20;
    CGFloat y = (self.view.frame.size.height-h)*0.5;
    self.checkBtn.frame = CGRectMake(x, y, w, h);
}

@end
