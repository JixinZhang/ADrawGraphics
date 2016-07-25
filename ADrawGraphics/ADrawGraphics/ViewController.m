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
    _mlayer.position = CGPointMake(70, 150);
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
    
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathMoveToPoint(circlePath, NULL, self.mlayer.position.x, self.mlayer.position.y);
//    CGPathAddArcToPoint(circlePath, NULL, 50, 150, 50, 150, 20);
    CGPathAddArc(circlePath, NULL, 50, 150, 20, 0, M_PI * 2, 0);
    
    keyFrameAnimaiton.path = circlePath;
    CGPathRelease(circlePath);
    keyFrameAnimaiton.duration = 1.0f;
    keyFrameAnimaiton.repeatCount = 10;
    [self.mlayer addAnimation:keyFrameAnimaiton forKey:@"KCKeyframeAnimation_Position"];
    
//    CAKeyframeAnimation *keyframeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
//    //2.设置路径
//    //绘制贝塞尔曲线
//    CGMutablePathRef path=CGPathCreateMutable();
//    CGPathMoveToPoint(path, NULL, _mlayer.position.x, _mlayer.position.y);//移动到起始点
//    CGPathAddCurveToPoint(path, NULL, 160, 280, -30, 300, 55, 400);//绘制二次贝塞尔曲线
//    
//    keyframeAnimation.path=path;//设置path属性
//    CGPathRelease(path);//释放路径对象
//    //设置其他属性
//    keyframeAnimation.duration=8.0;
//    keyframeAnimation.repeatCount = 10;
//    //3.添加动画到图层，添加动画后就会执行动画
//    [_mlayer addAnimation:keyframeAnimation forKey:@"KCKeyframeAnimation_Position"];
}

@end
