//
//  BalloonGameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "BalloonGameScene.h"

CGFloat obstacleXSpeed = 1.0;
CGFloat distanceTraveled = 0.0;
CGFloat obstacles = 0.0;

static const uint32_t playerCategory =   0x1 << 0;
static const uint32_t obstacleCategory = 0x1 << 1;
BOOL startAnimation = FALSE;

@implementation BalloonGameScene

-(void)InitializeScene
{
    obstacleXSpeed = 1.0;
    distanceTraveled = 0.0;
    obstacles = 0.0;
    
    NSLog(@"Balloon Game Scene initialized: %@", NSStringFromCGSize(self.frame.size));
    
    //Delegate blow event notification to a function
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBlowDetected:) name:@"blow" object:nil];
    
    self.backgroundColor = [SKColor whiteColor];
    // Set the scale mode to fit the window
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    //Initialize Background
    self.background1 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Background1"]
        color:[SKColor grayColor]
        size:self.frame.size];
    
    self.background1.anchorPoint = CGPointZero;
    self.background1.position = CGPointMake(0, 0);
    
    [self addChild:self.background1];
    
    self.background2 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Background2"]
        color:[SKColor grayColor]
        size:self.frame.size];

    self.background2.anchorPoint = CGPointZero;
    self.background2.position = CGPointMake(self.background1.size.width - 1, 0);
    
    [self addChild:self.background2];
    
    self.score = [SKLabelNode labelNodeWithFontNamed:@"Papyrus-Condensed"];
    
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
    [self StartSpawn:5 :5.0];
}

-(SKSpriteNode *) newPlayer
{
    CGSize playerSize = CGSizeMake((64 * self.frame.size.width)/667, (64 * self.frame.size.height)/375);
    
    self.life = 3;
    self.lifeIcon1 = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
        color:[SKColor grayColor]
        size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon1.zPosition = 999;
    self.lifeIcon1.position = CGPointMake((16 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon1];
    
    self.lifeIcon2 = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
        color:[SKColor grayColor]
        size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon2.zPosition = 999;
    self.lifeIcon2.position = CGPointMake((40 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon2];
    
    self.lifeIcon3 = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
        color:[SKColor grayColor]
        size:CGSizeMake(playerSize.width * 0.5, playerSize.height * 0.5)];
    
    self.lifeIcon3.zPosition = 999;
    self.lifeIcon3.position = CGPointMake((64 * self.frame.size.width)/667, self.frame.size.height - (20 * self.frame.size.height)/375);
    [self addChild:self.lifeIcon3];
    
    //Size, color and texture
    SKSpriteNode* hull = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
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
    
    SKAction* hover = [SKAction moveByX:200 y:0 duration:5.0];
    
    [hull runAction:hover completion:^(void) { startAnimation = TRUE; }];
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
    
    CGSize obstacleSize = CGSizeMake((90 * self.frame.size.width)/667, (156 * self.frame.size.height)/375);
    CGFloat XPos = self.frame.size.width + obstacleSize.height/2;
    
    CGFloat minYUp = 0.0;
    CGFloat maxYUp = obstacleSize.height/2;
    CGFloat minYDown = self.frame.size.height;
    CGFloat maxYDown = self.frame.size.height - obstacleSize.height/2;

    if([self Random:1: 100] > 50)
    {
        obstacle = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_ColumnUp"]
        color:[SKColor grayColor]
        size:obstacleSize];
    
        obstacle.position = CGPointMake(XPos, [self Random:minYUp: maxYUp]);
    }
    else
    {
        obstacle = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_ColumnDown"]
        color:[SKColor grayColor]
        size:obstacleSize];
        
        obstacle.position = CGPointMake(XPos, [self Random:minYDown: maxYDown]);
    }
    obstacle.name = @"obstacle";
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithTexture:obstacle.texture size:obstacle.size];
    obstacle.physicsBody.dynamic = FALSE;
    
    obstacle.physicsBody.categoryBitMask = obstacleCategory;
    
    [self addChild:obstacle];
}

-(void)GameOver
{
    //[self ChangeScene:1];
    self.gameOver = true;
    
    self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    self.player.physicsBody.affectedByGravity = FALSE;
    self.player.physicsBody.collisionBitMask = 0;
    self.player.physicsBody.contactTestBitMask = 0;
    
    SKLabelNode *menuTitle = [SKLabelNode labelNodeWithFontNamed:@"Papyrus-Condensed"];
    
    menuTitle.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.65);
    menuTitle.text = @"Game Over";
    menuTitle.fontSize = (50 * self.frame.size.height)/375;
    
    [self addChild:menuTitle];
    
    self.menu1 = [SKLabelNode labelNodeWithFontNamed:@"Papyrus-Condensed"];
    
    self.menu1.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.50);
    self.menu1.text = @"Reset game";
    self.menu1.fontSize = (35 * self.frame.size.height)/375;
    
    [self addChild:self.menu1];
    
    self.menu2 = [SKLabelNode labelNodeWithFontNamed:@"Papyrus-Condensed"];
    
    self.menu2.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.35);
    self.menu2.text = @"Main menu";
    self.menu2.fontSize = (35 * self.frame.size.height)/375;
    
    [self addChild:self.menu2];
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
        
        distanceTraveled += 0.01;
        self.score.text = [NSString stringWithFormat:@"Distance: %.0f", distanceTraveled];
    }
}

//Update after physics simulated
-(void) didSimulatePhysics
{
    if(self.sceneInitialized && !self.gameOver)
    {
        //Player fall off screen
        if(self.player.position.y < -self.player.size.height)
            [self GameOver];
        else if(self.player.position.y > self.frame.size.height - (self.player.size.height / 2))
        {
            self.player.position = CGPointMake(self.player.position.x, self.frame.size.height - (self.player.size.height / 2) - 0.5);
            self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        }
        if(startAnimation)
            self.player.position = CGPointMake(200, self.player.position.y);
        
        //Update all obstacles
        [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop)
         {
             //Delete non visible obstacles
             if(node.position.x < -50.0)
             {
                 obstacles++;
                 if((int)obstacles % 5 == 0)
                 {
                    float spawnTime = 5.0 - obstacleXSpeed;
                    if(spawnTime > 0.5)
                    {
                        obstacleXSpeed += obstacleXSpeed * 0.2;
                        [self StartSpawn:spawnTime :spawnTime];
                    }
                 }
                 [node removeFromParent];

             }
             else
                 node.position = CGPointMake(node.position.x - obstacleXSpeed, node.position.y);
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

-(void)AddImpulse:(float) force
{
    if(self.sceneInitialized && !self.gameOver)
        [self.player.physicsBody applyImpulse:CGVectorMake(0.0, force)];
}

-(void)OnBlowDetected:(NSNotification *) notification
{
    [self AddImpulse:50.0];
    NSLog(@"Blow detected");
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

@end
