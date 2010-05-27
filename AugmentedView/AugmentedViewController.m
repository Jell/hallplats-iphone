//
//  AugmentedViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedViewController.h"
#import "AugmentedView.h"
#define MIN_SCREEN_WIDTH		320.0
#define MAX_SCREEN_WIDTH		480.0
#define OFFSCREEN_SQUARE_SIZE	520.0
#define MAP_SIZE				520.0
#define PERSPECTIVE_DEPTH_OFFSET			100
#define PROJECTION_DEPTH		900
#define MAX_ZOOM				4

@implementation AugmentedViewController
@synthesize mAlpha;
@synthesize mBeta;
@synthesize mTeta;
@synthesize mVerticalOffset;
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
	calloutBubble.view.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	
	[poiOverlay addSubview:calloutBubble.view];
	//[poiOverlay addTarget:self action:@selector(blankTouch:) forControlEvents:UIControlEventTouchDown];

	
	ar_poiList = [[NSMutableArray alloc] init];
	ar_poiViews = [[NSMutableArray alloc] init];
	
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
	gridView.region = [gridView regionThatFits:region];
	gridView.mapType=MKMapTypeStandard;
	gridView.zoomEnabled=FALSE;
	gridView.scrollEnabled =FALSE;
	gridView.showsUserLocation = FALSE;
	gridView.delegate = self;
	gridView.clipsToBounds = NO;
	[gridView setAlpha:0.5];
	[gridView resignFirstResponder];
	[mapMask removeFromSuperview];
	[gridView addSubview:mapMask];
	mapMask.center = CGPointMake(MAP_SIZE/2, MAP_SIZE/2);
	
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(updateProjection:)
								   userInfo:nil
									repeats:NO];
	
}

- (void)locationManager: (CLLocationManager *)manager
	didUpdateToLocation: (CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	@synchronized(self){
	currentLocation = newLocation;
	[gridView setCenterCoordinate:newLocation.coordinate animated:YES];
	[self updatePoisLocations];
	}
	
}

