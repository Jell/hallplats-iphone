//
//  AugmentedViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedViewController.h"
#import "AugmentedView.h"
#define GRID_HEIGHT				400.0
#define GRID_SQUARE_WIDTH		120.0
#define MIN_SCREEN_WIDTH		320.0
#define MAX_SCREEN_WIDTH		480.0
#define OFFSCREEN_SQUARE_SIZE	520.0
#define CAMERA_ANGLE_X			17.0
#define CAMERA_ANGLE_Y			28.0
#define POI_BUTTON_SIZE			40.0
#define PERSPECTIVE_VERTICAL_OFFSET			50
#define PERSPECTIVE_DEPTH_OFFSET			400
#define PERSPECTIVE_INNER_CIRCLE_RADIUS		0

@implementation AugmentedViewController
@synthesize currentLocation;
@synthesize ar_poiList;
@synthesize ar_poiViews;
@synthesize selectedPoi;
@synthesize delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	currentLocation = nil;
	selectedPoi = -1;
	
	calloutBubble = [[AugmentedCalloutBubbleController alloc] initWithNibName:@"AugmentedCalloutBubbleView" bundle:nil];
	calloutBubble.delegate = self.delegate;
	
	[poiOverlay addSubview:calloutBubble.view];
	//[poiOverlay addTarget:self action:@selector(blankTouch:) forControlEvents:UIControlEventTouchDown];

	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
	
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
	gridView.region = [gridView regionThatFits:region];
	gridView.mapType=MKMapTypeStandard;
	gridView.zoomEnabled=FALSE;
	gridView.scrollEnabled =FALSE;
	gridView.showsUserLocation = FALSE;
	gridView.delegate = self;
} 

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	currentLocation = newLocation;
	[gridView setCenterCoordinate:newLocation.coordinate animated:YES];

	for (AugmentedPoi *aPoi in ar_poiList) {
		[aPoi updateFrom:newLocation.coordinate];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{

	float headinAngle = M_PI * newHeading.trueHeading / 180.0;
	float jitter = angleXY - headinAngle;
	
	int i = 0;
	[self translateView:calloutBubble.view withTeta:M_PI andDistance:200 withScale:NO];
	for (AugmentedPoi *aPoi in ar_poiList) {
		float teta = jitter - [aPoi azimuth];

		CLLocationCoordinate2D coordinateLocation = [[aPoi annotation] coordinate];
		CGPoint pixelLocation = [gridView convertCoordinate:coordinateLocation toPointToView:gridView];
		
		//float dist = GRID_HEIGHT * ([aPoi distance] - minDistance)/ (maxDistance - minDistance);
		
		float fromcenterX = 500 - pixelLocation.x;
		float fromcenterY = 500 - pixelLocation.y;
		float dist = 3*sqrt(fromcenterX*fromcenterX + fromcenterY*fromcenterY);
		
		[self translateView:[ar_poiViews objectAtIndex:i] withTeta:teta andDistance:dist withScale:YES];
		
		if(i == selectedPoi){
			[self translateView:calloutBubble.view withTeta:teta andDistance:dist withScale:NO];
		}
		i++;
	}
	[self translateGridWithTeta:jitter];
}

-(void)translateGridWithTeta:(float)teta{
	CATransform3D rotationAndPerspectiveTransform = CATransform3DMakeTranslation(0.0, PERSPECTIVE_VERTICAL_OFFSET + 40, 0.0);
	rotationAndPerspectiveTransform.m34 = 1.0 / -500;
	rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, PERSPECTIVE_DEPTH_OFFSET);
	rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI-teta, 0.0f, 1.0f, 0.0f);
	rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI / 2.0f, 1.0f, 0.0f, 0.0f);
	rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 3, 3, 0);
	gridView.layer.transform = rotationAndPerspectiveTransform;
}

-(void)translateView:(UIView *)aView withTeta:(float)teta andDistance:(float)distance withScale:(BOOL)scaleEnabled{
	CATransform3D transfomMatrix = CATransform3DIdentity;
	transfomMatrix.m34 = 1.0 / -500;
	transfomMatrix = CATransform3DTranslate(transfomMatrix, (distance+PERSPECTIVE_INNER_CIRCLE_RADIUS) * cos(teta), PERSPECTIVE_VERTICAL_OFFSET , (distance+PERSPECTIVE_INNER_CIRCLE_RADIUS) * sin(teta) + PERSPECTIVE_DEPTH_OFFSET);
	if(!scaleEnabled){
		transfomMatrix = CATransform3DScale(transfomMatrix, transfomMatrix.m44, transfomMatrix.m44, 1.0);
	}else{
		if(transfomMatrix.m44 < 0.8){
			transfomMatrix = CATransform3DScale(transfomMatrix,0.8, 0.8, 1.0);

		}
	}

	aView.layer.transform = transfomMatrix;
}

