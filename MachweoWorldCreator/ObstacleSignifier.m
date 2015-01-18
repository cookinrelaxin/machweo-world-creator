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
            [self resetZRotation];
            break;
        case motionTypeLeftAndRight:
            [self resetZRotation];
            [self moveLeftAndRightAtSpeed:speed];
            break;
        case motionTypeUpAndDown:
            [self resetZRotation];
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

-(void)resetZRotation{
    self.zRotation = 0;
}

-(void)moveLeftAndRightAtSpeed:(float)speed{

    for (ObstacleSignifier* node in self.parent.children) {
        if (node == self) {
            continue;
        }
        if ([node isKindOfClass:[ObstacleSignifier class]]) {
            if (CGRectIntersectsRect(self.frame, node.frame)) {
                isMovingLeft = !isMovingLeft;
                break;
            }
        }
    }

    if (isMovingLeft) {
        self.position = CGPointMake(self.position.x - speed, self.position.y);
    }
    else{
        self.position = CGPointMake(self.position.x + speed, self.position.y);
    }

}

-(void)moveUpAndDownAtSpeed:(float)speed{
    SKScene* scene = (SKScene*)self.parent.parent;
    for (SKSpriteNode* node in self.parent.children) {
        if (node == self) {
            continue;
        }
        if ([node isKindOfClass:[ObstacleSignifier class]]) {
            if (CGRectIntersectsRect(self.frame, node.frame)) {
                isMovingUp = !isMovingUp;
                break;
            }
        }
    }
    
    {
        CGPoint topSide = CGPointMake(self.position.x, self.position.y + (self.size.height / 2));
        CGPoint topSideInScene = [scene convertPoint:topSide fromNode:self.parent];
        if (topSideInScene.y >= scene.size.height) {
            isMovingUp = false;
        }
    }
    {
        CGPoint bottomSide = CGPointMake(self.position.x, self.position.y - (self.size.height / 2));
        CGPoint bottomSideInScene = [scene convertPoint:bottomSide fromNode:self.parent];
        if (bottomSideInScene.y <= 0) {
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
    self.zRotation = self.zRotation - .015 * speed;
}

-(void)rotateCounterclockwiseAtSpeed:(float)speed{
    self.zRotation = self.zRotation + .015 * speed;

}

-(NSString*)stringValueOfCurrentMotionType{
    NSString* motionString;
    switch (_currentMotionType) {
        case motionTypeNone:
            motionString = @"doesn't move";
            break;
        case motionTypeLeftAndRight:
            motionString = @"moves left and right";
            break;
        case motionTypeUpAndDown:
            motionString = @"moves up and down";
            break;
        case motionTypeRotatesClockwise:
            motionString = @"rotates clockwise";
            break;
        case motionTypeRotatesCounterclockwise:
            motionString = @"rotates counterclockwise";
            break;
        default:
            break;
    }
    return motionString;
}

-(NSString*)stringValueOfCurrentSpeedType{
    NSString* speedString;
    switch (_currentSpeedType) {
        case speedTypeSlowest:
            speedString = @"slowest";
            break;
        case speedTypeSlower:
            speedString = @"slower";
            break;
        case speedTypeSlow:
            speedString = @"slow";
            break;
        case speedTypeFast:
            speedString = @"fast";
            break;
        case speedTypeFaster:
            speedString = @"faster";
            break;
        case speedTypeFastest:
            speedString = @"fastest";
            break;
        default:
            break;
    }
    return speedString;
}



@end