-(void)updatePoisLocations{
	int i = 0;
	for (AugmentedPoi *aPoi in ar_poiList) {
		
		[aPoi updateAngleFrom:[[self currentLocation] coordinate]];
		
		CGPoint pixelLocation = [gridView convertCoordinate:[[aPoi annotation] coordinate] toPointToView:gridView];
		float fromcenterX = MAP_SIZE/2 - pixelLocation.x;
		float fromcenterY = MAP_SIZE/2 - pixelLocation.y;
		float pixelDist = sqrt(fromcenterX*fromcenterX + fromcenterY*fromcenterY);
		if(pixelDist > MAP_SIZE / 2){
			[[[[ar_poiViews objectAtIndex:i] subviews] objectAtIndex:1] setHidden:TRUE];
			pixelDist = MAP_SIZE / 2;
		}else {
			[[[[ar_poiViews objectAtIndex:i] subviews] objectAtIndex:1] setHidden:FALSE];
		}
		[aPoi setPixelDist:pixelDist];
		i++;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	@synchronized(self){
	[self setMTeta:M_PI * newHeading.trueHeading / 180.0];
	}
}

-(void)updateProjection:(NSTimer *)theTimer{
	float teta = [self mTeta];
	float alpha = [self mAlpha] - teta;
	float beta = [self mBeta];
	float sinb = sin(beta);
	float cosb = cos(beta);
	float verticalOffset = [self mVerticalOffset];
	int i = 0;
	
	calloutBubble.view.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	for (AugmentedPoi *aPoi in ar_poiList) {
		float teta = alpha - [aPoi azimuth];
		float pixelDist = [aPoi pixelDist];
		float dist = pixelDist * MAX_ZOOM * sin(beta);
		
		translateView([ar_poiViews objectAtIndex:i], teta, cosb, sinb, verticalOffset, dist);
		
		if(i == selectedPoi){
			[self setBubbleMatrixForView:[ar_poiViews objectAtIndex:i]];
		}
		i++;
	}

	translateGridWithTeta(gridView, M_PI + alpha, cosb, sinb, verticalOffset);
	
	CATransform3D final_transform = CATransform3DMakeRotation(M_PI-[self mAlpha], 0.0, 0.0, 1.0);
	poiOverlay.layer.transform = final_transform;
	
	
	[NSTimer scheduledTimerWithTimeInterval:0.08
									 target:self
								   selector:@selector(updateProjection:)
								   userInfo:nil
									repeats:NO];
}

void translateGridWithTeta(UIView* aView, float teta, float cosb, float sinb, float verticalOffset){
	float cost = cos(teta);
	float sint = sin(teta);
	
	CATransform3D transformMatrix = {
		cost * MAX_ZOOM * sinb,		sint * cosb * MAX_ZOOM * sinb,							sint * sinb * MAX_ZOOM * sinb,			-sint * sinb * MAX_ZOOM * sinb/ PROJECTION_DEPTH,
		-sint * MAX_ZOOM * sinb,	cost * cosb * MAX_ZOOM * sinb,							cost * sinb * MAX_ZOOM * sinb,			-cost * sinb / PROJECTION_DEPTH * MAX_ZOOM * sinb,
		0.0,						-sinb,													cosb,									-cosb / PROJECTION_DEPTH,
		0.0,						(PERSPECTIVE_DEPTH_OFFSET) * sinb + verticalOffset,		-(PERSPECTIVE_DEPTH_OFFSET) * cosb,		1.0
	};
	
	aView.layer.transform = transformMatrix;
};

void translateView(UIView *aView, float teta, float cosb, float sinb, float verticalOffset, float distance){
	float sint = sin(teta);
	float m34 = 1.0 / -PROJECTION_DEPTH;
	float m43 = - (PERSPECTIVE_DEPTH_OFFSET) * cosb + distance * sinb * sint;
	float m44 = 1 + m34 * m43;
	
	CATransform3D transfomMatrix = {
		m44,					0,																				0,		0,
		0,						m44,																			0,		0,
		0,						0,																				1,		m34,
		distance * cos(teta),	(PERSPECTIVE_DEPTH_OFFSET) * sinb + distance * cosb * sint + verticalOffset,	m43,	m44
	};
	
	aView.layer.transform = transfomMatrix;
}

-(void)setBubbleMatrixForView:(UIView *)aview{
	if(aview == nil){
		calloutBubble.view.hidden = TRUE;
		calloutBubble.view.layer.transform = CATransform3DMakeTranslation(200, 0, 0);
	}else {
		CATransform3D transfomMatrix = [[aview layer] transform];
		calloutBubble.view.layer.transform = transfomMatrix;
		calloutBubble.view.hidden = FALSE;
	}
}


-(void)accelerationChangedX:(float)x y:(float)y z:(float)z
{
	// Get the current device angle
	float beta = M_PI - atan2(sqrt(y*y+x*x), z);
	if(beta > M_PI /2){
		beta = M_PI/2 + sqrt(beta - M_PI /2) * sqrt(M_PI) / 10;
	}
	[self setMBeta:beta];

	float alpha;
	if(x*x + y*y > 0.25){
		alpha = atan2(-x, y);
		[self setMAlpha:alpha];		
	}else{
		alpha = [self mAlpha];
	}
	[self setMVerticalOffset: sin(beta)*(MIN_SCREEN_WIDTH / 6.0 + abs((MAX_SCREEN_WIDTH - MIN_SCREEN_WIDTH) * cos(alpha)/3))];
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
		[self addPoiView];

		if([[anAnnotation title] isEqual:selectedAnnotationTitle]){
			[self setSelectedPoi:i];
		}
		i++;
	}
	[self updatePoisLocations];
	}
}

-(void)addPoiView{
	CGPoint center = {OFFSCREEN_SQUARE_SIZE/2.0, OFFSCREEN_SQUARE_SIZE/2.0 - 1.5 * POI_BUTTON_SIZE/2};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	aButton.exclusiveTouch = NO;
	aButton.frame = CGRectMake(0.0, 0.0, POI_BUTTON_SIZE, POI_BUTTON_SIZE);
	aButton.backgroundColor = [UIColor clearColor];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"augmentedpoi.png"];
	[aButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"augmentedpoiselect.png"];
	[aButton setBackgroundImage:buttonImagePressed forState:UIControlStateHighlighted];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDragInside];
	
	aButton.center = center;
	
	UIImageView *needleAndShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needleandshadow.png"]];
	[needleAndShadow setFrame:CGRectMake(0, 0, POI_BUTTON_SIZE*2.3, POI_BUTTON_SIZE*1.5)];
	[aButton addSubview:needleAndShadow];
	[aButton sendSubviewToBack:needleAndShadow];
	[needleAndShadow release];
	
	[poiOverlay addSubview:aButton];
	[ar_poiViews addObject:aButton];
	[aButton release];
	
}

-(IBAction) blankTouch:(id)view{
	[self setBubbleMatrixForView:nil];
	[self setSelectedPoi:-1];
}

-(void) poiSelected:(id) poiViewId{
	[self setSelectedPoi:[ar_poiViews indexOfObject:poiViewId]];
	[self setBubbleMatrixForView:poiViewId];
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
	@synchronized(self){
	currentLocation = location;
	[gridView setCenterCoordinate:location.coordinate];
	[self updatePoisLocations];
	}
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

-(BOOL)canBecomeFirstResponder {
    return NO;
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
