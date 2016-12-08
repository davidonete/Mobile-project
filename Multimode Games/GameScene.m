//
//  GameScene.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view
{
    if(!self.sceneInitialized)
    {
        [self InitializeScene];
        self.sceneInitialized = TRUE;
    }
}

-(void)InitializeScene {}

-(void)ChangeScene:(int)sceneID
{
    [self.viewController ChangeScene:sceneID];
}

@end
