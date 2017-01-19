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
#import "Scenes/SpaceGameScene.h"
#import "Scenes/MenuGameScene.h"

@implementation GameViewController

- (void)dealloc
{
    recorder = nil;
    audioRecorderTimer = nil;
    motionManager = nil;
    operationQueue = nil;
    timer = nil;
    locationManager = nil;
    myMapView = nil;
    routeOverlay = nil;
    currentRoute = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    gameOver = TRUE;
    TimeLeftText.hidden = TRUE;
    DistanceText.hidden = TRUE;
    GameOver.hidden = TRUE;
    replayButton.hidden = TRUE;
    MainMenuButton.hidden = TRUE;
    locationUpdate.hidden = TRUE;
    currentCoord.hidden = TRUE;
    endCoord.hidden = TRUE;
    
    myMapView.hidden = TRUE;
    myMapView.delegate = self;
    
    SKView *skView = (SKView *)self.view;
    
    //skView.showsFPS = YES;
    //skView.showsDrawCount = YES;
    //skView.showsNodeCount = YES;
    
    if(!skView.scene)
    {
        [self ChangeScene:0];
    }
}

-(BOOL)shouldAutorotate
{
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    } else
//    {
//        return UIInterfaceOrientationMaskAll;
//    }
//}

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
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
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
    if([recorder averagePowerForChannel:0] > -5.0 && [recorder peakPowerForChannel:0] > -0.05)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"blow" object:self];
    
    //NSLog(@"Average input: %f Peak input: %f Low Pass Result: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
}

-(void)GyroscopeUpdate
{
    CMDeviceMotion* dm = motionManager.deviceMotion;
    CMAttitude* attitude = dm.attitude;
    int pitch = 180.0 * attitude.pitch / M_PI;
    NSDictionary* dictionary = @{@"gyroscope":@(pitch)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gyroscope" object:self userInfo:dictionary];
}

- (CLLocationCoordinate2D) locationWithBearing:(float)bearing distance:(float)distanceMeters fromLocation:(CLLocationCoordinate2D)origin
{
    CLLocationCoordinate2D target;
    const double distRadians = distanceMeters / (6372797.6); // earth radius in meters
    
    float lat1 = origin.latitude * M_PI / 180;
    float lon1 = origin.longitude * M_PI / 180;
    
    float lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing));
    float lon2 = lon1 + atan2( sin(bearing) * sin(distRadians) * cos(lat1),
                              cos(distRadians) - sin(lat1) * sin(lat2) );
    
    target.latitude = lat2 * 180 / M_PI;
    target.longitude = lon2 * 180 / M_PI;
    
    return target;
}

-(CGFloat)Random:(CGFloat)min :(CGFloat)max
{
    return (rand() / (CGFloat) RAND_MAX) * (max - min) + min;
}

-(void)GPSUpdate
{
    timeLeft--;
    TimeLeftText.text = [NSString stringWithFormat:@"Time left: %.0f", timeLeft];
    
    locationUpdate.hidden = TRUE;
    
    [locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
    
    if(timeLeft <= 0.0)
        [self GameOver];
}

-(void) LocationInit
{
    gameOver = FALSE;
    TimeLeftText.hidden = FALSE;
    DistanceText.hidden = FALSE;
    
    firstLocationUpdate = FALSE;
    myMapView.hidden = FALSE;
    myMapView.showsUserLocation = YES;
    myMapView.showsBuildings = YES;
    myMapView.mapType = MKMapTypeSatellite;
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    [locationManager startUpdatingHeading];
    //[locationManager setAllowsBackgroundLocationUpdates:YES];
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization];
    if([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [locationManager requestAlwaysAuthorization];
    
    timeLeft = 100.0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(GPSUpdate) userInfo:nil repeats:TRUE];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if(!gameOver)
    {
    userCoords = [locations objectAtIndex:0].coordinate;
    
    if(!firstLocationUpdate)
    {
        float bearing = [self Random:0 :100];
        destinationCoords = [self locationWithBearing:bearing distance:150 fromLocation:userCoords];
        endCoord.text = [NSString stringWithFormat:@"End: %f, %f", destinationCoords.latitude, destinationCoords.longitude];
        firstLocationUpdate = TRUE;
    }
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:userCoords.latitude longitude:userCoords.longitude];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:destinationCoords.latitude longitude:destinationCoords.longitude];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
    
    DistanceText.text = [NSString stringWithFormat:@"Distance: %.0f", distance];
    currentCoord.text = [NSString stringWithFormat:@"Current: %f, %f", userCoords.latitude, userCoords.longitude];
    //locationUpdate.hidden = FALSE;
        
    if(distance < 50)
        [self GameOver];
        
    [self UpdateMapDirections:destinationCoords user:userCoords];
    }
}

