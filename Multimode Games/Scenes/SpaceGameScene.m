//
//  SpaceGameScene.m
//  Multimode Games
//
//  Created by David Parra on 17/01/17.
//  Copyright © 2017 David Parra. All rights reserved.
//

#import "SpaceGameScene.h"

@implementation SpaceGameScene

CGFloat obstaclesDestroyed = 0.0;
CGFloat obstacleYSpeed = 1.0;

static const uint32_t playerCategory =   0x1 << 0;
static const uint32_t obstacleCategory = 0x1 << 1;
BOOL StartAnim = FALSE;

-(void)InitializeScene
{
    obstacleYSpeed = 1.0;
    obstaclesDestroyed = 0.0;
    
    NSLog(@"Space Game Scene initialized: %@", NSStringFromCGSize(self.frame.size));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GyroscopeUpdate:) name:@"gyroscope" object:nil];
    
    self.backgroundColor = [SKColor whiteColor];
    // Set the scale mode to fit the window
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    //Initialize Background
    self.background1 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Space_Background"]
                                                       color:[SKColor grayColor]
                                                        size:self.frame.size];
    
    self.background1.anchorPoint = CGPointZero;
    self.background1.position = CGPointMake(0, 0);
    
    [self addChild:self.background1];
    
    self.background2 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Space_Background"]
                                                       color:[SKColor grayColor]
                                                        size:self.frame.size];
    
    self.background2.anchorPoint = CGPointZero;
    self.background2.position = CGPointMake(0, self.background1.size.height - 1);
    
    [self addChild:self.background2];
    
    self.score = [SKLabelNode labelNodeWithFontNamed:@"Palatino-Bold"];
    
    self.score.position = CGPointMake(self.frame.size.width * 0.82, self.frame.size.height * 0.9);
    self.score.zPosition = 999;
    self.score.fontSize = (40 * self.frame.size.height)/375;
    
    [self addChild:self.score];
    
    //Initialize Player
    self.player = [self newPlayer];
    [self addChild:self.player];
    
    //Initialize gravity
    self.physicsWorld.gravity = CGVectorMake(0.0, -1.0);
    self.physicsWorld.contactDelegate = self;
    
    //Start obstacle spawn timer
    //[self StartSpawn:5 :5.0];
}

