//
//  ViewController.m
//  ADrawGraphics
//
//  Created by WSCN on 7/22/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "ViewController.h"
#import "ADGGraphicsView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenheight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic, strong) ADGGraphicsView *graphicsView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.graphicsView = [[ADGGraphicsView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenheight - 64)];
    self.graphicsView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.graphicsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
