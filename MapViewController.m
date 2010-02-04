//
//  MapViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "MapView.h"

@implementation MapViewController

@synthesize annotationList;
@synthesize currentLocation;
@synthesize mpnApiHandler;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mpnApiHandler = [[MPNApiHandler alloc] init];
	opQueue = [[NSOperationQueue alloc] init];
	[opQueue setMaxConcurrentOperationCount:1];
	[activityIndicator startAnimating];
	
	//Initialise map
	//start location
	CLLocationCoordinate2D location;
	location.latitude = 57.7119;
	location.longitude = 11.9683;
	//starting span (=zoom)
	MKCoordinateSpan span;
	span.latitudeDelta = 0.1;
	span.longitudeDelta = 0.1;
	MKCoordinateRegion region;
	region.center = location;
	region.span = span;
	//Set MapView
	mMapView.region = [mMapView regionThatFits:region];
	mMapView.mapType=MKMapTypeStandard;
	mMapView.zoomEnabled=TRUE;
	mMapView.scrollEnabled =FALSE;
	mMapView.showsUserLocation = FALSE;
	mMapView.delegate = self;
	//start updating POI list
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:self];
	[opQueue addOperation:request];
	[request release];
}

-(void)setCurrentLocation:(CLLocation *)location{
	[currentLocation release];
	currentLocation = [location copy];
	if(currentLocation){
		[mMapView setCenterCoordinate:self.currentLocation.coordinate animated:NO];
	}
	if(!mMapView.showsUserLocation) mMapView.showsUserLocation = TRUE;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	if(!animated){
		if(self.currentLocation){
			if(mapView.region.center.latitude !=currentLocation.coordinate.latitude &&
			   mapView.region.center.longitude !=currentLocation.coordinate.longitude)
				[mapView setCenterCoordinate:self.currentLocation.coordinate animated:YES] ;
		}
	}
}

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if(!mMapView.showsUserLocation) mMapView.showsUserLocation = TRUE;
	[currentLocation release];
	currentLocation = [newLocation copy];
	[mMapView setCenterCoordinate:newLocation.coordinate animated:TRUE];
	//[manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	int annotationNumber = mMapView.annotations.count;
	for(int i = 0; i < annotationNumber; i++){
		[mMapView viewForAnnotation: (MPNAnnotation *)[mMapView.annotations objectAtIndex:i]].layer.transform = CATransform3DMakeRotation(3.14 * newHeading.trueHeading / 180., 0., 0., 1.);
		[mMapView viewForAnnotation: (MPNAnnotation *)[mMapView.annotations objectAtIndex:i]].layer.zPosition = 
		cos(3.14 * newHeading.trueHeading / 180.)*[mMapView viewForAnnotation: (MPNAnnotation *)[mMapView.annotations objectAtIndex:i]].layer.position.y -
		sin(3.14 * newHeading.trueHeading / 180.)*[mMapView viewForAnnotation: (MPNAnnotation *)[mMapView.annotations objectAtIndex:i]].layer.position.x;
	}
	mMapView.layer.transform = CATransform3DMakeRotation(-3.14 * newHeading.trueHeading / 180., 0., 0., 1.);
	
	CATransform3D startRotation = mMapView.layer.transform;
	CATransform3D endRotation = CATransform3DMakeRotation(-3.14 * newHeading.trueHeading / 180., 0., 0., 1.);
	
	CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
	theAnimation.fromValue = [NSValue valueWithCATransform3D: startRotation];
	theAnimation.toValue = [NSValue valueWithCATransform3D: endRotation];
	
	[mMapView.layer addAnimation: theAnimation forKey: @"animateRotation"];
	
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
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
	annotationList = [(NSArray *)response copyWithZone:NULL];
	[mMapView removeAnnotations:mMapView.annotations];
	mMapView.showsUserLocation = FALSE;
	mMapView.showsUserLocation = TRUE;
	[mMapView addAnnotations:annotationList];

	[activityIndicator stopAnimating];
	updateButton.enabled = TRUE;
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return NO;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[opQueue cancelAllOperations];
	[mpnApiHandler release];
	[currentLocation release];
	[opQueue release];
	[annotationList release];
}

- (void)dealloc {
	[opQueue cancelAllOperations];
	[mpnApiHandler release];
	[currentLocation release];
	[opQueue release];
	[annotationList release];
    [super dealloc];
}


@end
