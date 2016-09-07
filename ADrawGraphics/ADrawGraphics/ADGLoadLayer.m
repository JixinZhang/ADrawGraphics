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
#define mainColor [UIColor colorWithRed:24/255.0 green:197/255.0 blue:138/255.0 alpha:1]
#define grayBorderColor [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1]
@interface ADGLoadLayer()

@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) ADGCircle *startCircle;
@property (nonatomic, strong) ADGCircle *moveCircle;
@property (nonatomic, strong) ADGCircle *endCircle;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *circleBorderColor;

@end

@implementation ADGLoadLayer

@dynamic progress;
@dynamic center;
@dynamic width;
@dynamic height;

- (UIBezierPath *)path {
    if (!_path) {
        _path = [[UIBezierPath alloc] init];
        UIColor *fillColor = [UIColor redColor];
        [fillColor set];
    }
    return _path;
}

- (ADGCircle *)startCircle {
    if (!_startCircle) {
        _startCircle = [[ADGCircle alloc] init];
//        _startCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _startCircle.radius = 10;
    }
    return _startCircle;
}

- (ADGCircle *)moveCircle {
    if (!_moveCircle) {
        _moveCircle = [[ADGCircle alloc] init];
//        _moveCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _moveCircle.radius = 13;
    }
    return _moveCircle;
}

- (ADGCircle *)endCircle {
    if (!_endCircle) {
        _endCircle = [[ADGCircle alloc] init];
        //        _moveCircle.center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
        _endCircle.radius = 10;
    }
    return _endCircle;
}


