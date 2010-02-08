//
//  AugmentedPOI.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedPOI.h"


@implementation AugmentedPOI
@synthesize teta;
@synthesize annotation;

-(id)initWithAnnotation:(MPNAnnotation *) anAnnotation fromOrigin:(CLLocationCoordinate2D)origin
{
	self.annotation = anAnnotation;
	self.teta = atan2((origin.latitude - anAnnotation.coordinate.latitude) * (110.574 + 0.562 * abs(origin.latitude / 90)),
					  (origin.longitude - anAnnotation.coordinate.longitude) * 111.320 * cos(origin.latitude * 3.14 / 180));
	return self;
}

-(void)updateAngleFrom:(CLLocationCoordinate2D)origin
{
	self.teta = atan2((origin.latitude - annotation.coordinate.latitude)* (110.574 + 0.562 * abs(origin.latitude / 90)),
					  (origin.longitude - annotation.coordinate.longitude) * 111.320 * cos(origin.latitude * 3.14 / 180));
}

- (void)dealloc {
	[annotation release];
    [super dealloc];
}

@end
