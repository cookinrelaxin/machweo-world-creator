//
//  MyWindowController.h
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/8/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>
#import "DragView.h"

@interface MyWindowController : NSWindowController
@property (nonatomic, strong) IBOutlet NSView *windowView;
@property (nonatomic) NSMutableArray *obstacleImages;
@property (nonatomic) NSMutableArray *decorationImages;
@property (weak) IBOutlet NSTextField *imageName;
@property (weak) IBOutlet NSImageView *currentlySelectedImage;
@property (weak) IBOutlet NSComboBox *zPositionComboBox;
@property (weak) IBOutlet NSTextField *zPositionInfoLabel;
@property (weak) IBOutlet NSComboBox *obstacleMotionSelectionComboBox;
@property (weak) IBOutlet NSComboBox *motionSpeedComboBox;
@property (weak) IBOutlet NSTextField *obstacleMotionSelectionLabel;
@property (weak) IBOutlet NSTextField *motionSpeedLabel;

@end