+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    [self.path removeAllPoints];
    CGFloat halfWidth;
    
    //绘制跑道形->圆形->跑道形
    if (self.progress < 30) {
        halfWidth = self.width / 2.0;
        self.fillColor = [UIColor colorWithRed:24/255.0 green:197/255.0 blue:138/255.0 alpha:1];
        self.circleBorderColor = mainColor;
    }else if (self.progress <= 40){
        CGFloat changeRate = (self.progress - 30) / 10.0;
        halfWidth = self.width * (1 - changeRate) / 2.0;
        self.fillColor = [UIColor colorWithRed:(24 + (255 - 24) * changeRate) / 255.0
                                         green:(197 + (255 - 197) * changeRate) / 255.0
                                          blue:(138 + (255 - 138) * changeRate) / 255.0
                                         alpha:1];
        self.circleBorderColor = [UIColor colorWithRed:(24 + (180 - 24) * changeRate) / 255.0
                                                 green:(197 + (180 - 197) * changeRate) / 255.0
                                                  blue:(138 + (180 - 138) * changeRate) / 255.0
                                                 alpha:1];
    }else if (self.progress <= 115){
        halfWidth = 0;
        self.fillColor = [UIColor whiteColor];
        self.circleBorderColor = grayBorderColor;
    }else {
        CGFloat changeRate = (self.progress - 115) / 59;
        halfWidth = self.width * (1 - (174 - self.progress) / 59) / 2.0;
        self.fillColor = [UIColor colorWithRed:(255 - (255 - 24) * changeRate) / 255.0
                                         green:(255 - (255 - 197) * changeRate) / 255.0
                                          blue:(255 - (255 - 138) * changeRate) / 255.0
                                         alpha:1];
        self.circleBorderColor = [UIColor colorWithRed:(180 - (180 - 24) * changeRate) / 255.0
                                                 green:(180 - (180 - 197) * changeRate) / 255.0
                                                  blue:(180 - (180 - 138) * changeRate) / 255.0
                                                 alpha:1];
    }
    
    [self.path moveToPoint:CGPointMake(self.center.x, self.center.y - self.height / 2.0)];
    [self.path addLineToPoint:CGPointMake(self.center.x + halfWidth, self.center.y - self.height / 2.0)];

    [self.path addArcWithCenter:CGPointMake(self.center.x + halfWidth, self.center.y) radius:self.height / 2.0 startAngle:-M_PI_2 endAngle:M_PI_2 clockwise:YES];

    [self.path addLineToPoint:CGPointMake(self.center.x - halfWidth, self.center.y + self.height / 2.0)];

    [self.path addArcWithCenter:CGPointMake(self.center.x - halfWidth, self.center.y) radius:self.height / 2.0 startAngle:M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];

    [self.path addLineToPoint:CGPointMake(self.center.x, self.center.y - self.height / 2.0)];
    [self.path moveToPoint:CGPointMake(self.center.x, self.center.y - self.height / 2.0)];
    [self.path closePath];
    
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextSetLineWidth(ctx, 3.0f);
    CGContextSetStrokeColorWithColor(ctx, self.circleBorderColor.CGColor);
    CGContextAddPath(ctx, self.path.CGPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGContextRestoreGState(ctx);
    
    
    //绘制文字
    NSString *text = @"Submit";
    if (self.progress <= 2) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14 - self.progress],NSForegroundColorAttributeName:[UIColor whiteColor]};
        CGPoint textCenter = CGPointMake(self.center.x - [text sizeWithAttributes:attributes].width / 2.0, self.center.y - [text sizeWithAttributes:attributes].height / 2.0);
        UIGraphicsPushContext(ctx);
        [text drawAtPoint:textCenter withAttributes:attributes];
        UIGraphicsPopContext();
    }else if (self.progress <=4) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:10 + self.progress],NSForegroundColorAttributeName:[UIColor whiteColor]};
        CGPoint textCenter = CGPointMake(self.center.x - [text sizeWithAttributes:attributes].width / 2.0, self.center.y - [text sizeWithAttributes:attributes].height / 2.0);
        UIGraphicsPushContext(ctx);
        [text drawAtPoint:textCenter withAttributes:attributes];
        UIGraphicsPopContext();
    }else if (self.progress < 39) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0f],NSForegroundColorAttributeName:[UIColor whiteColor]};
        CGPoint textCenter = CGPointMake(self.center.x - [text sizeWithAttributes:attributes].width / 2.0, self.center.y - [text sizeWithAttributes:attributes].height / 2.0);
        UIGraphicsPushContext(ctx);
        [text drawAtPoint:textCenter withAttributes:attributes];
        UIGraphicsPopContext();
    }
    
    //绘制loading过程
    if (self.progress > 40 &&
        self.progress <= 115) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SubmitButtonAnimationStop" object:nil];
        UIBezierPath *circlePath = [UIBezierPath bezierPath];
        CGFloat originstart = -M_PI_2;
        CGFloat currentOrigin = originstart + 2 * M_PI *((self.progress - 40) / (115.0 - 40.0));
        
        [circlePath addArcWithCenter:self.center radius:self.height / 2.0 startAngle:originstart endAngle:currentOrigin clockwise:YES];
        CGContextSaveGState(ctx);
        CGContextSetLineWidth(ctx, 3.0f);
        CGContextSetStrokeColorWithColor(ctx, mainColor.CGColor);
        CGContextAddPath(ctx, circlePath.CGPath);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);
    }else if (self.progress > 119) {
        //绘制对号√
        CGPoint checkMarkCenter = CGPointMake(self.center.x, self.center.y + 16);
        
        CGFloat baseLength = ((self.progress - 119) >= 40 ? 40: (self.progress - 119));
        CGPoint leftPoint = CGPointMake(checkMarkCenter.x - baseLength / 3.0 * cosf(M_PI_4), checkMarkCenter.y - baseLength / 3.0 * sinf(M_PI_4));
        CGPoint rightPoint = CGPointMake(checkMarkCenter.x + baseLength * cosf(M_PI_4), checkMarkCenter.y - baseLength * sinf(M_PI_4));
        
        CGContextSaveGState(ctx);
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextAddArc(ctx, leftPoint.x, leftPoint.y, 2.0, 0, 2 * M_PI, 1);
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextAddArc(ctx, checkMarkCenter.x, checkMarkCenter.y, 2.0, 0, 2 * M_PI, 1);
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextAddArc(ctx, rightPoint.x, rightPoint.y, 2.0, 0, 2 * M_PI, 1);
        CGContextDrawPath(ctx, kCGPathFill);
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        CGContextSetLineWidth(ctx, 4.0f);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextMoveToPoint(ctx, leftPoint.x, leftPoint.y);
        CGContextAddLineToPoint(ctx, checkMarkCenter.x, checkMarkCenter.y);
        CGContextMoveToPoint(ctx, checkMarkCenter.x, checkMarkCenter.y);
        CGContextAddLineToPoint(ctx, rightPoint.x, rightPoint.y);
        CGContextMoveToPoint(ctx, rightPoint.x, rightPoint.y);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);
    }

    
    
