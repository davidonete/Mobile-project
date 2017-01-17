//
//  PlatformerGameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "PlatformerGameScene.h"

CGFloat obstacleSpeed = 4.0;
double obstaclesAvoided = 0.0;

BOOL StartAnimation = FALSE;
BOOL canJump = TRUE;

static const uint32_t playerCategory =   0x1 << 0;
static const uint32_t obstacleCategory = 0x1 << 1;

@implementation PlatformerGameScene

-(void)InitializeScene
{
    obstacleSpeed = 4.0;
    obstaclesAvoided = 0;
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
    
    self.score = [SKLabelNode labelNodeWithFontNamed:@"Palatino-Bold"];
    
    self.score.position = CGPointMake(self.frame.size.width * 0.82, self.frame.size.height * 0.92);
    self.score.zPosition = 999;
    self.score.fontSize = (25 * self.frame.size.height)/375;;
    [self addChild:self.score];
    
    //Initialize Player
    self.player = [self newPlayer];
    [self addChild:self.player];
    
    //Initialize gravity
    self.physicsWorld.gravity = CGVectorMake(0.0, -2.0);
    self.physicsWorld.contactDelegate = self;
    
    //Start obstacle spawn timer
    [self StartSpawn:7.0 :5.0];
}

-(SKSpriteNode *) newPlayer
{
    CGSize playerSize = CGSizeMake((64 * self.frame.size.width)/667, (64 * self.frame.size.height)/375);
    
    self.life = 3;
    self.lifeIcon1 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon1.position = CGPointMake((16 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon1];
    
    self.lifeIcon2 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon2.position = CGPointMake((50 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon2];
    
    self.lifeIcon3 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon3.position = CGPointMake((85 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon3];
    
    //Size, color and texture
    SKSpriteNode* hull = [[SKSpriteNode alloc]
                          initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Player"]
                          color:[SKColor grayColor]
                          size:playerSize];
    
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
    
    SKAction* hover = [SKAction moveByX:150 y:0 duration:5.0];
    
    [hull runAction:hover completion:^(void) { StartAnimation = TRUE; }];
    return hull;
}

-(void)StartSpawn:(CGFloat)spawnTime :(CGFloat)randomRange
{
    //Stop previous spawn actions
    [self removeActionForKey:@"spawn"];
    
    //Configure spawn action
    SKAction* spawnObstacles = [SKAction sequence:@[
                                                    [SKAction performSelector:@selector(addObstacle) onTarget:self],
                                                    [SKAction waitForDuration:spawnTime withRange:randomRange]]];
    
    //Run spawn action
    [self runAction:[SKAction repeatActionForever:spawnObstacles] withKey:@"spawn"];
}

-(void) addObstacle
{
    SKSpriteNode* obstacle;
    
    CGSize obstacleSize = CGSizeMake((40 * self.frame.size.width)/667, (40 * self.frame.size.height)/375);
    CGFloat XPos = self.frame.size.width + obstacleSize.height/2;
    
    CGFloat minYDown = (obstacleSize.height * 0.5) + self.ground1.size.height;
    CGFloat maxYDown = minYDown + obstacleSize.height * 2.0f;
    
    obstacle = [[SKSpriteNode alloc]
                initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Obstacle"]
                color:[SKColor grayColor]
                size:obstacleSize];
    
    if([self Random:1: 100] > 50)
        obstacle.position = CGPointMake(XPos, minYDown);
    else
        obstacle.position = CGPointMake(XPos, maxYDown);
    obstacle.name = @"obstacle";
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:obstacle.texture size:obstacle.size];
    obstacle.physicsBody.dynamic = FALSE;
    
    obstacle.physicsBody.categoryBitMask = obstacleCategory;
    
    [self addChild:obstacle];
}

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
        
        g1.position = CGPointMake(g1.position.x - obstacleSpeed, g1.position.y);
        g2.position = CGPointMake(g2.position.x - obstacleSpeed, g2.position.y);
        
        if(g1.position.x < -g1.size.width)
            g1.position = CGPointMake(g2.position.x + g2.size.width, g1.position.y);
        
        if(g2.position.x < -g2.size.width)
            g2.position = CGPointMake(g1.position.x + g1.size.width, g2.position.y);
        
        self.score.text = [NSString stringWithFormat:@"Obstacles: %.f", obstaclesAvoided];
    }
}

