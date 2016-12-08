//
//  PlatformerGameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "PlatformerGameScene.h"

@implementation PlatformerGameScene

-(void)InitializeScene
{
    NSLog(@"Platformer Game Scene initialized");
    
    //Delegate shake event notification to a function
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnShakeDetected:) name:@"shake" object:nil];
    
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFill;
}

-(void)OnShakeDetected:(NSNotification *) notification
{
    NSLog(@"Shake detected");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self ChangeScene:1];
}

@end