//    CGPoint center = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
//    CGFloat radius = 120;
//    NSArray *centers = @[[NSValue valueWithCGPoint:CGPointMake(center.x, center.y - radius)],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x + radius / sqrtf(2), center.y - radius / sqrtf(2))],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x + radius, center.y)],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x + radius / sqrtf(2), center.y + radius / sqrtf(2))],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x, center.y + radius)],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x - radius / sqrtf(2), center.y + radius / sqrtf(2))],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x - radius, center.y)],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x - radius / sqrtf(2), center.y - radius / sqrtf(2))],
//                         [NSValue valueWithCGPoint:CGPointMake(center.x, center.y - radius)]
//                         ];
//    [ADGUtils drawCircles:ctx fillColor:[UIColor redColor] points:centers radius:10.0f];
//    
//    self.distance = [ADGUtils distanceBetweenPointA:[centers[0] CGPointValue] pointB:[centers[1] CGPointValue]];
//    
//    UIBezierPath *circlePath = [UIBezierPath bezierPath];
//    CGFloat originstart = -M_PI_2;
//    CGFloat currentOrigin = originstart + (M_PI_4 * self.progress);
//    CGFloat currentDest = 2 * M_PI - M_PI_2;
//    
//    CGFloat x = center.x + radius * cosf(currentOrigin);
//    CGFloat y = center.y + radius * sinf(currentOrigin);
//    CGPoint point = CGPointMake(x, y);
//    
//    [circlePath addArcWithCenter:center radius:radius startAngle:currentOrigin endAngle:currentDest clockwise:0];
////    CGContextAddPath(ctx, circlePath.CGPath);
//    
////    [ADGUtils drawCircle:ctx fillcolor:[UIColor brownColor] radius:15.0f point:point];
//    
//    NSString *index = [NSString stringWithFormat:@"%.0f",floorf(self.progress)];
//    NSInteger endCircleIndex = ((index.integerValue + 1) == 9 ? 0 : (index.integerValue + 1));
//    self.startCircle.center = [centers[index.intValue] CGPointValue];
//    self.endCircle.center = [centers[endCircleIndex] CGPointValue];
//    self.moveCircle.center = point;
////    [self drawstartCircle:self.startCircle moveCircle:self.moveCircle context:ctx];
//    [self drawStartCircle:self.startCircle
//               moveCircle:self.moveCircle
//                endCircle:self.endCircle
//                  context:ctx];
}