-(void)accelerationChangedX:(float)x y:(float)y z:(float)z
{
	// Get the current device angle
	float phi = atan2(sqrt(y*y+x*x), z);
	angleXY = atan2(-x, y);

	poiOverlay.layer.transform = CATransform3DMakeRotation(M_PI-angleXY, 0.0, 0.0, 1.0);	
	poiOverlay.layer.transform = CATransform3DTranslate(poiOverlay.layer.transform,0.0, (MAX_SCREEN_WIDTH/2.0) * sin(phi + (M_PI / 2.0))/ sin(CAMERA_ANGLE_Y * M_PI / 180), 0.0);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void)setAnnotationList:(NSArray *)newList{
	@synchronized(self){
		for(UIView *aView in ar_poiViews){
			[aView removeFromSuperview];
		}
		
		NSString *selectedAnnotationTitle = nil;
		
		if(selectedPoi >= 0){
			VTAnnotation *selectedAnnotation = [[ar_poiList objectAtIndex:selectedPoi] annotation];
			selectedAnnotationTitle = [selectedAnnotation title];
		}
		
		[self setSelectedPoi:-1];
		
		[ar_poiViews release];
		[ar_poiList release];
		
		ar_poiList = [[NSMutableArray alloc] init];
		ar_poiViews = [[NSMutableArray alloc] init];
		
		CLLocationCoordinate2D origin = {0,0};
		if(currentLocation){
			origin = currentLocation.coordinate;
		}
		
		int i = 0;
		for(VTAnnotation *anAnnotation in newList){
			AugmentedPoi *aPoi = [[AugmentedPoi alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
			[ar_poiList addObject:aPoi];

			[aPoi release];
			if([[anAnnotation title] isEqual:@"ICE House AB"]){
				[self addHQView];
			}else {
				[self addPoiView];
			}

			if([[anAnnotation title] isEqual:selectedAnnotationTitle]){
				[self setSelectedPoi:i];
			}
			i++;
		}
	}
}

-(void)addPoiView{
	CGPoint center = {OFFSCREEN_SQUARE_SIZE/2.0, OFFSCREEN_SQUARE_SIZE/2.0};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	aButton.exclusiveTouch = NO;
	aButton.frame = CGRectMake(0.0, 0.0, POI_BUTTON_SIZE/1.5, POI_BUTTON_SIZE/1.5);
	aButton.backgroundColor = [UIColor clearColor];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"augmentedpoi.png"];
	[aButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"augmentedpoiselect.png"];
	[aButton setBackgroundImage:buttonImagePressed forState:UIControlStateHighlighted];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDragInside];
	
	aButton.center = center;
	
	UIImageView *needleAndShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needleandshadow.png"]];
	[needleAndShadow setFrame:CGRectMake(5, 5, needleAndShadow.frame.size.width, needleAndShadow.frame.size.height)];
	[aButton addSubview:needleAndShadow];
	[aButton sendSubviewToBack:needleAndShadow];
	[needleAndShadow release];
	
	[poiOverlay addSubview:aButton];
	[ar_poiViews addObject:aButton];
	[aButton release];
	
}

-(void)addHQView{
	CGPoint center = {OFFSCREEN_SQUARE_SIZE/2.0, OFFSCREEN_SQUARE_SIZE/2.0};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	aButton.exclusiveTouch = NO;
	aButton.frame = CGRectMake(0.0, 0.0, POI_BUTTON_SIZE/1.5, POI_BUTTON_SIZE/1.5);
	aButton.backgroundColor = [UIColor clearColor];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"home.png"];
	[aButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"home.png"];
	[aButton setBackgroundImage:buttonImagePressed forState:UIControlStateHighlighted];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDragInside];
	
	aButton.center = center;
	
	UIImageView *needleAndShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needleandshadow.png"]];
	[needleAndShadow setFrame:CGRectMake(5, 5, needleAndShadow.frame.size.width, needleAndShadow.frame.size.height)];
	[aButton addSubview:needleAndShadow];
	[aButton sendSubviewToBack:needleAndShadow];
	[needleAndShadow release];
	
	[poiOverlay addSubview:aButton];
	[ar_poiViews addObject:aButton];
	[aButton release];
	
}

-(IBAction) blankTouch:(id)view{
	[self setSelectedPoi:-1];
}

-(void) poiSelected:(id) poiViewId{
	[self setSelectedPoi:[ar_poiViews indexOfObject:poiViewId]];
}

-(void) setSelectedPoi:(int)value{
	if(selectedPoi >= 0){
		UIButton *previousSelectedButton = [ar_poiViews objectAtIndex:selectedPoi];
		[previousSelectedButton setEnabled:TRUE];
	}
	selectedPoi = value;
	if(selectedPoi >=0){
		UIButton *selectedView = [ar_poiViews objectAtIndex:selectedPoi];
		[selectedView setEnabled:FALSE];
		VTAnnotation *selectedAnnotation = [[ar_poiList objectAtIndex:selectedPoi] annotation];
		
		[calloutBubble setTitle:[selectedAnnotation title] subtitle:[selectedAnnotation subtitle]];
		[calloutBubble setTramLines:[selectedAnnotation getLineList]];
	}
}

-(void)setCurrentLocation:(CLLocation *)location{
	currentLocation = location;
	[gridView setCenterCoordinate:location.coordinate];
	for (AugmentedPoi *aPoi in ar_poiList) {
		[aPoi updateFrom:location.coordinate];
	}
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

- (void)viewDidUnload {
	[calloutBubble release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[calloutBubble release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];

    [super dealloc];
}


@end
