//
//  GameViewController.m
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import "GameViewController.h"
#import "Scenes/BalloonGameScene.h"
#import "Scenes/PlatformerGameScene.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    SKView *skView = (SKView *)self.view;
    
    skView.showsFPS = YES;
    skView.showsDrawCount = YES;
    skView.showsNodeCount = YES;
    
    if(!skView.scene)
    {
        [self ChangeScene:1];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else
    {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(BOOL) canBecomeFirstResponder
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(motion == UIEventSubtypeMotionShake)
    {
        //Send shake notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];
    }
}

-(void)ChangeScene:(int)sceneID
{
    SKView* skView = (SKView *)self.view;
    GameScene* NewScene;
    SKTransition* doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    
    switch(sceneID)
    {
        case 0:
            NewScene = [[PlatformerGameScene alloc] initWithSize:skView.bounds.size];
        break;
        case 1:
            NewScene = [[BalloonGameScene alloc] initWithSize:skView.bounds.size];
        break;
        default:
           NewScene = [[GameScene alloc] initWithSize:skView.bounds.size];
        break;
        
    }
    
    NewScene.viewController = self;
    [skView presentScene:NewScene transition:doors];
}

@end
