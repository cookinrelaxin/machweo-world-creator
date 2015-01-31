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
@property(nonatomic, strong) NSMutableArray* shapeVertices;
@property(nonatomic, strong) NSMutableArray* lineVertices;
@property(nonatomic) BOOL firstLineDrawn;

@property(nonatomic, strong) SKNode* lineNode;
@property(nonatomic, strong) SKTexture* terrainTexture;
@property(nonatomic, strong) SKCropNode* cropNode;
@property(nonatomic) BOOL isClosed;
@property(nonatomic) BOOL permitVertices;
@property(nonatomic) CGPoint anchorPointForStraightLines;
@property(nonatomic) SKShapeNode* lastLineNode;



//@property(nonatomic) CGVector differenceFromCurrentPointToFirstVertex;



-(void)addVertex:(NSPoint)vertex :(BOOL)straightLine;
-(instancetype)initWithTexture:(SKTexture*)terrainTexture;
-(void)closeLoopAndFillTerrainInView:(SKView*)view;
-(void)cleanUpAndRemoveLines;
-(void)completeLine;
-(void)checkForClosedShape;
-(void)moveTo:(CGPoint)point :(SKShapeNode*)outlineNode :(CGVector)offset;
@end
