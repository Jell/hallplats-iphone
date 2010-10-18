//
//  AugmentedViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedViewController.h"
#import "AugmentedView.h"
#define MIN_SCREEN_WIDTH			320.0
#define MAX_SCREEN_WIDTH			480.0
#define OFFSCREEN_SQUARE_SIZE		510.0
#define MAP_SIZE					510.0
#define PERSPECTIVE_DEPTH_OFFSET	115
#define PROJECTION_DEPTH			900
#define MAX_ZOOM					5
#define SHADOW_TAG					42

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
	//calloutBubble.view.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	[calloutBubble.view setCenter:CGPointMake(0,-50)];
	
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
	groundView.region = [groundView regionThatFits:region];
	groundView.mapType=MKMapTypeStandard;
	groundView.zoomEnabled=FALSE;
	groundView.scrollEnabled =FALSE;
	groundView.showsUserLocation = FALSE;
	groundView.userInteractionEnabled = FALSE;
	groundView.delegate = self;
	groundView.clipsToBounds = NO;
	[groundView setAlpha:0.5];
	[groundView resignFirstResponder];
	[groundView setNeedsDisplay];
	
	[mapMask removeFromSuperview];
	[groundView addSubview:mapMask];
	mapMask.center = CGPointMake(MAP_SIZE/2, MAP_SIZE/2);
	
	[locationBubble removeFromSuperview];
	[groundView addSubview:locationBubble];
	locationBubble.center = CGPointMake(MAP_SIZE/2, MAP_SIZE/2);
	
	groundView.layer.shouldRasterize = YES;
	
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
	[groundView setCenterCoordinate:newLocation.coordinate animated:YES];
	[self updatePOILocations];
	}
	
}

