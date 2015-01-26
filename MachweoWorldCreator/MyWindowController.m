//
//  MyWindowController.m
//  MachweoWorldCreator
//
//  Created by Feldcamp, Zachary Satoshi on 12/8/14.
//  Copyright (c) 2014 Feldcamp, Zachary Satoshi. All rights reserved.
//

#import "MyWindowController.h"
#import "DragView.h"
#import "GameScene.h"
#import "ObstacleSignifier.h"

@interface MotionTypeHandler : NSObject <NSComboBoxDelegate>
@property (nonatomic, strong) MyWindowController* controller;
@end

@implementation MotionTypeHandler
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
 //   NSLog(@"motion handler called");
    [_controller reappearMotionComboBoxes];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"motionTypeChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_controller.imageName.stringValue, @"imageName", [_controller.obstacleMotionSelectionComboBox objectValueOfSelectedItem], @"obstacleMotion", nil]];
    //NSLog(@"[_controller.obstacleMotionSelectionComboBox objectValueOfSelectedItem]: %@", [_controller.obstacleMotionSelectionComboBox objectValueOfSelectedItem]);
}
@end

@interface MotionSpeedHandler : NSObject <NSComboBoxDelegate>
@property (nonatomic, strong) MyWindowController* controller;
@end

@implementation MotionSpeedHandler
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
 //   NSLog(@"speed handler called");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"motionSpeedChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_controller.imageName.stringValue, @"imageName", [_controller.motionSpeedComboBox objectValueOfSelectedItem], @"motionSpeed", nil]];
   // NSLog(@"[_controller.obstacleMotionSelectionComboBox objectValueOfSelectedItem]: %@", [_controller.motionSpeedComboBox objectValueOfSelectedItem]);
    
}
@end

@interface ZPositionHandler : NSObject <NSComboBoxDelegate>
@property (nonatomic, strong) MyWindowController* controller;
@end

@implementation ZPositionHandler
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    NSLog(@"zPosition handler called");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"zPositionChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_controller.imageName.stringValue, @"imageName", [_controller.zPositionComboBox objectValueOfSelectedItem], @"zPosition", nil]];

}
@end

@interface MyWindowController (){
    DragView* dragView;
    GameScene *scene;
}
@end

@implementation MyWindowController{
    ZPositionHandler * zHandler;
    MotionTypeHandler * motionHandler;
    MotionSpeedHandler * speedHandler;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self loadComboBoxes];
    [self loadEditorViewController];
    [self loadSpriteScroller];
    [self registerForNotifications];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)loadEditorViewController{
   // NSLog(@"_windowView.bounds:%f %f %f %f", _windowView.bounds.origin.x, _windowView.bounds.origin.y, _windowView.bounds.size.width, _windowView.bounds.size.height);
    scene = [GameScene sceneWithSize:CGSizeMake(1366, 768)];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    dragView = [[DragView alloc] initWithFrame:_windowView.bounds forScene:scene];
    dragView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    dragView.autoresizesSubviews = true;
    [_windowView addSubview:dragView];
    [dragView presentScene:scene];
    
}


-(void)loadSpriteScroller{
    NSMutableArray * obstacleArray = [NSMutableArray array];
    NSMutableArray * decorationArray = [NSMutableArray array];
    NSArray *gameObjectPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];
    
    for (NSString* path in gameObjectPaths) {
        NSString* fileName = [[path lastPathComponent] stringByDeletingPathExtension];
        //NSLog(@"fileName: %@", fileName);

        if ([fileName rangeOfString:@"obstacle"].location != NSNotFound) {
            NSImage* obstacleImage = [NSImage imageNamed:fileName];
            obstacleImage.name = fileName;
            [obstacleArray addObject:obstacleImage];
        }
        if ([fileName rangeOfString:@"decoration"].location != NSNotFound) {
            NSImage* decorationImage = [NSImage imageNamed:fileName];
            decorationImage.name = fileName;
            [decorationArray addObject:decorationImage];
        }

    }
    
    [self setObstacleImages:obstacleArray];
    [self setDecorationImages:decorationArray];

}

-(void)registerForNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(changeCurrentlySelectedSprite:) name:@"currentlySelectedSpriteMayHaveChanged" object:nil];
}

