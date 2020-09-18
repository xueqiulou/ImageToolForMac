//
//  TMTestAppStoreVC.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/11.
//  Copyright © 2020 TM728. All rights reserved.
//

#import "TMTestAppStoreVC.h"

#define StringFromCGFloat(a) [NSString stringWithFormat:@"%.2f",a];

@interface TMTestAppStoreVC ()<NSTextFieldDelegate>

@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSImageView *imageView;

@property (weak) IBOutlet NSTextField *xTF;
@property (weak) IBOutlet NSTextField *yTF;

@property (weak) IBOutlet NSTextField *wTF;
@property (weak) IBOutlet NSTextField *hTF;

@end

@implementation TMTestAppStoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSImage *image = [NSImage imageNamed:@"2688_01"];
    self.imageView.image = image;
    
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width/3, self.imageView.image.size.height/3);
    
    self.scrollView.documentView = self.imageView;
    
    //设置textfield代理
    self.xTF.delegate = self;
    self.yTF.delegate = self;
    self.wTF.delegate = self;
    self.hTF.delegate = self;
    
    //添加监听滚动
    [self.scrollView.contentView setPostsBoundsChangedNotifications:true];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.scrollView.contentView];
    
    
}


-(void)boundsDidChange:(NSNotification *)noti
{
    NSLog(@"contentOffset-----%@",NSStringFromRect(self.scrollView.contentView.bounds));
    self.xTF.stringValue = StringFromCGFloat(self.scrollView.contentView.bounds.origin.x)
    self.yTF.stringValue = StringFromCGFloat(self.scrollView.contentView.bounds.origin.y)
    self.wTF.stringValue = StringFromCGFloat(self.scrollView.contentView.bounds.size.width)
    self.hTF.stringValue = StringFromCGFloat(self.scrollView.contentView.bounds.size.height)
}

- (void)viewDidLayout
{
    [super viewDidLayout];
}


#pragma mark --- NSTextFieldDelegate ---
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ([NSStringFromSelector(commandSelector) isEqualToString:@"insertNewline:"]) {
        
        if (([NSApplication sharedApplication].currentEvent.modifierFlags & NSEventModifierFlagShift) != 0) {
            NSLog(@"Shift-Enter detected.");
            [textView insertNewlineIgnoringFieldEditor:self];
            return YES;
        }else {//敲回车事件
            NSLog(@"Enter detected.");
            [self resetImagePosition];
        }
    }
    return NO;
}

-(void)resetImagePosition
{
    CGFloat x = self.xTF.stringValue.floatValue;
    CGFloat y = self.yTF.stringValue.floatValue;
    CGFloat w = self.wTF.stringValue.floatValue;
    CGFloat h = self.hTF.stringValue.floatValue;
    self.scrollView.contentView.bounds = CGRectMake(x, y, w, h);
}

@end
