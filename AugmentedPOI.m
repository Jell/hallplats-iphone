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
	self.teta = atan2(anAnnotation.coordinate.latitude - origin.latitude ,
					  anAnnotation.coordinate.longitude - origin.longitude);
	return self;
}

-(void)updateAngleFrom:(CLLocationCoordinate2D)origin
{
	self.teta = atan2(self.annotation.coordinate.latitude - origin.latitude ,
					  self.annotation.coordinate.longitude - origin.longitude);
}

- (void)dealloc {
	[annotation release];
    [super dealloc];
}

@end
