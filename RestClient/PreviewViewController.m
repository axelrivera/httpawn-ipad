//
//  PreviewViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/22/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (id)init
{
    self = [super initWithNibName:@"PreviewViewController" bundle:nil];
    if (self) {
        self.title = @"Preview";
    }
    return self;
}

- (id)initWithRequest:(RCRequest *)request
{
    self = [self init];
    if (self) {
        _request = request;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismissAction:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 1;
    } else if (section == 1) {
        rows = [self.request.headers count];
    } else {
        rows = [self.request.parameters count];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *URLIdentifier = @"URLCell";
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:URLIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:URLIdentifier];
            cell.textLabel.numberOfLines = 3;
            cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        }
        
        cell.textLabel.text = self.request.URLString;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    RCRequestOption *option = nil;
    
    if (indexPath.section == 1) {
        option = self.request.headers[indexPath.row];
    } else {
        option = self.request.parameters[indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = option.objectName;
    cell.detailTextLabel.text = option.objectValue;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"URL String";
    } else if (section == 1 && [self.request.headers count] > 0) {
        title = @"Headers";
    } else if (section == 2 && [self.request.parameters count] > 0) {
        title = @"Parameters";
    }
    return title;
}

@end