- (void)drawstartCircle:(ADGCircle *)startCircle moveCircle:(ADGCircle *)moveCircle context:(CGContextRef)context {
//    CGContextRef context = UIGraphicsGetCurrentContext();
    //静止的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor clearColor] radius:startCircle.radius point:startCircle.center];
    
    //移动的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor redColor] radius:moveCircle.radius point:moveCircle.center];
    
    NSArray *points = [self commonTangentPointsOfCircleA:startCircle cricleB:moveCircle];
    CGPoint point1 = [points[0] CGPointValue];
    CGPoint point2 = [points[1] CGPointValue];
    CGPoint point3 = [points[2] CGPointValue];
    CGPoint point4 = [points[3] CGPointValue];
    
    
    //两个圆外公切线
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:[points[0] CGPointValue] endPoint:[points[1] CGPointValue]];
//    [ADGUtils drawLine:context color:[UIColor blackColor] width:1.0 startPoint:[points[2] CGPointValue] endPoint:[points[3] CGPointValue]];
    CGFloat currDistance = [ADGUtils distanceBetweenPointA:startCircle.center pointB:moveCircle.center];
    if (currDistance < self.distance / 2.0) {
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
    }else {
        CGFloat controlPointDistance = self.distance - currDistance + 20;
        CGFloat ß = controlPointDistance / self.distance;
        CGFloat y = (moveCircle.center.y - startCircle.center.y) * ß + startCircle.center.y;
        CGFloat x = (moveCircle.center.x - startCircle.center.x) * ß + startCircle.center.x;
        
        CGPoint controlPoint = CGPointMake(x, y);
        
        NSLog(@"dis = %.f, x = %.f, y = %.f",controlPointDistance,x,y);
        [self.path removeAllPoints];
        [self drawCurveWithPointA:point1 pointB:point3 controlPoint:controlPoint];
        [self.path moveToPoint:point1];
        [self.path closePath];
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextAddPath(context, self.path.CGPath);
        CGContextDrawPath(context, kCGPathFill);
    }
}

/**
 *  绘制三个圆，startCircle和endCircle连成一条弧线，moveCircle在弧线上运动
 *
 *  @param startCircle 开始的圆
 *  @param moveCircle  运动的圆
 *  @param endCircle   结束的圆
 *  @param context     上下文
 */

