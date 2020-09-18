//
//  ViewController.m
//  TMImageGenerator
//
//  Created by 薛秋楼 on 2020/9/4.
//  Copyright © 2020 admin. All rights reserved.
//

#import "ViewController.h"
#import "TMDragToDisplayView.h"
#import "TMGenerateScaleImageController.h"
#import "TMGenerateIconsController.h"
#import "TMAppStoreImageController.h"
#import "TMTestAppStoreVC.h"

#define screenW NSScreen.mainScreen.frame.size.width
#define screenH NSScreen.mainScreen.frame.size.height

@interface ViewController ()<TMDragImageDelegate,NSTabViewDelegate>

@property (weak) IBOutlet NSTabView *tabView;

@property (strong,nonatomic) NSImageView *imageView;
@property (strong,nonatomic) TMDragToDisplayView *dragView;

@property (strong,nonatomic) TMGenerateScaleImageController *scaleImageVC;
@property (strong,nonatomic) TMGenerateIconsController *iconsVC;
@property (strong,nonatomic) TMAppStoreImageController *storeVC;
@property (strong,nonatomic) TMTestAppStoreVC *testVC;

@property (strong,nonatomic) NSArray *names;

@end

@implementation ViewController
//#import "TMAppStoreNewImageController.h"
- (void)viewDidLoad {
    [super viewDidLoad];
    self.names = @[
        @"TMGenerateScaleImageController",
        @"TMGenerateIconsController",
        @"TMAppStoreNewImageController",
        @"TMCompressImageController"
    ];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self.view.window
//    selector:@selector(windowDidResize:)
//        name:NSWindowDidResizeNotification
//        object:self];
//
//
//    TMDragToDisplayView *dragView = [[TMDragToDisplayView alloc] init];
//    dragView.autoresizingMask = NSViewMaxXMargin|NSViewMaxYMargin;
//    dragView.frame = CGRectMake(20, 20, 200, 200);
//    dragView.wantsLayer = true;
//    dragView.layer.backgroundColor = [NSColor redColor].CGColor;
////
//    dragView.delegate = self;
//    [self.view addSubview:dragView];
//    self.dragView = dragView;
    
//    NSTabViewItem *tabViewItem1 = [self.tabView.tabViewItems objectAtIndex:0];
//    self.scaleImageVC = [[TMGenerateScaleImageController alloc] initWithNibName:@"TMGenerateScaleImageController" bundle:nil];
//    [tabViewItem1 setView:self.scaleImageVC.view];
//
//    NSTabViewItem *tabViewItem2 = [self.tabView.tabViewItems objectAtIndex:1];
//    self.iconsVC = [[TMGenerateIconsController alloc] initWithNibName:@"TMGenerateIconsController" bundle:nil];
//    [tabViewItem2 setView:self.iconsVC.view];
    
    [self tabViewAddChildControllers];
}

-(void)tabViewAddChildControllers
{
    int index = 0;
    for (NSString *name in self.names) {
        NSTabViewItem *tabViewItem = [self.tabView.tabViewItems objectAtIndex:index];
        Class class = NSClassFromString(name);
        NSViewController *vc = [[class alloc] initWithNibName:name   bundle:nil];
        [tabViewItem setView:vc.view];
        [tabViewItem setViewController:vc];//不添加这句,控制器上的子控件不响应事件
        index ++;
    }
}

-(void)windowDidResize{
    NSLog(@"%@",NSStringFromRect(self.view.window.frame));
}

-(void)viewDidLayout{
    [super viewDidLayout];
    
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)dragViewCompleteWithFiles:(NSArray *)filePaths
{
    NSLog(@"%@",filePaths);
    
    self.dragView.layer.contents = [[NSImage alloc] initByReferencingFile:filePaths.firstObject];

}

#pragma mark --- NSTabView 代理方法 ---
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    NSLog(@"%@",tabViewItem.label);
    return true;
}
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    NSLog(@"%s -- %@",__FUNCTION__,tabViewItem.label);
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem
{
    NSLog(@"%s -- %@",__FUNCTION__,tabViewItem.label);
}
- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView
{
    NSLog(@"%s",__FUNCTION__);
}

@end