-(SKSpriteNode *) newPlayer
{
    CGSize playerSize = CGSizeMake((64 * self.frame.size.width)/667, (64 * self.frame.size.height)/375);
    
    self.life = 3;
    self.lifeIcon1 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Space_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon1.zPosition = 999;
    self.lifeIcon1.position = CGPointMake((16 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon1];
    
    self.lifeIcon2 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Space_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon2.zPosition = 999;
    self.lifeIcon2.position = CGPointMake((50 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon2];
    
    self.lifeIcon3 = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Space_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon3.zPosition = 999;
    self.lifeIcon3.position = CGPointMake((84 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon3];
    
    //Size, color and texture
    SKSpriteNode* hull = [[SKSpriteNode alloc]
                          initWithTexture: [SKTexture textureWithImageNamed:@"Space_Player"]
                          color:[SKColor grayColor]
                          size:playerSize];
    
    //Initial Position
    hull.position = CGPointMake(self.frame.size.width/2, -50);
    
    //Initialize Physic body (collision and mass)
    hull.physicsBody = [SKPhysicsBody bodyWithTexture:hull.texture size:hull.size];
    hull.physicsBody.usesPreciseCollisionDetection = TRUE;
    hull.physicsBody.mass = 1.0;
    hull.physicsBody.allowsRotation = FALSE;
    hull.physicsBody.angularVelocity = 0.0;
    hull.physicsBody.dynamic = FALSE;
    
    hull.physicsBody.categoryBitMask = playerCategory;
    hull.physicsBody.collisionBitMask = obstacleCategory;
    hull.physicsBody.contactTestBitMask = obstacleCategory;
    
    SKAction* hover = [SKAction moveByX:0 y:100 duration:2.5];
    
    [hull runAction:hover completion:^(void) { StartAnim = TRUE; }];
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
    
    CGSize obstacleSize = CGSizeMake((50 * self.frame.size.width)/667, (50 * self.frame.size.height)/375);
    CGFloat YPos = self.frame.size.height + obstacleSize.height;
    
    int random = [self Random:1: 100];
    NSString* obstacleImage;
    if(random < 24)
        obstacleImage = @"Space_Obstacle1";
    else if (random > 25 && random < 49)
        obstacleImage = @"Space_Obstacle2";
    else if (random > 50 && random < 74)
        obstacleImage = @"Space_Obstacle3";
    else
        obstacleImage = @"Space_Obstacle4";
        
    obstacle = [[SKSpriteNode alloc]
                    initWithTexture: [SKTexture textureWithImageNamed:obstacleImage]
                    color:[SKColor grayColor]
                    size:obstacleSize];
        
    obstacle.position = CGPointMake([self Random:obstacleSize.width: self.frame.size.width - obstacleSize.width], YPos);
    obstacle.name = @"obstacle";
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:obstacle.texture size:obstacle.size];
    obstacle.physicsBody.dynamic = FALSE;
    
    obstacle.physicsBody.categoryBitMask = obstacleCategory;
    
    [self addChild:obstacle];
}

-(void)GameOver
{

}

//Update before physics
-(void)update:(NSTimeInterval)currentTime
{
    if(self.sceneInitialized && !self.gameOver)
    {
        //Background movement
        SKSpriteNode* bg1 = self.background1;
        SKSpriteNode* bg2 = self.background2;
        
        bg1.position = CGPointMake(bg1.position.x, bg1.position.y - 0.5);
        bg2.position = CGPointMake(bg2.position.x, bg2.position.y - 0.5);
        
        if(bg1.position.y < -bg1.size.height)
            bg1.position = CGPointMake(bg1.position.x, bg2.position.y + bg1.size.height);
        
        if(bg2.position.y < -bg2.size.height)
            bg2.position = CGPointMake(bg2.position.x, bg1.position.y + bg2.size.height);
    }
}

//Update after physics simulated
-(void) didSimulatePhysics
{
    if(self.sceneInitialized && !self.gameOver)
    {
        //if(StartAnim)
            //self.player.position = CGPointMake(200, self.player.position.y);
        
        //Update all obstacles
        [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop)
         {
             //Delete non visible obstacles
             if(node.position.y < -50.0)
             {
                 /*
                 obstacles++;
                 if((int)obstacles % 5 == 0)
                 {
                     float spawnTime = 5.0 - obstacleYSpeed;
                     if(spawnTime > 0.5)
                     {
                         obstacleYSpeed += obstacleYSpeed * 0.2;
                         [self StartSpawn:spawnTime :spawnTime];
                     }
                 }
                 */
                 [node removeFromParent];
                 
             }
         }];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{

}

-(void)TakeDamage
{

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.gameOver)
    {
        UITouch* t = [touches anyObject];
        
        CGPoint touchLocation = [t locationInNode:self.scene];
        
        if(CGRectContainsPoint(self.menu1.frame, touchLocation))
            [self ChangeScene:1];
        if(CGRectContainsPoint(self.menu2.frame, touchLocation))
            [self ChangeScene:0];
    }
}

-(void)GyroscopeUpdate:(NSNotification*) notification
{
    NSDictionary* dictionary = notification.userInfo;
    NSNumber* number = (NSNumber*)dictionary[@"gyroscope"];
    int value = number.intValue;
    
    float speed = 5.0;
    
    if(value > 5)
        self.player.position = CGPointMake(self.player.position.x + speed, self.player.position.y);
    else if(value < -5)
        self.player.position = CGPointMake(self.player.position.x - speed, self.player.position.y);
        
    //NSLog(@"%i", number.intValue);
}

@end
