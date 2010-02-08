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
#import "AugmentedPOI.h"

@interface AugmentedViewController : UIViewController <ARViewDelegate>{
	NSMutableArray *ar_poiList;
	NSMutableArray *ar_poiViews;
	CLLocation *currentLocation;
	float angleXY;
}

@property (retain) NSMutableArray *ar_poiList;
@property (retain) NSMutableArray *ar_poiViews;
@property (assign)  CLLocation *currentLocation;

-(void)translateView:(UIView *)aView withTeta:(float)teta;

@end
