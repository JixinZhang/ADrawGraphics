//
//  ADGLoadLayer.h
//  ADrawGraphics
//
//  Created by WSCN on 7/25/16.
//  Copyright © 2016 JixinZhang. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ADGLoadLayer : CALayer

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end
