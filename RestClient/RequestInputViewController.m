//
//  RequestInputViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/16/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestInputViewController.h"

#import "UIViewController+Layout.h"
#import <UIView+AutoLayout.h>

#import "RCInputObject.h"
#import "RequestInputCell.h"

@interface RequestInputViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (assign, nonatomic) CGFloat tableOrigin;

@end

@implementation RequestInputViewController

- (id)init
{
    return [self initWithType:RequestInputTypeHeaders dataSource:@[]];
}

- (id)initWithType:(RequestInputType)inputType dataSource:(NSArray *)dataSource
{
    self = [super initWithNibName:@"RequestInputViewController" bundle:nil];
    if (self) {
        _inputType = inputType;
        if (IsEmpty(dataSource)) {
            dataSource = @[];
        }
        _dataSource = [dataSource mutableCopy];

        if (inputType == RequestInputTypeHeaders) {
            self.title = @"Headers";
        } else {
            self.title = @"Parameters";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.inputType == RequestInputTypeHeaders) {
        self.navigationItem.prompt = @"Enter Request Headers";
    } else {
        self.navigationItem.prompt = @"Enter Request Parameters";
    }

    self.navigationItem.leftBarButtonItem = [self editButtonItem];

    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(dismissAction:)];

    self.navigationItem.rightBarButtonItem = self.doneButton;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableOrigin = self.topOrigin;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - Public Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];

    if (editing) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }

    [self.tableView reloadData];
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    [self.delegate requestInputViewController:self didFinishWithInputType:self.inputType objects:self.dataSource];
}

- (void)keyboardDidChangeFrame:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbIntersectFrame = [window convertRect:CGRectIntersection(window.frame, kbFrame) toView:self.tableView];

    // get point before contentInset change
    CGPoint pointBefore = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableOrigin, 0.0, kbIntersectFrame.size.height, 0.0);

    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;

    // get point after contentInset change
    CGPoint pointAfter = self.tableView.contentOffset;

    // avoid jump by settings contentOffset
    self.tableView.contentOffset = pointBefore;

    // and now animate smoothly
    [self.tableView setContentOffset:pointAfter animated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (self.isEditing) {
        sections = 1;
    } else {
        sections = 2;
    }

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.isEditing) {
        rows = [self.dataSource count];
    } else {
        if (section == 0) {
            rows = [self.dataSource count];
        } else {
            rows = 1;
        }
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddIdentifier = @"AddCell";
    static NSString *CellIdentifier = @"Cell";

    if (!self.isEditing && indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddIdentifier];
        }

        if (self.inputType == RequestInputTypeHeaders) {
            cell.textLabel.text = @"Add Header";
        } else {
            cell.textLabel.text = @"Add Parameter";
        }

        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    }

    RequestInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RequestInputCell alloc] initWithReuseIdentifier:CellIdentifier];

        if (self.inputType == RequestInputTypeHeaders) {
            cell.nameTextField.placeholder = @"Header Name";
            cell.valueTextField.placeholder = @"Header Value";
        } else {
            cell.nameTextField.placeholder = @"Parameter Name";
            cell.valueTextField.placeholder = @"Parameter Value";
        }
    }
    
    cell.inputObject = self.dataSource[indexPath.row];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    RCInputObject *inputObject = self.dataSource[fromIndexPath.row];
    [self.dataSource removeObjectAtIndex:fromIndexPath.row];
    [self.dataSource insertObject:inputObject atIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.isEditing) {
        return;
    }

    if (indexPath.section == 0) {
        return;
    }

    RCInputObject *inputObject = [[RCInputObject alloc] init];

    if (self.dataSource == nil) {
        self.dataSource = [@[] mutableCopy];
    }

    [self.dataSource addObject:inputObject];
    [self.tableView reloadData];
}

@end
