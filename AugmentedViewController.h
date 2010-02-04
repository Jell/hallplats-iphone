//
//  AugmentedViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARViewProtocol.h"

@interface AugmentedViewController : UIViewController <ARViewDelegate>{
	CLLocation *currentLocation;
	NSArray *annotationList;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSArray *annotationList;

@end
