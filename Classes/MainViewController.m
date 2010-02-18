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
	[activityIndicator startAnimating];
	
	mVTApiHandler = [[VTApiHandler alloc] init];
	

	currentLocation = nil;
	viewDisplayedController = [[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil];
	[viewDisplayed addSubview:viewDisplayedController.view];
	augmentedIsOn = TRUE;
	
	//Enable Location Manager
	mLocationManager = [[CLLocationManager alloc] init];
	mLocationManager.delegate = self; // send loc updates to myself
	[mLocationManager startUpdatingLocation];
	[mLocationManager startUpdatingHeading];
	
	//Enable Accelerometer
	xxAverage = 0;
	yyAverage = 0;
	zzAverage = 0;
	accelerationBufferIndex = 0;
	for (int i = 0; i < ACCELERATION_BUFFER_SIZE; i++) {
		xxArray[i] = 0;
		yyArray[i] = 0;
		zzArray[i] = 0;
	}
	mAccelerometer = [UIAccelerometer sharedAccelerometer];
	[mAccelerometer setUpdateInterval:1.0f / (5.0f * (float) ACCELERATION_BUFFER_SIZE)];
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
	int selected = [viewDisplayedController selectedPoi];
	if(selected >=0){
		MPNAnnotation *anAnnotation = [annotationList objectAtIndex:selected];
		[controller setAnnotationDisplayed:anAnnotation];
	}
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
	CLLocationCoordinate2D center = {57.7119, 11.9683};
	if(currentLocation){
		center = currentLocation.coordinate;
	}
	
	id response = [mVTApiHandler getAnnotationsFromCoordinates:center];
		
	[(MapViewController *)object performSelectorOnMainThread:@selector(updatePerformed:) withObject:response waitUntilDone:YES];
		
}

- (void) updatePerformed:(id)response {
	
	[viewDisplayedController setAnnotationList:(NSArray *)response];
	
	[annotationList release];
	annotationList = (NSArray *)response;
	
	[activityIndicator stopAnimating];
	updateButton.enabled = TRUE;
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
	if(accelerationBufferIndex == 0){
		[viewDisplayedController accelerationChangedX:xx y:yy z:zz];
	}
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
	int selectedPoi = [viewDisplayedController selectedPoi];
	[[viewDisplayed.subviews objectAtIndex:0] removeFromSuperview];
	[viewDisplayedController resignFirstResponder];
	[viewDisplayedController release];
	viewDisplayedController = viewController;
	[[viewDisplayed layer] addAnimation:transition forKey:kCATransitionReveal];
	[viewDisplayed addSubview:viewDisplayedController.view];
	[viewDisplayedController setCurrentLocation:currentLocation];
	[viewDisplayedController setAnnotationList:annotationList];
	[viewDisplayedController setOrientation:mInterfaceOrientation];
	[viewDisplayedController setSelectedPoi:selectedPoi];
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
	[viewDisplayedController release];
	
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
	[viewDisplayedController release];
	
	free(xxArray);
	free(yyArray);
	free(zzArray);
	
    [super dealloc];
}


@end
