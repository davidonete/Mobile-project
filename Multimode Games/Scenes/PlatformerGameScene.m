//
//  PlatformerGameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "PlatformerGameScene.h"

//CGFloat obstacleXSpeed = 1.0;
//BOOL startAnimation = FALSE;

//static const uint32_t playerCategory =   0x1 << 0;
//static const uint32_t obstacleCategory = 0x1 << 1;

@implementation PlatformerGameScene

-(void)InitializeScene
{
    NSLog(@"Platformer Game Scene initialized: %@", NSStringFromCGSize(self.frame.size));
    
    //Delegate shake event notification to a function
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnShakeDetected:) name:@"shake" object:nil];
    
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
}

/*
-(SKSpriteNode *) newPlayer
{
    self.life = 3;
    self.lifeIcon1 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(32, 32)];
    
    self.lifeIcon1.position = CGPointMake(16, self.frame.size.height - 20);
    [self addChild:self.lifeIcon1];
    
    self.lifeIcon2 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(32, 32)];
    
    self.lifeIcon2.position = CGPointMake(40, self.frame.size.height - 20);
    [self addChild:self.lifeIcon2];
    
    self.lifeIcon3 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(32, 32)];
    
    self.lifeIcon3.position = CGPointMake(64, self.frame.size.height - 20);
    [self addChild:self.lifeIcon3];
    
    //Size, color and texture
    SKSpriteNode* hull = [[SKSpriteNode alloc]
                          initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
                          color:[SKColor grayColor]
                          size:CGSizeMake(64, 64)];
    
    //Initial Position
    hull.position = CGPointMake(0, self.frame.size.height + 50);
    
    //Initialize Physic body (collision and mass)
    hull.physicsBody = [SKPhysicsBody bodyWithTexture:hull.texture size:hull.size];
    hull.physicsBody.usesPreciseCollisionDetection = TRUE;
    hull.physicsBody.mass = 1.0;
    hull.physicsBody.allowsRotation = FALSE;
    hull.physicsBody.angularVelocity = 0.0;
    
    hull.physicsBody.categoryBitMask = playerCategory;
    hull.physicsBody.collisionBitMask = obstacleCategory;
    hull.physicsBody.contactTestBitMask = obstacleCategory;
    
    SKAction* hover = [SKAction moveByX:200 y:0 duration:5.0];
    
    [hull runAction:hover completion:^(void) { startAnimation = TRUE; }];
    return hull;
}
*/

-(void)OnShakeDetected:(NSNotification *) notification
{
    NSLog(@"Shake detected");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self ChangeScene:1];
}

@end
