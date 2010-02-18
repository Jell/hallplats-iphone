//
//  VTForecast.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTForecast.h"


@implementation VTForecast

@synthesize lineNumber, foregroundColor, backgroundColor, imageType, destination, nastaTime, nastaHandicap, darefterTime, darefterHandicap;

-(void)dealloc{
	[lineNumber release];
	[foregroundColor release];
	[backgroundColor release];
	[imageType release];
	[destination release];
	[nastaTime release];
	[darefterTime release];
	[super dealloc];
}
@end
