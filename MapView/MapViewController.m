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
@synthesize selectedPoi;
@synthesize delegate;
@synthesize mTeta;

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
	selectedPoi = -1;
	recentering = NO;
	CLLocationCoordinate2D location;
	location.latitude = 57.7119;
	location.longitude = 11.9683;
	//starting span (=zoom)
	MKCoordinateSpan span;
	span.latitudeDelta = 0.02;
	span.longitudeDelta = 0.02;
	MKCoordinateRegion region;
	region.center = location;
	region.span = span;
	//Set MapView
	[arrowView removeFromSuperview];
	mMapView.region = [mMapView regionThatFits:region];
	mMapView.mapType=MKMapTypeStandard;
	mMapView.zoomEnabled=TRUE;
	mMapView.scrollEnabled =FALSE;
	mMapView.showsUserLocation = FALSE;
	mMapView.delegate = self;
	mMapView.exclusiveTouch = NO;
}

-(void)setCurrentLocation:(CLLocation *)location{
	currentLocation = location;
	if(currentLocation){
		[mMapView setCenterCoordinate:currentLocation.coordinate animated:NO];
		recentering = NO;
	}
	if(!mMapView.showsUserLocation) mMapView.showsUserLocation = TRUE;
}

-(int)selectedPoi{
	NSArray *selectedAnnotationsArray = [mMapView selectedAnnotations];
	if(selectedAnnotationsArray){
		if([selectedAnnotationsArray count] > 0){
			id <MKAnnotation> selectedAnnotation = [selectedAnnotationsArray objectAtIndex:0];
			if([annotationList containsObject:selectedAnnotation]){
				return [annotationList indexOfObject:selectedAnnotation];
			}
		}
	}
	return -1;
}

-(void)setSelectedPoi:(int)poiId{
	if(selectedPoi >=0){
		[mMapView deselectAnnotation:[annotationList objectAtIndex:selectedPoi] animated:NO];
	}
	selectedPoi = poiId;
	if(selectedPoi >=0){
		[mMapView selectAnnotation:[annotationList objectAtIndex:selectedPoi] animated:NO];
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	if(currentLocation){
		if(!animated){
			if(mapView.region.center.latitude !=currentLocation.coordinate.latitude &&
			   mapView.region.center.longitude !=currentLocation.coordinate.longitude){
				recentering = YES;
				[mapView setCenterCoordinate:currentLocation.coordinate animated:YES];
			}
		}else{
			if(!recentering){
				if(mapView.region.center.latitude !=currentLocation.coordinate.latitude &&
				   mapView.region.center.longitude !=currentLocation.coordinate.longitude){
					recentering = YES;
					[mapView setCenterCoordinate:currentLocation.coordinate animated:YES];
				}
			}else{
				recentering = NO;
			}
		}
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
	if(selectedPoi >=0){
		[mMapView selectAnnotation:[annotationList objectAtIndex:selectedPoi] animated:NO];
	}
	[mapView resignFirstResponder];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id <MKAnnotation>)annotation {
	
	MKPinAnnotationView *view = nil;
	if(annotation != mapView.userLocation) {
		
		view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:[annotation title]];
		
		if(nil == view) {
			
			view = [[[MKPinAnnotationView alloc]
					 initWithAnnotation:annotation reuseIdentifier:[annotation title]]
					autorelease];
			
			[view setPinColor:MKPinAnnotationColorPurple];
			[view setCanShowCallout:YES];
			[view setAnimatesDrop:NO];
			[view setExclusiveTouch:NO];
			
			UIImageView *busImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"augmentedpoi.png"]];
			busImage.layer.frame = CGRectMake(-3, -3, 20, 20);
			[view addSubview:busImage];
			[busImage release];
			
			if([[(VTAnnotation *) annotation forecastList] count] > 0){
			UIButton *infoButton = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
			infoButton.exclusiveTouch = NO;
			infoButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
			[infoButton addTarget:delegate action:@selector(showInfo:) forControlEvents:UIControlEventTouchDown];
			
			[view setRightCalloutAccessoryView:infoButton];
			
			[infoButton release];
			}
		}
		
	} else {
		
		/*CLLocation *location = [[CLLocation alloc] 
								initWithLatitude:annotation.coordinate.latitude
								longitude:annotation.coordinate.longitude];
		[self setCurrentLocation:location];*/
		[mapView.userLocation setTitle:@""];
		
	}
	return view;
}

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if(!mMapView.showsUserLocation) mMapView.showsUserLocation = TRUE;
	[self setCurrentLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	[self setMTeta:-M_PI * newHeading.trueHeading / 180.0];
	[self rotateMap];
}

- (void)rotateMap{
	float teta = [self mTeta];
	mMapView.layer.transform = CATransform3DMakeRotation(teta, 0., 0., 1.);
	CATransform3D annotationRotation = CATransform3DMakeRotation(phase-teta, 0., 0., 1.);
	//Set animation and rotation for the annotations
	for(VTAnnotation *annotation in mMapView.annotations){
		CALayer *annotationLayer = [mMapView viewForAnnotation: annotation].layer;
		annotationLayer.transform = annotationRotation;
		annotationLayer.zPosition = 1000 + cos(phase-teta)*annotationLayer.position.y - sin(phase-teta)*annotationLayer.position.x;
	}
	
	UIView *locationView = [mMapView viewForAnnotation:mMapView.userLocation];
	if(locationView != nil){
		[arrowView removeFromSuperview];
		CGPoint center = {12, 10};
		[arrowView setCenter:center];
		[locationView addSubview:arrowView];
	}
}

-(void)setAnnotationList:(NSArray *)newList{
	NSString *selectedAnnotationTitle = nil;
	int selectedPoiIndex = [self selectedPoi];
	if(selectedPoiIndex >= 0){
		VTAnnotation *selectedAnnotation = [annotationList objectAtIndex:selectedPoiIndex];
		selectedAnnotationTitle = [selectedAnnotation title];
	}
	[mMapView removeAnnotations:annotationList];
	annotationList = newList;
	[mMapView addAnnotations:annotationList];
	
	int i = 0;
	for(VTAnnotation *anAnnotation in newList){
		if([[anAnnotation title] isEqual:selectedAnnotationTitle]){
			[self setSelectedPoi:i];
		}
		i++;
	}
	[self rotateMap];
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			phase = M_PI;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			phase = -M_PI/2;
			break;
		case UIInterfaceOrientationLandscapeRight:
			phase = M_PI/2;
			break;
		default:
			phase = 0.0;
			break;
	}
	//arrowView.layer.transform = CATransform3DMakeRotation(phase, 0.0, 0.0, 1.0);
}

-(void)accelerationChangedX:(float)x y:(float)y z:(float)z
{
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	mMapView.showsUserLocation = YES;
	[self resignFirstResponder];
}
- (void)viewWillDisappear{
	mMapView.showsUserLocation = NO;
}

-(BOOL)canBecomeFirstResponder {
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
	[mMapView removeFromSuperview];
	[mMapView release];
	[arrowView removeFromSuperview];
	[arrowView release];
}

- (void)dealloc {
	[mMapView removeFromSuperview];
	[mMapView release];
	[arrowView removeFromSuperview];
	[arrowView release];
    [super dealloc];
}


@end
