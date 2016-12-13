//
//  BalloonGameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "BalloonGameScene.h"

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
    hull.physicsBody.mass = 1.0;
    
    SKAction* hover = [SKAction moveByX:200 y:0 duration:5.0];
    
    [hull runAction:hover];
    return hull;
}

-(void)ResetScene
{
    [self ChangeScene:1];
}

-(void)update:(NSTimeInterval)currentTime
{
    //Background movement
    SKSpriteNode* bg1 = self.background1;
    SKSpriteNode* bg2 = self.background2;
    
    bg1.position = CGPointMake(bg1.position.x - 1, bg1.position.y);
    bg2.position = CGPointMake(bg2.position.x - 1, bg2.position.y);
    
    if(bg1.position.x < -bg1.size.width)
        bg1.position = CGPointMake(bg2.position.x + bg2.size.width, bg1.position.y);
    
    if(bg2.position.x < -bg2.size.width)
        bg2.position = CGPointMake(bg1.position.x + bg1.size.width, bg2.position.y);
    
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
    }
}

-(void)AddImpulse:(float) force
{
    //self.player.physicsBody.velocity = CGVectorMake(0.0, 0.0);
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
