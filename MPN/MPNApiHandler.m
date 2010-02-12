//
//  MPNApiHandler.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNApiHandler.h"


@implementation MPNApiHandler

-(NSArray *)getAnnotationsFromCoordinates:(CLLocationCoordinate2D) upperLeft toCoordinates:(CLLocationCoordinate2D) lowerRight{
	NSArray *poiList = [self getPoiFromCoordinates:upperLeft toCoordinates:lowerRight];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:poiList.count];
	[result retain];
	CLLocationCoordinate2D location = {0.0, 0.0};
	
	location.latitude = 57.7119;
	location.longitude = 11.9683;
	
	for(int i=0;i<poiList.count;i++){
		// get the bundle of one poi
		NSDictionary *bundle = (NSDictionary *)[poiList objectAtIndex:i];
		
		// get info qbout the site
		NSDictionary *site = (NSDictionary *)[bundle valueForKey:@"site"];
	
		// get coordinqtes
		location.latitude = [(NSString *)[site valueForKey:@"latitude"] floatValue];
		location.longitude = [(NSString *)[site valueForKey:@"longitude"] floatValue];
		
		/*
		 float radius = (float) 6.28 / (float) poiList.count;
		location.latitude = 57.7119 + 0.025 * cos(radius * i);
		location.longitude = 11.9683 + 0.05 * sin(radius * i);
		*/
		
		//create an annotation object
		MPNAnnotation *annotation = [[MPNAnnotation alloc] initWithCoordinate:location];
		[annotation retain];
		
		NSString *title = (NSString *)[site valueForKey:@"title"];
		[title retain];
		NSString *subtitle = (NSString *)[site valueForKey:@"city"];
		[subtitle retain];
		// set the title and city of the annotation
		[annotation setTitle:title
					subtitle:subtitle];
		
		[result addObject:annotation];
	}
	
	// return converted C array into NSArray
	return result;
}


- (id)getPoiFromCoordinates:(CLLocationCoordinate2D) upperLeft
					toCoordinates:(CLLocationCoordinate2D) lowerRight
{
	return [self objectWithUrl:[NSURL URLWithString:
								[NSString stringWithFormat:
									@"http://42934.se/foretag.json?bounds=%.2f%%2B%.2f%%2B%.2f%%2B%.2f",
									upperLeft.latitude,
									upperLeft.longitude,
									lowerRight.latitude,
									lowerRight.longitude]]];
}

- (NSString *)stringWithUrl:(NSURL *)url
{
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest
									returningResponse:&response
												error:&error];
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (id) objectWithUrl:(NSURL *)url
{
	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [self stringWithUrl:url];
	id object = [jsonParser objectWithString:jsonString error:NULL];
	[jsonParser release];
	[jsonString release];
	// Parse the JSON into an Object
	return object;
}

@end
