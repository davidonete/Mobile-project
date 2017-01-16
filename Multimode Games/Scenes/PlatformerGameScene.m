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
    
    //Initialize Background
    self.background1 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Background"]
                                                       color:[SKColor grayColor]
                                                        size:self.frame.size];
    
    self.background1.anchorPoint = CGPointZero;
    self.background1.position = CGPointMake(0, 0);
    
    [self addChild:self.background1];
    
    self.background2 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Background"]
                                                       color:[SKColor grayColor]
                                                        size:self.frame.size];
    
    self.background2.anchorPoint = CGPointZero;
    self.background2.position = CGPointMake(self.background1.size.width - 1, 0);
    
    [self addChild:self.background2];
    
    //CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
    
    self.ground1 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Ground"]
                                                       color:[SKColor grayColor]
                                                       size:CGSizeMake(self.frame.size.width, 80.0)];
    
    self.ground1.anchorPoint = CGPointZero;
    self.ground1.position = CGPointMake(0, 0);
    
    [self addChild:self.ground1];
    
    self.ground2 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Ground"]
                                                       color:[SKColor grayColor]
                                                        size:CGSizeMake(self.frame.size.width, 80.0)];
    
    self.ground2.anchorPoint = CGPointZero;
    self.ground2.position = CGPointMake(self.ground2.size.width - 1, 0);
    
    [self addChild:self.ground2];
    
    self.score = [SKLabelNode labelNodeWithFontNamed:@"Papyrus-Condensed"];
    
    self.score.position = CGPointMake(self.frame.size.width * 0.9, self.frame.size.height * 0.90);
    self.score.zPosition = 999;
    [self addChild:self.score];
    
    //Initialize Player
    //self.player = [self newPlayer];
    //[self addChild:self.player];
    
    //Initialize gravity
    //self.physicsWorld.gravity = CGVectorMake(0.0, -1.0);
    //self.physicsWorld.contactDelegate = self;
    
    //Start obstacle spawn timer
    //[self StartSpawn:5.0 :5.0];
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

//Update before physics
-(void)update:(NSTimeInterval)currentTime
{
    if(self.sceneInitialized && !self.gameOver)
    {
        //Background movement
        SKSpriteNode* bg1 = self.background1;
        SKSpriteNode* bg2 = self.background2;
        
        bg1.position = CGPointMake(bg1.position.x - 0.5, bg1.position.y);
        bg2.position = CGPointMake(bg2.position.x - 0.5, bg2.position.y);
        
        if(bg1.position.x < -bg1.size.width)
            bg1.position = CGPointMake(bg2.position.x + bg2.size.width, bg1.position.y);
        
        if(bg2.position.x < -bg2.size.width)
            bg2.position = CGPointMake(bg1.position.x + bg1.size.width, bg2.position.y);
        
        //Ground movement
        SKSpriteNode* g1 = self.ground1;
        SKSpriteNode* g2 = self.ground2;
        
        g1.position = CGPointMake(g1.position.x - 0.5, g1.position.y);
        g2.position = CGPointMake(g2.position.x - 0.5, g2.position.y);
        
        if(g1.position.x < -g1.size.width)
            g1.position = CGPointMake(g2.position.x + g2.size.width, g1.position.y);
        
        if(g2.position.x < -g2.size.width)
            g2.position = CGPointMake(g1.position.x + g1.size.width, g2.position.y);
        
        //distanceTraveled += 0.01;
        //self.score.text = [NSString stringWithFormat:@"Distance: %.0f", distanceTraveled];
    }
}

//Update after physics simulated
-(void) didSimulatePhysics
{
    
}

-(void)OnShakeDetected:(NSNotification *) notification
{
    NSLog(@"Shake detected");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self ChangeScene:1];
}

@end
