//
//  MenuGameScene.m
//  Multimode Games
//
//  Created by PARRA AUSINA, DAVID on 17/01/2017.
//  Copyright © 2017 David Parra. All rights reserved.
//

#import "MenuGameScene.h"

@implementation MenuGameScene

-(void)InitializeScene
{
    //Initialize Background
    self.background1 = [[SKSpriteNode alloc] initWithTexture: [SKTexture textureWithImageNamed:@"Space_Background"]
                                                       color:[SKColor grayColor]
                                                        size:self.frame.size];
    
    self.background1.anchorPoint = CGPointZero;
    self.background1.position = CGPointMake(0, 0);
    
    [self addChild:self.background1];
    
    SKLabelNode *menuTitle = [SKLabelNode labelNodeWithFontNamed:@"Palatino-Bold"];
    
    menuTitle.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.70);
    menuTitle.text = @"Multimode Games";
    menuTitle.fontSize = (40 * self.frame.size.height)/375;
    
    [self addChild:menuTitle];
    
    CGSize iconSize = CGSizeMake((128 * self.frame.size.width)/667, (128 * self.frame.size.height)/375);
    
    self.balloon = [[SKSpriteNode alloc]
                      initWithTexture: [SKTexture textureWithImageNamed:@"Balloon_Player"]
                      color:[SKColor grayColor]
                      size:CGSizeMake(iconSize.width * 0.5, iconSize.height * 0.5)];
    self.balloon.position = CGPointMake(self.frame.size.width * 0.35, self.frame.size.height * 0.5);
    [self addChild:self.balloon];
    
    self.platformer = [[SKSpriteNode alloc]
                    initWithTexture: [SKTexture textureWithImageNamed:@"Platformer_Player"]
                    color:[SKColor grayColor]
                    size:CGSizeMake(iconSize.width * 0.5, iconSize.height * 0.5)];
    self.platformer.position = CGPointMake(self.frame.size.width * 0.65, self.frame.size.height * 0.5);
    [self addChild:self.platformer];
    
    self.space = [[SKSpriteNode alloc]
                    initWithTexture: [SKTexture textureWithImageNamed:@"Space_Player"]
                    color:[SKColor grayColor]
                    size:CGSizeMake(iconSize.width * 0.5, iconSize.height * 0.5)];
    self.space.position = CGPointMake(self.frame.size.width * 0.35, self.frame.size.height * 0.25);
    [self addChild:self.space];
    
    self.gps = [[SKSpriteNode alloc]
                    initWithTexture: [SKTexture textureWithImageNamed:@"GPS_Icon"]
                    color:[SKColor grayColor]
                    size:CGSizeMake(iconSize.width * 0.5, iconSize.height * 0.5)];
    self.gps.position = CGPointMake(self.frame.size.width * 0.65, self.frame.size.height * 0.25);
    [self addChild:self.gps];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
        UITouch* t = [touches anyObject];
        
        CGPoint touchLocation = [t locationInNode:self.scene];
        
        if(CGRectContainsPoint(self.balloon.frame, touchLocation))
            [self ChangeScene:1];
        if(CGRectContainsPoint(self.platformer.frame, touchLocation))
            [self ChangeScene:2];
        if(CGRectContainsPoint(self.space.frame, touchLocation))
            [self ChangeScene:3];
        if(CGRectContainsPoint(self.gps.frame, touchLocation))
            [self ChangeScene:4];
}

@end