- (void)drawStartCircle:(ADGCircle *)startCircle
             moveCircle:(ADGCircle *)moveCircle
              endCircle:(ADGCircle *)endCircle
                context:(CGContextRef)context {
    [self.path removeAllPoints];
    //绘制开始的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor redColor] radius:startCircle.radius point:startCircle.center];
    
    //绘制结束的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor redColor] radius:endCircle.radius point:endCircle.center];
    
    //绘制运动的圆
    [ADGUtils drawCircle:context fillcolor:[UIColor redColor] radius:moveCircle.radius point:moveCircle.center];
    
    //startCirlce和endCircle之间的弧长，半径为8个圆的所在圆的半径
    CGFloat distanceSE = [ADGUtils calculateArcLengthRadius:120 angle:45.0f];
    
    //先处理startCircle和moveCircle-SM
    NSArray *pointsSM = [self commonTangentPointsOfCircleA:startCircle cricleB:moveCircle];
    CGPoint pointSM1 = [pointsSM[0] CGPointValue];
    CGPoint pointSM2 = [pointsSM[1] CGPointValue];
    CGPoint pointSM3 = [pointsSM[2] CGPointValue];
    CGPoint pointSM4 = [pointsSM[3] CGPointValue];
    
    CGFloat currDisSM = [ADGUtils distanceBetweenPointA:startCircle.center pointB:moveCircle.center];
    if (currDisSM < distanceSE / 2.0) {
//        [self.path removeAllPoints];
        [self drawCurveWithPointA:pointSM1 pointB:pointSM2 controlPoint:[ADGUtils midpointBetweenPointA:pointSM1 pointB:pointSM4]];
        [self.path addLineToPoint:pointSM4];
        
        [self drawCurveWithPointA:pointSM4 pointB:pointSM3 controlPoint:[ADGUtils midpointBetweenPointA:pointSM3 pointB:pointSM2]];
        [self.path addLineToPoint:pointSM1];
        
        [self.path moveToPoint:pointSM1];
        [self.path closePath];
        [self.path fill];
//        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
//        CGContextAddPath(context, self.path.CGPath);
//        CGContextDrawPath(context, kCGPathFill);
    }else {
        CGFloat controlPointDistance = distanceSE - currDisSM + 30;
        CGFloat ß = controlPointDistance / self.distance;
        CGFloat ySM = (moveCircle.center.y - startCircle.center.y) * ß + startCircle.center.y;
        CGFloat xSM = (moveCircle.center.x - startCircle.center.x) * ß + startCircle.center.x;
        
        CGPoint controlPoint = CGPointMake(xSM, ySM);
//        [self.path removeAllPoints];
        [self drawCurveWithPointA:pointSM1 pointB:pointSM3 controlPoint:controlPoint];
        [self.path moveToPoint:pointSM1];
        [self.path closePath];
        
        CGFloat yMS = (startCircle.center.y - moveCircle.center.y) * ß + moveCircle.center.y;
        CGFloat xMS = (startCircle.center.x - moveCircle.center.x) * ß + moveCircle.center.x;
        
        CGPoint controlPointMS = CGPointMake(xMS, yMS);
        [self drawCurveWithPointA:pointSM2 pointB:pointSM4 controlPoint:controlPointMS];
        [self.path moveToPoint:pointSM2];
        [self.path closePath];
        
//        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
//        CGContextAddPath(context, self.path.CGPath);
//        CGContextDrawPath(context, kCGPathFill);
    }
    
    
    //endCircle和moveCircle-EM
    
    NSArray *pointsEM = [self commonTangentPointsOfCircleA:endCircle cricleB:moveCircle];
    CGPoint pointEM1 = [pointsEM[0] CGPointValue];
    CGPoint pointEM2 = [pointsEM[1] CGPointValue];
    CGPoint pointEM3 = [pointsEM[2] CGPointValue];
    CGPoint pointEM4 = [pointsEM[3] CGPointValue];
    CGFloat currDisEM = [ADGUtils distanceBetweenPointA:endCircle.center pointB:moveCircle.center];
    if (currDisEM >= distanceSE / 2.0 &&
        currDisEM < distanceSE ) {
        CGFloat controlPointDistance = currDisSM - distanceSE / 2.0;
        CGFloat ß = controlPointDistance / distanceSE / 2.0;
        CGFloat yEM = (moveCircle.center.y - endCircle.center.y) * ß + endCircle.center.y;
        CGFloat xEM = (moveCircle.center.x - endCircle.center.x) * ß + endCircle.center.x;
        
        CGPoint controlPoint = CGPointMake(xEM, yEM);
//        [self.path removeAllPoints];
        [self drawCurveWithPointA:pointEM2 pointB:pointEM4 controlPoint:controlPoint];
        [self.path moveToPoint:pointSM2];
        [self.path closePath];
        
        CGFloat yME = (endCircle.center.y - moveCircle.center.y) * ß + moveCircle.center.y;
        CGFloat xME = (endCircle.center.x - moveCircle.center.x) * ß + moveCircle.center.x;
        
        CGPoint controlPointMS = CGPointMake(xME, yME);
        [self drawCurveWithPointA:pointEM1 pointB:pointEM3 controlPoint:controlPointMS];
        [self.path moveToPoint:pointEM1];
        [self.path closePath];
        
    }else if (currDisEM <= distanceSE / 2.0) {
        [self drawCurveWithPointA:pointEM1 pointB:pointEM2 controlPoint:[ADGUtils midpointBetweenPointA:pointEM1 pointB:pointEM4]];
        [self.path addLineToPoint:pointEM4];
        
        [self drawCurveWithPointA:pointEM4 pointB:pointEM3 controlPoint:[ADGUtils midpointBetweenPointA:pointEM3 pointB:pointEM2]];
        [self.path addLineToPoint:pointEM1];
        [self.path moveToPoint:pointEM1];
        
        [self.path closePath];
    }
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddPath(context, self.path.CGPath);
    CGContextDrawPath(context, kCGPathFill);
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

- (void)drawDropletForCircleA:(ADGCircle *)circleA circleB:(ADGCircle *)circleB {
    
}
@end
