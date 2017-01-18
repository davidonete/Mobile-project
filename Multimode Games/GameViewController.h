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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface GameViewController : UIViewController <MKMapViewDelegate>
{
    AVAudioRecorder* recorder;
    NSTimer* audioRecorderTimer;
    CMMotionManager* motionManager;
    NSOperationQueue* operationQueue;
    NSTimer* timer;
    CLLocationManager* locationManager;
    __weak IBOutlet MKMapView *myMapView;
    MKPolyline *routeOverlay;
    MKRoute* currentRoute;
    CLLocationCoordinate2D userCoords;
    CLLocationCoordinate2D destinationCoords;
    BOOL firstLocationUpdate;
    BOOL gameOver;
    __weak IBOutlet UILabel *DistanceText;
    __weak IBOutlet UILabel *TimeLeftText;
    __weak IBOutlet UILabel *GameOver;
    __weak IBOutlet UIButton *replayButton;
    __weak IBOutlet UIButton *MainMenuButton;
    
    float timeLeft;
}

-(void)ChangeScene:(int)sceneID;
-(void)AudioRecorderTimerCallback:(NSTimer *)timer;

@end
