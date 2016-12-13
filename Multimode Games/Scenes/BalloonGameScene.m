//
//  BalloonGameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "BalloonGameScene.h"

CGFloat obstacleXSpeed = 1.0;

@implementation BalloonGameScene

-(void)InitializeScene
{
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
    
    //Initialize Player
    self.player = [self newPlayer];
    [self addChild:self.player];
    
    //Initialize gravity
    self.physicsWorld.gravity = CGVectorMake(0.0, -1.0);
    
    //Start obstacle spawn timer
    [self StartSpawn:5.0 :5.0];
}

-(SKSpriteNode *) newPlayer
{
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
    hull.physicsBody.collisionBitMask = 0;
    
    SKAction* hover = [SKAction moveByX:200 y:0 duration:5.0];
    
    [hull runAction:hover];
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
    
    CGSize obstacleSize = CGSizeMake(90, 156);
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
    
    [self addChild:obstacle];
}

-(void)ResetScene
{
    [self ChangeScene:1];
}

//Update before physics
-(void)update:(NSTimeInterval)currentTime
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
}

//Update after physics simulated
-(void) didSimulatePhysics
{
    if(self.sceneInitialized)
    {
        //Player fall off screen
        if(self.player.position.y < -self.player.size.height)
            [self ResetScene];
        else if(self.player.position.y > self.frame.size.height - (self.player.size.height / 2))
        {
            self.player.position = CGPointMake(self.player.position.x, self.frame.size.height - (self.player.size.height / 2) - 0.5);
            self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        }
        
        //Update all obstacles
        [self enumerateChildNodesWithName:@"obstacle" usingBlock:^(SKNode *node, BOOL *stop)
         {
             //Delete non visible obstacles
             if(node.position.x < -150.0)
                 [node removeFromParent];
             else
             {
                 node.position = CGPointMake(node.position.x - obstacleXSpeed, node.position.y);
             }
        }];
    }
}

-(void)AddImpulse:(float) force
{
    [self.player.physicsBody applyImpulse:CGVectorMake(0.0, force)];
}

-(void)OnBlowDetected:(NSNotification *) notification
{
    [self AddImpulse:25.0];
    NSLog(@"Blow detected");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self AddImpulse:200.0];
}

@end
