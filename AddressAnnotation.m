//
//  AddressAnnotation.m
//  Map View
//
//  Created by Jean-Louis on 2010-01-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


@implementation AddressAnnotation

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
