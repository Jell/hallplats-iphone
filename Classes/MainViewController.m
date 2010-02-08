//
//  MainViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@implementation MainViewController
@synthesize mLocationManager;
@synthesize mAccelerometer;
@synthesize viewDisplayedController;
@synthesize currentLocation;
@synthesize mpnApiHandler;
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
	
	mpnApiHandler = [[MPNApiHandler alloc] init];
	opQueue = [[NSOperationQueue alloc] init];
	[opQueue setMaxConcurrentOperationCount:1];
	[activityIndicator startAnimating];
	
	currentLocation = nil;
	viewDisplayedController = [[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil];
	[viewDisplayed addSubview:viewDisplayedController.view];
	augmentedIsOn = TRUE;
	
	//Enable Location Manager
	self.mLocationManager = [[[CLLocationManager alloc] init] autorelease];
	self.mLocationManager.delegate = self; // send loc updates to myself
	[mLocationManager startUpdatingLocation];
	[mLocationManager startUpdatingHeading];
	
	//Enable Accelerometer
	mAccelerometer = [UIAccelerometer sharedAccelerometer];
	[mAccelerometer setUpdateInterval:1.0f / 5.0f];
	[mAccelerometer setDelegate:self];
	
	//start updating POI list
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:self];
	[opQueue addOperation:request];
	[request release];
}


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
	[mAccelerometer setDelegate:self];
}


- (IBAction)showInfo {    
	//Stop Updating:
	[mAccelerometer setDelegate:nil];
	//Launch flipside Modal View
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:controller animated:YES];
	
	
	[controller release];
}

- (IBAction)updateInfo {
	updateButton.enabled = FALSE;
	[activityIndicator startAnimating];
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:self];
	[opQueue addOperation:request];
	[request release];
}

- (void) performUpdate:(id)object{
	//get the JSON
	CLLocationCoordinate2D upperLeft = {57.60,11.80};
	CLLocationCoordinate2D lowerRight = {57.87,12.13};
	id response = [mpnApiHandler getAnnotationsFromCoordinates:upperLeft toCoordinates:lowerRight];
	[(MapViewController *)object performSelectorOnMainThread:@selector(updatePerformed:) withObject:response waitUntilDone:YES];
}

- (void) updatePerformed:(id)response {
	
	[annotationList release];
	annotationList = (NSArray *)response;

	[viewDisplayedController setAnnotationList:annotationList];
	
	[activityIndicator stopAnimating];
	updateButton.enabled = TRUE;
}
 

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	float xx = [acceleration x];
	float yy = [acceleration y];
	float zz = [acceleration z];
	// Check if we have to switch view
	if(augmentedIsOn){
		if(zz < -0.9 && (yy > -0.2 && yy <  0.2 && xx > -0.2 && xx <  0.2))
		{
			[self loadMapView];
		}
	}else{
		if( (zz > -0.7 &&  zz <  0.0) &&
			(yy < -0.8 || yy >  0.8 || xx < -0.8 || xx >  0.8)  )
		{
			[self loadAugmentedView];
		}
	}

	float angle = atan2(xx, yy);
	if(angle < 0.785 && angle >-0.785){
		mInterfaceOrientation = UIInterfaceOrientationPortrait;	
	}
	
	if(angle < 2.355 && angle > 0.785){
		mInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;	
	}
	
	if(angle < -0.785 && angle >-2.355){
		mInterfaceOrientation = UIInterfaceOrientationLandscapeRight;	
	}
	
	if(angle > 2.355 || angle <-2.355){
		mInterfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;	
	}
	

	
	// Dispatch acceleration
	[viewDisplayedController accelerometer:accelerometer didAccelerate:acceleration];
}


- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[currentLocation release];
	currentLocation = [newLocation copy];
	
	//Dispatch new Location
	[viewDisplayedController locationManager:manager didUpdateToLocation:currentLocation fromLocation:oldLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	//Dispatch new Heading
	[viewDisplayedController locationManager:manager didUpdateHeading:newHeading];
}

- (void)locationManager: (CLLocationManager *)manager
	   didFailWithError: (NSError *)error
{
}

- (void)loadMapView{
	augmentedIsOn = FALSE;
	
	CATransition *applicationLoadViewIn = [CATransition animation];
	[applicationLoadViewIn setDuration:0.5];
	[applicationLoadViewIn setType:kCATransitionPush];
	
	switch (mInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			[applicationLoadViewIn setSubtype:kCATransitionFromBottom];
			break;
		case UIInterfaceOrientationLandscapeLeft:
			[applicationLoadViewIn setSubtype:kCATransitionFromRight];
			break;
		case UIInterfaceOrientationLandscapeRight:
			[applicationLoadViewIn setSubtype:kCATransitionFromLeft];
			break;
		default:
			[applicationLoadViewIn setSubtype:kCATransitionFromTop];
			break;
	}

	[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	
	[self loadViewController:[[MapViewController alloc] initWithNibName:@"MapView" bundle:nil]
			  withTransition:applicationLoadViewIn];
}

- (void)loadAugmentedView{
	augmentedIsOn = TRUE;
	
	CATransition *applicationLoadViewIn = [CATransition animation];
	[applicationLoadViewIn setDuration:0.5];
	[applicationLoadViewIn setType:kCATransitionPush];
	
	switch (mInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			[applicationLoadViewIn setSubtype:kCATransitionFromTop];
			break;
		case UIInterfaceOrientationLandscapeLeft:
			[applicationLoadViewIn setSubtype:kCATransitionFromLeft];
			break;
		case UIInterfaceOrientationLandscapeRight:
			[applicationLoadViewIn setSubtype:kCATransitionFromRight];
			break;
		default:
			[applicationLoadViewIn setSubtype:kCATransitionFromBottom];
			break;
	}
	[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	
	[self loadViewController:[[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil]
			  withTransition:applicationLoadViewIn];

}

- (void)loadViewController:(UIViewController<ARViewDelegate> *)viewController
			withTransition:(CATransition *)transition
{
	[[viewDisplayed.subviews objectAtIndex:0] removeFromSuperview];
	[viewDisplayedController release];
	viewDisplayedController = viewController;
	[[viewDisplayed layer] addAnimation:transition forKey:kCATransitionReveal];
	[viewDisplayed addSubview:viewDisplayedController.view];
	[viewDisplayedController setCurrentLocation:currentLocation];
	[viewDisplayedController setAnnotationList:annotationList];
	[viewDisplayedController setOrientation:mInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[opQueue cancelAllOperations];
	[mpnApiHandler release];
	[mLocationManager release];
	[mAccelerometer release];
	[opQueue release];
	[viewDisplayedController release];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[opQueue cancelAllOperations];
	[mpnApiHandler release];
	[mLocationManager release];
	[mAccelerometer release];
	[opQueue release];
	[viewDisplayedController release];
    [super dealloc];
}


@end
