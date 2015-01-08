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

@interface MyWindowController (){
    DragView* dragView;
    GameScene *scene;
}
@end

@implementation MyWindowController
//-(void)awakeFromNib{
//}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self loadComboBox];
    [self loadEditorViewController];
    [self loadSpriteScroller];
    [self registerForNotifications];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)loadEditorViewController{
   // NSLog(@"_windowView.bounds:%f %f %f %f", _windowView.bounds.origin.x, _windowView.bounds.origin.y, _windowView.bounds.size.width, _windowView.bounds.size.height);
    scene = [GameScene sceneWithSize:CGSizeMake(1136, 640)];
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
    [center addObserver:self selector:@selector(changeCurrentlySelectedImage:) name:@"currentlySelectedImageChanged" object:nil];
     
}

-(void)changeCurrentlySelectedImage:(NSNotification*)notification{
    //NSLog(@"%@", notification.name);
    NSString* imageName = [notification.userInfo objectForKey:@"imageName"];
    //NSLog(@"imageName: %@", imageName);
    _currentlySelectedImage.image = [NSImage imageNamed:imageName];
    [_imageName setStringValue:imageName];
    for (NSImage* image in _obstacleImages) {
        if ([image.name isEqualToString:imageName]) {
            //[_zPositionComboBox setEnabled:false];
            //[_zPositionComboBox selectItemWithObjectValue:[NSString stringWithFormat:@"%d", 10]];
            [_zPositionComboBox setHidden:true];
            [_zPositionInfoLabel setStringValue:@"the zPosition of all obstacles is always 10"];
            return;
        }
    }
    //[_zPositionComboBox setEnabled:true];
    [_zPositionComboBox setHidden:false];
    [_zPositionComboBox selectItemWithObjectValue:[NSString stringWithFormat:@"%d", [(NSNumber*)[notification.userInfo objectForKey:@"zPosition"] intValue]]];
    [_zPositionInfoLabel setStringValue:[NSString stringWithFormat:@"z-position of all %@ instances (lower values are farther away)", imageName]];
   // z-position of all sprites of this name (lower values are farther from the camera)
}

-(void)loadComboBox{
    [_zPositionComboBox addItemsWithObjectValues:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"12"]];
    [_zPositionComboBox selectItemAtIndex:0];
    _zPositionComboBox.delegate = self;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
   // NSLog(@"%@", notification.name);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"zPositionChanged" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_imageName.stringValue, @"imageName", [_zPositionComboBox objectValueOfSelectedItem], @"zPosition", nil]];
}

- (IBAction)changeSnapPermission:(id)sender {
    NSButton* buttonSender = (NSButton*)sender;
    BOOL allowSnapping = (buttonSender.state == 1) ? true :false;
    NSNumber *allowSnappingObject = [NSNumber numberWithBool:allowSnapping];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSnapPermission" object:nil userInfo:[NSDictionary dictionaryWithObject:allowSnappingObject forKey:@"allow snapping"]];
}


@end
