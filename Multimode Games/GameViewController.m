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

- (void)dealloc
{
    recorder = nil;
    audioRecorderTimer = nil;
}

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

-(void)InitializeAudioRecorder
{
    NSURL* url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
        [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
        [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
        [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
        nil];
    
    NSError* error;
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if(recorder)
    {
        [recorder prepareToRecord];
        recorder.meteringEnabled = TRUE;
        [recorder record];
        audioRecorderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(AudioRecorderTimerCallback:) userInfo:nil repeats:TRUE];
                              
    }
    else
        NSLog(@"%@", [error description]);
}

-(void)AudioRecorderTimerCallback:(NSTimer *)timer
{
    [recorder updateMeters];
    
    //const double alpha = 0.05;
    //double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    //lowPassResults = alpha * peakPowerForChannel + (1.0 - alpha) * lowPassResults;
    
    //if(lowPassResults > 2.50)
    if([recorder averagePowerForChannel:0] > 4.0 && [recorder peakPowerForChannel:0] > 12.0)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"blow" object:self];
    
    //NSLog(@"Average input: %f Peak input: %f Low Pass Result: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
}

-(void)ChangeScene:(int)sceneID
{
    SKView* skView = (SKView *)self.view;
    GameScene* NewScene;
    SKTransition* fade = [SKTransition fadeWithDuration:0.5];
    
    //Delete previous recorder instance (?)
    if(recorder)
    {
        recorder = nil;
        audioRecorderTimer = nil;
    }
    
    switch(sceneID)
    {
        case 0:
            NewScene = [[PlatformerGameScene alloc] initWithSize:skView.bounds.size];
        break;
        case 1:
            [self InitializeAudioRecorder];
            NewScene = [[BalloonGameScene alloc] initWithSize:skView.bounds.size];
        break;
        default:
           NewScene = [[GameScene alloc] initWithSize:skView.bounds.size];
        break;
    }
    
    NewScene.viewController = self;
    [skView presentScene:NewScene transition:fade];
}

@end
