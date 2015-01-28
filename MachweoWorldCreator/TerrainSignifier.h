//
//  TerrainSignifier.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TerrainSignifier : NSObject
@property(nonatomic, strong) NSMutableArray* vertices;
@property(nonatomic, strong) SKNode* lineNode;
@property(nonatomic, strong) SKTexture* terrainTexture;
@property(nonatomic, strong) SKCropNode* cropNode;


@property(nonatomic) float zPosition;

@property(nonatomic) BOOL isClosed;


-(void)addVertex:(NSPoint)vertex inNode:(SKNode*)node;
-(instancetype)initWithTexture:(SKTexture*)terrainTexture inNode:(SKNode*)node;
-(void)closeLoopAndFillTerrainInNode:(SKNode*)node;
-(void)cleanUpAndRemoveLines;
@end
