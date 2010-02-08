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
	//Initialise map
	//start location
	phase = 0.0;
	
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
}

-(void)setCurrentLocation:(CLLocation *)location{
	currentLocation = location;
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
				[mapView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
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
	[self rotateMapWithTeta: -3.14 * newHeading.trueHeading / 180.0];
}

- (void)rotateMapWithTeta:(float)teta{
	
	mMapView.layer.transform = CATransform3DMakeRotation(teta, 0., 0., 1.);
	CATransform3D annotationRotation = CATransform3DMakeRotation(phase-teta, 0., 0., 1.);
	//Set animation and rotation for the annotations
	int annotationNumber = mMapView.annotations.count;
	for(int i = 0; i < annotationNumber; i++){
		
		CALayer *annotationLayer = [mMapView viewForAnnotation: (MPNAnnotation *)[mMapView.annotations objectAtIndex:i]].layer;
		annotationLayer.transform = annotationRotation;
		annotationLayer.zPosition = cos(phase-teta)*annotationLayer.position.y - sin(phase-teta)*annotationLayer.position.x;
		
	}
}

-(void)setAnnotationList:(NSArray *)newList{
	[mMapView removeAnnotations:annotationList];
	[annotationList release];
	annotationList = [newList copy];
	[mMapView addAnnotations:annotationList];
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			phase = 3.14;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			phase = -1.57;
			break;
		case UIInterfaceOrientationLandscapeRight:
			phase = 1.57;
			break;
		default:
			phase = 0.0;
			break;
	}
	arrowView.layer.transform = CATransform3DMakeRotation(phase, 0.0, 0.0, 1.0);
	
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[mMapView removeFromSuperview];
	[mMapView release];
	[arrowView removeFromSuperview];
	[arrowView release];
	[annotationList release];
}

- (void)dealloc {
	[mMapView removeFromSuperview];
	[mMapView release];
	[arrowView removeFromSuperview];
	[arrowView release];
	[annotationList release];
    [super dealloc];
}


@end
