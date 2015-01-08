//
//  GameScene.h
//  MachweoWorldCreator
//

//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

-(void)addObstacleSignifierForImage:(NSImage*)image fromPointInView:(CGPoint)point withName: (NSString*)name;
-(void)addDecorationSignifierForImage:(NSImage*)image fromPointInView:(CGPoint)point withName: (NSString*)name;

@end
