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
    
    //Initialize player
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"Player_balloon"];
    self.player.position = CGPointMake(100, 100);
    
    //Add it to the scene
    [self addChild:self.player];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self ChangeScene:0];
}

@end