-(void)changeCurrentlySelectedSprite:(NSNotification*)notification{
    //NSLog(@"%@", notification.name);
    SKSpriteNode* sprite = [notification.userInfo objectForKey:@"sprite"];
    NSString* imageName = sprite.name;
    //NSLog(@"imageName: %@", imageName);
    _currentlySelectedImage.image = [NSImage imageNamed:imageName];
    [_imageName setStringValue:imageName];
    for (NSImage* image in _obstacleImages) {
        if ([image.name isEqualToString:imageName]) {
            //[_zPositionComboBox setEnabled:false];
            //[_zPositionComboBox selectItemWithObjectValue:[NSString stringWithFormat:@"%d", 10]];
            [_zPositionComboBox setHidden:true];
            [_zPositionInfoLabel setStringValue:@"the zPosition of all obstacles is always 16"];
            
            ObstacleSignifier* obs = (ObstacleSignifier*)sprite;
            NSString* motionString = [obs stringValueOfCurrentMotionType];
            NSString* speedString = [obs stringValueOfCurrentSpeedType];
            
            [_obstacleMotionSelectionComboBox selectItemWithObjectValue:motionString];
            [_motionSpeedComboBox selectItemWithObjectValue:speedString];
            [self reappearMotionComboBoxes];
            return;
        }
    }
    [self hideMotionComboBoxes];
    [_zPositionComboBox setHidden:false];
    //[_zPositionComboBox selectItemWithObjectValue:[NSString stringWithFormat:@"%d", [(NSNumber*)[notification.userInfo objectForKey:@"zPosition"] intValue]]];
    [_zPositionComboBox selectItemWithObjectValue:[NSString stringWithFormat:@"%d", (int)sprite.zPosition]];
    [_zPositionInfoLabel setStringValue:[NSString stringWithFormat:@"z-position of all %@ instances (lower values are farther away)", imageName]];
    
}

-(void)loadComboBoxes{
    motionHandler = [[MotionTypeHandler alloc] init];
    motionHandler.controller = self;
    speedHandler = [[MotionSpeedHandler alloc] init];
    speedHandler.controller = self;
    zHandler = [[ZPositionHandler alloc] init];
    zHandler.controller = self;
    
    NSMutableArray* temp = [NSMutableArray array];
    for(int i = 1; i < 101; i ++){
        [temp addObject:[NSString stringWithFormat:@"%d", i]];
    }
   // [_zPositionComboBox addItemsWithObjectValues:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"19"]];
    [_zPositionComboBox addItemsWithObjectValues:temp];
    [_zPositionComboBox selectItemAtIndex:0];
    _zPositionComboBox.delegate = zHandler;
    
    [_obstacleMotionSelectionComboBox addItemsWithObjectValues:@[@"doesn't move", @"moves up and down", @"moves left and right", @"rotates clockwise", @"rotates counterclockwise"]];
    [_obstacleMotionSelectionComboBox selectItemAtIndex:0];
    _obstacleMotionSelectionComboBox.delegate = motionHandler;
    
    [_motionSpeedComboBox addItemsWithObjectValues:@[@"slowest", @"slower", @"slow", @"fast", @"faster", @"fastest"]];
    [_motionSpeedComboBox selectItemAtIndex:0];
    _motionSpeedComboBox.delegate = speedHandler;
}

-(void)hideMotionComboBoxes{
    _obstacleMotionSelectionComboBox.hidden = true;
    _obstacleMotionSelectionLabel.hidden = true;
    
    _motionSpeedComboBox.hidden = true;
    _motionSpeedLabel.hidden = true;
}

-(void)reappearMotionComboBoxes{
    _obstacleMotionSelectionComboBox.hidden = false;
    _obstacleMotionSelectionLabel.hidden = false;
    NSString* currentMotionType = [_obstacleMotionSelectionComboBox objectValueOfSelectedItem];
    if (![currentMotionType isEqualToString:@"doesn't move"]) {
        _motionSpeedComboBox.hidden = false;
        _motionSpeedLabel.hidden = false;
    }
    else{
        
        _motionSpeedComboBox.hidden = true;
        _motionSpeedLabel.hidden = true;
    }
}

- (IBAction)changeSnapPermission:(id)sender {
    NSButton* buttonSender = (NSButton*)sender;
    BOOL allowSnapping = (buttonSender.state == 1) ? true :false;
    NSNumber *allowSnappingObject = [NSNumber numberWithBool:allowSnapping];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSnapPermission" object:nil userInfo:[NSDictionary dictionaryWithObject:allowSnappingObject forKey:@"allow snapping"]];
}


@end
