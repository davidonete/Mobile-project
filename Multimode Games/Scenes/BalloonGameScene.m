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
    NSLog(@"Balloon Game Scene initialized");
    
    self.backgroundColor = [SKColor whiteColor];
    // Set the scale mode to fit the window
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    self.player = [self newPlayer];

    //Add it to the scene
    [self addChild:self.player];
}

-(SKSpriteNode *) newPlayer
{
    //Size, color and texture
    SKSpriteNode* hull = [[SKSpriteNode alloc]
        initWithTexture: [SKTexture textureWithImageNamed:@"Player_balloon"]
        color:[SKColor grayColor]
        size:CGSizeMake(64, 64)];
    
    //Initial Position
    hull.position = CGPointMake(-25, CGRectGetMidY(self.frame));
    
    SKAction* hover = [SKAction sequence:@[[SKAction waitForDuration:0.5], [SKAction moveByX:80 y:0 duration:2.0]]];
    
    [hull runAction:hover];
    return hull;
}

-(void)update:(NSTimeInterval)currentTime
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self ChangeScene:0];
}

@end
