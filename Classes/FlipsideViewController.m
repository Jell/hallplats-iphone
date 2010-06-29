//
//  FlipsideViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "VTTableViewCell.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize annotationDisplayed;
@synthesize tmpCell;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:48.0/255.0 blue:80.0/255.0 alpha:1.0];
	if(annotationDisplayed){
		[flipsideTitle setTitle:[NSString stringWithFormat:@"%@", [annotationDisplayed title]]];
	}else{
		[flipsideTitle setTitle:@" "];
	}
	
	[footerText setTitle:NSLocalizedString(@"Flipside Footer", @"©2010 ICE House AB") forState:UIControlStateNormal];
	[mTableView setDelegate:self];
	[mTableView setDataSource:self];
	[mTableView reloadData];

	//[mTableView setBackgroundColor:[UIColor colorWithRed:62.0/255.0 green:166.0/255.0 blue:247.0/255.0 alpha:1.0]];
}


- (IBAction)done {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

-(void)setAnnotationDisplayed:(VTAnnotation *)anAnnotation{
	annotationDisplayed = anAnnotation;
	lineList = [[anAnnotation getLineList] retain];
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
	if(lineList){
		return [lineList count];
	}else {
		return 0;
	}

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
	NSMutableArray *indexNames = [[NSMutableArray alloc] init];
	for(VTLineInfo *lineinfo in lineList){
		[indexNames addObject:lineinfo.lineNumber];
	}
	return indexNames;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Line", @"Line"), [(VTLineInfo *)[lineList objectAtIndex:section] lineNumber]];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(annotationDisplayed){
		
		int i = 0;
		NSString *sectionName = [(VTLineInfo *)[lineList objectAtIndex:section] lineNumber];
		
		for(VTForecast *forecast in annotationDisplayed.forecastList){
			if([forecast.lineNumber isEqual: sectionName]){
				i++;
			}
		}

		return i;
	}else{
		return 0;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
		
	VTTableViewCell *cell = (VTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"VTTableViewCell" owner:self options:nil];
		cell = (VTTableViewCell *)tmpCell;
        self.tmpCell = nil;
		//[[[VTTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}

	// Set up the cell...
	int i = 0;
	NSString *sectionName = [(VTLineInfo *)[lineList objectAtIndex:indexPath.section] lineNumber];
	VTForecast *forecast = nil;
	
	for(VTForecast *forecastTmp in annotationDisplayed.forecastList){
		if([forecastTmp.lineNumber isEqual:sectionName]){
			if(i == indexPath.row){
				forecast = forecastTmp;
				break;
			}
			i++;
		}
	}
	
	

	[cell setForecast:forecast];
	
	return cell;
}

- (IBAction)linkToIceHouse{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.icehouse.se/"]];
}

- (void)dealloc {
	[tmpCell release];
	[flipsideTitle release];
	[mTableView release];
	[footerText release];
	[lineList release];
    [super dealloc];
}


@end