-(void)UpdateMapDirections:(CLLocationCoordinate2D)destinationLocation user: (CLLocationCoordinate2D) sourceLocation
{
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationLocation];
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceLocation];
    
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.transportType = MKDirectionsTransportTypeWalking;
    
    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    [request setSource:source];
    [request setDestination:destination];
    
    MKDirections *direction = [[MKDirections alloc] initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if(error)
        {
            NSLog(@"Error doing direction");
            return;
        }

        currentRoute = [response.routes firstObject];
        [self AddRouteToMap:currentRoute];
    }];
}

-(CLLocationCoordinate2D)GetLastCoordinateOfRoute:(MKRoute*) route
{
    NSUInteger pointCount = route.polyline.pointCount;
    CLLocationCoordinate2D *routeCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
    
    [route.polyline getCoordinates:routeCoordinates range:NSMakeRange(0, pointCount)];

    CLLocationCoordinate2D coord = routeCoordinates[pointCount-1];
    
    free(routeCoordinates);
    return coord;
}

-(void)GameOver
{
    [timer invalidate];
    gameOver = TRUE;
    GameOver.hidden = FALSE;
    replayButton.hidden = FALSE;
    MainMenuButton.hidden = FALSE;
    
    [locationManager stopUpdatingLocation];
}

- (IBAction)MainMenuPressed:(id)sender
{
    gameOver = TRUE;
    TimeLeftText.hidden = TRUE;
    DistanceText.hidden = TRUE;
    GameOver.hidden = TRUE;
    replayButton.hidden = TRUE;
    MainMenuButton.hidden = TRUE;
    myMapView.hidden = TRUE;
    
    locationManager = nil;
    routeOverlay = nil;
    currentRoute = nil;
    
    float bearing = [self Random:0 :100];
    destinationCoords = [self locationWithBearing:bearing distance:150 fromLocation:userCoords];
    [self UpdateMapDirections:destinationCoords user:userCoords];
    
    [self ChangeScene:0];
}

- (IBAction)ReplayPressed:(id)sender
{
    gameOver = TRUE;
    TimeLeftText.hidden = TRUE;
    DistanceText.hidden = TRUE;
    GameOver.hidden = TRUE;
    replayButton.hidden = TRUE;
    MainMenuButton.hidden = TRUE;
    myMapView.hidden = TRUE;
    
    locationManager = nil;
    routeOverlay = nil;
    currentRoute = nil;
    
    float bearing = [self Random:0 :100];
    destinationCoords = [self locationWithBearing:bearing distance:150 fromLocation:userCoords];
    [self UpdateMapDirections:destinationCoords user:userCoords];
    [self ChangeScene:4];
}

-(void)AddRouteToMap:(MKRoute*)route
{
    [myMapView removeOverlays:myMapView.overlays];
    routeOverlay = route.polyline;
    
    [myMapView addOverlay:routeOverlay];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate: userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) eyeAltitude:500];
    
    [mapView setCamera:camera animated:YES];
}

-(MKOverlayRenderer*) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return renderer;
}

-(void)ChangeScene:(int)sceneID
{
    SKView* skView = (SKView *)self.view;
    GameScene* NewScene;
    SKTransition* fade = [SKTransition fadeWithDuration:0.5];
    
    [audioRecorderTimer invalidate];
    [timer invalidate];
    
    //Delete previous recorder instance (?)
    if(recorder)
    {
        recorder = nil;
        audioRecorderTimer = nil;
        motionManager = nil;
        operationQueue = nil;
        timer = nil;
    }
    
    switch(sceneID)
    {
        case 0:
            NewScene = [[MenuGameScene alloc] initWithSize:skView.bounds.size];
        break;
        case 1:
            [self InitializeAudioRecorder];
            NewScene = [[BalloonGameScene alloc] initWithSize:skView.bounds.size];
        break;
        case 2:
            NewScene = [[PlatformerGameScene alloc] initWithSize:skView.bounds.size];
            break;
        case 3:
            motionManager = [[CMMotionManager alloc] init];
            motionManager.deviceMotionUpdateInterval = 1 / 60.0;
            [motionManager startDeviceMotionUpdates];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(GyroscopeUpdate) userInfo:nil repeats:TRUE];
            NewScene = [[SpaceGameScene alloc] initWithSize:skView.bounds.size];
        break;
        case 4:
            [self LocationInit];
        break;
        default:
           NewScene = [[GameScene alloc] initWithSize:skView.bounds.size];
        break;
    }
    
    NewScene.viewController = self;
    [skView presentScene:NewScene transition:fade];
}

@end
