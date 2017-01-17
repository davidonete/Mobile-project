//
//  GameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)dealloc
{
    //NSLog(@"Removed previous scene");
    [self removeActionForKey:@"spawn"];
}

-(CGFloat)Random:(CGFloat)min :(CGFloat)max
{
    return (rand() / (CGFloat) RAND_MAX) * (max - min) + min;
}

-(void)didMoveToView:(SKView *)view
{
    if(!self.sceneInitialized)
    {
        [self InitializeScene];
        self.sceneInitialized = TRUE;
    }
}

-(void)InitializeScene
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GyroscopeUpdate:) name:@"gyroscope" object:nil];

}

-(void)GyroscopeUpdate:(NSNotification*) notification
{
    NSDictionary* dictionary = notification.userInfo;
    NSNumber* number = (NSNumber*)dictionary[@"gyroscope"];
    NSLog(@"%i", number.intValue);
}

-(void)ResetScene {}

-(void)ChangeScene:(int)sceneID
{
    [self.viewController ChangeScene:sceneID];
}

@end