//Update after physics simulated
-(void) didSimulatePhysics
{
    if(self.sceneInitialized && !self.gameOver)
    {
        //Player fall off screen
        if(self.player.position.y < self.ground1.size.height + self.player.size.height * 0.4)
        {
            if(!canJump)
                canJump = TRUE;
            self.player.position = CGPointMake(self.player.position.x, self.ground1.size.height + self.player.size.height * 0.4);
            self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        }
        if(StartAnimation)
            self.player.position = CGPointMake(150, self.player.position.y);
        
        //Update all obstacles
        [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop)
         {
             //Delete non visible obstacles
             if(node.position.x < -50.0)
             {
                 [node removeFromParent];
                 obstaclesAvoided++;
                 if((int)obstaclesAvoided % 10 == 0)
                 {
                     float spawnTime = 7.0 - obstacleSpeed;
                     if(spawnTime > 0.5)
                     {
                         obstacleSpeed += obstacleSpeed * 0.2;
                         [self StartSpawn:spawnTime :spawnTime];
                     }
                 }
             }
             else
             {
                 node.position = CGPointMake(node.position.x - obstacleSpeed, node.position.y);
             }
         }];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    [self TakeDamage];
}

-(void)TakeDamage
{
    if(!self.invincible)
    {
        self.life--;
        if(self.life < 0)
            [self GameOver];
        else
        {
            if(self.life == 2)
                [self.lifeIcon3 removeFromParent];
            else if(self.life == 1)
                [self.lifeIcon2 removeFromParent];
            else if(self.life == 0)
                [self.lifeIcon1 removeFromParent];
        
            self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
            self.player.position = CGPointMake(200, self.player.position.y);
        
            self.player.physicsBody.collisionBitMask = 0;
            self.player.physicsBody.contactTestBitMask = 0;
        
            SKAction *animation = [SKAction sequence:@[
                                                   [SKAction runBlock:^(void) { self.player.hidden = TRUE; }],
                                                   [SKAction waitForDuration:0.2],
                                                   [SKAction runBlock:^(void) { self.player.hidden = FALSE; }],
                                                   [SKAction waitForDuration:0.2]]];
            self.invincible = TRUE;
        
            [self runAction:[SKAction repeatAction:animation count:7]
             completion:^(void)
             {
                 self.player.physicsBody.collisionBitMask = obstacleCategory;
                 self.player.physicsBody.contactTestBitMask = obstacleCategory;
                 self.invincible = FALSE;
             }];
        }
    }
}

-(void)GameOver
{
    self.gameOver = true;
    
    self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    self.player.physicsBody.affectedByGravity = FALSE;
    self.player.physicsBody.collisionBitMask = 0;
    self.player.physicsBody.contactTestBitMask = 0;
    
    SKLabelNode *menuTitle = [SKLabelNode labelNodeWithFontNamed:@"Palatino-Bold"];
    
    menuTitle.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.65);
    menuTitle.text = @"Game Over";
    menuTitle.fontSize = (40 * self.frame.size.height)/375;;
    
    [self addChild:menuTitle];
    
    self.menu1 = [SKLabelNode labelNodeWithFontNamed:@"Palatino-Bold"];
    
    self.menu1.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.45);
    self.menu1.text = @"Reset game";
    self.menu1.fontSize = (30 * self.frame.size.height)/375;
    
    [self addChild:self.menu1];
    
    self.menu2 = [SKLabelNode labelNodeWithFontNamed:@"Palatino-Bold"];
    
    self.menu2.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.3);
    self.menu2.text = @"Main menu";
    self.menu2.fontSize = (30 * self.frame.size.height)/375;
    
    [self addChild:self.menu2];
}

-(void)AddImpulse:(float) force
{
    if(self.sceneInitialized && !self.gameOver)
        [self.player.physicsBody applyImpulse:CGVectorMake(0.0, force)];
}

-(void)OnShakeDetected:(NSNotification *) notification
{
    NSLog(@"Shake detected");
    if(canJump)
    {
        [self AddImpulse:300.0];
        canJump = FALSE;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.gameOver)
    {
        UITouch* t = [touches anyObject];
            
        CGPoint touchLocation = [t locationInNode:self.scene];
            
        if(CGRectContainsPoint(self.menu1.frame, touchLocation))
            [self ChangeScene:2];
        if(CGRectContainsPoint(self.menu2.frame, touchLocation))
            [self ChangeScene:0];
    }
}

@end
