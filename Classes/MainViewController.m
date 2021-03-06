//
//  MainViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright ICE House 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@implementation MainViewController
//@synthesize timer;
@synthesize mLocationManager;
@synthesize mAccelerometer;
@synthesize viewDisplayedController;
@synthesize mMapViewController;
@synthesize mAugmentedViewController;
@synthesize currentLocation;
@synthesize mVTApiHandler;
@synthesize annotationList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	//mpnApiHandler = [[MPNApiHandler alloc] init];
	opQueue = [[NSOperationQueue alloc] init];
	mVTApiHandler = [[VTApiHandler alloc] init];
	
	currentLocation = nil;
	
	mAugmentedViewController = [[[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil] retain];
	mMapViewController = [[[MapViewController alloc] initWithNibName:@"MapView" bundle:nil] retain];
	mMapViewController.delegate = self;
	
	viewDisplayedController = mAugmentedViewController;
	[viewDisplayed addSubview:viewDisplayedController.view];
	
	//Enable Location Manager
	mLocationManager = [[CLLocationManager alloc] init];
	[mLocationManager setDistanceFilter:5];
	mLocationManager.delegate = self; // send loc updates to myself
	firstLocationUpdate = YES;
	secondLocationUpdate = NO;
	
	//Enable Accelerometer
	xxAverage = 0;
	yyAverage = 0;
	zzAverage = -1.0;
	accelerationBufferIndex = 0;
	for (int i = 0; i < ACCELERATION_BUFFER_SIZE; i++) {
		xxArray[i] = 0;
		yyArray[i] = 0;
		zzArray[i] = -1.0;
	}
	
	loadingDisplay.layer.cornerRadius = 10;
	mAccelerometer = [UIAccelerometer sharedAccelerometer];
	[mAccelerometer setDelegate:self];
	[mAccelerometer setUpdateInterval:1.0f / 25];
	[mLocationManager startUpdatingLocation];
	[mLocationManager startUpdatingHeading];
}

-(void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
	if(!lockButton.selected){
		[mAccelerometer setDelegate:self];
		[mLocationManager startUpdatingHeading];
		[mLocationManager startUpdatingLocation];
	}
}

- (void)showInfo:(id)sender {    
	//Stop Updating:
	[mAccelerometer setDelegate:nil];
	[mLocationManager stopUpdatingHeading];
	[mLocationManager stopUpdatingLocation];
	//Launch flipside Modal View
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	int selected = [viewDisplayedController selectedPoi];
	if(selected >=0){
		VTAnnotation *anAnnotation = [annotationList objectAtIndex:selected];
		[controller setAnnotationDisplayed:anAnnotation];
	}
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self resignFirstResponder];
	[self presentModalViewController:controller animated:YES];
	
	
	[controller release];
}

- (void) performUpdate:(id)object{
	//get the JSON
	if([self currentLocation]){
		CLLocationCoordinate2D center = [[self currentLocation] coordinate];
		id response = [mVTApiHandler getAnnotationsFromCoordinates:center];
		[self performSelectorOnMainThread:@selector(updatePerformed:) withObject:response waitUntilDone:YES];
	}
	
}

- (void) beginUdpate:(id)object {
	[UIView beginAnimations:@"loading" context:nil];
	[UIView setAnimationDuration:0.5];
    loadingDisplay.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
	
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:nil];
	[opQueue addOperation:request];
	[request release];
}

