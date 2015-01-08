//
//  DragView.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/12/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface DragView : SKView <NSDraggingDestination>

-(instancetype)initWithFrame:(NSRect)frameRect forScene:(GameScene*)scene;
@end
