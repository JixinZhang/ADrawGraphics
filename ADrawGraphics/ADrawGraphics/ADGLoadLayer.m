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

@implementation ADGLoadLayer

@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"progress"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGPoint center = CGPointMake(180, 500);
    CGFloat radius = 50;
    NSArray *centers = @[[NSValue valueWithCGPoint:CGPointMake(180, 450)],
                         [NSValue valueWithCGPoint:CGPointMake(180 + 50 / sqrtf(2), 500 - 50 / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(180 + 50, 500)],
                         [NSValue valueWithCGPoint:CGPointMake(180 + 50 / sqrtf(2), 500 + 50 / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(180, 500 + 50)],
                         [NSValue valueWithCGPoint:CGPointMake(180 - 50 / sqrtf(2), 500 + 50 / sqrtf(2))],
                         [NSValue valueWithCGPoint:CGPointMake(180 - 50, 500)],
                         [NSValue valueWithCGPoint:CGPointMake(180 - 50 / sqrtf(2), 500 - 50 / sqrtf(2))]
                         ];
    [ADGUtils drawCircles:ctx fillColor:[UIColor orangeColor] points:centers radius:10.0f];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat originstart = -M_PI_2;
    CGFloat currentOrigin = originstart + (M_PI_4 * self.progress);
    CGFloat currentDest = 10 * M_PI - M_PI_2;
    
    [path addArcWithCenter:center radius:radius startAngle:currentOrigin endAngle:currentDest clockwise:0];
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}
@end
