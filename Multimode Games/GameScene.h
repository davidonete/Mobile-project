//
//  GameScene.h
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"

@interface GameScene : SKScene

@property (nonatomic) SKSpriteNode* player;
@property (nonatomic) BOOL sceneInitialized;
@property GameViewController* viewController;

-(void)ChangeScene:(int)sceneID;

@end
