//
//  ADGLoadLayer.m
//  ADrawGraphics
//
//  Created by WSCN on 7/25/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import "ADGLoadLayer.h"
#import <UIKit/UIKit.h>
#import "ADGUtils.h"
#import "ADGCircle.h"

#define screenWidth self.frame.size.width
#define screenHeight self.frame.size.height

@interface ADGLoadLayer()

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) ADGCircle *staticCircle;
@property (nonatomic, strong) ADGCircle *moveCircle;

@end

@implementation ADGLoadLayer

@dynamic progress;

- (UIBezierPath *)path {
    if (!_path) {
        _path = [[UIBezierPath alloc] init];
        UIColor *fillColor = [UIColor redColor];
        [fillColor set];
    }
    return _path;
}

- (ADGCircle *)staticCircle {
    if (!_staticCircle) {
        _staticCircle = [[ADGCircle alloc] init];
//        _staticCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _staticCircle.radius = 10;
    }
    return _staticCircle;
}

- (ADGCircle *)moveCircle {
    if (!_moveCircle) {
        _moveCircle = [[ADGCircle alloc] init];
//        _moveCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _moveCircle.radius = 13;
    }
    return _moveCircle;
}


+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGPoint center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
    CGFloat radius = 100;
    NSArray *centers = @[[NSValue valueWithCGPoint:CGPointMake(center.x, center.y - radius)],
                         [NSValue valueWithCGPoint:CGPointMake(center.x + radius / sqrtf(2), center.y - radius / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(center.x + radius, center.y)],
                         [NSValue valueWithCGPoint:CGPointMake(center.x + radius / sqrtf(2), center.y + radius / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(center.x, center.y + radius)],
                         [NSValue valueWithCGPoint:CGPointMake(center.x - radius / sqrtf(2), center.y + radius / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(center.x - radius, center.y)],
                         [NSValue valueWithCGPoint:CGPointMake(center.x - radius / sqrtf(2), center.y - radius / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(center.x, center.y - radius)]
                         ];
    [ADGUtils drawCircles:ctx fillColor:[UIColor redColor] points:centers radius:10.0f];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    CGFloat originstart = -M_PI_2;
    CGFloat currentOrigin = originstart + (M_PI_4 * self.progress);
    CGFloat currentDest = 2 * M_PI - M_PI_2;
    
    CGFloat x = center.x + radius * cosf(currentOrigin);
    CGFloat y = center.y + radius * sinf(currentOrigin);
    CGPoint point = CGPointMake(x, y);
    
    [circlePath addArcWithCenter:center radius:radius startAngle:currentOrigin endAngle:currentDest clockwise:0];
//    CGContextAddPath(ctx, circlePath.CGPath);
    
//    [ADGUtils drawCircle:ctx fillcolor:[UIColor brownColor] radius:15.0f point:point];
    NSString *index = [NSString stringWithFormat:@"%.0f",self.progress];
    NSLog(@"index = %@",index);
    self.staticCircle.center = [centers[index.intValue] CGPointValue];
    self.moveCircle.center = point;
    [self drawStaticCircle:self.staticCircle moveCircle:self.moveCircle context:ctx];
}

- (void)drawStaticCircle:(ADGCircle *)staticCircle moveCircle:(ADGCircle *)moveCircle context:(CGContextRef)context {
//    CGContextRef context = UIGraphicsGetCurrentContext();
    //静止的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor redColor] radius:staticCircle.radius point:staticCircle.center];
    
    //移动的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor redColor] radius:moveCircle.radius point:moveCircle.center];
    
    NSArray *points = [self commonTangentPointsOfCircleA:staticCircle cricleB:moveCircle];
    CGPoint point1 = [points[0] CGPointValue];
    CGPoint point2 = [points[1] CGPointValue];
    CGPoint point3 = [points[2] CGPointValue];
    CGPoint point4 = [points[3] CGPointValue];
    
    
    //两个圆外公切线
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:[points[0] CGPointValue] endPoint:[points[1] CGPointValue]];
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:[points[2] CGPointValue] endPoint:[points[3] CGPointValue]];
    
    [self.path removeAllPoints];
    [self drawCurveWithPointA:point1 pointB:point2 controlPoint:[ADGUtils midpointBetweenPointA:point1 pointB:point4]];
    [self.path addLineToPoint:point4];
    
    [self drawCurveWithPointA:point4 pointB:point3 controlPoint:[ADGUtils midpointBetweenPointA:point3 pointB:point2]];
    [self.path addLineToPoint:point1];
    
    [self.path moveToPoint:point1];
    [self.path closePath];
    [self.path fill];
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddPath(context, self.path.CGPath);
    CGContextDrawPath(context, kCGPathFill);
    
    //p1 static.center p2,p3 move.center p4
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:staticCircle.center endPoint:point1];
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:staticCircle.center endPoint:point3];
//
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:moveCircle.center endPoint:point4];
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:moveCircle.center endPoint:point2];
}

- (void)drawCurveWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB controlPoint:(CGPoint)controlPoint {
    [self.path moveToPoint:pointA];
    [self.path addQuadCurveToPoint:pointB controlPoint:controlPoint];
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
@end
