//
//  ADGGraphicsView.m
//  ADrawGraphics
//
//  Created by WSCN on 7/22/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "ADGGraphicsView.h"
#import "ADGUtils.h"
#import "ADGCircle.h"
#import "ADGLoadLayer.h"

#define screenWidth self.frame.size.width
#define screenHeight self.frame.size.height

@interface ADGGraphicsView()

@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, strong) ADGCircle *staticCircle;
@property (nonatomic, strong) ADGCircle *moveCircle;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) ADGLoadLayer *loadLayer;
@property (nonatomic, assign) double loadingProgress;
@property (nonatomic, strong) NSTimer* timer;
@end

@implementation ADGGraphicsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.touchPoint = CGPointMake(150, 50);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationPause) name:@"SubmitButtonAnimationStop" object:nil];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loadingProgressChanged) userInfo:nil repeats:YES];
        [self stopTimer];
        self.loadingProgress = 4.0f;
    }
    return self;
}

- (ADGCircle *)staticCircle {
    if (!_staticCircle) {
        _staticCircle = [[ADGCircle alloc] init];
        _staticCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _staticCircle.radius = 20;
    }
    return _staticCircle;
}

- (ADGCircle *)moveCircle {
    if (!_moveCircle) {
        _moveCircle = [[ADGCircle alloc] init];
        _moveCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _moveCircle.radius = 50;
    }
    return _moveCircle;
}

- (UIBezierPath *)path {
    if (!_path) {
        _path = [[UIBezierPath alloc] init];
    }
    return _path;
}

- (void)drawRect:(CGRect)rect {
    [self drawGraphic];
    [self drawCurve];
    [self drawTouchCircle:self.touchPoint];
    [self drawStaticCircle:self.staticCircle moveCircle:self.moveCircle];
    
//    [self setupLoadLayer];
}

- (void)drawGraphic {
    //圆
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint point = CGPointMake(150, 50);
    [ADGUtils drawCircle:context fillcolor:[UIColor greenColor] radius:20 point:point];
    
    //同心圆
    [ADGUtils drawConcentricCircle:context lineColor:[UIColor redColor] fillColor:[UIColor purpleColor] lineWidth:5 radius:20 point:CGPointMake(60, 50)];
    
    //矩形
    [ADGUtils drawRect:context lineColor:[UIColor brownColor] fillColor:[UIColor redColor] lineWidht:5.0 rect:CGRectMake(200, 30, 30, 60)];
    
    //直线
    [ADGUtils drawLine:context color:[UIColor redColor] width:2 startPoint:CGPointMake(215, 15) endPoint:CGPointMake(215, 105)];
    
    //文字
    [ADGUtils drawText:context
                  text:@"绘制图形"
                   point:CGPointMake(screenWidth / 2.0, 5)
                   align:NSTextAlignmentCenter
                   attrs:nil];
    
    //虚线
    [ADGUtils drawDashLine:context color:[UIColor grayColor] width:1.0f startPoint:CGPointMake(14, 140) endPoint:CGPointMake(320, 140)];

    //圆角矩形
    [ADGUtils drawRoundedRect:context lineColor:[UIColor blackColor] fillColor:[UIColor brownColor] lineWidth:2.0f cornerRadius:10.0f rect:CGRectMake(30, 150, 100, 30)];
    
    //三角形
    [ADGUtils drawTriangle:context lineColor:[UIColor blackColor] fillColor:[UIColor blueColor] centerPoint:CGPointMake(30, 220) length:40 lineWidth:1.0 direction:TriangleDirectionUp];
    
    [ADGUtils drawTriangle:context lineColor:[UIColor blackColor] fillColor:[UIColor blueColor] centerPoint:CGPointMake(90, 220) length:60 lineWidth:1.0 direction:TriangleDirectionDown];
    
    [ADGUtils drawTriangle:context lineColor:[UIColor blackColor] fillColor:[UIColor blueColor] centerPoint:CGPointMake(150, 220) length:60 lineWidth:1.0 direction:TriangleDirectionLeft];
    
    [ADGUtils drawTriangle:context lineColor:[UIColor blackColor] fillColor:[UIColor blueColor] centerPoint:CGPointMake(220, 220) length:60 lineWidth:1.0 direction:TriangleDirectionRight];
    
    //任意三角形
    NSArray *pointArr = @[[NSValue valueWithCGPoint:CGPointMake(280, 350)],
                          [NSValue valueWithCGPoint:CGPointMake(300, 380)],
                          [NSValue valueWithCGPoint: CGPointMake(320, 330)]];
    [ADGUtils drawTriangle:context lineColor:[UIColor blueColor] fillColor:[UIColor blueColor] pointArr:pointArr lineWidth:1.0f];
}

