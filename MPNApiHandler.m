//
//  MPNApiHandler.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNApiHandler.h"


@implementation MPNApiHandler

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
	[jsonString release];
	// Parse the JSON into an Object
	return object;
}

@end
