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

@synthesize poiList;

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
	opQueue = [[NSOperationQueue alloc] init];
	[activityIndicator startAnimating];
	
	//Initialise map
	//start location
	CLLocationCoordinate2D location;
	location.latitude = 57.7119;
	location.longitude = 11.9683;
	//starting span (=zoom)
	MKCoordinateSpan span;
	span.latitudeDelta = 0.01;
	span.longitudeDelta = 0.01;
	MKCoordinateRegion region;
	region.center = location;
	region.span = span;
	//Set MapView
	mapView.region = [mapView regionThatFits:region];
	mapView.mapType=MKMapTypeStandard;
	mapView.zoomEnabled=TRUE;
	mapView.scrollEnabled =TRUE;
	
	//start updating POI list
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:self];
	[opQueue addOperation:request];
	[request release];
}

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if(!mapView.showsUserLocation) mapView.showsUserLocation = TRUE;
	[mapView setCenterCoordinate:newLocation.coordinate animated:TRUE];
	//[manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	int annotationNumber = mapView.annotations.count;
	for(int i = 0; i < annotationNumber; i++){
		[mapView viewForAnnotation: (AddressAnnotation *)[mapView.annotations objectAtIndex:i]].layer.transform = CATransform3DMakeRotation(3.14 * newHeading.trueHeading / 180., 0., 0., 1.);
		[mapView viewForAnnotation: (AddressAnnotation *)[mapView.annotations objectAtIndex:i]].layer.zPosition = 
		cos(3.14 * newHeading.trueHeading / 180.)*[mapView viewForAnnotation: (AddressAnnotation *)[mapView.annotations objectAtIndex:i]].layer.position.y -
		sin(3.14 * newHeading.trueHeading / 180.)*[mapView viewForAnnotation: (AddressAnnotation *)[mapView.annotations objectAtIndex:i]].layer.position.x;
	}
	mapView.layer.transform = CATransform3DMakeRotation(-3.14 * newHeading.trueHeading / 180., 0., 0., 1.);
	
	CATransform3D startRotation = mapView.layer.transform;
	CATransform3D endRotation = CATransform3DMakeRotation(-3.14 * newHeading.trueHeading / 180., 0., 0., 1.);
	
	CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
	theAnimation.fromValue = [NSValue valueWithCATransform3D: startRotation];
	theAnimation.toValue = [NSValue valueWithCATransform3D: endRotation];
	
	[mapView.layer addAnimation: theAnimation forKey: @"animateRotation"];
	
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
}

- (IBAction)updateInfo {  
	[activityIndicator startAnimating];
	NSInvocationOperation *request = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(performUpdate:) object:self];
	[opQueue addOperation:request];
	[request release];
}

- (void) performUpdate:(id)object{
	//get the JSON
	id response = [self objectWithUrl:[NSURL URLWithString:@"http://42934.se/foretag.json?bounds=57.60%2B11.80%2B57.87%2B12.13"]];
	
	[poiList release];
	poiList = [(NSArray *)response copyWithZone:NULL];
	[(MapViewController *)object performSelectorOnMainThread:@selector(updatePerformed:) withObject:NULL waitUntilDone:YES];
}

- (void) updatePerformed:(NSString *)text {
	CLLocationCoordinate2D location;
	location.latitude = 0.0;
	location.longitude = 0.0;
	[mapView removeAnnotations:mapView.annotations];
	mapView.showsUserLocation = FALSE;
	mapView.showsUserLocation = TRUE;
	int i;
	for(i=0;i<poiList.count;i++){
		NSDictionary *bundle = (NSDictionary *)[poiList objectAtIndex:i];	
		NSDictionary *site = (NSDictionary *)[bundle valueForKey:@"site"];
		location.latitude = [(NSString *)[site valueForKey:@"latitude"] floatValue];
		location.longitude = [(NSString *)[site valueForKey:@"longitude"] floatValue];
		AddressAnnotation *annotation = [[[AddressAnnotation alloc] initWithCoordinate:location] autorelease];
		[annotation setTitle:(NSString *)[site valueForKey:@"title"]
					subtitle:(NSString *)[site valueForKey:@"city"]];
		[mapView addAnnotation:annotation];
	}
	
	[activityIndicator stopAnimating];
}

- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
	
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (id) objectWithUrl:(NSURL *)url
{
	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [self stringWithUrl:url];
	id object = [jsonParser objectWithString:jsonString error:NULL];
	[jsonString release];
	// Parse the JSON into an Object
	return object;
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
	[opQueue release];
	[poiList release];
}


- (void)dealloc {
	[opQueue release];
	[poiList release];
    [super dealloc];
}


@end
