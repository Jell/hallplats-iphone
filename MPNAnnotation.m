//
//  MPNAnnotation.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNAnnotation.h"

@implementation MPNAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
	return [NSString stringWithFormat:@"%@", mSubTitle];
}

- (NSString *)title{
	return [NSString stringWithFormat:@"%@", mTitle];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle{
	mTitle = title;
	mSubTitle = subtitle;
}

@end