-(void)updatePOILocations{
	int i = 0;
	for (AugmentedPoi *aPoi in ar_poiList) {
		
		[aPoi updateAngleFrom:[[self currentLocation] coordinate]];
		
		CGPoint pixelLocation = [groundView convertCoordinate:[[aPoi annotation] coordinate] toPointToView:groundView];
		float fromcenterX = MAP_SIZE/2 - pixelLocation.x;
		float fromcenterY = MAP_SIZE/2 - pixelLocation.y;
		float pixelDist = sqrt(fromcenterX*fromcenterX + fromcenterY*fromcenterY);
		if(pixelDist > MAP_SIZE / 2){
			[[[ar_poiViews objectAtIndex:i] viewWithTag:SHADOW_TAG] setHidden:TRUE];
			pixelDist = MAP_SIZE / 1.7;
		}else {
			[[[ar_poiViews objectAtIndex:i] viewWithTag:SHADOW_TAG] setHidden:FALSE];
		}
		[aPoi setPixelDist:pixelDist];
		i++;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
	[self setMTeta:M_PI * newHeading.trueHeading / 180.0];
}

-(void)updateProjection:(NSTimer *)theTimer{
	float verticalOffset = [self mVerticalOffset];
	float alpha = [self mAlpha];
	float teta = alpha - [self mTeta];
	float beta = [self mBeta];
	float sinb = sin(beta);
	float cosb = cos(beta);
	
	int i = 0;
	
	//calloutBubble.view.layer.transform = CATransform3DMakeTranslation(400, 0, 0);
	[calloutBubble.view setCenter:CGPointMake(0,-50)];
	for (AugmentedPoi *aPoi in ar_poiList) {
		float teta_r = teta - [aPoi azimuth];
		float pixelDist = [aPoi pixelDist];
		float dist = pixelDist * MAX_ZOOM * sin(beta);
		
		setViewTransfrom([ar_poiViews objectAtIndex:i], teta_r, cosb, sinb, verticalOffset, dist);
		
		if(i == selectedPoi){
			[self setBubbleTransfromForView:[ar_poiViews objectAtIndex:i]];
		}
		i++;
	}

	setGroundTransform(groundView, M_PI + teta, cosb, sinb, verticalOffset);	
	
	[locationBubble setTransform:CGAffineTransformMakeRotation(-M_PI - teta)];
	
	CATransform3D final_transform = CATransform3DMakeRotation(M_PI-alpha, 0.0, 0.0, 1.0);
	poiOverlay.layer.transform = final_transform;
	
	
	[NSTimer scheduledTimerWithTimeInterval:0.12
									 target:self
								   selector:@selector(updateProjection:)
								   userInfo:nil
									repeats:NO];
}

static inline void setGroundTransform(UIView* aView, float teta, float cosb, float sinb, float verticalOffset){
	float cost = cos(teta);
	float sint = sin(teta);
	
	float m11 = cost * MAX_ZOOM * sinb;
	float m21 = -sint * MAX_ZOOM * sinb;
	float m12 = sint * cosb * MAX_ZOOM * sinb;
	float m22 = cost * cosb * MAX_ZOOM * sinb;
	float m42 = (PERSPECTIVE_DEPTH_OFFSET) * sinb + verticalOffset;
	float m13 = sint * sinb * MAX_ZOOM * sinb;
	float m23 = cost * sinb * MAX_ZOOM * sinb;
	float m43 = -(PERSPECTIVE_DEPTH_OFFSET) * cosb;
	float m14 = -sint * sinb * MAX_ZOOM * sinb/ PROJECTION_DEPTH;
	float m24 = -cost * sinb / PROJECTION_DEPTH * MAX_ZOOM * sinb;
	float m34 = -cosb / PROJECTION_DEPTH;
	
	CATransform3D transformMatrix = {
		m11,	m12,		m13,		m14,
		m21,	m22,		m23,		m24,
		0.0,	-sinb,		cosb,		m34,
		0.0,	m42,		m43,		1.0
	};
	
	//aView.layer.transform = CATransform3DIdentity;
	aView.layer.transform = transformMatrix;
};

static inline void setViewTransfrom(UIView *aView, float teta, float cosb, float sinb, float verticalOffset, float distance){
	float sint = sin(teta);
	float m41 = distance * cos(teta);
	float m42 = (PERSPECTIVE_DEPTH_OFFSET) * sinb + distance * cosb * sint + verticalOffset;
	float m34 = 1.0 / -PROJECTION_DEPTH;
	float m43 = - (PERSPECTIVE_DEPTH_OFFSET) * cosb + distance * sinb * sint;
	float m44 = 1 + m34 * m43;
	
	
	CATransform3D transformMatrix = CATransform3DIdentity;
	
	transformMatrix.m11 = m44;
	transformMatrix.m22 = m44;
	transformMatrix.m34 = m34;
	transformMatrix.m41 = m41;
	transformMatrix.m42 = m42;
	transformMatrix.m43 = m43;
	transformMatrix.m44 = m44;
	
	/*{
		m44,	0,		0,		0,
		0,		m44,	0,		0,
		0,		0,		1,		m34,
		m41,	m42,	m43,	m44
	};*/
	
	aView.layer.transform = transformMatrix;
}

-(void)setBubbleTransfromForView:(UIView *)aview{
	if(aview == nil){
		calloutBubble.view.hidden = TRUE;
		//calloutBubble.view.layer.transform = CATransform3DMakeTranslation(200, 0, 0);
		[calloutBubble.view setCenter:CGPointMake(0,-50)];
	}else {
		CGAffineTransform t = CATransform3DGetAffineTransform([[aview layer] transform]);
		[calloutBubble setCenter:CGPointMake(t.tx/t.a, t.ty/t.d)];
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
	[self setMVerticalOffset: sin(beta)*(MIN_SCREEN_WIDTH / 6.0 + abs(((MAX_SCREEN_WIDTH - MIN_SCREEN_WIDTH)/3) * cos(alpha)))];
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
	UIImage *busImage = [UIImage imageNamed:@"augmentedpoi.png"];
	for(VTAnnotation *anAnnotation in newList){
		AugmentedPoi *aPoi = [[AugmentedPoi alloc] initWithAnnotation:anAnnotation fromOrigin:origin];
		[ar_poiList addObject:aPoi];

		[aPoi release];
		[self addPoiView:busImage];

		if([[anAnnotation title] isEqual:selectedAnnotationTitle]){
			[self setSelectedPoi:i];
		}
		i++;
	}
	[self updatePOILocations];
	}
}

-(void)addPoiView:(UIImage *)image{
	CGPoint center = {OFFSCREEN_SQUARE_SIZE/2.0, OFFSCREEN_SQUARE_SIZE/2.0 - 1.5 * POI_BUTTON_SIZE/2};
	
	UIButton *aButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	//aButton.exclusiveTouch = NO;
	aButton.clearsContextBeforeDrawing = NO;
	aButton.frame = CGRectMake(0.0, 0.0, POI_BUTTON_SIZE, POI_BUTTON_SIZE);
	aButton.backgroundColor = [UIColor clearColor];
	[aButton setBackgroundImage:image forState:UIControlStateNormal];
	[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDown];
	//[aButton addTarget:self action:@selector(poiSelected:) forControlEvents:UIControlEventTouchDragInside];
	
	aButton.center = center;
	
	UIImageView *needleAndShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needleandshadow.png"]];
	[needleAndShadow setFrame:CGRectMake(0, 0, POI_BUTTON_SIZE*2.3, POI_BUTTON_SIZE*1.5)];
	[aButton addSubview:needleAndShadow];
	[aButton sendSubviewToBack:needleAndShadow];
	[needleAndShadow release];
	needleAndShadow.tag = SHADOW_TAG;
	
	[poiOverlay addSubview:aButton];
	[ar_poiViews addObject:aButton];
	[aButton release];
	
}

-(IBAction) blankTouch:(id)view{
	[self setBubbleTransfromForView:nil];
	[self setSelectedPoi:-1];
}

-(void) poiSelected:(id) poiViewId{
	[self setSelectedPoi:[ar_poiViews indexOfObject:poiViewId]];
	[self setBubbleTransfromForView:poiViewId];
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
	[groundView setCenterCoordinate:location.coordinate];
	[self updatePOILocations];
	}
}

-(void)setOrientation:(UIInterfaceOrientation)orientation{
}

-(BOOL)canBecomeFirstResponder {
    return NO;
}

- (void)viewDidUnload {
	/*
	[calloutBubble release];
	[ar_poiList release];
	for(UIView *aView in ar_poiViews){
		[aView removeFromSuperview];
	}
	[ar_poiViews release];
	*/
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
