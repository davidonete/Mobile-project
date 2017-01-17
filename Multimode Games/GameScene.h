//
//  GameScene.h
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode* player;
@property (nonatomic) SKSpriteNode* ground1;
@property (nonatomic) SKSpriteNode* ground2;
@property (nonatomic) SKSpriteNode* background1;
@property (nonatomic) SKSpriteNode* background2;
@property (nonatomic) SKSpriteNode* lifeIcon1;
@property (nonatomic) SKSpriteNode* lifeIcon2;
@property (nonatomic) SKSpriteNode* lifeIcon3;
@property (nonatomic) SKLabelNode* menu1;
@property (nonatomic) SKLabelNode* menu2;
@property (nonatomic) SKLabelNode* score;

@property (nonatomic) BOOL gameOver;
@property (nonatomic) BOOL invincible;
@property (nonatomic) BOOL sceneInitialized;
@property (nonatomic) GLint life;
@property GameViewController* viewController;

-(void)ChangeScene:(int)sceneID;
-(CGFloat) Random:(CGFloat)min :(CGFloat)max;

@end
