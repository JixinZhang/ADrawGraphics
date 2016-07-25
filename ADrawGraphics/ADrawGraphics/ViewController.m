//
//  ViewController.m
//  ADrawGraphics
//
//  Created by WSCN on 7/22/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "ViewController.h"
#import "ADGGraphicsView.h"
#import "ADGUtils.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenheight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) ADGGraphicsView *graphicsView;
@property (nonatomic, strong) CALayer *mlayer;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.graphicsView = [[ADGGraphicsView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenheight - 64)];
    self.graphicsView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.graphicsView];
    
    _mlayer = [[CALayer alloc] init];
    _mlayer.bounds = CGRectMake(0, 0, 20, 20);
    _mlayer.position = CGPointMake(100, 150);
    //        _mlayer.backgroundColor = [UIColor orangeColor].CGColor;
    _mlayer.contents = (id)[UIImage imageNamed:@"wechat.png"].CGImage;
    [self.view.layer addSublayer:_mlayer];
    [self translationAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)translationAnimation {
    CAKeyframeAnimation *keyFrameAnimaiton = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimaiton.delegate = self;
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathMoveToPoint(circlePath, NULL, self.mlayer.position.x, self.mlayer.position.y);
    CGPathAddArc(circlePath, NULL, 50, 150, 50, 0, M_PI * 2, 0);
    
    keyFrameAnimaiton.path = circlePath;
    CGPathRelease(circlePath);
    keyFrameAnimaiton.duration = 5.0f;
    keyFrameAnimaiton.repeatCount = 10;
    keyFrameAnimaiton.repeatDuration = INFINITY;
    [self.mlayer addAnimation:keyFrameAnimaiton forKey:@"KCKeyframeAnimation_Position"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    _mlayer.position = CGPointMake(100, 150);
}
@end
