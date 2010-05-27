/**
 Controls the display of an AugmentedView.
 */

//
//  AugmentedViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "ARViewProtocol.h"
#import "AugmentedPoi.h"
#import "AugmentedCalloutBubbleController.h"
#import "VTAnnotation.h"

@interface AugmentedViewController : UIViewController <ARViewDelegate, MKMapViewDelegate>{
	IBOutlet UIView *poiOverlay;					/**< View container for Poi display */
	IBOutlet MKMapView *gridView;						/**< Perspective Grid View */
	IBOutlet UIButton *backgroundButton;
	IBOutlet UIImageView *mapMask;
	AugmentedCalloutBubbleController *calloutBubble;	/**< Poi call out bubble controller */
	int selectedPoi;								/**< Currently selected POI, -1 if none is selected */
	NSMutableArray *ar_poiList;						/**< List containing the POI */
	NSMutableArray *ar_poiViews;					/**< List containing the POI views */
	CLLocation *currentLocation;					/**< Current location of the user */
	float mAlpha;
	float mBeta;/**< Angle at which the iPhone is held on the XY plane*/
	float mTeta;
	float mVerticalOffset;
	id delegate;
}

@property float mAlpha;
@property float mBeta;
@property float mTeta;
@property float mVerticalOffset;
@property(retain) NSMutableArray *ar_poiList;
@property(retain) NSMutableArray *ar_poiViews;
@property(assign)  CLLocation *currentLocation;
@property(assign) id delegate;
-(void)updatePoisLocations;
-(void)updateProjection:(NSTimer *)theTimer;

/* Moves the perspective grid according to the given orientation
 @param teta current azimuth of the user from -pi to pi 
 @param beta current pitch of the user from -pi to pi */
void translateGridWithTeta(UIView* aView, float teta, float cosb, float sinb, float verticalOffset);

/* Position the given view according to its azimuth and distance to current location
 @param aView the view to position
 @param teta azimuth of the POI represented by the view, valued from -pi to pi
 @param beta current pitch of the user from -pi to pi
 @param distance distance of the POI represented by the view, must be greater than 0
 @param scaleEnabled If set to YES, the view is scaled to perspective*/
void translateView(UIView *aView, float teta, float cosb, float sinb, float verticalOffset, float distance);

-(void)setBubbleMatrixForView:(UIView *)aview;

-(IBAction) blankTouch:(id)view;

/** Performed when a POI is selected */
-(void) poiSelected:(id) poiViewId;

/** Add a POI view to the Poi overlay */
-(void)addPoiView;

@end
