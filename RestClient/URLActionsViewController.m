//
//  URLActionsViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/16/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "URLActionsViewController.h"

@interface URLActionsViewController ()

@end

@implementation URLActionsViewController

- (instancetype)initWithCurrentAction:(NSString *)currentAction
{
    self = [super initWithNibName:@"URLActionsViewController" bundle:nil];
    if (self) {
        _currentURLAction = currentAction;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"URL Actions";

    self.dataSource = [NSArray availableHTTPActions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *textStr = self.dataSource[indexPath.row];

    cell.textLabel.text = textStr;

    if ([textStr isEqualToString:self.currentURLAction]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger currentIndex = [self.dataSource indexOfObject:self.currentURLAction];
    if (currentIndex != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:indexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    [self.delegate URLActionsController:self didSelectAction:self.dataSource[indexPath.row]];
}

@end
