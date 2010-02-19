//
//  FlipsideViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"


@implementation FlipsideViewController

@synthesize delegate;
@synthesize annotationDisplayed;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];  
	NSString *text = [annotationDisplayed title];
	if(annotationDisplayed){
		titleLabel.text = [NSString stringWithFormat:@"%@", text];
	}else{
		titleLabel.text = @"";
	}
	[mTableView setDelegate:self];
	[mTableView setDataSource:self];
	[mTableView reloadData];
}


- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

-(void)setAnnotationDisplayed:(VTAnnotation *)anAnnotation{
	annotationDisplayed = anAnnotation;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(annotationDisplayed){
		return [annotationDisplayed.forecastList count];
	}else{
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
		
	// Set up the cell...
	VTForecast *forecast = [annotationDisplayed.forecastList objectAtIndex:indexPath.row];
	[[cell textLabel] setFont:[UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)]];
	//[[cell textLabel] setTextColor:forecast.foregroundColor];
	//[[cell textLabel] setBackgroundColor:forecast.backgroundColor];
	[[cell textLabel] setNumberOfLines:3];
	[[cell textLabel] setText:[NSString stringWithFormat:@"Line: %@\nDestination: %@\n       Nästa: %@min      Därefter: %@min",
							   forecast.lineNumber, forecast.destination, forecast.nastaTime, forecast.darefterTime]];
		
	return cell;
}

- (void)dealloc {
    [super dealloc];
}


@end
