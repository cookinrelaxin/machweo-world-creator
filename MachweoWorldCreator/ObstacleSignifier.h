//
//  ObstacleSignifier.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/19/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum MotionType
{
    motionTypeNone,
    motionTypeUpAndDown,
    motionTypeLeftAndRight,
    motionTypeRotatesClockwise,
    motionTypeRotatesCounterclockwise
} Motion;

typedef enum SpeedType
{
    speedTypeSlowest,
    speedTypeSlower,
    speedTypeSlow,
    speedTypeFast,
    speedTypeFaster,
    speedTypeFastest
} Speed;

@interface ObstacleSignifier : SKSpriteNode
@property (nonatomic) Motion currentMotionType;
@property (nonatomic) Speed currentSpeedType;

-(void)move;
@end
