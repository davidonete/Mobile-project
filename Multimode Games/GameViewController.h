//
//  GameViewController.h
//  Multimode Games
//
//  Created by David Parra on 08/12/16.
//  Copyright © 2016 David Parra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameplayKit/GameplayKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreMotion/CoreMotion.h>

@interface GameViewController : UIViewController
{
    AVAudioRecorder* recorder;
    NSTimer* audioRecorderTimer;
    CMMotionManager* motionManager;
    NSOperationQueue* operationQueue;
    NSTimer* timer;
}

-(void)ChangeScene:(int)sceneID;
-(void)AudioRecorderTimerCallback:(NSTimer *)timer;

@end
