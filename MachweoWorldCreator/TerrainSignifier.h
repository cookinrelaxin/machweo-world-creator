//
//  TerrainSignifier.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 1/27/15.
//  Copyright (c) 2015 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface TerrainSignifier : SKNode
@property(nonatomic, strong) NSMutableArray* vertices;
@property(nonatomic, strong) SKNode* lineNode;
@property(nonatomic, strong) SKTexture* terrainTexture;
@property(nonatomic, strong) SKCropNode* cropNode;
//@property(nonatomic) float zPosition;
@property(nonatomic) BOOL isClosed;
@property(nonatomic) BOOL permitVertices;
@property(nonatomic) CGPoint anchorPointForStraightLines;
@property(nonatomic) SKShapeNode* lastLineNode;



//@property(nonatomic) CGVector differenceFromCurrentPointToFirstVertex;



-(void)addVertex:(NSPoint)vertex :(BOOL)straightLine;
-(instancetype)initWithTexture:(SKTexture*)terrainTexture inNode:(SKNode*)node;
-(void)closeLoopAndFillTerrain;
-(void)cleanUpAndRemoveLines;
-(void)completeLine;
-(void)checkForClosedShape;
@end