- (void) updatePerformed:(id)response {
	if(response == nil || [response count] == 0){
		UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
														  message:NSLocalizedString(@"ErrorReachServer", @"The application couldn't reach the servers")
														 delegate:nil
												cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	}
	
	NSArray *newList = [(NSArray *)response retain];
	[mMapViewController setAnnotationList:newList];
	[mAugmentedViewController setAnnotationList:newList];
	[self setAnnotationList:newList];
	[newList release];
	
	[self becomeFirstResponder];
	
	[UIView beginAnimations:@"loading" context:nil];
	[UIView setAnimationDuration:0.5];
    loadingDisplay.transform = CGAffineTransformMakeTranslation(0, -30);
    [UIView commitAnimations];
	//timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:NO];
}
 
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	xxAverage -= (xxArray[accelerationBufferIndex] / (float) ACCELERATION_BUFFER_SIZE);
	yyAverage -= (yyArray[accelerationBufferIndex] / (float) ACCELERATION_BUFFER_SIZE);
	zzAverage -= (zzArray[accelerationBufferIndex] / (float) ACCELERATION_BUFFER_SIZE);
	
	xxArray[accelerationBufferIndex] = [acceleration x];
	yyArray[accelerationBufferIndex] = [acceleration y];
	zzArray[accelerationBufferIndex] = [acceleration z];
	
	xxAverage += (xxArray[accelerationBufferIndex] / (float) ACCELERATION_BUFFER_SIZE);
	yyAverage += (yyArray[accelerationBufferIndex] / (float) ACCELERATION_BUFFER_SIZE);
	zzAverage += (zzArray[accelerationBufferIndex] / (float) ACCELERATION_BUFFER_SIZE);
		
	accelerationBufferIndex++;
	accelerationBufferIndex %= ACCELERATION_BUFFER_SIZE;
	
	float xx = xxAverage;
	float yy = yyAverage;
	float zz = zzAverage;

	// if the phone is not in almost flat position, change the orientation
	if(zz > -0.7 && zz < 0.7){
		float angle = atan2(xx, yy);
		if(angle < 0.785 && angle >-0.785){
			if(mInterfaceOrientation != UIInterfaceOrientationPortrait){
				mInterfaceOrientation = UIInterfaceOrientationPortrait;
				[UIView beginAnimations:@"rotate_lock" context:nil];
				lockButton.layer.transform = CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0);
				[UIView commitAnimations];
			}
		}
		
		if(angle < 2.355 && angle > 0.785){
			if(mInterfaceOrientation != UIInterfaceOrientationLandscapeLeft){
				mInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
				[UIView beginAnimations:@"rotate_lock" context:nil];
				lockButton.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0, 0.0, 1.0);
				[UIView commitAnimations];
			}
		}
		
		if(angle < -0.785 && angle >-2.355){
			if(mInterfaceOrientation != UIInterfaceOrientationLandscapeRight){
				mInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
				[UIView beginAnimations:@"rotate_lock" context:nil];
				lockButton.layer.transform = CATransform3DMakeRotation(M_PI/2, 0.0, 0.0, 1.0);
				[UIView commitAnimations];
			}
		}
		
		if(angle > 2.355 || angle <-2.355){
			if(mInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown){
				mInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
				[UIView beginAnimations:@"rotate_lock" context:nil];
				lockButton.layer.transform = CATransform3DMakeRotation(0.0, 0.0, 0.0, 1.0);
				[UIView commitAnimations];
			}
		}
	}
	// Dispatch acceleration
	[viewDisplayedController accelerationChangedX:xx y:yy z:zz];
	
	// Check if we have to switch view
	if(viewDisplayedController == mAugmentedViewController){
		if(zz < -0.9 && (yy > -0.2 && yy <  0.2 && xx > -0.2 && xx <  0.2))
		{
			[self loadMapView];
		}
	}else{
		if( (zz > -0.7 &&  zz <  0.0) &&
		   (yy < -0.3 || yy >  0.3 || xx < -0.3 || xx >  0.3)  )
		{
			[self loadAugmentedView];
		}
	}
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		//[timer release];
		[self resignFirstResponder];
		[self beginUdpate:nil];
	}
}

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[self setCurrentLocation:newLocation];
	//currentLocation = [[CLLocation alloc] initWithLatitude:59.330917 longitude:18.060389];
	//currentLocation = [[CLLocation alloc] initWithLatitude:57.7118 longitude:11.967];
	NSLog(@"%@", currentLocation);

	if(secondLocationUpdate){
		[self beginUdpate:nil];
		secondLocationUpdate = NO;
	}
	
	if(firstLocationUpdate){
		if(newLocation.horizontalAccuracy >= 0  && newLocation.horizontalAccuracy < 500){
			[self beginUdpate:nil];
		}else{
			secondLocationUpdate = YES;
		}
		firstLocationUpdate = NO;
	}
	
	for (VTAnnotation *anAnnotation in annotationList) {
		[anAnnotation updateDistanceFrom:newLocation.coordinate];
	}
	//Dispatch new Location
	[viewDisplayedController locationManager:manager didUpdateToLocation:[self currentLocation] fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	//Dispatch new Heading
	[viewDisplayedController locationManager:manager didUpdateHeading:newHeading];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
	return NO;
}

	
- (void)locationManager: (CLLocationManager *)manager
	   didFailWithError: (NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
							   message:NSLocalizedString(@"ErrorNoGPS", @"The GPS is deactivated, please enable it and try again")
							  delegate:nil
					 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
					 otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)loadMapView{
	CATransition *applicationLoadViewIn = [CATransition animation];
	[applicationLoadViewIn setDuration:0.5];
	[applicationLoadViewIn setType:kCATransitionFade];

	[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	
	[self loadViewController:mMapViewController
			  withTransition:applicationLoadViewIn];
}

- (void)loadAugmentedView{
	CATransition *applicationLoadViewIn = [CATransition animation];
	[applicationLoadViewIn setDuration:0.5];
	[applicationLoadViewIn setType:kCATransitionFade];

	[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	
	[self loadViewController:mAugmentedViewController
			  withTransition:applicationLoadViewIn];

}

- (void)loadViewController:(UIViewController<ARViewDelegate> *)viewController
			withTransition:(CATransition *)transition
{
	@synchronized(self){
		int selectedPoi = [viewDisplayedController selectedPoi];
		[viewDisplayedController.view removeFromSuperview];
		viewDisplayedController = viewController;
		[[viewDisplayed layer] addAnimation:transition forKey:kCATransitionReveal];
		[viewDisplayed addSubview:viewDisplayedController.view];
		[viewDisplayedController setCurrentLocation:currentLocation];
		[viewDisplayedController setAnnotationList:annotationList];
		[viewDisplayedController setOrientation:mInterfaceOrientation];
		[viewDisplayedController setSelectedPoi:selectedPoi];
	}
}

-(IBAction)lockPress{
	if(lockButton.selected == NO){
		[mAccelerometer setDelegate:nil];
		[mLocationManager stopUpdatingHeading];
		[mLocationManager stopUpdatingLocation];
		lockButton.selected = YES;
	}else{
		[mAccelerometer setDelegate:self];
		[mLocationManager startUpdatingHeading];
		[mLocationManager startUpdatingLocation];
		lockButton.selected = NO;
	}

}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[opQueue cancelAllOperations];
	[mVTApiHandler release];
	[mLocationManager release];
	[mAccelerometer release];
	[opQueue release];
	[mAugmentedViewController release];
	[mMapViewController release];
	
	free(xxArray);
	free(yyArray);
	free(zzArray);
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[opQueue cancelAllOperations];
	[mVTApiHandler release];
	[mLocationManager release];
	[mAccelerometer release];
	[opQueue release];
	[mAugmentedViewController release];
	[mMapViewController release];
	
	free(xxArray);
	free(yyArray);
	free(zzArray);
	
    [super dealloc];
}


@end
