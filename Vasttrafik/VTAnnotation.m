//
//  VTAnnotation.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTAnnotation.h"


@implementation VTAnnotation
@synthesize coordinate;
@synthesize friendly_name, stop_name, county, order, distance, stop_id, stop_id_with_hash_key,shortcut,stop_type, forecastList;

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

-(NSArray *)getLineList{
	NSMutableArray *lineNumbers = [[NSMutableArray alloc] init];
	NSMutableArray *lineList = [[NSMutableArray alloc] init];
	for(VTForecast *forecast in forecastList){
		NSString *lineNumber = forecast.lineNumber;
		if(![lineNumbers containsObject:lineNumber]){
			[lineNumbers addObject:lineNumber];
			VTLineInfo *info = [[VTLineInfo alloc] init];
			info.lineNumber = lineNumber;
			info.backgroundColor = forecast.backgroundColor;
			info.foregroundColor = forecast.foregroundColor;
			info.imageType = forecast.imageType;
			[lineList addObject:info];
		}
	}
	
	NSArray *result = [[NSArray alloc] initWithArray:lineList];
	[lineList release];
	[lineNumbers release];
	return result;
}

-(void)dealloc{
	[friendly_name release];
	[stop_name release];
	[county release];
	[stop_id release];
	[stop_id_with_hash_key release];
	[shortcut release];
	[stop_type release];
	
	[forecastList release];
	
	[super dealloc];
}
@end