- (void)drawCurve {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor brownColor].CGColor);
    
    CGContextMoveToPoint(context, 120, 400);
//    CGContextAddQuadCurveToPoint(context, 155, 200, 310, 400);
    
    CGContextAddCurveToPoint(context, 60, 350, 60, 250, 120, 300);
    CGContextMoveToPoint(context, 120, 300);
    CGContextAddCurveToPoint(context, 180, 250, 180, 350, 120, 400);
    CGContextMoveToPoint(context, 120, 400);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawTouchCircle:(CGPoint)point {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [ADGUtils drawCircle:context fillcolor:[UIColor greenColor] radius:20 point:point];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    self.moveCircle.center = [touch locationInView:self];
    
//    [self setNeedsDisplay];
    
//    UITouch *touch=touches.anyObject;
    //判断是否已经常见过动画，如果已经创建则不再创建动画
    CAAnimation *animation= [_loadLayer animationForKey:@"test"];
    if(animation){
        if (_loadLayer.speed==0) {
            [self animationResume];
        }else{
            [self animationPause];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self];
    self.moveCircle.center = [touch locationInView:self];

//    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (NSArray *)commonTangentPointsOfCircleA:(ADGCircle *)circleA cricleB:(ADGCircle *)circleB {
/*
 *  计算两个圆的外公切线的四个点的坐标
 *  http://blog.csdn.net/xieyupeng520/article/details/50374561
 *    α	Alpha
 *    β	Beta
 *    γ	Gamma
 *    ζ	Zeta
 */
    CGPoint pointA = circleA.center;
    double radiusA = circleA.radius;
    CGPoint pointB = circleB.center;
    double radiusB = circleB.radius;
    
    double d = [ADGUtils distanceBetweenPointA:pointA pointB:pointB];
    double gamma = asin((circleB.radius - circleA.radius) / d);
    double alpha = atan((pointB.y - pointA.y) / (pointA.x - pointB.x));
    
    double beta = M_PI_2 - gamma - alpha;
    
    CGPoint p1 = CGPointMake(pointA.x - cos(beta) * radiusA, pointA.y - sin(beta) * radiusA);
    CGPoint p2 = CGPointMake(pointB.x - cos(beta) * radiusB, pointB.y - sin(beta) * radiusB);
    
    double zeta = M_PI_2 + gamma - alpha;
    CGPoint p3 = CGPointMake(pointA.x + cos(zeta) * radiusA, pointA.y + sin(zeta) * radiusA);
    CGPoint p4 = CGPointMake(pointB.x + cos(zeta) * radiusB, pointB.y + sin(zeta) * radiusB);
    
    NSArray *points = @[[NSValue valueWithCGPoint:p1],
                        [NSValue valueWithCGPoint:p2],
                        [NSValue valueWithCGPoint:p3],
                        [NSValue valueWithCGPoint:p4]];
    return points;
}

- (void)drawStaticCircle:(ADGCircle *)staticCircle moveCircle:(ADGCircle *)moveCircle {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //静止的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor purpleColor] radius:staticCircle.radius point:staticCircle.center];
    
    //移动的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor purpleColor] radius:moveCircle.radius point:moveCircle.center];
    
    CGFloat distance = [ADGUtils distanceBetweenPointA:staticCircle.center pointB:moveCircle.center];
    
    NSArray *points = [self commonTangentPointsOfCircleA:staticCircle cricleB:moveCircle];
    CGPoint point1 = [points[0] CGPointValue];
    CGPoint point2 = [points[1] CGPointValue];
    CGPoint point3 = [points[2] CGPointValue];
    CGPoint point4 = [points[3] CGPointValue];
    if (distance < 70) {
        //两个圆外公切线
        [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:[points[0] CGPointValue] endPoint:[points[1] CGPointValue]];
        [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:[points[2] CGPointValue] endPoint:[points[3] CGPointValue]];
        
        [self.path removeAllPoints];
        [self drawCurveWithPointA:point1 pointB:point2 controlPoint:[ADGUtils midpointBetweenPointA:point1 pointB:point4]];
        [self.path addLineToPoint:point4];
        
        [self drawCurveWithPointA:point4 pointB:point3 controlPoint:[ADGUtils midpointBetweenPointA:point3 pointB:point2]];
        [self.path addLineToPoint:point1];
        
        [self.path moveToPoint:point1];
        [self.path closePath];
        [self.path fill];
        
        //p1 static.center p2,p3 move.center p4
        [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:staticCircle.center endPoint:point1];
        [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:staticCircle.center endPoint:point3];
        
        [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:moveCircle.center endPoint:point4];
        [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:moveCircle.center endPoint:point2];
    }else {
        CGFloat controlPointDistance = distance / 2.0 / 10 * 9;
        CGFloat ß = controlPointDistance / distance;
        CGFloat y = (moveCircle.center.y - staticCircle.center.y) * ß + staticCircle.center.y;
        CGFloat x = (moveCircle.center.x - staticCircle.center.x) * ß + staticCircle.center.x;
        
        CGPoint controlPoint = CGPointMake(x, y);
        [self.path removeAllPoints];
        [self drawCurveWithPointA:point1 pointB:point3 controlPoint:controlPoint];
        [self.path moveToPoint:point1];
        [self.path closePath];
        [self.path fill];

    }
    
    
}

- (void)drawCurveWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB controlPoint:(CGPoint)controlPoint {
    [self.path moveToPoint:pointA];
    [self.path addQuadCurveToPoint:pointB controlPoint:controlPoint];
}

- (ADGLoadLayer *)loadLayer {
    if (!_loadLayer) {
        self.loadLayer = [ADGLoadLayer layer];
        self.loadLayer.contentsScale = [UIScreen mainScreen].scale;
        self.loadLayer.bounds = CGRectMake(0, 0, screenWidth, screenHeight);
        self.loadLayer.position = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        self.loadLayer.progress = 174;
        self.loadLayer.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        self.loadLayer.width = 150.0f;
        self.loadLayer.height = 50.0f;
        self.loadLayer.speed = 0;
    }
    return  _loadLayer;
}

- (void)setupLoadLayer {
    [self.layer addSublayer:self.loadLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.duration = 17.4f;
    animation.fromValue = @0.0;
    animation.toValue = @174.0;
    animation.repeatCount = 1;
    animation.delegate = self;
    [self.loadLayer addAnimation:animation forKey:@"test"];
    
}

-(void)animationResume {
    //获得暂停的时间
    CFTimeInterval beginTime= CACurrentMediaTime()- _loadLayer.timeOffset;
    //设置偏移量
    _loadLayer.timeOffset=0;
    //设置开始时间
    _loadLayer.beginTime=beginTime;
    //设置动画速度，开始运动
    _loadLayer.speed=1.0;
}

-(void)animationPause{
    //取得指定图层动画的媒体时间，后面参数用于指定子图层，这里不需要
    CFTimeInterval interval=[_loadLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    //设置时间偏移量，保证暂停时停留在旋转的位置
    [_loadLayer setTimeOffset:interval];
    //速度设置为0，暂停动画
    _loadLayer.speed=0;
    
    [self startTimer];
}

- (void)loadingProgressChanged {
    self.loadingProgress += 0.1;
    if (self.loadingProgress > 11.5) {
        [self animationResume];
        return;
    }
    CFTimeInterval newInterval  = self.loadingProgress;
    [_loadLayer setTimeOffset:newInterval];
    _loadLayer.speed = 0;
}

- (void)stopTimer {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)startTimer {
    [self.timer setFireDate:[NSDate distantPast]];
}


@end
