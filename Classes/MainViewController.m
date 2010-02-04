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
	[mAccelerometer setUpdateInterval:1.0f / 60.0f];
	[mAccelerometer setDelegate:self];
	
	//start updating POI list
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:self];
	[opQueue addOperation:request];
	[request release];
}



 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
	 return NO;
 }


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
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
	// Check if we have to switch view
	if(augmentedIsOn){
		if(acceleration.z < -0.9 && (acceleration.y > -0.2 &&
									 acceleration.y <  0.2 &&
									 acceleration.x > -0.2 &&
									 acceleration.x <  0.2)){
			[self loadMapView];
		}
	}else{
		if(acceleration.z > -0.7 &&
		   acceleration.z <  0.0 && (acceleration.y < -0.8 ||
									 acceleration.y >  0.8 ||
									 acceleration.x < -0.8 ||
									 acceleration.x >  0.8) ){
			[self loadAugmentedView];
		}
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
	[viewDisplayedController locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
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
	[[viewDisplayed.subviews objectAtIndex:0] removeFromSuperview];
	[viewDisplayedController release];
	viewDisplayedController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];
	
	[viewDisplayed addSubview:viewDisplayedController.view];
	CATransition *applicationLoadViewIn = [CATransition animation];
	[applicationLoadViewIn setDuration:0.5];
	[applicationLoadViewIn setType:kCATransitionPush];
	[applicationLoadViewIn setSubtype:kCATransitionFromTop];
	[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	[[viewDisplayed layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
	[viewDisplayedController setCurrentLocation:currentLocation];
	[viewDisplayedController setAnnotationList:annotationList];
	augmentedIsOn = FALSE;
}

- (void)loadAugmentedView{
	[[viewDisplayed.subviews objectAtIndex:0] removeFromSuperview];
	[viewDisplayedController release];
	viewDisplayedController = [[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil];
	
	[viewDisplayed addSubview:viewDisplayedController.view];
	CATransition *applicationLoadViewIn = [CATransition animation];
	[applicationLoadViewIn setDuration:0.5];
	[applicationLoadViewIn setType:kCATransitionPush];
	[applicationLoadViewIn setSubtype:kCATransitionFromBottom];
	[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	[[viewDisplayed layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
	[viewDisplayedController setCurrentLocation:currentLocation];
	[viewDisplayedController setAnnotationList:annotationList];
	augmentedIsOn = TRUE;
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
