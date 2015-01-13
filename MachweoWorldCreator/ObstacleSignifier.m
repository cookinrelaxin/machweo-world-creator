//
//  ObstacleSignifier.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/19/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "ObstacleSignifier.h"

@implementation ObstacleSignifier{
    BOOL isMovingUp;
    BOOL isMovingLeft;

}

-(void)move{
    float speed;
    
    switch (_currentSpeedType) {
        case speedTypeSlowest:
            speed = 1;
            break;
        case speedTypeSlower:
            speed = 2;
            break;
        case speedTypeSlow:
            speed = 3;
            break;
        case speedTypeFast:
            speed = 4;
            break;
        case speedTypeFaster:
            speed = 5;
            break;
        case speedTypeFastest:
            speed = 6;
            break;
            
        default:
            break;
    }
    switch (_currentMotionType) {
        case motionTypeNone:
            break;
        case motionTypeLeftAndRight:
            [self moveLeftAndRightAtSpeed:speed];
            break;
        case motionTypeUpAndDown:
            [self moveUpAndDownAtSpeed:speed];
            break;
        case motionTypeRotatesClockwise:
            [self rotateClockwiseAtSpeed:speed];
            break;
        case motionTypeRotatesCounterclockwise:
            [self rotateCounterclockwiseAtSpeed:speed];
            break;
        default:
            break;
    }
}

-(void)moveLeftAndRightAtSpeed:(float)speed{
    
}

-(void)moveUpAndDownAtSpeed:(float)speed{
    SKScene* scene = (SKScene*)self.parent.parent;
    {
        CGPoint topSide = CGPointMake(self.position.x, self.position.y + (self.size.height / 2));
        CGPoint topSideInScene = [scene convertPoint:topSide fromNode:self.parent];
        if (topSideInScene.x >= scene.size.height) {
            isMovingUp = false;
        }
    }
    {
        CGPoint bottomSide = CGPointMake(self.position.x, self.position.y - (self.size.height / 2));
        CGPoint bottomSideInScene = [scene convertPoint:bottomSide fromNode:self.parent];
        if (bottomSideInScene.x <= 0) {
            isMovingUp = true;
        }
    }
    if (isMovingUp) {
        self.position = CGPointMake(self.position.x, self.position.y + speed);
    }
    else{
        self.position = CGPointMake(self.position.x, self.position.y - speed);

    }
    
}

-(void)rotateClockwiseAtSpeed:(float)speed{
    
}

-(void)rotateCounterclockwiseAtSpeed:(float)speed{
    
}


@end
